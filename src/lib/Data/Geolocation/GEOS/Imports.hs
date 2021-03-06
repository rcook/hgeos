{-|
Module      : Data.Geolocation.GEOS.Imports
Description : FFI bindings for GEOS C API
Copyright   : (C) Richard Cook, 2016
Licence     : MIT
Maintainer  : rcook@rcook.org
Stability   : experimental
Portability : portable

These are low-level FFI bindings for the Geometry Engine Open Source C API
derived from <http://geos.osgeo.org/doxygen/geos__c_8h_source.html geos_c.h>.
These enable low-level access to the native functions for parts of the C API
for which high-level wrappers do not yet exist.

For the high-level API, see "Data.Geolocation.GEOS".

For the monad transformer wrappers, see "Data.Geolocation.GEOS.Trans".

<https://github.com/rcook/hgeos/blob/master/src/test/GEOSTest/LowLevelAPI.hs View sample>
-}

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Data.Geolocation.GEOS.Imports
    ( GEOSContextHandle ()
    , GEOSCoordSequencePtr ()
    , GEOSGeometryPtr ()
    , GEOSWKTReaderPtr ()
    , GEOSWKTWriterPtr ()
    , NullablePtr (isNullPtr, rawIntPtr)
    , c_GEOSArea_r
    , c_GEOSCoordSeq_create_r
    , c_GEOSCoordSeq_destroy_r
    , c_GEOSCoordSeq_getOrdinate_r
    , c_GEOSCoordSeq_getSize_r
    , c_GEOSCoordSeq_getX_r
    , c_GEOSCoordSeq_getY_r
    , c_GEOSCoordSeq_getZ_r
    , c_GEOSCoordSeq_setOrdinate_r
    , c_GEOSCoordSeq_setX_r
    , c_GEOSCoordSeq_setY_r
    , c_GEOSCoordSeq_setZ_r
    , c_GEOSEnvelope_r
    , c_GEOSFree_r_CString
    , c_GEOSGeomTypeId_r
    , c_GEOSGeom_createCollection_r
    , c_GEOSGeom_createEmptyPolygon_r
    , c_GEOSGeom_createLinearRing_r
    , c_GEOSGeom_createPolygon_r
    , c_GEOSGeom_destroy_r
    , c_GEOSGeom_getCoordSeq_r
    , c_GEOSGetExteriorRing_r
    , c_GEOSGetGeometryN_r
    , c_GEOSGetNumGeometries_r
    , c_GEOSIntersection_r
    , c_GEOSWKTReader_create_r
    , c_GEOSWKTReader_destroy_r
    , c_GEOSWKTReader_read_r
    , c_GEOSWKTWriter_create_r
    , c_GEOSWKTWriter_destroy_r
    , c_GEOSWKTWriter_write_r
    , c_GEOSisEmpty_r
    , c_GEOSversion
    , c_finishGEOS_r
    , c_getErrorMessage
    , c_initializeGEOSWithHandlers
    ) where

import Foreign.C
import Foreign.Ptr
import Foreign.Storable

-- |Determines if given pointer is null
class NullablePtr a where
    -- |Evaluates to @True@ if pointer is null, @False@ otherwise
    isNullPtr :: a -> Bool
    rawIntPtr :: a -> IntPtr

-- |Wraps @GEOSContextHandle@
newtype GEOSContextHandle = GEOSContextHandle (Ptr GEOSContextHandle)

-- |Wraps @GEOSCoordSequence*@
newtype GEOSCoordSequencePtr = GEOSCoordSequencePtr (Ptr GEOSCoordSequencePtr)
instance NullablePtr GEOSCoordSequencePtr where
    isNullPtr (GEOSCoordSequencePtr p) = p == nullPtr
    rawIntPtr (GEOSCoordSequencePtr p) = ptrToIntPtr p

-- |Wraps @GEOSGeometry*@
newtype GEOSGeometryPtr = GEOSGeometryPtr (Ptr GEOSGeometryPtr) deriving Storable
instance NullablePtr GEOSGeometryPtr where
    isNullPtr (GEOSGeometryPtr p) = p == nullPtr
    rawIntPtr (GEOSGeometryPtr p) = ptrToIntPtr p

