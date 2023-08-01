{-# LANGUAGE OverloadedStrings #-}

  module Main(main, main2) where
  import Prelude
  import Database.PostgreSQL.Simple
      ( connectPostgreSQL )
  
  import MyPrelude
  import Data.Time.Clock 
  import Histories(createRow,History(..))
  import Versions(createRow, Version(..))
  import Validities(createRow, Validity(..))
  import Database.PostgreSQL.Simple.Time (Unbounded(Finite))
  import Contracts ( Contract(Contract) ,myprint)

  c :: Contract
  c::Contract =  Contract 0 nil
  
  main :: IO Validity
  main = do
    myprint c
    conn <- connectPostgreSQL "host=localhost port=5432 user=postgres dbname=postgres connect_timeout=10"
    (histo:_)::[History] <- Histories.createRow conn (History nil "schrumpled8y") 
    print histo
    (version:_)::[Version] <- Versions.createRow conn (Version (0::Int64) (history_id histo) False)
    print version
    from <- getCurrentTime
    (validity: _) <- Validities.createRow conn (Validity 0  (PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from))))(PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from)))))
    return validity

  main2 :: IO ()
  main2 = do
    myprint c
  -- readddl = do
  --  readFile "schema.sql"
