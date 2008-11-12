{-# OPTIONS_GHC -fglasgow-exts -cpp #-}

module Pugs.Embed.Haskell where

-- #include "../pugs_config.h"
#if !defined(PUGS_HAVE_HSPLUGINS)

import Pugs.AST

evalHaskell :: String -> Eval Val
evalHaskell _ = fail "need hs-plugins for eval_haskell"

#else

import qualified System.Eval
import Pugs.AST

evalHaskell :: String -> Eval Val
evalHaskell code = do
    let imports = []
    -- eval_ code [import] [flags] [package.confs] [load paths]
    --   -> IO (Either [error-strings] (Maybe a))
    ret <- io $ System.Eval.eval_ code imports [] [] []
    case ret of
        Right (Just x) -> return $ VStr x
        Right Nothing  -> fail "Something strange happened"
        Left x         -> fail $ unlines x

#endif
