{-# OPTIONS -fglasgow-exts -cpp #-}

{-
    Online help and banner text.

    But if of ships I now should sing,
    what ship would come to me,
    What ship would bear me ever back
    across so wide a Sea?
-}

#define PUGS_VERSION "6"
#define PUGS_DATE ""
#define PUGS_SVN_REVISION "0"
#include "config.h"
#include "version.h"

module Help (printHelp, banner, versnum, version, 
             copyright, disclaimer, intro) where

printHelp :: IO ()
printHelp
   = do putStrLn "Commands available from the prompt:"
        putStrLn ":h              = show this help message"
        putStrLn ":q              = quit"
        putStrLn ". <exp>         = show the syntax tree of an expression"
        putStrLn "? <exp>         = evaluate an expression in small steps"
        putStrLn "<exp>           = evaluate an expression"
{-
        putStrLn ":l <filename>   = load a pugs file (need quotes around the name)" 
        putStrLn ":r              = reload the current file"
-}

name       = "Perl6 User's Golfing System"
versnum    = PUGS_VERSION
date	   = PUGS_DATE
version    = name ++ ", version " ++ versnum ++ ", " ++ date ++ revision
copyright  = "Copyright 2005 by Autrijus Tang"
revision
    | rev <- show(PUGS_SVN_REVISION :: Integer)
    , rev /= "0"
    = " (r" ++ rev ++ ")"
    | otherwise
    = ""
disclaimer =
    "This software is distributed under the terms of the " ++
    "GNU Public Licence.\n" ++
    "NO WARRANTY WHATSOEVER IS PROVIDED. " ++
    "See the details in the documentation."

versionFill n = fill ++ vstr
    where
    fill = replicate (n - vlen) ' '
    vlen = length vstr
    vstr = "Version: " ++ versnum ++ revision

banner :: IO ()
banner = putStrLn $ unlines
    [ ".=====. __  __  ____   ___    _________________________________________"
    , "||   || ||  || ||  || ||__'   Pugs 6: Based on the Perl 6 Synopses     "
    , "||====' ||__|| ||__||  __||   " ++ copyright
    , "||      `===='  ___|| `==='   World Wide Web: http://autrijus.org/pugs "
    , "||             `===='         Report bugs to: autrijus@autrijus.org    "
    , "==" ++ versionFill 27 ++        " ====================================="
    ]

intro :: IO ()
intro = putStrLn $ unlines
    [ "Welcome to Pugs -- " ++ name
    , "Type :h for help"
    ]
