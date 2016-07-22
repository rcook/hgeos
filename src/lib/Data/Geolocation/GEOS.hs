{-|
Module      : Data.Geolocation.GEOS
Description : High-level API for interoperating with GEOS C API
Copyright   : (C) Richard Cook, 2016
Licence     : MIT
Maintainer  : rcook@rcook.org
Stability   : experimental
Portability : POSIX

A high-level API for interoperating with GEOS C API which includes automatic
management of lifetimes of objects such as readers, writers and geometries.

For the low-level FFI bindings, see "Data.Geolocation.GEOS.Imports".
-}

{-# LANGUAGE RecordWildCards #-}

module Data.Geolocation.GEOS
    ( Context ()
    , CoordinateSequence ()
    , Geometry ()
    , Reader ()
    , Writer ()
    , coordinateSequence
    , envelope
    , exteriorRing
    , intersection
    , mkReader
    , mkWriter
    , readGeometry
    , withContext
    , writeGeometry
    ) where

import Control.Exception
import Data.Geolocation.GEOS.Imports
import Data.IORef
import Foreign.C

-- |Represents a <https://trac.osgeo.org/geos/ GEOS> context
data Context = Context ContextStateRef

data ContextState = ContextState
    { hCtx :: GEOSContextHandle_t
    , hReaders :: [GEOSWKTReaderPtr]
    , hWriters :: [GEOSWKTWriterPtr]
    , hGeometries :: [GEOSGeometryPtr]
    , hCoordinateSequences :: [GEOSCoordSequencePtr]
    }

type ContextStateRef = IORef ContextState

-- |References a <https://trac.osgeo.org/geos/ GEOS> coordinate sequence
data CoordinateSequence = CoordinateSequence ContextStateRef GEOSCoordSequencePtr

-- |References a <https://en.wikipedia.org/wiki/Well-known_text WKT> reader
data Reader = Reader ContextStateRef GEOSWKTReaderPtr

-- |References a <https://en.wikipedia.org/wiki/Well-known_text WKT> writer
data Writer = Writer ContextStateRef GEOSWKTWriterPtr

-- |References a <https://trac.osgeo.org/geos/ GEOS> geometry
data Geometry = Geometry ContextStateRef GEOSGeometryPtr

-- |Returns a 'CoordinateSequence' from the supplied 'Geometry'
coordinateSequence :: Geometry -> IO CoordinateSequence
coordinateSequence (Geometry sr hGeometry) = do
    ContextState{..} <- readIORef sr
    h <- c_GEOSGeom_getCoordSeq_r hCtx hGeometry
    -- Do not track
    --modifyIORef' sr (\p@ContextState{..} -> p { hCoordinateSequences = h : hCoordinateSequences })
    return $ CoordinateSequence sr h

doNotTrack :: ContextStateRef -> (GEOSContextHandle_t -> IO GEOSGeometryPtr) -> IO Geometry
doNotTrack sr f = do
    ContextState{..} <- readIORef sr
    h <- f hCtx
    return $ Geometry sr h

-- |Returns a 'Geometry' instance representing the envelope of the supplied
-- 'Geometry'
envelope :: Geometry -> IO Geometry
envelope (Geometry sr h) =
    track sr (\hCtx -> c_GEOSEnvelope_r hCtx h)

-- |Returns a 'Geometry' instance representing the exterior ring of the
-- supplied 'Geometry'
exteriorRing :: Geometry -> IO Geometry
exteriorRing (Geometry sr h) =
    doNotTrack sr (\hCtx -> c_GEOSGetExteriorRing_r hCtx h)

-- |Returns a 'Geometry' instance representing the intersection of the two
-- supplied 'Geometry' instances:
intersection :: Geometry -> Geometry -> IO Geometry
intersection (Geometry sr0 h0) (Geometry sr1 h1) =
    track sr0 (\hCtx -> c_GEOSIntersection_r hCtx h0 h1)

mkContext :: IO Context
mkContext = do
    hCtx <- c_initializeGEOSWithHandlers
    sr <- newIORef $ ContextState hCtx [] [] [] []
    return $ Context sr

-- |Creates a reader used to deserialize 'Geometry' instances from
-- <https://en.wikipedia.org/wiki/Well-known_text WKT>-format text:
mkReader :: Context -> IO Reader
mkReader (Context sr) = do
    ContextState{..} <- readIORef sr
    h <- c_GEOSWKTReader_create_r hCtx
    modifyIORef' sr (\p@ContextState{..} -> p { hReaders = h : hReaders })
    return $ Reader sr h

-- |Creates a writer used to serialize 'Geometry' instances to
-- <https://en.wikipedia.org/wiki/Well-known_text WKT>-format text:
mkWriter :: Context -> IO Writer
mkWriter (Context sr) = do
    ContextState{..} <- readIORef sr
    h <- c_GEOSWKTWriter_create_r hCtx
    modifyIORef' sr (\p@ContextState{..} -> p { hWriters = h : hWriters })
    return $ Writer sr h

-- |Deserializes a 'Geometry' instance from the given 'String' using the
-- supplied 'Reader':
readGeometry :: Reader -> String -> IO Geometry
readGeometry (Reader sr h) str = withCString str $ \cs -> do
    track sr (\hCtx -> c_GEOSWKTReader_read_r hCtx h cs)

releaseContext :: Context -> IO ()
releaseContext (Context sr) = do
    ContextState{..} <- readIORef sr
    mapM_ (c_GEOSCoordSeq_destroy_r hCtx) hCoordinateSequences
    mapM_ (c_GEOSGeom_destroy_r hCtx) hGeometries
    mapM_ (c_GEOSWKTWriter_destroy_r hCtx) hWriters
    mapM_ (c_GEOSWKTReader_destroy_r hCtx) hReaders
    c_uninitializeGEOS hCtx

track :: ContextStateRef -> (GEOSContextHandle_t -> IO GEOSGeometryPtr) -> IO Geometry
track sr f = do
    ContextState{..} <- readIORef sr
    h <- f hCtx
    modifyIORef' sr $ (\p@ContextState{..} -> p { hGeometries = h : hGeometries })
    return $ Geometry sr h

-- |Creates a <https://trac.osgeo.org/geos/ GEOS> context, passes it to a block
-- and releases the context and all associated objects such as readers, writers
-- and geometries at the end:
--
-- @
--    withContext $ \ctx -> do
--
--        -- Use context
--
--        return ()
-- @
withContext :: (Context -> IO a) -> IO a
withContext = bracket mkContext releaseContext

-- |Serializes a 'Geometry' instance to a 'String' using the supplied 'Writer':
writeGeometry :: Writer -> Geometry -> IO String
writeGeometry (Writer sr hWriter) (Geometry _ hGeometry) = do
    ContextState{..} <- readIORef sr
    str <- bracket
        (c_GEOSWKTWriter_write_r hCtx hWriter hGeometry)
        (c_GEOSFree_r_CString hCtx)
        peekCString
    return str
