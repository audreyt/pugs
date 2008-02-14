{-# OPTIONS_GHC -fglasgow-exts -fallow-overlapping-instances #-}
module Pugs.Parser.Util where

import Pugs.Internals
import Pugs.AST
import Pugs.Types
import Pugs.Lexer
import Pugs.Rule
import Pugs.Parser.Types
import qualified Data.Map as Map
import qualified Data.Set as Set

grammaticalCategories :: [String]
grammaticalCategories = ["prefix_circumfix_meta_operator:","infix_circumfix_meta_operator:","prefix_postfix_meta_operator:","postfix_prefix_meta_operator:","infix_postfix_meta_operator:","statement_modifier:","statement_control:","scope_declarator:","trait_auxiliary:","trait_verb:","regex_mod_external:","regex_mod_internal:","regex_assertion:","regex_backslash:","regex_metachar:","postcircumfix:","circumfix:","postfix:","infix:","prefix:","quote:","term:"]


retBlockWith :: (Exp -> Exp) -> BlockInfo -> RuleParser BlockInfo
retBlockWith f bi = return bi{ bi_body = f (bi_body bi) }

-- around a block body we save the package and the current lexical pad
-- at the start, so that they can be restored after parsing the body
localBlock :: RuleParser Exp -> RuleParser BlockInfo
localBlock m = do
    state   <- get

    -- XXX - Perhaps clone the protopad right here, for $_ etc?
    compPad <- newMPad (s_protoPad state)

    -- traceM $ "Gen:" ++ show compPad
    let env     = s_env state
        lexPads = (PCompiling compPad:envLexPads env)
        protoVars = Map.map (const compPad) (padEntries $ s_protoPad state)

    put state
        { s_closureTraits   = (id : s_closureTraits state)
        , s_env             = env
            { envLexPads = lexPads  -- enter the scope
            , envCompPad = Just compPad
            }
        , s_protoPad        = emptyPad
        , s_knownVars       = s_knownVars state `Map.union` protoVars
        }

    body    <- m
    state'  <- get

    -- Remove from knownVars the bindings belonging to this scope.
    let outerKnownVars = Map.filter (/= compPad) (s_knownVars state')
        outerOuterVars = Map.delete compPad (s_outerVars state')
        (traits, outerTraits) = case s_closureTraits state' of
            (t:ts)  -> (t, ts)
            _       -> (id, [])

    put state
        { s_env = (s_env state')
            { envPackage = envPackage env
            , envLexical = envLexical env
            , envLexPads = envLexPads env
            , envCompPad = envCompPad env
            }
        , s_closureTraits = outerTraits
        , s_knownVars     = outerKnownVars
        , s_outerVars     = outerOuterVars
        , s_protoPad      = emptyPad
        }

    -- Re-read compile time refs into the new protos at end of scope.
    newPad <- return $! unsafePerformSTM $! do
        curPad  <- readMPad compPad
        entries <- forM (padToList curPad) $ \(var, entry) -> do
            proto   <- readPadEntry entry
            let newEntry = entry{ pe_proto = proto }
            return (newEntry `seq` (var, newEntry))
        let newPad = listToPad (length entries `seq` entries)
        writeMPad compPad newPad
        return newPad
    return $ MkBlockInfo{ bi_pad = newPad, bi_body = body, bi_traits = traits }

ruleParamList :: ParensOption -> RuleParser a -> RuleParser (Maybe [[a]])
ruleParamList wantParens parse = rule "parameter list" $ do
    (formal, hasParens) <- f $
        (((try parse) `sepEndBy` lexeme (oneOf ",;")) `sepEndBy` invColon)
    case formal of
        [[]]   -> return $ if hasParens then Just [[], []] else Nothing
        [args] -> return $ Just [[], args]
        [_,_]  -> return $ Just formal
        _      -> fail "Only one invocant list allowed"
    where
    f = case wantParens of
        ParensOptional  -> maybeParensBool
        ParensMandatory -> \x -> do rv <- parens x; return (rv, True)
    invColon = do
        ch <- oneOf ":;"
        -- Compare:
        --   sub foo (: $a)   # vs.
        --   sub foo (:$a)
        lookAhead $ (many1 space <|> string ")")
        whiteSpace
        return ch
        
maybeParensBool :: RuleParser a -> RuleParser (a, Bool)
maybeParensBool p = choice
    [ do rv <- parens p; return (rv, True)
    , do rv <- p; return (rv, False)
    ]


{-| Wraps a call to @&Pugs::Internals::check_for_io_leak@ around the input
    expression. @&Pugs::Internals::check_for_io_leak@ should @die()@ if the
    expression returned an IO handle. -}
-- Please remember to edit Prelude.pm, too, if you rename the name of the
-- checker function.
checkForIOLeak :: VCode -> Exp
checkForIOLeak code =
    App (_Var "&Pugs::Internals::check_for_io_leak") Nothing [ Val $ VCode code ]
    
defaultParamFor :: SubType -> [Param]
defaultParamFor SubBlock    = [] -- defaultScalarParam]
defaultParamFor SubPointy   = []
defaultParamFor _           = [defaultArrayParam]

extractNamedPlaceholders :: SubType -> Maybe [Param] -> Exp -> (Exp, [Var], [Param])
extractNamedPlaceholders SubBlock formal body = (fun, names', params)
    where
    (fun, names) = extractPlaceholderVars body Set.empty
    names' | isJust formal
           = sortNames (Set.delete varTopic names)
           | otherwise
           = sortNames names
    params = map nameToParam names' ++ (maybe [] id formal)
extractNamedPlaceholders SubPointy formal body = (body, [], maybe [] id formal)
extractNamedPlaceholders SubMethod formal body = (body, [], maybe [] id formal)
extractNamedPlaceholders _ formal body = (body, names', params)
    where
    (_, names) = extractPlaceholderVars body Set.empty
    names' | isJust formal
           = sortNames (Set.delete varTopic names)
           | otherwise
           = sortNames (Set.filter (== varTopic) names)
    params = map nameToParam names' ++ (maybe [] id formal)

sortNames :: Set Var -> [Var]
sortNames = sortBy (\x y -> v_name x `compare` v_name y) . Set.toList

nameToParam :: Var -> Param
nameToParam name = MkOldParam
    { isInvocant    = False
    , isOptional    = False
    , isNamed       = False
    , isLValue      = True
    , isWritable    = (name == varTopic)
    , isLazy        = False
    , paramName     = name
    , paramContext  = CxtItem $ typeOfSigilVar name
    , paramDefault  = Noop
    }

_percentUnderscore :: Var
_percentUnderscore = cast "%_"

paramsFor :: SubType -> Maybe [Param] -> [Param] -> [Param]
paramsFor SubMethod formal params 
    | isNothing (find ((_percentUnderscore ==) . paramName) params)
    = paramsFor SubRoutine formal params ++ [defaultHashParam]
paramsFor styp Nothing []       = defaultParamFor styp
paramsFor _ _ params            = params

processFormals :: Monad m => [[Exp]] -> m (Maybe Exp, [Exp])
processFormals formal = case formal of
    []      -> return (Nothing, [])
    [args]  -> return (Nothing, unwind args)
    [invs,args] | [inv] <- unwind invs -> return (Just inv, unwind args)
    _                   -> fail "Only one invocant allowed"
    where
    unwind :: [Exp] -> [Exp]
    unwind [] = []
    unwind ((Syn "," list):xs) = unwind list ++ unwind xs
    unwind x  = x

-- | A Param representing the default (unnamed) invocant of a method on the given type.
selfParam :: Type -> Param
selfParam typ = MkOldParam
    { isInvocant    = True
    , isOptional    = False
    , isNamed       = False
    , isLValue      = True
    , isWritable    = True
    , isLazy        = False
    , paramName     = cast "$__SELF__"
    , paramContext  = CxtItem typ
    , paramDefault  = Noop
    }

hashComposerCheck :: Exp -> RuleParser Bool
hashComposerCheck exp
    | Ann (Prag [MkPrag "eol-block" _]) _ <- exp = do
        when isHash $
            fail "Closing hash curly may not terminate a line;\nplease add a comma or a semicolon to disambiguate"
        return False
    | otherwise = return isHash
    where
    isHash = doCheck (possiblyUnwrap exp)

    possiblyUnwrap (Ann _ exp) = possiblyUnwrap exp
    possiblyUnwrap (Syn "block" [exp]) = unwrap exp
    possiblyUnwrap (App (Val (VCode (MkCode { subType = SubBlock, subBody = fun }))) Nothing []) = unwrap fun
    possiblyUnwrap x = x
    
    isHashOrPair (Ann _ exp)            = isHashOrPair exp
    isHashOrPair (App (Var var) _ _)    = (var == cast "&pair") || (var == cast "&infix:=>") 
    isHashOrPair (Syn "%{}" _)          = True
    isHashOrPair (Var var)              = v_sigil var == SHash
    isHashOrPair _                      = False
    
    doCheck Noop                   = True
    doCheck (Syn "," (subexp:_))   = isHashOrPair subexp
    doCheck exp                    = isHashOrPair exp

tryLookAhead :: RuleParser a -> RuleParser b -> RuleParser a
tryLookAhead rule after = try $ do
    rv <- rule
    lookAhead after
    return rv

makeVar :: String -> Exp
makeVar (s:"<>") =
    makeVarWithSigil s $ _Var "$/"
makeVar (s:rest) | all (`elem` "1234567890") rest =
    makeVarWithSigil s $ Syn "[]" [_Var "$/", Val $ VInt (read rest)]
makeVar (s:'<':'<':name) =
    makeVarWithSigil s $ Syn "{}" [_Var "$/", doSplitStr shellWords (init (init name))]
makeVar (s:'\171':name) =
    makeVarWithSigil s $ Syn "{}" [_Var "$/", doSplitStr shellWords (init name)]
makeVar (s:'<':name) =
    makeVarWithSigil s $ Syn "{}" [_Var "$/", doSplitStr perl6Words (init name)]
makeVar var = _Var var

makeVarWithSigil :: Char -> Exp -> Exp
makeVarWithSigil '$' x = x
makeVarWithSigil s   x = Syn (s:"{}") [x]

-- | splits the string into expressions on whitespace.
-- Implements the <> operator at parse-time.
doSplitStr :: (String -> [String]) -> String -> Exp
doSplitStr f str = case f str of
    []  -> Syn "," []
    [x] -> Val (VStr x)
    xs  -> Syn "," $ map (Val . VStr) xs

perl6Words :: String -> [String]
perl6Words s
    | [] <- findSpace = []
    | otherwise       = w : words s''
    where
    (w, s'')  = break isBreakingSpace findSpace
    findSpace = dropWhile isBreakingSpace s

isBreakingSpace :: Char -> Bool
isBreakingSpace '\x09'  = True
isBreakingSpace '\x0a'  = True
isBreakingSpace '\x0d'  = True
isBreakingSpace '\x20'  = True
isBreakingSpace _       = False

followedBy, tryFollowedBy :: RuleParser a -> RuleParser b -> RuleParser a
followedBy rule after = do
    rv <- rule
    after
    return rv

tryFollowedBy = (try .) . followedBy

-- XXX - Naive implementation of << 1 '2' 3 >>, only used in $<< 'foo' >> so far

data ShellWordsState = MkShellWordsState
    { s_escape  :: Bool
    , s_quote   :: (Maybe Char)
    , s_cur     :: Maybe String
    , s_acc     :: [String]
    }

shellWords :: String -> [String]
shellWords = postProc . foldl doShellWords (MkShellWordsState False Nothing Nothing [])
    where
    doShellWords state ch
        | s_escape state
        = normalChar{ s_escape = False }
        | '\\' <- ch
        = state{ s_escape = True }
        | Just q <- s_quote state
        = if ch == q then closeQuote else normalChar
        | isBreakingSpace ch
        = nextWord
        | '"' <- ch     = beginQuote
        | '\'' <- ch    = beginQuote
        | otherwise     = normalChar
        where
        cur = s_cur state
        acc = s_acc state
        normalChar = state{ s_cur = Just (maybe [ch] (ch:) cur) }
        beginQuote = state{ s_quote = Just ch }
        closeQuote = state{ s_quote = Nothing, s_cur = Just (maybe "" id cur) }
        nextWord   = state{ s_acc = maybe acc (:acc) cur, s_cur = Nothing }
    postProc MkShellWordsState{ s_cur = cur, s_acc = acc } = reverse (map reverse acc')
        where
        acc' = maybe acc (:acc) cur
