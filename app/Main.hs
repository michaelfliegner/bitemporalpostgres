{-# LANGUAGE OverloadedStrings #-} 

  module Main where 
  import Prelude 
  import Database.PostgreSQL.Simple
      ( connectPostgreSQL )
  
  import MyPrelude
  import Data.Time.Clock 
  import Data.String(fromString)
  import Histories(createRow,History(..))
  import Versions(createRow, Version(..))
  import Validities(createRow, Validity(..))
  import Database.PostgreSQL.Simple.Time (Unbounded(Finite))
  import Database.PostgreSQL.Simple.Range(RangeBound(..))
  import System.IO
  
  import Contracts -- (Contract(Contract), createEntityRow,ContractRevisionJSON)
 
  version::Version = Version 0 nil False

  c::Contract = Contract 0 nil 

  crj::ContractRevisionJSON=ContractRevisionJSON("schnaps")

  cr::ContractRevision = ContractRevision (0::Int64) (version_id version) (PGRange(Inclusive(version_id version))(Exclusive(version_id version))) crj

  main = do 
    print crj
    print cr
    conn <- connectPostgreSQL "host=localhost port=5432 user=postgres dbname=postgres connect_timeout=10"
    (histo:_)::[History] <- Histories.createRow conn (History nil "schrumpled8y") 
    print histo
    (version:_)::[Version] <- Versions.createRow conn (Version (0::Int64) (history_id histo) False)
    print version
    from <- getCurrentTime
    (validity: _)::[Validity]<- Validities.createRow conn (Validity (0::Int64) (version_id version) (PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from))))(PGRange (Inclusive (Finite from))( Exclusive (Finite (addUTCTime (8*60*60) from)))))
    (contract: _)::[Contract] <- Contracts.createEntityRow conn (Contract (0::Int64) (history_id histo) )
    print contract
    print (ContractRevision (0::Int64) (version_id version) (PGRange(Inclusive(version_id version))(Exclusive(version_id version))) crj)
    (contractrevision: _)::[ContractRevision] <- Contracts.createRevisionRow conn (ContractRevision (0::Int64) (contract_id contract) (PGRange(Inclusive(version_id version))(Exclusive((version_id version)+1))) crj)
    return contract

  createSchema = do
    conn <- connectPostgreSQL "host=localhost port=5432 user=postgres dbname=postgres connect_timeout=10"
    handle <- openFile "schema.sql" ReadMode  
    qrytext <- hGetContents handle 
    _ <- execute_ conn "drop schema public cascade;"
    _ <- execute_ conn "create schema public;"
    return (execute_ conn (fromString qrytext))