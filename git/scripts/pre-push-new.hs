#!/usr/bin/env stack
-- stack script --resolver lts-18.18

import System.Directory (doesFileExist, getPermissions, executable)
import System.Exit (exitFailure)
import System.IO (hGetContents, stdin)
import System.Process (readProcess, callProcess)
import System.Environment (getArgs)
import System.FilePath ((</>), takeDirectory)

logMessage :: String -> String -> IO ()
logMessage level message = do
    let levels = [("DEBUG", "\ESC[34m"), ("INFO", "\ESC[32m"), ("WARNING", "\ESC[33m"), ("ERROR", "\ESC[31m"), ("CRITICAL", "\ESC[35m"), ("RESET", "\ESC[0m")]
    let colorCode = maybe "\ESC[0m" id (lookup level levels)
    putStrLn $ colorCode ++ "[" ++ level ++ "] " ++ message ++ "\ESC[0m"

isExecutable :: FilePath -> IO Bool
isExecutable filePath = do
    exists <- doesFileExist filePath
    if exists
        then do
            perms <- getPermissions filePath
            return (executable perms)
        else return False

readSingleLine :: FilePath -> IO String
readSingleLine filePath = do
    contents <- readFile filePath
    return (head (lines contents))

getParentDirectory :: FilePath -> FilePath
getParentDirectory = takeDirectory . takeDirectory

main :: IO ()
main = do
    worktreeDir <- fmap init (readProcess "git" ["rev-parse", "--show-toplevel"] "")
    let branchesDir = getParentDirectory worktreeDir
    let repoDir = getParentDirectory branchesDir
    let hooksDir = repoDir </> ".git" </> "hooks"

    stdinContent <- hGetContents stdin
    if "null" `elem` words stdinContent
        then do
            logMessage "ERROR" "You really do not want to push this branch. Aborting."
            exitFailure
        else do
            let prePushHook = hooksDir </> "pre-push"
            hookExists <- isExecutable prePushHook
            if hookExists
                then do
                    logMessage "INFO" $ "Found " ++ prePushHook ++ ". Executing."
                    args <- getArgs
                    callProcess prePushHook args
                else logMessage "INFO" $ "Completed pre-push. No hook under " ++ prePushHook ++ " found. Exiting."
