{-# LANGUAGE CPP, FlexibleInstances, ScopedTypeVariables #-}

module Main where

------------------------------------------------------------------------------
-- Haskell imports
import Control.Monad.IO.Class ( liftIO )
import Control.Monad.Trans.Reader ( ask, ReaderT, runReaderT )
import Control.Monad.Trans.State ( evalState )

-- import Control.Monad.Trans
import Data.List
import Data.Map ( Map )
import qualified Data.Map as Map
-- import Data.Maybe

import Prelude hiding ( print, putStr, putStrLn )

import System.Environment
import System.Exit

------------------------------------------------------------------------------
-- Agda library imports
import Agda.Syntax.Abstract ( ModuleName )
import Agda.Syntax.Common ( RoleATP )
import Agda.Syntax.Internal ( Type )

import Agda.TypeChecking.Monad.Base
    ( Definition
    , Definitions
    , defType
    , Interface
    )

import Agda.Utils.Impossible ( catchImpossible
                             , Impossible(..)
                             , throwImpossible
                             )
import qualified Agda.Utils.IO.Locale as LocIO

------------------------------------------------------------------------------
-- Local imports
-- import FOL.Pretty
import Common.Types ( HintName, PostulateName )
import FOL.Monad ( initialVars )
import FOL.Translation
import FOL.Types
import MyAgda.Interface
    ( getAxiomsATP
    , getImportedModules
    , getInterface
    , getTheoremsATP
    )
import MyAgda.Syntax.Abstract.Name ( moduleNameToFilePath )
import Options ( parseOptions )
import Reports ( R, reportLn )
import TPTP.Files
import TPTP.Monad
import TPTP.Translation
import TPTP.Types ( AnnotatedFormula )

#include "undefined.h"

------------------------------------------------------------------------------

-- We translate the ATP pragma axioms in an interface file to FOL formulas.
axiomsToFOLs :: Interface -> R [AnnotatedFormula]
axiomsToFOLs i = do

  opts <- ask

  -- We get the ATP pragmas axioms
  let axiomsDefs :: Definitions
      axiomsDefs = getAxiomsATP i
  reportLn "axiomsToFOLs" 20 $ "Axioms:\n" ++ (show $ Map.keys axiomsDefs)

  -- We get the types of the axioms.
  let axiomsTypes :: Map PostulateName Type
      axiomsTypes = Map.map defType axiomsDefs
  reportLn "axiomsToFOLs" 20 $ "Axioms types:\n" ++ (show axiomsTypes)

  -- The axioms types are translated to FOL formulas.
  formulas <- liftIO $
              mapM (\ty -> runReaderT
                             (runReaderT (typeToFormula ty) initialVars) opts)
                   (Map.elems axiomsTypes)

  -- The axioms are associated with their FOL formulas.
  let axiomsFormulas :: Map PostulateName Formula
      axiomsFormulas = Map.fromList $ zip (Map.keys axiomsTypes) formulas
  reportLn "axiomsToFOLs" 20 $ "FOL formulas:\n" ++ (show axiomsFormulas)

  let afs :: [AnnotatedFormula]
      afs = evalState
              (mapM (\(aName, formula) ->
                       (postulateToTPTP aName "axiom" formula))
                    (zip (Map.keys axiomsFormulas)
                         (Map.elems axiomsFormulas)))
              initialNames
  reportLn "axiomsToFOLs" 20 $ "TPTP formulas:\n" ++ (show afs)

  return afs

-- We translate the ATP pragma theorems in an interface file to FOL formulas.
-- ToDo: Unify with 'axiomsToFOLs'
theoremsToFOLs :: Interface -> R [AnnotatedFormula]
theoremsToFOLs i = do

  opts <- ask

  -- We get the ATP pragmas theorems
  let theoremsDefs :: Definitions
      theoremsDefs = getTheoremsATP i
  reportLn "theoremsToFOLs" 20 $ "Theorems:\n" ++ (show $ Map.keys theoremsDefs)

  -- We get the types of the theorems.
  let theoremsTypes :: Map PostulateName Type
      theoremsTypes = Map.map defType theoremsDefs
  reportLn "theoremsToFOLs" 20 $ "Theorems types:\n" ++ (show theoremsTypes)

  -- The theorems types are translated to FOL formulas.
  formulas <- liftIO $
              mapM (\ty -> runReaderT
                             (runReaderT (typeToFormula ty) initialVars) opts)
                   (Map.elems theoremsTypes)

  -- The theorems are associated with their FOL formulas.
  let theoremsFormulas :: Map PostulateName Formula
      theoremsFormulas = Map.fromList $ zip (Map.keys theoremsTypes) formulas
  reportLn "theoremsToFOLs" 20 $ "FOL formulas:\n" ++ (show theoremsFormulas)

  let afs :: [AnnotatedFormula]
      afs = evalState
              (mapM (\(tName, formula) ->
                       (postulateToTPTP tName "theorem" formula))
                    (zip (Map.keys theoremsFormulas)
                         (Map.elems theoremsFormulas)))
              initialNames
  reportLn "theoremsToFOLs" 20 $ "TPTP formulas:\n" ++ (show afs)

  return afs

translation :: Interface -> R ()
translation i = do

  -- We translate the ATP pragma axioms of current module and of all
  -- the imported modules.

  let importedModules :: [ModuleName]
      importedModules = getImportedModules i

  ( is :: [Interface] ) <-
      liftIO $ mapM getInterface (map moduleNameToFilePath importedModules)

  ( axiomsAFss :: [[AnnotatedFormula]] ) <- mapM axiomsToFOLs (i : is)

  -- We translate the ATP pragma theorems of current module.

  ( theoremsAFs :: [AnnotatedFormula] ) <- theoremsToFOLs i

  -- We create the TPTP files.
  liftIO $ createFilesTPTP $ (concat axiomsAFss ++ theoremsAFs)

runAgdaATP :: IO ()
runAgdaATP = do
  prgName <- getProgName
  argv <- getArgs --fmap head $ liftIO getArgs

  -- Reading the command line options.
  (opts, names) <- parseOptions argv prgName

  -- Gettting the interface.
  i <- getInterface $ head names

  -- runReaderT (postulatesToFOLs i) opts
  runReaderT (translation i) opts

main :: IO ()
main = catchImpossible runAgdaATP $
         \e -> do LocIO.putStr $ show e
                  exitFailure
