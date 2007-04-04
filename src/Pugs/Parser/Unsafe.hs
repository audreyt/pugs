{-# OPTIONS_GHC -fglasgow-exts -fno-full-laziness -fno-cse #-}

-- possibly this needs to be beside the AST or Eval, not the Parser
module Pugs.Parser.Unsafe (
    unsafeEvalLexDiff,
    unsafeEvalEnv,
    unsafeEvalExp,
    possiblyApplyMacro,
) where
import Pugs.Internals
import Pugs.AST
import Pugs.Pretty
import Pugs.Parser.Types
import Pugs.Parser.Util
import Pugs.Eval.Var
import Pugs.Types
import Pugs.Rule
import DrIFT.YAML ()

unsafeEvalLexDiff :: Exp -> RuleParser Pad
unsafeEvalLexDiff exp = do
    env  <- getRuleEnv
    putRuleEnv env{ envLexical = mkPad [] }
    env' <- unsafeEvalEnv exp
    putRuleEnv env'{ envLexical = envLexical env' `unionPads` envLexical env }
    return $ envLexical env'

-- XXX: Should these fail instead of error?
unsafeEvalEnv :: Exp -> RuleParser Env
unsafeEvalEnv exp = do
    -- pos <- getPosition
    env <- getRuleEnv
    val <- unsafeEvalExp $ mergeStmts exp (Syn "continuation" [])
    case val of
        Val (VControl (ControlContinuation { ccEnv = env' })) ->
            return env'{ envDebug = envDebug env }
        _  -> error $ pretty val

{-# NOINLINE unsafeEvalExp #-}
unsafeEvalExp :: Exp -> RuleParser Exp
unsafeEvalExp exp = do
    -- clearDynParsers
    env <- getRuleEnv
    let val = unsafePerformIO $ do
        runEvalIO env $ do
            evl <- asks envEval
            evl exp
    case val of
        VError{} -> error $ pretty (val :: Val)
        _        -> return $ Val val

{-# NOINLINE possiblyApplyMacro #-}
{-| @possiblyApplyMacro@ takes an @Exp@ containg only an @App@. It then checks
    if the code to be executed is a reference to a macro. If it is, the macro
    is executed now, i.e. during compile-time. The return value of the macro is
    then processed accordingly (i.e. a return value of type @Str@ will be
    parsed, and a @Code@ will be executed during runtime).
-}
possiblyApplyMacro :: Exp            -- ^ The @Exp@ containg only an @App@ to
                                     --   check if it calls a macro
                   -> RuleParser Exp -- ^ The result expression (either the
                                     --   original one or the result of
                                     --   applying the macro)
possiblyApplyMacro app@(App (Var name) invs args) = do
    -- First, we've to resolve name to a vcode.
    env <- getRuleEnv
    -- Note that we don't have to clearDynParsers, as we just do a variable
    -- lookup here.
    subCode <- return $! unsafePerformIO $! runEvalIO env $! do
        res <- findVar name
        maybe (return undef) readRef res
    case subCode of
        -- If we found a Code var, possibly process it further.
        VCode vcode -> possiblyApplyMacro' vcode app
        -- Else, return the original expression.
        _ -> return app
    where
    {-# NOINLINE possiblyApplyMacro' #-}
    possiblyApplyMacro' :: VCode -> Exp -> RuleParser Exp
    possiblyApplyMacro' vcode app
        | SubMacro <- subType vcode
        = do
            -- The vcode is a macro! Apply it and substitute its return value.
            ret <- unsafeEvalExp $! App (Val $ VCode vcode{ subType = SubRoutine }) invs args
            -- local (maybe id const (subEnv vcode)) $ 
            substMacroResult ret
        | otherwise
        = return app
    {-# NOINLINE substMacroResult #-}
    substMacroResult :: Exp -> RuleParser Exp
    -- An AST is spliced
    substMacroResult (Val (VObject o)) | objType o == mkType "Code::Exp" = do
        return $! fromObject o
    -- A Str should be (re)parsed.
    substMacroResult (Val (VStr code)) = fmap bi_body . localBlock $ do
        parseProgram <- gets s_parseProgram
        env          <- ask
        pos          <- getPosition
        case envBody (parseProgram env ("MACRO { " ++ show pos ++" }") code) of
            Val (err@VError{})  -> fail $ pretty err
            exp                 -> return exp
    -- A Code does not need to be parsed, so simply return the equivalent of
    --  $code().
    substMacroResult code@(Val (VCode _)) = do
        return $! App code Nothing []
    substMacroResult (Val (VUndef)) = return emptyExp
    substMacroResult _ = fail "Macro did not return an AST, a Str or a Code!"
possiblyApplyMacro x = return x
