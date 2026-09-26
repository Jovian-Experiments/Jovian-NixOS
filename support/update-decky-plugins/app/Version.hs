{-# LANGUAGE DeriveGeneric #-}

module Version where

import Data.Aeson (FromJSON, ToJSON)
import qualified Data.Text as T
import GHC.Generics (Generic)

data Version = Version
  { name :: T.Text
  , hash :: T.Text
  , created :: T.Text
  , downloads :: Integer
  , updates :: Integer
  }
  deriving (Show, Generic)

instance FromJSON Version
instance ToJSON Version

type Versions = [Version]
