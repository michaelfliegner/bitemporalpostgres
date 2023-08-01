{-# LANGUAGE DeriveAnyClass #-}
--{-# LANGUAGE OverloadedStrings #-}
--{-# LANGUAGE EmptyDataDeriving #-}
-- {-# LANGUAGE MonoLocalBinds #-}

{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE DerivingVia #-}

{-# LANGUAGE MonoLocalBinds #-}

module Contracts (Contract(..),createEntityRow,ContractRevision(..),ContractRevisionJSON(..),createRevisionRow) where 
   import MyPrelude(Connection,query, Generic,UUID, Int64, FromRow, ToRow,toRow, toField, ToField, FromField, Action, PGRange)

   import Entities
   import Database.PostgreSQL.Simple.Newtypes (Aeson(..))
   import Data.Aeson
   
   
   data Contract = Contract {contract_id::Int64, ref_history::UUID}
    deriving (Show, Generic,FromRow)
    
   instance ToRow Contract where
    toRow :: Contract -> [Action] 
    toRow a = [toField (ref_history a)]

   instance BitemporalEntity Contract
     where 
      createEntityRow :: FromRow Contract => Connection -> Contract -> IO [Contract]
      createEntityRow conn c = 
         query conn "insert into contracts (ref_history) values (?) returning id, ref_history" (toRow c)


   data ContractRevisionJSON where
     ContractRevisionJSON :: {bubu :: String} -> ContractRevisionJSON
      deriving (Show, Generic)
      deriving (ToField, FromField) via Aeson ContractRevisionJSON   -- DerivingVia
   instance FromJSON ContractRevisionJSON
   instance ToJSON ContractRevisionJSON


   data ContractRevision = ContractRevision {contract_revision_id::Int64, ref_component::Int64, ref_valid::PGRange Int64, content:: ContractRevisionJSON}
    deriving (Show, Generic,FromRow) 
   

   instance ToRow ContractRevision where
    toRow :: ContractRevision -> [Action] 
    toRow a = [toField(ref_component a), toField (ref_valid a),toField(content a)] 

   instance BitemporalRevision ContractRevision
     where
      createRevisionRow :: FromRow ContractRevision => Connection -> ContractRevision -> IO [ContractRevision]
      createRevisionRow conn cr = 
         query conn "insert into contract_revisions (ref_component,ref_valid,content) values (?,?,?) returning id, ref_component,ref_valid,content" (toRow cr)
