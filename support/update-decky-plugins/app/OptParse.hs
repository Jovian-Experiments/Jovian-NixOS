{-# LANGUAGE OverloadedStrings #-}

module OptParse (Options(..), Output(..), parse) where
import Options.Applicative
import qualified Data.Text as T

data Options = Options
  { withStoreUrl :: T.Text
  , output :: Output
  , numPlugins :: Maybe Int
  }
  deriving Show

data Output = StdOut | OutputFile !FilePath
  deriving Show

optionsParser :: Parser Options
optionsParser =
  Options <$> withStoreUrlParser
  <*> outputParser
  <*> numPluginsParser
  where
    withStoreUrlParser :: Parser T.Text
    withStoreUrlParser = strOption
      ( long "store-url"
        <> short 's'
        <> metavar "STOREURL"
        <> help "Store url to use"
        <> value "plugins.deckbrew.xyz")

    outputParser :: Parser Output
    outputParser = option (OutputFile <$> str)
      ( long "output"
        <>  short 'o'
        <> metavar "FILE"
        <> help "Output file"
        <> value StdOut )

    numPluginsParser :: Parser (Maybe Int)
    numPluginsParser = optional (option auto $
       long "num-plugins"
        <> short 'n'
        <> metavar "NUMPLUGINS"
        <> help "Number of plugins to process"
      )
  
optsParser :: ParserInfo Options
optsParser = info (helper <*> optionsParser) (fullDesc
                   <> Options.Applicative.header "decky-plugin-updater - a decky plugin to nix derivation generator"
                   <> progDesc "Convert decky plugins to a set of nix derivations")

parse :: IO Options
parse = execParser optsParser
