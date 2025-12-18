#!/usr/bin/env stack
-- stack script --resolver lts-23.8
-- package directory
-- package process
-- package text
-- package base
-- package containers
{-# LANGUAGE OverloadedStrings #-}

-- import System.Directory (doesFileExist, getPermissions, executable)
-- import System.Environment (getArgs)
-- import System.Exit (exitFailure)
-- import System.FilePath (takeDirectory, (</>))
-- import System.IO (hGetContents, stdin)
-- import System.Process (readProcess, callProcess, callCommand)
-- import Control.Monad (when, unless)
-- import Data.List (isInfixOf)
-- import Data.Text (Text, pack, unpack)
-- import qualified Data.Text as T
-- import qualified Data.Text.IO as TIO
-- import Text.Printf (printf)
-- import Data.Monoid ((<>))
import System.Directory (doesFileExist, getPermissions, executable)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.FilePath (takeDirectory, (</>))
import System.IO (hGetContents, stdin)
import System.Process (readProcess, callProcess, callCommand)
import Control.Monad (when, unless)
import Data.List (isInfixOf)
import Data.Text (Text, pack, unpack)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Text.Printf (printf)
import Data.Monoid ((<>))

-- logMessage :: Text -> Text -> IO ()
-- logMessage level message = do
--     let levels = [("DEBUG", "\ESC[34m"), ("INFO", "\ESC[32m"), ("WARNING", "\ESC[33m"), ("ERROR", "\ESC[31m"), ("CRITICAL", "\ESC[35m"), ("RESET", "\ESC[0m")]
--     let colorCode = maybe "\ESC[0m" id (lookup level levels)
--     TIO.putStrLn $ pack $ printf "%s[%s] %s%s" colorCode (unpack level) (unpack message) (snd $ last levels)
logMessage :: Text -> Text -> IO ()
logMessage level message = do
    let levels :: [(Text, Text)]
        levels = [("DEBUG", "\ESC[34m"), ("INFO", "\ESC[32m"), ("WARNING", "\ESC[33m"), ("ERROR", "\ESC[31m"), ("CRITICAL", "\ESC[35m"), ("RESET", "\ESC[0m")]
    let colorCode = maybe "\ESC[0m" id (lookup level levels)
    TIO.putStrLn $ colorCode <> "[" <> level <> "] " <> message <> (snd $ last levels)

isExecutable :: FilePath -> IO Bool
isExecutable filePath = do
    exists <- doesFileExist filePath
    if exists
        then do
            perms <- getPermissions filePath
            return $ executable perms
        else return False

readSingleLine :: FilePath -> IO Text
readSingleLine filePath = do
    contents <- TIO.readFile filePath
    return $ head $ T.lines contents

getParentDirectory :: FilePath -> FilePath
getParentDirectory = takeDirectory . takeDirectory

main :: IO ()
main = do
    -- let binaryName = "pre-push-binary"
    -- binaryExists <- doesFileExist binaryName
    -- unless binaryExists $ do
    --     logMessage "INFO" "Binary does not exist. Compiling..."
    --     callCommand "stack ghc -- -o pre-push-binary script.hs"
    --     logMessage "INFO" "Compilation finished."

    worktreeDir <- fmap init $ readProcess "git" ["rev-parse", "--show-toplevel"] ""
    let branchesDir = getParentDirectory worktreeDir
    let repoDir = getParentDirectory branchesDir
    let hooksDir = repoDir </> "hooks"

    stdinContent <- hGetContents stdin
    when ("null" `isInfixOf` stdinContent) $ do
        logMessage "ERROR" "You really do not want to push this branch. Aborting."
        exitFailure

    let prePushHook = hooksDir </> "pre-push"
    hookExists <- isExecutable prePushHook
    if hookExists
        then do
            logMessage "INFO" $ "Found " <> pack prePushHook <> ". Executing."
            args <- getArgs
            callProcess prePushHook args
        else
            logMessage "INFO" $ "Completed pre-push. No hook under " <> pack prePushHook <> " found. Exiting."
