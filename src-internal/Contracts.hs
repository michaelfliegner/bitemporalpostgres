{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE DerivingVia #-}

{-# LANGUAGE MonoLocalBinds #-}

module Contracts (Contract(..),create, createEntityRow,ContractRevision(..),ContractRevisionJSON(..),createRevisionRow) where
   import MyPrelude(Connection,query, Generic,UUID, Int64, FromRow, ToRow,toRow, toField, ToField, FromField, Action, PGRange, nil)

   import Entities
   import Database.PostgreSQL.Simple.Newtypes (Aeson(..))
   import Data.Aeson
   import Database.PostgreSQL.Simple
   --import Histories

   data Contract = Contract {contract_id::Int64, ref_history::UUID}
    deriving (Show, Generic,FromRow)

   instance Row Contract where
      get_id :: Contract -> Int64
      get_id = contract_id

   instance ToRow Contract where
    toRow :: Contract -> [Action]
    toRow a = [toField (ref_history a)]


   instance EntityRow Contract
     where
      createEntityRow :: FromRow Contract => Connection -> UUID -> IO [Contract]
      createEntityRow conn refh = query conn "insert into contracts (ref_history) values (?) returning id, ref_history" (toRow (Contract{contract_id=0,ref_history=refh}))

      set_history :: Contract -> UUID -> Contract
      set_history c h =
       c{ref_history=h}

   data ContractRevisionJSON where
     ContractRevisionJSON :: {bubu :: String} -> ContractRevisionJSON
      deriving (Show, Generic)
      deriving (ToField, FromField) via Aeson ContractRevisionJSON   -- DerivingVia
   instance FromJSON ContractRevisionJSON
   instance ToJSON ContractRevisionJSON


   data ContractRevision = ContractRevision {contract_revision_id::Int64, ref_component::Int64, ref_valid::PGRange Int64, content:: ContractRevisionJSON}
    deriving (Show, Generic,FromRow)

   instance Row ContractRevision where
      get_id :: ContractRevision -> Int64
      get_id = contract_revision_id

   instance ToRow ContractRevision where
    toRow :: ContractRevision -> [Action]
    toRow a = [toField (ref_component a), toField (ref_valid a),toField (content a)]

   instance  RevisionRow ContractRevision
     where
      createRevisionRow :: FromRow ContractRevision => Connection -> ContractRevision -> IO [ContractRevision]
      createRevisionRow conn cr =
         query conn "insert into contract_revisions (ref_component,ref_valid,content) values (?,?,?) returning id, ref_component,ref_valid,content" (toRow cr)

      set_component :: ContractRevision -> Int64 -> ContractRevision
      set_component r cid =
         r{ref_component= cid}

   instance BitemporalEntity Contract ContractRevision
