{-# OPTIONS_GHC -fglasgow-exts -cpp -fallow-overlapping-instances #-}

{-|
    External call utilities.

>   To the Sea, to the Sea! The white gulls are crying,
>   The wind is blowing, and the white foam is flying.
>   West, west away, the round sun is falling.
>   Grey ship, grey ship, do you hear them calling?
-}

module Pugs.External where
import Pugs.Internals
import Pugs.AST
import Pugs.External.Haskell (externalizeHaskell, loadHaskell)

externalize :: String -> Exp -> IO String
externalize mod stmts = externExternalize backend mod code
    where
    (backend, code)
        | null things   = error "no inline found"
        | [_] <- things = head things
        | otherwise     = error "multiple inline found"
    things = [ (backend, code)
             | (Syn "inline" [Val (VStr backend), Val (VStr code)]) <- flatten stmts
             ]
    flatten (Stmts cur rest) = (cur:flatten rest)
    flatten exp = [exp]


externExternalize :: String -> String -> String -> IO String
externExternalize "Haskell" = externalizeHaskell
externExternalize backend   = error $ "Unrecognized inline backend: " ++ backend

externLoad :: String -> FilePath -> IO [(String, [Val] -> Eval Val)]
externLoad "Haskell" = loadHaskell
externLoad backend   = error $ "Unrecognized inline backend: " ++ backend

externRequire :: String -> FilePath -> Eval ()
externRequire lang name = do
    glob        <- asks envGlobal
    bindings    <- io $ externLoad lang name
    stm $ do
        newSyms     <- mapM gen bindings
        modifyMPad glob (\pad -> combine newSyms pad)
    where
    gen (name, fun) = genSym (cast ('&':name)) . codeRef $ mkPrim
        { subName       = cast name
        , subParams     = [buildParam "List" "" "*@?1" (Val VUndef)]
        , subBody       = (Prim fun)
        }

