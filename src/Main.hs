{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

------------------------------------------------------------------------------
-- Haskell imports
import Control.Monad ( when, zipWithM )
import Control.Monad.IO.Class ( liftIO )
import Control.Monad.Trans.Reader ( ask, ReaderT, runReaderT )

-- import Control.Monad.Trans
import Data.Map ( Map )
import qualified Data.Map as Map
-- import Data.Maybe

import System.Environment
import System.Exit

------------------------------------------------------------------------------
-- Agda library imports
import Agda.Syntax.Abstract.Name ( ModuleName, QName(..) )
import Agda.Syntax.Common ( RoleATP(..) )
import Agda.Syntax.Internal ( Clause, Type )

import Agda.TypeChecking.Monad.Base
    ( Definition
    , Definitions
    , defType
    , Interface(iImportedModules, iModuleName)
    )

import Agda.Utils.Impossible ( catchImpossible
                             , Impossible(..)
                             , throwImpossible
                             )
-- import qualified Agda.Utils.IO.Locale as LocIO

------------------------------------------------------------------------------
-- Local imports
-- import FOL.Pretty
import FOL.Monad ( iVarNames )
import FOL.Translation.SymbolDefinitions ( symDefToFormula )
import FOL.Translation.Types ( typeToFormula )
import FOL.Types ( FormulaFOL )
import MyAgda.Interface
    ( getClauses
    , getConjectureHints
    , getInterface
    , getQNameDefinition
    , getRoleATP
    )
import MyAgda.Syntax.Abstract.Name ( moduleNameToFilePath )
import Options ( Options(optHelp, optVersion), parseOptions, usage )
import Reports ( R, reportS, reportSLn )
import TPTP.Files ( createAxiomsFile, createConjectureFile )
import TPTP.Translation ( toAF )
import TPTP.Types ( AnnotatedFormula )
import Utils.IO ( bye )
import Utils.Version ( version )

#include "undefined.h"

------------------------------------------------------------------------------

-- We translate the ATP axioms and general hints in an
-- interface file to FOL formulas.
axiomsAndHintsToFOLs :: Interface -> R [AnnotatedFormula]
axiomsAndHintsToFOLs i = do

  opts <- ask

  -- We get the ATP axioms
  let axiomsDefs :: Definitions
      axiomsDefs = getRoleATP AxiomATP i
  reportSLn "axiomsAndHintsToFOLs" 20 $
               "Axioms:\n" ++ show (Map.keys axiomsDefs)

  -- We get the ATP general hints
  let hintsDefs :: Definitions
      hintsDefs = getRoleATP HintATP i
  reportSLn "axiomsAndHintsToFOLs" 20 $ "Hints:\n" ++ show (Map.keys hintsDefs)

  -- ToDo: What happen when are duplicates keys?
  let axiomsAndHintsDefs :: Definitions
      axiomsAndHintsDefs = Map.union axiomsDefs hintsDefs

  -- We get the types of the axioms/hints.
  let axiomsAndHintsTypes :: Map QName Type
      axiomsAndHintsTypes = Map.map defType axiomsAndHintsDefs
  reportSLn "axiomsAndHintsToFOLs" 20 $
               "Axioms/hints types:\n" ++ show axiomsAndHintsTypes

  -- The axioms/hints types are translated to FOL formulas.
  formulas <- liftIO $
    mapM (\ty -> runReaderT
                   (runReaderT (typeToFormula ty) iVarNames) opts)
         (Map.elems axiomsAndHintsTypes)

  -- The axioms/hints are associated with their FOL formulas.
  let axiomsAndHintsFormulas :: Map QName FormulaFOL
      axiomsAndHintsFormulas = Map.fromList $
                               zip (Map.keys axiomsAndHintsTypes) formulas
  reportSLn "axiomsAndHintsToFOLs" 20 $
               "FOL formulas:\n" ++ show axiomsAndHintsFormulas

  -- The FOL formulas are translated to annotated formulas
  let afs :: [AnnotatedFormula]
      afs = map (\(ahName, formula) -> (toAF ahName AxiomATP formula))
                (zip (Map.keys axiomsAndHintsFormulas)
                     (Map.elems axiomsAndHintsFormulas))
  -- reportSLn "axiomsAndHintsToFOLs" 20 $ "TPTP formulas:\n" ++ prettyTPTP afs

  return afs

-- We translate the ATP pragma conjectures and their hints in an
-- interface file to FOL formulas. For each conjecture we return its
-- tranlation and a list of the translatation of its hints, i.e. we
-- return a pair ( AnnotatedFormula, [AnnotatedFormula] ).
conjecturesToFOLs :: Interface -> R [ (AnnotatedFormula, [AnnotatedFormula]) ]
conjecturesToFOLs i = do

  opts <- ask

  -- We get the ATP pragmas conjectures
  let conjecturesDefs :: Definitions
      conjecturesDefs = getRoleATP ConjectureATP i
  reportSLn "conjecturesToFOLs" 20 $
    "Conjectures:\n" ++ show (Map.keys conjecturesDefs)

  -- We get the types of the conjectures.
  let conjecturesTypes :: Map QName Type
      conjecturesTypes = Map.map defType conjecturesDefs
  reportSLn "conjecturesToFOLs" 20 $
               "Conjectures types:\n" ++ show conjecturesTypes

  -- The conjectures types are translated to FOL formulas.
  formulas <- liftIO $
              mapM (\ty -> runReaderT
                             (runReaderT (typeToFormula ty) iVarNames) opts)
                   (Map.elems conjecturesTypes)

  -- The conjectures are associated with their FOL formulas.
  let conjecturesFormulas :: Map QName FormulaFOL
      conjecturesFormulas =
          Map.fromList $ zip (Map.keys conjecturesTypes) formulas
  reportSLn "conjecturesToFOLs" 20 $
               "FOL formulas:\n" ++ show conjecturesFormulas

  -- We translate the hints associated with each ATP pragma conjecture to
  -- TPTP formulas.
  ( hintsAFss :: [[AnnotatedFormula]] ) <-
      mapM conjecturaHintsToFOLs $ Map.elems conjecturesDefs

  -- We translate the FOL formula associated with each ATP pragma
  -- conjecture to a annotated formula.
  let afs :: [AnnotatedFormula]
      afs = map (\(tName, formula) -> (toAF tName ConjectureATP formula))
                (zip (Map.keys conjecturesFormulas)
                     (Map.elems conjecturesFormulas))
  -- reportSLn "conjecturesToFOLs" 20 $ "TPTP formulas:\n" ++ (prettyTPTP afs)

  return $ zip afs hintsAFss

-- We translate an hint to a FOL formula.
conjectureHintToFOL :: QName -> R AnnotatedFormula
conjectureHintToFOL hName = do

  opts <- ask

  (i :: Interface) <- liftIO $
                      getInterface $ moduleNameToFilePath $ qnameModule hName

  let hDef :: Definition
      hDef = case getQNameDefinition i hName of
               Just _hDef -> _hDef
               Nothing   -> __IMPOSSIBLE__

  let hType :: Type
      hType =  defType hDef

  formula <- liftIO $ runReaderT
                        (runReaderT (typeToFormula hType) iVarNames) opts

  let af :: AnnotatedFormula
      af = toAF hName AxiomATP formula

  return af

-- We translate the hints of an ATP conjecture to FOL formulas.
-- Invariant: The Definition should be an ATP pragma conjecture
conjecturaHintsToFOLs :: Definition -> R [AnnotatedFormula]
conjecturaHintsToFOLs conjectureDef = do

  let hints :: [QName]
      hints = getConjectureHints conjectureDef
  reportSLn "hintsToFOLs" 20 $
    "The hints for the conjecture " ++ show conjectureDef ++
    " are " ++ show hints

  ( afs :: [AnnotatedFormula] ) <- mapM conjectureHintToFOL hints

  return afs

-- We translate the ATP definitions in an interface file to FOL
-- formulas.
symbolsToFOLs :: Interface -> R [AnnotatedFormula]
symbolsToFOLs i = do

  opts <- ask

  -- We get the ATP definitions
  let symDefs :: Definitions
      symDefs = getRoleATP DefinitionATP i
  reportSLn "symbolsToFOLs" 20 $
               "Symbols:\n" ++ show (Map.keys symDefs)

  -- We get the clauses that define the symbol
  -- (All the symbols must be functions)
  let symClauses :: Map QName [Clause]
      symClauses = Map.map getClauses symDefs
  reportSLn "symbolsToFOLs" 20 $
               "Symbols' clauses:\n" ++ show symClauses

  -- The symbols' definitions are translated to FOL formulas.
  formulas <- liftIO $
    zipWithM (\(qname :: QName) (cls :: [Clause]) ->
                  runReaderT
                    (runReaderT (symDefToFormula qname cls) iVarNames) opts)
             (Map.keys symClauses)
             (Map.elems symClauses)

  reportSLn "symbolsToFOLs" 20 $
               "FOL formulas:\n" ++ show formulas

  -- The symbols' definitions are associated with their FOL formulas.
  let symFormulas :: Map QName FormulaFOL
      symFormulas = Map.fromList $
                               zip (Map.keys symClauses) formulas
  reportSLn "symbolsToFOLs" 20 $
               "FOL formulas:\n" ++ show symFormulas

  -- The FOL formulas are translated to annotated formulas.
  -- N.B. We are using the TPTP role AxiomATP. We should use the role
  -- 'definition' but Equinox doesn't support it.
  let afs :: [AnnotatedFormula]
      afs = map (\(sName, formula) -> (toAF sName AxiomATP formula))
                (zip (Map.keys symFormulas)
                     (Map.elems symFormulas))
  -- reportSLn "symbolsToFOLs" 20 $ "TPTP formulas:\n" ++ prettyTPTP afs

  return afs

translation :: Interface -> R ()
translation i = do
  reportS "" 1 $ "Translating " ++ show (iModuleName i)

  let importedModules :: [ModuleName]
      importedModules = iImportedModules i

  ( is :: [Interface] ) <-
      liftIO $ mapM (getInterface . moduleNameToFilePath) importedModules

  -- We translate the ATP axioms and general hints of current module
  -- and of all the imported modules.
  ( axiomsAndHintsAFss :: [[AnnotatedFormula]] ) <-
      mapM axiomsAndHintsToFOLs (i : is)

  ( symbolsAFss :: [[AnnotatedFormula]] ) <- mapM symbolsToFOLs (i : is)

  -- We translate the ATP pragma conjectures and their associated hints
  -- of current module.
  conjecturesAFs <- conjecturesToFOLs i


  -- We create the TPTP files.
  liftIO $ createAxiomsFile $
         concat axiomsAndHintsAFss ++ concat symbolsAFss
  liftIO $ mapM_ createConjectureFile conjecturesAFs -- ++ concat hintsAFss

runAgda2ATP :: IO ()
runAgda2ATP = do
  prgName <- getProgName
  argv <- getArgs --fmap head $ liftIO getArgs

  -- Reading the command line options.
  (opts, names) <- parseOptions argv prgName

  when (optVersion opts) $ bye $ prgName ++ " version " ++ version ++ "\n"

  when (optHelp opts) $ bye $ usage prgName

  -- Gettting the interface.
  i <- getInterface $ head names

  runReaderT (translation i) opts

main :: IO ()
main = catchImpossible runAgda2ATP $
         \e -> do putStr $ show e
                  exitFailure
