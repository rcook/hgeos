module Main (main) where

import Control.Exception
import Data.Geocoding.GEOS
import Data.Geocoding.GEOS.Imports
import Foreign.C
import Foreign.Ptr

-- Demonstrates direct use of imports
lowLevelAPIDemo :: IO ()
lowLevelAPIDemo = do
    wkt0 <- newCString "POLYGON (( 10 10, 10 20, 20 20, 20 10, 10 10 ))"
    wkt1 <- newCString "POLYGON (( 11 11, 11 12, 12 12, 12 11, 11 11 ))"

    withGEOS $ \ctx -> do
        withWKTReader ctx $ \reader -> do
            g0 <- c_GEOSWKTReader_read_r ctx reader wkt0
            g1 <- c_GEOSWKTReader_read_r ctx reader wkt1
            g2 <- c_GEOSIntersection_r ctx g0 g1
            withWKTWriter ctx $ \writer -> do
                str <- bracket
                    (c_GEOSWKTWriter_write_r ctx writer g2)
                    (c_GEOSFree_r_CChar ctx)
                    peekCString
                print str
                c_GEOSGeom_destroy_r ctx g2 -- TODO: Use bracket
                c_GEOSGeom_destroy_r ctx g1 -- TODO: Use bracket
                c_GEOSGeom_destroy_r ctx g0 -- TODO: Use bracket
                putStrLn "lowLevelAPIDemo done"
    where
        withGEOS :: (GEOSContextHandle_t -> IO a) -> IO a
        withGEOS = bracket c_initializeGEOSWithHandlers c_uninitializeGEOS
        withWKTReader :: GEOSContextHandle_t -> (GEOSWKTReaderPtr -> IO a) -> IO a
        withWKTReader ctx = bracket (c_GEOSWKTReader_create_r ctx) (c_GEOSWKTReader_destroy_r ctx)
        withWKTWriter :: GEOSContextHandle_t -> (GEOSWKTWriterPtr -> IO a) -> IO a
        withWKTWriter ctx = bracket (c_GEOSWKTWriter_create_r ctx) (c_GEOSWKTWriter_destroy_r ctx)

-- Demonstrates use of high-level API
highLevelAPIDemo :: IO ()
highLevelAPIDemo = do
    withContext $ \ctx -> do
        reader <- mkReader ctx
        g0 <- readGeometry reader "POLYGON (( 10 10, 10 20, 20 20, 20 10, 10 10 ))"
        g1 <- readGeometry reader "POLYGON (( 11 11, 11 12, 12 12, 12 11, 11 11 ))"
        g2 <- intersection g0 g1
        writer <- mkWriter ctx
        str <- writeGeometry writer g2
        putStrLn str
        putStrLn "highLevelAPIDemo done"

main :: IO ()
main = do
    s <- peekCString c_GEOSversion
    putStrLn s
    lowLevelAPIDemo
    highLevelAPIDemo
