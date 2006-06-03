module Pugs.Prim.FileTest (
    isReadable, isWritable, isExecutable,
    exists, isFile, isDirectory,
    fileSize, sizeIsZero,
) where
import Pugs.Internals
import Pugs.AST hiding (isWritable)

-- filetest operators --

-- Officially, these should return a stat object, which sometimes pretends
-- to be a boolean, and may(?) return the filename in string context.
-- DARCS was working on stat, and we should perhaps grab their work:
--  http://www.abridgegame.org/pipermail/darcs-users/2005-February/005499.html
-- They currently (2004-04-05) seem to be using:
--  http://abridgegame.org/cgi-bin/darcs.cgi/darcs/win32/System/Posix.hs
-- For the moment, these return filename and false or undef.
-- Known Bugs: multiple stat()s are done, and filename isnt a boolean.

isReadable   :: Val -> Eval Val
isReadable   = fileTestIO fileTestIsReadable
isWritable   :: Val -> Eval Val
isWritable   = fileTestIO fileTestIsWritable
isExecutable :: Val -> Eval Val
isExecutable = fileTestIO fileTestIsExecutable
exists       :: Val -> Eval Val
exists       = fileTestIO fileTestExists
isFile       :: Val -> Eval Val
isFile       = fileTestIO fileTestIsFile
isDirectory  :: Val -> Eval Val
isDirectory  = fileTestIO fileTestIsDirectory
fileSize     :: Val -> Eval Val
fileSize     = fileTestIO fileTestFileSize
sizeIsZero   :: Val -> Eval Val
sizeIsZero   = fileTestIO fileTestSizeIsZero

fileTestIO :: (Value n) => (n -> IO Val) -> Val -> Eval Val
fileTestIO f v = do
    str <- fromVal =<< fromVal' v
    tryIO undef $ f str

valFromBool :: Value a => a -> Bool -> Val
valFromBool v b = if b then castV v else VBool False

testPerms :: (Permissions -> Bool) -> FilePath -> IO Val
testPerms t f = do
    p <- getPermissions f
    let b = t p
    return $ valFromBool f b

fileTestIsReadable :: FilePath -> IO Val
fileTestIsReadable = testPerms readable

fileTestIsWritable :: FilePath -> IO Val
fileTestIsWritable = testPerms writable

fileTestIsExecutable :: FilePath -> IO Val
fileTestIsExecutable = testPerms $ liftM2 (||) executable searchable

fileTestExists :: FilePath -> IO Val
fileTestExists f = doesExist f >>= return . (valFromBool f)

fileTestIsFile :: FilePath -> IO Val
fileTestIsFile f = doesFileExist f >>= return . (valFromBool f)

fileTestIsDirectory :: FilePath -> IO Val
fileTestIsDirectory f = doesDirectoryExist f >>= return . (valFromBool f)

fileTestFileSize :: FilePath -> IO Val
fileTestFileSize f = statFileSize f >>= return . VInt

fileTestSizeIsZero :: FilePath -> IO Val
fileTestSizeIsZero f = do
    n <- statFileSize f
    return $ if n == 0 then VBool True else VBool False
