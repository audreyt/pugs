{-# OPTIONS -fglasgow-exts -O #-}
{-# OPTIONS -#include "Linker.h" #-}

{-|

   Load and unload\/Haskell modules at runtime.  This is not really \'dynamic
   loading\', as such -- that implies that you\'re working with proper shared
   libraries, whereas this is far more simple and only loads object files.  But
   it achieves the same goal: you can load a Haskell module at runtime, load a
   function from it, and run the function.  I have no idea if this works for
   types, but that doesn\'t mean that you can\'t try it :).

   FIXME: Reformat this as a Haddock list

   To use this module:
   
   1. call the 'initialiseRuntimeLoader' function
   
   2. call 'loadObject' on the module(s) you wish to load
   
   3. call 'resolveFunctions' to make the GHC runtime system
      resolve the symbol table.  

   4. use 'loadFunction' to call the function from the module that you want to
      load
   
   The RuntimeLoader performs no dependency tracking; i.e. if you have a module
   Foo which imports a module Bar, you must manually load Foo and Bar
   before calling 'resolveFunctions'.  I don\'t /want/ the basic RuntimeLoader
   module to have any dependency tracking, since many people will not need it.
   GHC doesn\'t compile the dependency information into object files anyway, so
   it\'s quite hard to do.  In the future, I\'d imagine that a
   AdvancedRuntimeLoader module will implement this feature for you.

   Of course, the best thing would be for all this to go away and be
   replaced with a real dynamic loader :).

-}


{-

   TODO:

   * Make loadObject more intelligent about finding modules (try the given
     module name with a .o extension, etc)
   
   * Module search paths?  Uh oh ...
   
   * Get a list of all the currently loaded modules

   * Use module handles instead of direct module paths for e.g. loadFunction
   
   * There's no dlclose()?

-}

module Internals.RuntimeLoader (
   RuntimeModule,
   initialiseRuntimeLoader,	-- :: IO ()
   initializeRuntimeLoader,	-- :: IO ()
   loadObject,			-- :: FilePath -> IO RuntimeModule
   loadLibrary,		        -- :: FilePath -> IO RuntimeModule
   loadPackage,		        -- :: String -> IO ()
   unloadObject,		-- :: RuntimeModule -> IO ()
   resolveFunctions,		-- :: IO ()
   loadFunction,  	        -- :: RuntimeModule -> String -> IO (Maybe a)
) where

--import CTypes		   ( CChar )
import Directory
import GHC.Ptr             ( Ptr(..), nullPtr )
import Foreign.C.String	   ( CString, newCString, peekCString, withCString )
--import PrelByteArr
--import PrelPack	   ( packString )
import GHC.Exts		   ( addrToHValue# )
--import Ptr
import Control.Monad       ( unless, when )

data RuntimeModule = RuntimeModule
		     { path :: FilePath
		     , name :: String
		     , filetype :: ModuleFiletype
		     }

ghcLibraryPath = "undefined"
systemModulePrefix = "HS"
systemModuleExtension = ".o"

data ModuleFiletype = ObjectFile | LibraryFile

{-|

   Call the initialiseRuntimeLoader function first, before calling any of the
   other functions in this module --- otherwise you\'ll get unresolved symbols.

-}

initialiseRuntimeLoader :: IO ()
initialiseRuntimeLoader = do
   c_initLinker
-- unsafeLoadPackage "base"


{-|

   This is 'initialiseRuntimeLoader', for carbon-based lifeforms in North
   America.

-}

initializeRuntimeLoader = initialiseRuntimeLoader


{-|

   Loads a GHC package, such as \"text\" or \"lang\".

-}

loadPackage :: String -- ^ The name of the package to load
	    -> IO ()
loadPackage "std" = return ()
loadPackage packageName = unsafeLoadPackage packageName

unsafeLoadPackage :: String -> IO ()
unsafeLoadPackage packageName = do
   loadSystemModule packageName
   resolveFunctions


{-|

   Loads a \"system module\", which is a module in the GHC library directory.
   The GHC library directory is provided by the 'ghcLibraryPath' function in
   the "GHCLibraryPath" module.  If the system module has a corresponding
   \"cbits\" module, that is also loaded.

-}

loadSystemModule :: String -- ^ Name of the system module to load (e.g. \"concurrent\")
	         -> IO ()
loadSystemModule moduleName = do
   loadObject (ghcLibraryPath ++
               systemModulePrefix ++
	       moduleName ++
	       systemModuleExtension)
   let cbitsModule = ghcLibraryPath ++
                     systemModulePrefix ++
		     moduleName ++
		     "_cbits" ++
		     systemModuleExtension
   cbitsModuleExists <- doesFileExist cbitsModule
   when cbitsModuleExists (do loadObject cbitsModule; return ())


{-|

   Load a function from a module (which must be loaded and resolved first).
   Note that no type-checking is done; since this function returns a
   polymorphic type /a/, you will have to coerce the result of this function
   into the type that you think the real function should be, e.g.:

   > let foo = loadFunction "MyModule" "myFunction" :: IO (Int -> Int)

   This is very unsafe.  If you\'re really worried about what problems this
   could cause, try using dynamic types.  (See the "Dynamic" module that comes
   with GHC).

   See also 'loadObject', 'resolveFunctions'.

-}

loadFunction :: RuntimeModule -- ^ The module which the function resides in
             -> String -- ^ Name of the function you wish to load
	     -> IO a -- ^ The function you want to load
loadFunction runtimeModule functionName = do
   ptr@(~(Ptr addr)) <- findSymbol runtimeModule functionName
   when (ptr == nullPtr) (ioError e)
   case addrToHValue# addr of
        (# hval #) -> return hval
   where
      e = userError ("Couldn't find function name \"" ++ functionName ++ "\" in symbol table")

{-|

   Finds a symbol in a module.  (This is for internal use only.)

-}

findSymbol :: RuntimeModule -- ^ The module which the function resides in
	   -> String -- ^ Name of the function you wish to load
	   -> IO (Ptr a) -- ^ Pointer to the function in the module
findSymbol (RuntimeModule { name = moduleName }) functionName = do
   ptr <- withCString symbolName c_lookupSymbol
   if ptr /= nullPtr
      then
	 return ptr
      else do
	 -- XXX: on Darwin (Mac OS X), we need to prepend a _ to the symbol
         -- name.  If we fail looking for the symbol the first time, just
         -- try again ... (can you say 'ugh'?  I thought you could).  Ideally
	 -- this should be done at compile time -- maybe via Template Haskell?
	 ptr <- withCString ("_" ++ symbolName) c_lookupSymbol
	 return ptr
   where
      symbolName = moduleName ++ "_" ++ functionName ++ "_closure"

    

{-|

   Load a GHC-compiled Haskell module.  This will be a filename with a \".o\"
   extension.  (I think Windows has the same extension, although it could be
   \".obj\").  You should provide the full path to the module.  Remember to call
   'resolveFunctions' after loading all your modules, otherwise you will run into
   \"bad problems\" :).

   See also 'resolveFunctions'.

-}

loadObject :: FilePath -- ^ Path to the GHC-compiled module that you want to load
           -> IO RuntimeModule
loadObject modulePath = do
   r <- withCString modulePath c_loadObj
   unless r (ioError e)
   return (makeRuntimeModule ObjectFile modulePath)
   where
      e = userError ("Could not load module at " ++ modulePath)

makeRuntimeModule :: ModuleFiletype -> FilePath -> RuntimeModule
makeRuntimeModule t p = (RuntimeModule
                         { path = p, name = moduleName, filetype = t }
			)
   where
      -- FIXME: World's most stupid filename parsing function
      moduleName = takeWhile (/= '.') $ reverse $ takeWhile (/= '/') $ reverse p


{-|

   Resolve (link) the modules loaded by the 'loadObject' function.  You must
   call this after loading the modules you wish to load, so that the GHC
   runtime system can check to see whether all the symbols which this module
   requires are also in-memory and loaded.  Note that you can (and must)
   sometimes load more than one module with loadObject before calling
   resolveFunctions.

-}

resolveFunctions :: IO ()
resolveFunctions = do
   r <- c_resolveObjs
   unless r (ioError (userError ("resolveFunctions failed?" ++ show r)))

{-|

   Unload a module from memory.

-}

unloadObject :: RuntimeModule -- ^ Module that you wish to unload
             -> IO ()
unloadObject (RuntimeModule { path = p, filetype = t }) = do
   case t of
      (LibraryFile) -> do
         -- FIXME: Throw exception
	 return ()
      (ObjectFile) -> do
	 pCString <- newCString p
	 r <- c_unloadObj pCString
         unless r (ioError e)
         where
            e = userError ("Couldn't unload module at " ++ p)


{-|

   Load a shared library

-}

-- This be nabbed from GHC's ./compiler/ghci/InteractiveUI.hs

loadLibrary :: FilePath -> IO RuntimeModule
loadLibrary modulePath = do
   maybeErrmsg <- withCString modulePath c_addDLL
   if maybeErrmsg == nullPtr
      then return (makeRuntimeModule LibraryFile modulePath)
      -- throw exception
      else do modulePath <- peekCString maybeErrmsg
	      -- TODO: Fix up this error message
              ioError (userError ("Couldn't load library: " ++ modulePath))


{-

   C interface

-}

foreign import ccall unsafe "addDLL"
   c_addDLL :: CString -> IO CString

foreign import ccall unsafe "lookupSymbol"
   c_lookupSymbol :: CString -> IO (Ptr a)

foreign import ccall unsafe "loadObj"
   c_loadObj :: CString -> IO Bool

foreign import ccall unsafe "unloadObj"
   c_unloadObj :: CString -> IO Bool

foreign import ccall unsafe "resolveObjs"
   c_resolveObjs :: IO Bool

foreign import ccall unsafe "initLinker"
   c_initLinker :: IO ()

