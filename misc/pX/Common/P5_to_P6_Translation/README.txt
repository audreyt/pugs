General Information on this directory/project:

Perl 5 to Perl 6 Translation
Sage LaTorra
Google Summer of Code 2006

To build the translator, use 
  $ make
 or 
  $ ghc --make -o translate ASTTranslate.hs
(the Makefile is actually just an alias for this command). To build Sage's working copy, just
  $ make sage
which will make based on ASTTranslate-sage.hs, which may be newer but also less stable.

Useage for the resulting translator:
  $./translate [-Oo -V -U -R] inFile outFile
the -Oo, -U and -V switches are optional, and have these effects:

-Oo: Heavy object orientation. If there's an available (but optional) Oo translation it does it, such as translating close($fh) to $fh.close.

-V: Verbose. The translator prints the entire translated AST to STDOUT. Useful for debugging small programs, but not much else. For long files, echoing the entire tree to STDOUT may take more time then parsing.

-U: Unknown Debug. Whenever an unknown node is encountered during printing, prints "UnknownAbs" or "UnknownLit" to the file every place an unknown node is encountered. Also Echoes "UNKNOWN: UnknownAbs" or "UNKNOWN: UnknownLit" to STDOUT every time an unknown is encountered.

-R: Limited Regex Support. The only changes made to regexs will be adding the :Perl5 modifer (and moving existing modifiers into the regex, since tail modifiers are no longer allowed). Captures are also explicity aliased, so the regex _should_ work just like Perl 5.


Any changes and comments are welcome to anything in this directory, except ASTTranslate-Sage.hs which is my personal working copy, should I need it. Everything else is up for grabs.

Description of files:

AST_Description.txt - A description of the AST produced by Larry Wall's P5 parser. The info in this file is both to help me remember what's going on and to aid anybody else picking up development.

ASTDefinition.hs - Haskell module defining a Perl 5 AST. Used by just about every other module
in this directory.

ASTParser.hs - Haskell module for parsing a yaml file containing a P5AST as created by
the MADSKILLS parser. Uses Parsec (which shouldn't be a problem as Parsec comes with ghc).

ASTTranslate.hs - Haskell main module for translating an AST. The most important stuff happens here. To build it, use the Makefile or
     $ ghc --make -o translate ASTTranslate.hs

ASTTranslate-Sage.hs - My working copy.

ASTUtils.hs - Module that contains functions that make everything else cleaner and easier to read.

ConversionStageOne.txt - A description of the translations I'm trying to accomplish in the first stage of this project. I'll try to keep it updated so that finished translations are marked as such.

NodeGrabber.pl - A simple program to grab nodetypes or find nodes of a given type. Mostly just a development tool, but included for completeness.

Test.pl - My test script. Useage is:
    $ perl Test.pl [PATH]
to run a compiled version stored at PATH (which is optional). It can also be run as
    $ perl Test.pl -i [PATH]
which runs ghc seperately for each test. This option is very slow, but it is useful when the code does not compile (such as on Intel Macs without special consideration).

TestInit.pm - This is a sample output of the reconstructed, P6 version of TestInit.pm from the /t directory of the P5 source. It's not fully P6 (yet), but it's supposed to show what progress I've/We've made.

TestInit.pm.yaml - The AST output of Larry's parser. This is the first sample input I'm working on. I have parsed versions of the rest of /t, but for now this is my main test file.

translate.hs - DEPRECATED. Everything from this file was moved to modules to make everything cleaner and easier to use.

translate-sage.hs - DEPRECATED. Everything from this file was moved to modules to make everything cleaner and easier to use.


