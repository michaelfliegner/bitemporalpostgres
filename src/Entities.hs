{-# LANGUAGE AllowAmbiguousTypes #-}

module Entities where
  import MyPrelude
  import Histories
  import Versions
  import Validities
  import Data.Time (getCurrentTime, addUTCTime)
  import Database.PostgreSQL.Simple.Time
  
  class Row r
    where
      get_id::r->Int64

  class (Show e , Row e, FromRow e) => EntityRow e
   where
    createEntityRow :: FromRow e => Connection -> UUID -> IO [e]
    set_history :: e -> UUID -> e

     --  (version:_)::[Version] <- Versions.createRow conn (Version (0::Int64) (history_id histo) False)
      --  print version
      --  from <- getCurrentTime
      --  (_: _)::[Validity]<- Validities.createRow conn (Validity (0::Int64) (version_id version) (PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from))))(PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from)))))
      --  (e: _)::[e] <- createEntityRow conn entity
  
  class (Show e , Row e,  FromRow e ) => RevisionRow e 
   where
    createRevisionRow :: FromRow e => Connection -> e -> IO [e]
    set_component :: e -> Int64 -> e
    
  class (Show e, EntityRow e, RevisionRow f) => BitemporalEntity e f
    where
      create:: Connection -> f  -> IO e
      create conn revision = do
         (h:_)::[History] <- Histories.createRow conn (History nil "schrumpled8y") 
         (version:_)::[Version] <- Versions.createRow conn (Version (0::Int64) (history_id h) False)
         from <- getCurrentTime
         (_: _)::[Validity]<- Validities.createRow conn (Validity (0::Int64) (version_id version) (PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from))))(PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from))))) 
         (created: _)::[e] <- createEntityRow conn (history_id h)
         _ <- createRevisionRow conn (set_component revision (get_id created))
         return created
