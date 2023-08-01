{-# LANGUAGE AllowAmbiguousTypes #-}

module Entities where
  import MyPrelude
  import Histories
  import Versions

  class (Show e , FromRow e) => BitemporalEntity e
   where
    myprint :: e -> IO()
    myprint = print 
    createEntityRow :: FromRow e => Connection -> e -> IO [e]

  class (Show e , FromRow e ) => BitemporalRevision e 
   where
    createRevisionRow :: FromRow e => Connection -> e -> IO [e]
    --createRevision :: Version -> f -> IO e
    


-- class (BitemporalRevision e f) => BitemporalRootEntity e f
--  where
--   createRootEntity:: History -> Version -> f -> IO e  
--   
-- class (BitemporalRevision e f, BitemporalEntity g) => BitemporalComponent e f g
--  where
--   createComponent:: Version -> f -> g -> IO e