{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Plugin (Plugin, getPluginDrv, deckyPluginsFun)
where

import Control.Concurrent.Async (mapConcurrently)
import Data.Aeson (FromJSON, ToJSON)
import qualified Data.Text as T
import qualified Data.Text.IO as T.IO
import GHC.Generics (Generic)
import GHC.IO.Exception (ExitCode (ExitFailure, ExitSuccess))
import Nix.Expr
import Nix.Prelude (exitWith, fromMaybe)
import System.IO (stderr)
import System.Process (CreateProcess (std_err, std_out), StdStream (CreatePipe), createProcess, proc, waitForProcess)
import qualified Version as V

-- | Represent a single plugin structure
data Plugin = Plugin
  { id :: Integer
  , name :: T.Text
  , author :: T.Text
  , description :: T.Text
  , tags :: [T.Text]
  , versions :: V.Versions
  -- ^ Plugin versions
  , visible :: Bool
  , updates :: Integer
  , created :: T.Text
  , updated :: T.Text
  }
  deriving (Show, Generic)

instance FromJSON Plugin
instance ToJSON Plugin

{- | Constructs a derivation from the selected plugin, version, and hash
  Pure entrypoint for the unpure IO version, `getPluginDrv`
-}
pluginDrv :: Plugin -> V.Version -> T.Text -> T.Text -> NExpr
pluginDrv plugin version download_url download_hash = "buildDeckyPlugin" @@ fields
 where
  nix_tags = map mkStr (tags plugin)
  fields =
    attrsE
      [ ("name", mkStr $ name plugin)
      , ("version", mkStr $ V.name version)
      , ("url", mkStr download_url)
      , ("download_hash", mkStr download_hash)
      , ("meta", meta)
      ]

  meta =
    mkWith "lib" $
      attrsE
        [ ("description", mkStr $ description plugin)
        , ("decky_tags", mkList nix_tags)
        , ("platforms", "platforms.all")
        ]

-- | Returns a plugin download url from its hash
getPluginDownloadUrl :: Maybe T.Text -> V.Version -> T.Text
getPluginDownloadUrl cdn_url version = url
 where
  hash = V.hash version
  base_url = fromMaybe "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/" cdn_url
  url = base_url <> hash <> ".zip"

{- | Get a Sha256 hash from the provided url
  FIXME: Is there a way to do this without IO?
-}
getPluginSourceHash :: T.Text -> IO (Either T.Text T.Text)
getPluginSourceHash url = do
  (_, Just stdout, Just proc_stderr, handle) <- createProcess (proc "nix-prefetch-url" [T.unpack url]){std_out = CreatePipe, std_err = CreatePipe}
  exit_code <- waitForProcess handle

  case exit_code of
    ExitSuccess -> do
      hash <- T.IO.hGetContents stdout
      pure $ Left hash
    ExitFailure _ -> do
      messageFailure <- T.IO.hGetContents proc_stderr
      pure $ Right messageFailure

{- | Some plugins have special characters, such as !
  This function deals with this
-}
replaceSpecialChar :: Char -> Bool
replaceSpecialChar '!' = False
replaceSpecialChar _ = True

-- | Clean the name from spaces and special characters
cleanName :: Plugin -> T.Text
cleanName = clean
 where
  clean plugin =
    T.toLower
      . T.map (\c -> if c == ' ' then '_' else c)
      . T.filter replaceSpecialChar
      $ name plugin

-- | Get a nix key value pair for the specified plugin
getPluginDrv :: Maybe T.Text -> Plugin -> IO (T.Text, NExpr)
getPluginDrv cdn_url plugin =
  let
    latest_version = head (versions plugin)
    -- To wrap the name in quotes
    quotes toQuote = "\"" <> toQuote <> "\""
    -- Clean the name from spaces, special chars...
    key = quotes (cleanName plugin)
    url = getPluginDownloadUrl cdn_url latest_version
   in
    do
      T.IO.putStrLn ("Processing plugin with name: " <> name plugin)
      hash_result <- getPluginSourceHash url
      download_hash <- case hash_result of
        Left hash -> do
          let stripped = T.strip hash
          T.IO.putStrLn ("Got hash: " <> stripped)
          pure stripped
        Right message -> do
          T.IO.hPutStrLn stderr ("Process exit failed with " <> message)
          exitWith (ExitFailure 2)

      pure (key, pluginDrv plugin latest_version url download_hash)

-- | Get a attrset consisting of all decky plugins as nix expressions
getPluginDrvs :: Maybe T.Text -> [Plugin] -> IO NExpr
getPluginDrvs cdn_url plugins = do
  attrs <- mapConcurrently (getPluginDrv cdn_url) plugins
  pure $ attrsE attrs

deckyPluginsFun :: [Plugin] -> Maybe Int -> Maybe T.Text -> IO NExpr
deckyPluginsFun plugins numPlugins cdn_url = do
  let params = [("buildDeckyPlugin", Nothing), ("lib", Nothing), ("stdenv", Nothing), ("fetchurl", Nothing), ("unzip", Nothing)]
  pluginsDrv <- case numPlugins of
    Just n -> getPluginDrvs cdn_url (take n plugins)
    Nothing -> getPluginDrvs cdn_url plugins

  pure $ mkGeneralParamSet Nothing params False ==> pluginsDrv