-- |Wraps @GEOSWKTReader*@
newtype GEOSWKTReaderPtr = GEOSWKTReaderPtr (Ptr GEOSWKTReaderPtr)
instance NullablePtr GEOSWKTReaderPtr where
    isNullPtr (GEOSWKTReaderPtr p) = p == nullPtr
    rawIntPtr (GEOSWKTReaderPtr p) = ptrToIntPtr p

-- |Wraps @GEOSWKTWriter*@
newtype GEOSWKTWriterPtr = GEOSWKTWriterPtr (Ptr GEOSWKTWriterPtr)
instance NullablePtr GEOSWKTWriterPtr where
    isNullPtr (GEOSWKTWriterPtr p) = p == nullPtr
    rawIntPtr (GEOSWKTWriterPtr p) = ptrToIntPtr p

-- |Wraps @GEOSArea_r@
foreign import ccall "GEOSArea_r"
    c_GEOSArea_r :: GEOSContextHandle -> GEOSGeometryPtr -> Ptr CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_create_r@
foreign import ccall "GEOSCoordSeq_create_r"
    c_GEOSCoordSeq_create_r :: GEOSContextHandle -> CUInt -> CUInt -> IO GEOSCoordSequencePtr

-- |Wraps @GEOSCoordSeq_destroy_r@
foreign import ccall "GEOSCoordSeq_destroy_r"
    c_GEOSCoordSeq_destroy_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> IO ()

-- |Wraps @GEOSCoordSeq_getOrdinate_r@
foreign import ccall "GEOSCoordSeq_getOrdinate_r"
    c_GEOSCoordSeq_getOrdinate_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> CUInt -> Ptr CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_getSize_r@
foreign import ccall "GEOSCoordSeq_getSize_r"
    c_GEOSCoordSeq_getSize_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> Ptr CUInt -> IO CInt

-- |Wraps @GEOSCoordSeq_getX_r@
foreign import ccall "GEOSCoordSeq_getX_r"
    c_GEOSCoordSeq_getX_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> Ptr CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_getY_r@
foreign import ccall "GEOSCoordSeq_getY_r"
    c_GEOSCoordSeq_getY_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> Ptr CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_getZ_r@
foreign import ccall "GEOSCoordSeq_getZ_r"
    c_GEOSCoordSeq_getZ_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> Ptr CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_setOrdinate_r@
foreign import ccall "GEOSCoordSeq_setOrdinate_r"
    c_GEOSCoordSeq_setOrdinate_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> CUInt -> CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_setX_r@
foreign import ccall "GEOSCoordSeq_setX_r"
    c_GEOSCoordSeq_setX_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_setY_r@
foreign import ccall "GEOSCoordSeq_setY_r"
    c_GEOSCoordSeq_setY_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> CDouble -> IO CInt

-- |Wraps @GEOSCoordSeq_setZ_r@
foreign import ccall "GEOSCoordSeq_setZ_r"
    c_GEOSCoordSeq_setZ_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> CUInt -> CDouble -> IO CInt

-- |Wraps @GEOSEnvelope_r@
foreign import ccall "GEOSEnvelope_r"
    c_GEOSEnvelope_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO GEOSGeometryPtr

-- |Wraps @GEOSFree_r@ specialized to @const char*@
foreign import ccall "GEOSFree_r"
    c_GEOSFree_r_CString :: GEOSContextHandle -> CString -> IO ()

-- |Wraps @GEOSGeomTypeId_r@
foreign import ccall "GEOSGeomTypeId_r"
    c_GEOSGeomTypeId_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO CInt

-- |Wraps @GEOSGeom_createCollection_r@
foreign import ccall "GEOSGeom_createCollection_r"
    c_GEOSGeom_createCollection_r :: GEOSContextHandle -> CInt -> Ptr GEOSGeometryPtr -> CUInt -> IO GEOSGeometryPtr

-- |Wraps @GEOSGeom_createEmptyPolygon_r@
foreign import ccall "GEOSGeom_createEmptyPolygon_r"
    c_GEOSGeom_createEmptyPolygon_r :: GEOSContextHandle -> IO GEOSGeometryPtr

-- |Wraps @GEOSGeom_createLinearRing_r@
foreign import ccall "GEOSGeom_createLinearRing_r"
    c_GEOSGeom_createLinearRing_r :: GEOSContextHandle -> GEOSCoordSequencePtr -> IO GEOSGeometryPtr

