{-# OPTIONS_GHC -fglasgow-exts #-}
module Pugs.Prim.Eval (
    -- used by Pugs.Prim
    op1EvalHaskell, op1EvalP6Y,
    opEval, opEvalFile,
    opRequire, requireInc,
    EvalError(..), EvalResult(..), EvalStyle(..),
    -- used by Pugs.Eval -- needs factored somewhere bettwen
    retEvalResult,
) where
import Pugs.AST
import Pugs.Parser.Program
import Pugs.Embed
import Pugs.Monads
import Pugs.Internals
import Pugs.Pretty
import Pugs.Config
import Pugs.Prim.Keyed
import DrIFT.YAML
import Data.Yaml.Syck

data EvalError = EvalErrorFatal
               | EvalErrorUndef
               deriving Eq
data EvalResult = EvalResultLastValue
                | EvalResultModule
                | EvalResultEnv
                deriving Eq
data EvalStyle = MkEvalStyle
               { evalError  :: EvalError
               , evalResult :: EvalResult
               }


specialPackageNames :: [String]
specialPackageNames = ["MY", "OUR", "GLOBAL", "OUTER", "CALLER", "ENV", "SUPER", "COMPILING"]

opRequire :: Bool -> Val -> Eval Val
opRequire dumpEnv v = do
    mod         <- fromVal v
    if elem mod specialPackageNames then return (VBool True) else do
    incs        <- fromVal =<< readVar "@*INC"
    glob        <- askGlobal
    seen        <- findSymRef "%*INC" glob
    loaded      <- existsFromRef seen v
    let file    = (concat $ intersperse (getConfig "file_sep") $ split "::" mod) ++ ".pm"
    pathName    <- requireInc incs file (errMsg file incs)
    if loaded then opEval style pathName "" else do
        -- %*INC{mod} = { relname => file, pathname => pathName }
        evalExp $ Syn "="
            [ Syn "{}"             -- subscript
                [ Var "%*INC", Val . VStr $ decodeUTF8 mod ]
                , Syn "\\{}"       -- hashref
                    [ Syn "," [ mkStrPair "fullpath" (decodeUTF8 pathName)
                              , mkStrPair "relpath"  (decodeUTF8 file) ]
                    ]
            ]
        -- merge @*END here
        endAV   <- findSymRef "@*END" glob
        ends    <- fromVal =<< readRef endAV
        clearRef endAV
        rv <- tryFastEval (pathName ++ ".yml") $
                slowEval pathName
        endAV'  <- findSymRef "@*END" glob
        doArray (VRef endAV') (`array_unshift` ends)
        return rv
    where
    tryFastEval pathName' fallback = do
        ok <- liftIO $ doesFileExist pathName'
        if not ok then fallback else do
        rv <- resetT $ fastEval (pathName')
        case rv of
            VError _ [MkPos{posName=""}] -> fallback
            _                            -> opEval style pathName' ""
        
        
    fastEval = op1EvalP6Y . VStr
    slowEval pathName' = do 
        str      <- liftIO $ readFile pathName'
        opEval style pathName' (decodeUTF8 str)
    style = MkEvalStyle
        { evalError  = EvalErrorFatal
        , evalResult = (if dumpEnv == True then EvalResultEnv
                                           else EvalResultLastValue)}
    errMsg file incs = "Can't locate " ++ file ++ " in @*INC (@*INC contains: " ++ unwords incs ++ ")."
    mkStrPair :: String -> String -> Exp
    mkStrPair key val = App (Var "&infix:=>") Nothing (map (Val . VStr) [key, val])

requireInc :: (MonadIO m) => [FilePath] -> FilePath -> String -> m String
requireInc [] _ msg = fail msg
requireInc (p:ps) file msg = do
    let pathName  = p ++ (getConfig "file_sep") ++ file
    ok <- liftIO $ doesFileExist pathName
    if (not ok)
        then requireInc ps file msg
        else return pathName

opEvalFile :: String -> Eval Val
opEvalFile filename = do
    ok <- liftIO $ doesFileExist filename
    if (not ok)
        then fail $ "Can't locate " ++ filename ++ "."
        else do
            contents <- liftIO $ readFile filename
            opEval style filename $ decodeUTF8 contents
    where
    style = MkEvalStyle{ evalError=EvalErrorUndef
                       , evalResult=EvalResultLastValue}

op1EvalHaskell :: Val -> Eval Val
op1EvalHaskell cv = do
    str     <- fromVal cv
    val     <- resetT $ evalHaskell str
    retEvalResult style val
    where
    style = MkEvalStyle{ evalError=EvalErrorUndef
                       , evalResult=EvalResultLastValue}

op1EvalP6Y :: Val -> Eval Val
op1EvalP6Y fileName = do
    fileName' <- fromVal fileName
    yml  <- liftIO $ (`catch` (return . Left . show)) $
        fmap Right (parseYamlFile fileName')
    case yml of
        Right MkNode{ n_elem=ESeq (v:_) }
            | MkNode{ n_elem=EStr vnum } <- v
            , vnum /= (packBuf $ show compUnitVersion) -> do
                err "incompatible version number for compilation unit"
        Right yml' -> do
            globTVar    <- asks envGlobal
            MkCompUnit _ glob ast <- liftIO $ fromYAML yml'
            resetT $ do
                -- Inject the global bindings
                liftSTM $ do
                    glob' <- readTVar globTVar
                    writeTVar globTVar (glob `unionPads` glob')
                evl <- asks envEval
                evl ast
        x -> err x
    where
    err x = local (\e -> e{ envPos = (envPos e){ posName="" } }) $
        fail $ "failed loading Yaml: " ++ show x

opEval :: EvalStyle -> FilePath -> String -> Eval Val
opEval style path str = enterCaller $ do
    env <- ask
    let env' = parseProgram env path str
        trans = case evalResult style of
            EvalResultEnv -> (`mergeStmts` Syn "env" [])
            _             -> id
    val <- resetT $ local (const env') $ do
        evl <- asks envEval
        evl (trans $ envBody env')
    retEvalResult style val

retEvalResult :: EvalStyle -> Val -> Eval Val
retEvalResult style val = do
    glob <- askGlobal
    errSV <- findSymRef "$!" glob
    case val of
        err@(VError e _) -> do
            writeRef errSV e
            when (evalError style == EvalErrorFatal) $ do
                liftIO $ fail $ pretty err
            retEmpty
        _ -> do
            writeRef errSV VUndef
            return val

