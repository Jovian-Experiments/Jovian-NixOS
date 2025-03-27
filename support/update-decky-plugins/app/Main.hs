{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.HTTP.Req
import OptParse (parse, Options (withStoreUrl, output, numPlugins), Output (StdOut, OutputFile))
import Plugin (Plugin, deckyPluginsFun)
import qualified Data.Text as T
import Nix (prettyNix)

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

  case (output opts) of
    StdOut -> print pretty
    OutputFile path -> do
      putStrLn ("Saving derivations to: " <> path)
      writeFile path (show pretty)
      