-- |Wraps @GEOSGeom_createPolygon_r@
foreign import ccall "GEOSGeom_createPolygon_r"
    c_GEOSGeom_createPolygon_r :: GEOSContextHandle -> GEOSGeometryPtr -> Ptr GEOSGeometryPtr -> CUInt -> IO GEOSGeometryPtr

-- |Wraps @GEOSGeom_destroy_r@
foreign import ccall "GEOSGeom_destroy_r"
    c_GEOSGeom_destroy_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO ()

-- |Wraps @GEOSGeom_getCoordSeq_r@
foreign import ccall "GEOSGeom_getCoordSeq_r"
    c_GEOSGeom_getCoordSeq_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO GEOSCoordSequencePtr

-- |Wraps @GEOSGetExteriorRing_r@
foreign import ccall "GEOSGetExteriorRing_r"
    c_GEOSGetExteriorRing_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO GEOSGeometryPtr

-- |Wraps @GEOSGetGeometryN_r@
foreign import ccall "GEOSGetGeometryN_r"
    c_GEOSGetGeometryN_r :: GEOSContextHandle -> GEOSGeometryPtr -> CInt -> IO GEOSGeometryPtr

-- |Wraps @GEOSGetNumGeometries_r@
foreign import ccall "GEOSGetNumGeometries_r"
    c_GEOSGetNumGeometries_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO CInt

-- |Wraps @GEOSIntersection_r@
foreign import ccall "GEOSIntersection_r"
    c_GEOSIntersection_r :: GEOSContextHandle -> GEOSGeometryPtr -> GEOSGeometryPtr -> IO GEOSGeometryPtr

-- |Wraps @GEOSWKTReader_create_r@
foreign import ccall "GEOSWKTReader_create_r"
    c_GEOSWKTReader_create_r :: GEOSContextHandle -> IO GEOSWKTReaderPtr

-- |Wraps @GEOSWKTReader_destroy_r@
foreign import ccall "GEOSWKTReader_destroy_r"
    c_GEOSWKTReader_destroy_r :: GEOSContextHandle -> GEOSWKTReaderPtr -> IO ()

-- |Wraps @GEOSWKTReader_read_r@
foreign import ccall "GEOSWKTReader_read_r"
    c_GEOSWKTReader_read_r :: GEOSContextHandle -> GEOSWKTReaderPtr -> CString -> IO GEOSGeometryPtr

-- |Wraps @GEOSWKTWriter_create_r@
foreign import ccall "GEOSWKTWriter_create_r"
    c_GEOSWKTWriter_create_r :: GEOSContextHandle -> IO GEOSWKTWriterPtr

-- |Wraps @GEOSWKTWriter_destroy_r@
foreign import ccall "GEOSWKTWriter_destroy_r"
    c_GEOSWKTWriter_destroy_r :: GEOSContextHandle -> GEOSWKTWriterPtr -> IO ()

-- |Wraps @GEOSWKTWriter_write_r@
foreign import ccall "GEOSWKTWriter_write_r"
    c_GEOSWKTWriter_write_r :: GEOSContextHandle -> GEOSWKTWriterPtr -> GEOSGeometryPtr -> IO CString

-- |Wraps @GEOSisEmpty_r@
foreign import ccall "GEOSisEmpty_r"
    c_GEOSisEmpty_r :: GEOSContextHandle -> GEOSGeometryPtr -> IO CChar

-- |Wraps @GEOSversion@
foreign import ccall "GEOSversion"
    c_GEOSversion :: IO CString

-- |Wraps @finishGEOS_r@
foreign import ccall "finishGEOS_r"
    c_finishGEOS_r :: GEOSContextHandle -> IO ()

-- |Wraps @getErrorMessage@ helper function
foreign import ccall "getErrorMessage"
    c_getErrorMessage :: IO CString

-- |Wraps @getNoticeMessage@ helper function
foreign import ccall "getNoticeMessage"
    c_getNoticeMessage :: IO CString

-- |Wraps @initializeGEOSWithHandlers@ helper function
foreign import ccall "initializeGEOSWithHandlers"
    c_initializeGEOSWithHandlers :: IO GEOSContextHandle
