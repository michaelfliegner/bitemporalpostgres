{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE MonoLocalBinds #-}

module Versions(Versions.createRow,Version(..)) where
  import Prelude
  import MyPrelude(Connection,query, Generic,Int64,UUID, FromRow, ToRow, toField,Action)

  data Version = Version {version_id::Int64, ref_history::UUID, committed::Bool}
    deriving (Show,Generic,FromRow)

  instance ToRow Version where
  toRow :: Version -> [Action]
  toRow a = [toField (id(ref_history a)), toField(committed a)]

  createRow :: FromRow Version =>
    Connection -> Version -> IO [Version]
  createRow conn v = do
    query conn "insert into versions (ref_history ,committed) values (?,?) returning id, ref_history, committed" (toRow v)