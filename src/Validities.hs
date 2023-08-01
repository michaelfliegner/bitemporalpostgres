{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE MonoLocalBinds #-}

module Validities(createRow,Validity(..)) where
  import Prelude
  import MyPrelude(Action,Connection, FromRow,Generic,Int64,PGRange (..),query,ToRow, toField)
  import Database.PostgreSQL.Simple.Time (UTCTimestamp)
  
  data Validity = Validity {validity_id::Int64, ref_version::Int64, valid_ref::PGRange UTCTimestamp, valid_txn::PGRange UTCTimestamp }
    deriving (Show,Generic,FromRow)

  instance ToRow Validity where
  toRow :: Validity -> [Action]
  toRow a = [toField(ref_version a),toField (valid_ref a) , toField (valid_txn a)]

 
  createRow :: FromRow Validity => Connection -> Validity -> IO [Validity]
  createRow conn v = do
    query conn "insert into Validities (ref_version, valid_ref,valid_txn) values (?,?,?) returning id, ref_version, valid_ref,valid_txn" (toRow v)