{-# OPTIONS_GHC -fglasgow-exts -cpp #-}

{-|
    Online help and banner text.

>   But if of ships I now should sing,
>   what ship would come to me,
>   What ship would bear me ever back
>   across so wide a Sea?
-}

#include "pugs_config.h"

module Pugs.Help (printInteractiveHelp, printCommandLineHelp,
             banner, versnum, version, revnum,
             copyright, intro) where
import Pugs.Version
import Pugs.CodeGen (backends)
import Data.List (sort)

printInteractiveHelp :: IO ()
printInteractiveHelp
   = do putStrLn "Commands available from the prompt:"
        putStrLn ":h              = show this help message"
        putStrLn ":q              = quit"
        putStrLn ":r              = reset the evaluation environment"
        putStrLn ":l <filename>   = load a pugs file"
        putStrLn ":d <exp>        = show syntax tree of an expression"
        putStrLn ":D <exp>        = show raw syntax tree of an expression"
        putStrLn ":e <exp>        = run a command, and ugly-print the result"
        putStrLn ":er <exp>       = same, in a pristine environment"
        putStrLn ":E <exp>        = same, but evaluate in small steps"
        putStrLn ":ER <exp>       = same, in a pristine environment"
        putStrLn "<exp>           = run a command"

{- FIXME: Somebody with more UI skillz should make this nicer -}
printCommandLineHelp :: IO ()
printCommandLineHelp
   = do putStrLn "Usage: pugs [switches] [programfile] [arguments]"
        putStrLn "Command-line flags:"
        putStrLn "-e program       one line of program (several -e's allowed, omit programfile)"
        putStrLn "-n               wrap the -e fragments in a 'while(=<>){...}' loop"
        putStrLn "-p               wrap the -e fragments in a 'while(=<>){...;say}' loop"
        putStrLn "-c               parse the file or -e, but do not run it"
        putStrLn "-d               run the program with debug tracing"
        putStrLn "-Bbackend        execute using the compiler backend"
        putStrLn "-Cbackend        compile using the compiler backend"
        putStrLn "-Mmodule         execute 'use module' before running the program"
        putStrLn "-Ipath           add path to module search paths in @*INC"
        putStrLn ("                 (valid backends are: " ++ backendsStr ++ ")")
        putStrLn "-h or --help     give this message"
        putStrLn "-V               long configuration information & version"
        putStrLn "-V:item          short configuration information for item"
        putStrLn "-v or --version  version"
        putStrLn "-l and -w are ignored for compatibility with Perl 5"
        putStrLn "See documentation of pugs::run for more help."
    where
    backendsStr = foldr1 addComma $ sort ("JS":backends)
    addComma w s = w ++ (',':' ':s)

versionFill :: Int -> String
versionFill n = fill ++ vstr
    where
    fill = replicate (n - vlen) ' '
    vlen = length vstr
    vstr = "Version: " ++ versnum ++ revision

banner :: IO ()
banner = putStrLn $ unlines
    [ "   ______                                                           "
    , " /\\   __ \\                                                        "
    , " \\ \\  \\/\\ \\ __  __  ______  ______     (P)erl6                 "
    , "  \\ \\   __//\\ \\/\\ \\/\\  __ \\/\\  ___\\    (U)ser's           "
    , "   \\ \\  \\/ \\ \\ \\_\\ \\ \\ \\/\\ \\ \\___  \\   (G)olfing      "
    , "    \\ \\__\\  \\ \\____/\\ \\____ \\/\\_____\\  (S)ystem           "
    , "     \\/__/   \\/___/  \\/___/\\ \\/____/                           "
    , "                       /\\____/   " ++ versionFill 27
    , "                       \\/___/    " ++ copyright
    , "--------------------------------------------------------------------"
    , " Web: http://pugscode.org/           Email: perl6-compiler@perl.org "
    ]

intro :: IO ()
intro = putStrLn $ unlines
    [ "Welcome to Pugs -- " ++ name
    , "Type :h for help."
    ]
