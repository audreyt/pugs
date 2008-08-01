-----------------------------------------------------------------------------
-- |
-- Module      :  Network.Stream
-- Copyright   :  (c) Warrick Gray 2002, Bjorn Bringert 2003-2004, Simon Foster 2004, 2007 Robin Bate Boerop
-- License     :  BSD
--
-- Maintainer  :  bjorn@bringert.net
-- Stability   :  experimental
-- Portability :  non-portable (not tested)
--
-- An library for creating abstract streams. Originally part of Gray's\/Bringert's
-- HTTP module.
--
-- * Changes by Robin Bate Boerop <robin@bateboerop.name>:
--      - Removed unnecessary import statements.
--      - Moved Debug code to StreamDebugger.hs
--      - Moved Socket-related code to StreamSocket.hs.
--
-- * Changes by Simon Foster:
--      - Split Network.HTTPmodule up into to separate
--        Network.[Stream,TCP,HTTP] modules
-----------------------------------------------------------------------------
module Network.Stream
   ( Stream(..)
   , ConnError(..)
   , Result
   , bindE
   ) where

data ConnError = ErrorReset 
               | ErrorClosed
               | ErrorParse String
               | ErrorMisc String
    deriving(Show,Eq)

bindE :: Result a -> (a -> Result b) -> Result b
bindE (Left e)  _ = Left e
bindE (Right v) f = f v

-- | This is the type returned by many exported network functions.
type Result a = Either ConnError   {- error  -}
                       a           {- result -}

-- | Streams should make layering of TLS protocol easier in future,
-- they allow reading/writing to files etc for debugging,
-- they allow use of protocols other than TCP/IP
-- and they allow customisation.
--
-- Instances of this class should not trim
-- the input in any way, e.g. leave LF on line
-- endings etc. Unless that is exactly the behaviour
-- you want from your twisted instances ;)
class Stream x where 
    readLine   :: x -> IO (Result String)
    readBlock  :: x -> Int -> IO (Result String)
    writeBlock :: x -> String -> IO (Result ())
    close      :: x -> IO ()

