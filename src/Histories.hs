{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE MonoLocalBinds #-}
 
module Histories(History(..),createRow) where
  import Prelude
  import MyPrelude(Connection,query, Generic,UUID, FromRow, ToRow, toField,Action)

  data History = History {history_id::UUID, htype::String}
    deriving (Show,Generic,FromRow)

  instance ToRow History where
  toRow :: History -> [Action]
  toRow a = [toField (htype a)]

  createRow :: FromRow History =>
    Connection -> History -> IO [History]
  createRow conn h = query conn "insert into histories (htype) values (?) returning id,htype" (toRow h)

  