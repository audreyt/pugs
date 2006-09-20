{-# OPTIONS_GHC -fglasgow-exts -fvia-C -optc-w -fno-warn-orphans -cpp -fno-warn-deprecations #-}

{-|
    POSIX calls and emulations.

>   And now all those lands lie under the wave.
>   And I walk in Ambarona, in Tauremorna, in Aldalome.
>   In my own land, in the country of Fangorn,
>   Where the roots are long,
>   And the years lie thicker than the leaves
>   In Tauremornalome.
-}

#undef PUGS_HAVE_POSIX
#include "pugs_config.h"

module Pugs.Compat (
    createLink,
    createSymbolicLink,
    readSymbolicLink,
    rename,
    removeLink,
    setFileMode,
    getEnvironment,
    getArg0,
    statFileSize,
    getProcessID,
    getRealUserID,
    getEffectiveUserID,
    getRealGroupID,
    getEffectiveGroupID,
    getProcessTimes,
    setEnv,
    getEnv,
    unsetEnv,
    signalProcess,
    ProcessTimes(..),
    clocksPerSecond,
    DirStream,
    openDirStream,
    readDirStream,
    rewindDirStream,
    closeDirStream,
    executeFile',        -- the prime signifies we changed signature.
    getCurrentDirectory,
    setCurrentDirectory,
    doesFileExist,
    doesDirectoryExist,
    doesExist,
) where

import Foreign
import System.Cmd
import System.Posix.Types

#ifdef PUGS_HAVE_POSIX
import System.Posix.Files
import System.Posix.Process
import System.Posix.Env hiding (getEnvironment)
import System.Posix.Directory
import System.Posix.User
import System.Exit
import System.Environment (getEnvironment)
import Foreign.C.Types
import Foreign.C.String
import Data.Typeable
import qualified System.Posix.Signals

doesExist :: FilePath -> IO Bool
doesExist = fileExist

testStatusWith :: (FileStatus -> Bool) -> FilePath -> IO Bool
testStatusWith t f = fmap t (getFileStatus f) `catch` const (return False)

doesFileExist :: FilePath -> IO Bool
doesFileExist = testStatusWith isRegularFile

doesDirectoryExist :: FilePath -> IO Bool
doesDirectoryExist = testStatusWith isDirectory

getCurrentDirectory :: IO FilePath
getCurrentDirectory = getWorkingDirectory

setCurrentDirectory :: FilePath -> IO ()
setCurrentDirectory = changeWorkingDirectory

executeFile' :: FilePath -> Bool -> [String] -> Maybe [(String, String)] -> IO ExitCode
executeFile' prog True args Nothing = rawSystem prog args
executeFile' prog search args env = do
    print (prog, search, args, env)
    executeFile prog search args env
    return $ ExitFailure 1            -- if we got here, it failed.

statFileSize :: FilePath -> IO Integer
statFileSize f = do
    s <- getFileStatus f
    return (toInteger (fileSize s))

type Signal = System.Posix.Signals.Signal
signalProcess :: Signal -> ProcessID -> IO ()
signalProcess = System.Posix.Signals.signalProcess

clocksPerSecond :: (Num a) => a
clocksPerSecond = 1000000

data DirStream_ deriving (Typeable)

instance Typeable DirStream where
    typeOf _ = typeOf (undefined :: DirStream_)

#else

import Debug.Trace
import qualified System.Environment
import System.Directory (getCurrentDirectory, setCurrentDirectory, doesFileExist, doesDirectoryExist)
import IO
import System.IO
import System.Exit
import Foreign.C.String
import Foreign.Ptr
import Foreign.C.Types
import Data.Ratio
import Data.Typeable
import System.Posix.Internals
import Foreign.C.Error

failWith :: (Monad m) => String -> m a
failWith s = fail $ "'" ++ s ++ "' not implemented on this platform."

failWithIncomplete :: (Monad m) => String -> m a
failWithIncomplete s = fail $ "'" ++ s ++ "' not fully implemented on this platform."

warnWith :: String -> IO ()
warnWith s = trace ("'" ++ s ++ "' not implemented on this platform.") $ return ()

-- This should all be moved into Compat.Win32, once we go that route

-- This is partially right - but some APIs return even "better" resolution
clocksPerSecond :: (Num a) => a
clocksPerSecond = 1000000

foreign import stdcall unsafe "SetEnvironmentVariableW" win32SetEnv :: CWString -> CWString -> IO ()
foreign import stdcall unsafe "GetEnvironmentVariableW" win32GetEnv :: CWString -> CWString -> Int -> IO Int
-- also implement/redefine getEnvironment as GetEnvironmentStrings

setEnv :: String -> String -> Bool -> IO ()
setEnv k v _ = withCWString k $ \ key ->
               withCWString v $ \ value -> do
                 rc <- win32SetEnv key value
                 return $ rc

getEnv :: String -> IO (Maybe String)
getEnv k = withCWString k $ \ key ->
    withCWString (replicate size ' ') $ \ buf -> do
      rc <- win32GetEnv key buf size
      if rc > 0
        then do
          t <- peekCWString buf
          return $ Just t
        else
          return $ Nothing
      where
        size = 32768

unsetEnv :: String -> IO ()
unsetEnv k = withCWString k $ \ key -> withCWString "" $ \ v -> do
               win32SetEnv key v
-- #unsetEnv _ = warnWith "unsetEnv"

getEnvironment :: IO [(String, String)]
getEnvironment = System.Environment.getEnvironment

createLink :: FilePath -> FilePath -> IO ()
createLink _ _ = warnWith "link"

createSymbolicLink :: FilePath -> FilePath -> IO ()
createSymbolicLink _ _ = warnWith "symlink"

readSymbolicLink :: FilePath -> IO FilePath
readSymbolicLink _ = failWith "readlink"

rename :: FilePath -> FilePath -> IO ()
rename _ _ = warnWith "rename"

removeLink :: FilePath -> IO ()
removeLink _ = warnWith "unlink"

setFileMode :: FilePath -> FileMode -> IO ()
setFileMode _ _ = warnWith "chmod"

newtype DirStream = DirStream (Ptr CDir)
    deriving (Typeable)

openDirStream :: FilePath -> IO DirStream
openDirStream name =
  withCString name $ \s -> do
    dirp <- c_opendir s
    return (DirStream dirp)

readDirStream :: DirStream -> IO FilePath
readDirStream (DirStream dirp) =
  alloca $ \ptr_dEnt  -> loop ptr_dEnt
 where
  loop ptr_dEnt = do
    resetErrno
    r <- readdir dirp ptr_dEnt
    if (r == 0)
        then do
            dEnt <- peek ptr_dEnt
            if (dEnt == nullPtr) then return [] else do
                entry <- (d_name dEnt >>= peekCString)
                freeDirEnt dEnt
                return entry
        else do
            errno <- getErrno
            if (errno == eINTR) then loop ptr_dEnt else do
                let (Errno eo) = errno
                if (eo == end_of_dir)
                    then return []
                    else throwErrno "readDirStream"

rewindDirStream :: DirStream -> IO ()
rewindDirStream (DirStream dirp) = do
    c_rewinddir dirp
    return ()

closeDirStream :: DirStream -> IO ()
closeDirStream (DirStream dirp) = do
    c_closedir dirp
    return ()

-- Win32 specific

type FILETIME = CULLong -- we'll keep the accuracy as long as possible

data ProcessTimes = ProcessTimes {
  elapsedTime :: Rational
  , userTime :: Rational
  , systemTime :: Rational
  , childUserTime :: Rational
  , childSystemTime :: Rational
}

foreign import stdcall unsafe "GetProcessTimes" win32GetProcessTimes ::
  Int -> Ptr FILETIME -> Ptr FILETIME -> Ptr FILETIME -> Ptr FILETIME -> IO Int
-- relies on Int == Int32 on Windows

filetimeToSeconds :: FILETIME -> Rational
filetimeToSeconds ft = ((toInteger ft) % 10)

-- See Perl5 win32/win32.c for the complete implementation
-- that works on Windows 95 as well
getProcessTimes :: IO ProcessTimes
getProcessTimes = do
                    pid <- getProcessHandle
                    alloca $ \ pDummy  -> do
                    alloca $ \ pKernel -> do
                    alloca $ \ pUser   -> do
                      poke pDummy 0
                      poke pKernel 0
                      poke pUser 0
                      win32GetProcessTimes pid pDummy pDummy pKernel pUser
                      user    <- peek pUser
                      kernel  <- peek pKernel
                      return $ ProcessTimes 0 (filetimeToSeconds user) (filetimeToSeconds kernel) 0 0

-- This is Win32 specific, dunno about other non POSIX platforms
statFileSize :: FilePath -> IO Integer
statFileSize n = bracket (openFile n ReadMode) hClose hFileSize
-- statFileSize _ = failWith "-s"

-- Again, Win32 specific magic, as stolen from GHC
foreign import stdcall unsafe "GetCurrentProcessId" getProcessID :: IO Int -- relies on Int == Int32 on Windows
foreign import stdcall "GetCurrentProcess" getProcessHandle :: IO Int -- relies on Int == Int32 on Windows

-- getProcessID :: IO Int
-- getProcessID = return $ 1

type UserID = Int
type GroupID = Int

getRealUserID :: IO UserID
getRealUserID = return 1

getEffectiveUserID :: IO UserID
getEffectiveUserID = return 1

getRealGroupID :: IO GroupID
getRealGroupID = return 1

getEffectiveGroupID :: IO GroupID
getEffectiveGroupID = return 1

signalProcess :: Int -> Int -> IO ()
signalProcess _ _ = failWith "kill"

executeFile' :: FilePath -> Bool -> [String] -> Maybe [(String, String)] -> IO ExitCode
executeFile' prog True args Nothing = rawSystem prog args
executeFile' _ _ _ _ = failWithIncomplete "executeFile"

doesExist :: FilePath -> IO Bool
doesExist f = do
    rv <- doesFileExist f
    if rv then return rv else doesDirectoryExist f

#endif

foreign import ccall unsafe "getProgArgv"
  getProgArgv :: Ptr CInt -> Ptr (Ptr CString) -> IO ()

getArg0 :: IO String
getArg0 = do
    alloca $ \ p_argc -> do
    alloca $ \ p_argv -> do
        getProgArgv p_argc p_argv
        argv <- peek p_argv
        peekCString =<< peekElemOff argv 0

