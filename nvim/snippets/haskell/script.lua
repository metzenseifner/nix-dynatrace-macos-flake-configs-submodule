return {
  s("script-scaffolding", fmt([[
#!/usr/bin/env stack
{- stack script --resolver lts-22.18 --optimize
  --package optparse-applicative
-}
-- optimized flag to use binary if avail else create

import Options.Applicative

data Args = ArgsData
  { arg1 :: String,
    arg2 :: String
  } deriving (Show)

parseArgs :: Parser Args
parseArgs = ArgsData <$> parseArg1 <*> parseArg2
  where parseArg1 = strOption (long "arg1" <> help "Path for arg1 argument." <> metavar "ARG1")
        parseArg2 = strOption (long "arg2" <> help "Path for arg2 argument." <> metavar "ARG2")

main :: IO ()
main = do
  opts <- execParser args
  print opts
  where args = info (parseArgs <**> helper)
                ( fullDesc
               <> progDesc "Scaffolding for a CLI application."
               <> header "hello - a test for optparse-applicative, without subcommands" )
  ]], {}, {delimiters="[]"})),
  s("script-with-run-abstraction", fmt([[
#!/usr/bin/env stack
{- stack script --resolver lts-22.18 --optimize
  --package optparse-applicative
-}

import Options.Applicative

data Args = ArgsData
  { arg1 :: String,
    arg2 :: String
  } deriving (Show)

parseArgs :: Parser Args
parseArgs = ArgsData <$> parseArg1 <*> parseArg2
  where parseArg1 = strOption (long "arg1" <> help "Path for arg1 argument." <> metavar "ARG1")
        parseArg2 = strOption (long "arg2" <> help "Path for arg2 argument." <> metavar "ARG2")

run :: Args -> IO ()
run args = do
  print args
  
main :: IO ()
main = run =<< execParser args
  where args = info (parseArgs <**> helper)
                ( fullDesc
               <> progDesc "Scaffolding for a CLI application."
               <> header "hello - a test for optparse-applicative, without subcommands" )
  ]], {}, {delimiters="[]"})),

  s("script-standard", fmt([[
  ]], {}, {})),
  s("script-full-example", fmt([[
    #!/usr/bin/env stack
    {- stack script --resolver lts-22.16
      --package process
      --package directory
      --package filepath
      --package optparse-applicative
    -}
    -- see https://www.youtube.com/watch?v=mS186vrNleE
    -- see https://thoughtbot.com/blog/applicative-options-parsing-in-haskell
    -- will not be recognized by haskell-language-server using stack script until
    -- https://github.com/haskell/haskell-language-server/issues/111
    import Prelude
    
    import Options.Applicative
    import System.Directory (getDirectoryContents, listDirectory, doesDirectoryExist, doesFileExist, canonicalizePath, Permissions, getPermissions, searchable)
    import System.FilePath  ((</>), takeExtension, takeFileName, takeExtension, takeBaseName, takeDirectory, splitDirectories)
    import Control.Monad (filterM, forM, liftM)
    
    import           System.Process                 ( readProcessWithExitCode )
    import           System.Exit                    ( ExitCode )
    import           Data.List.NonEmpty  as NE (NonEmpty( (:|) ))
    import Data.List (isSubsequenceOf, intersect)
    
    import Control.Exception
      ( bracket
      , handle
      , SomeException(..)
      )
    
    import Debug.Trace (trace)

    instance Show DirSpec where
      show(DirectoryPathInput a) = a
    data DirSpec = DirectoryPathInput String 
    data Options = Options { 
        dir :: DirSpec,
        depth :: Int,
        stdError :: Maybe FilePath,
        stdOutput :: Maybe FilePath
        --cmd :: Command
      } deriving (Show)
    optionsParser :: Parser Options
    optionsParser = Options <$> dirParser <*> depthParser <*> stdErrorPathParser <*> stdOutputPathParser -- <*> parseCommand
    
    dirParser :: Parser DirSpec
    dirParser =  dirPathParser
      where 
        -- defines a set of parsers
        dirPathParser = DirectoryPathInput <$> strOption (long "dir" <> help "A path to a directory." <> metavar "DIR" <> value ".")
    depthParser :: Parser Int
    -- |A regular option is an option which takes a single argument, parses it, and returns a value. e.g. option whereby option is the "regular option" and auto is the "reader"
    depthParser = option auto (long "depth" <> short 'd' <> help "The recursion depth for directory structure." <> metavar "INT" <> value 1)
    stdErrorPathParser :: Parser (Maybe FilePath)
    stdErrorPathParser = optional $ strOption (long "stdErr" <> help "Path to standard error file." <> metavar "FILE")
    stdOutputPathParser :: Parser (Maybe FilePath)
    stdOutputPathParser = optional $ strOption (long "stdOut" <> help "Path to standard output file." <> metavar "FILE")
    
    
    run :: Options -> IO ()
    run opts = do
    --run (Options dir maxDepth stdOutFile stdErrFile) = do
      putStrLn "Do something with deconstructed options or pass around Options as-is."
      print opts
    
    main :: IO ()
    main = do
      opts <- execParser opts
      run opts
      where
        opts =
          info
            (optionsParser <**> helper)
            ( fullDesc
                <> progDesc "This is scaffolding for a CLI application."
                <> header "Help"
            )
      ]], {}, {delimiters="[]"}))
}
