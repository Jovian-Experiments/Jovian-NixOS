{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text as T
import Network.HTTP.Req
import Nix (prettyNix)
import OptParse (Options (numPlugins, output, withStoreUrl), Output (OutputFile, StdOut), parse)
import Plugin (Plugin, deckyPluginsFun)

-- | Get plugins from store
getPlugins :: T.Text -> IO [Plugin]
getPlugins storeUrl =
  runReq defaultHttpConfig $ do
    r <-
      req
        GET
        (https storeUrl /: "plugins")
        NoReqBody
        jsonResponse
        mempty

    return (responseBody r)

main :: IO ()
main = do
  opts <- parse
  plugins <- getPlugins (withStoreUrl opts)
  deckyPlugins <- deckyPluginsFun plugins (numPlugins opts)
  let pretty = prettyNix deckyPlugins

  case output opts of
    StdOut -> print pretty
    OutputFile path -> do
      putStrLn ("Saving derivations to: " <> path)
      writeFile path (show pretty)
