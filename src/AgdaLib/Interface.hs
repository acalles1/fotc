------------------------------------------------------------------------------
-- Handling of Agda interface files (*.agdai)
------------------------------------------------------------------------------

{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UnicodeSyntax #-}

module AgdaLib.Interface
  ( getClauses
  , getImportedInterfaces
  , getLocalHints
  , getATPRole
  , isATPDefinition
  , myGetInterface
  , myReadInterface
  , qNameDefinition
  , QNamesIn(qNamesIn)
  , qNameLine
  , qNameType
  )
  where

------------------------------------------------------------------------------
-- Haskell imports

import Control.Monad.Error ( throwError )
import Control.Monad.State ( evalStateT, get, put, StateT )
import Control.Monad.Trans ( lift, liftIO )

import Data.Int                  ( Int32 )
import qualified Data.Map as Map ( filter, lookup )
import Data.Maybe                ( fromMaybe )

------------------------------------------------------------------------------
-- Agda library imports

import Agda.Interaction.FindFile ( toIFile )
import Agda.Interaction.Imports  ( getInterface, readInterface )
import Agda.Interaction.Options
  ( CommandLineOptions(optIncludeDirs)
  , defaultOptions
  , defaultPragmaOptions
  , PragmaOptions(optVerbose)
  , Verbosity
  )
import Agda.Syntax.Abstract.Name
  ( ModuleName
  , Name(nameBindingSite)
  , QName
  , qnameName
  )
import Agda.Syntax.Common
  ( Arg(Arg), ATPRole(ATPAxiom, ATPConjecture, ATPDefinition, ATPHint) )
import Agda.Syntax.Internal
  ( Abs(Abs)
  , Clause(Clause)
  , ClauseBody(Bind, Body, NoBind, NoBody)
  , translatedClause
  , Term(Con, Def, DontCare, Fun, Lam, Level, Lit, MetaV, Pi, Sort, Var)
  , Type(El)
  )
import Agda.Syntax.Position
  ( Interval(iStart)
  , Position(posLine)
  , rangeToInterval
  )
import Agda.TypeChecking.Monad.Base
  ( axATP
  , conATP
  , Defn(Axiom, Constructor, Function)
  , Interface(iImportedModules, iModuleName)
  , Definition(defType)
  , Definitions
  , funATP
  , funClauses
  , runTCM
  , TCErr
  , theDef
  )
import Agda.TypeChecking.Monad.Options
  ( setCommandLineOptions
  , setPragmaOptions
  )
import Agda.Utils.FileName
  ( absolute
  , filePath
--  , mkAbsolute
  )
import Agda.Utils.Impossible ( Impossible(Impossible), throwImpossible )
import qualified Agda.Utils.Trie as Trie ( singleton )

------------------------------------------------------------------------------
-- Local imports

import Monad.Base    ( T, TState(tAllDefs, tOpts) )
import Monad.Reports ( reportSLn )
import Options       ( Options(optAgdaIncludePath) )

#include "../undefined.h"

------------------------------------------------------------------------------

getATPRole ∷ ATPRole → Definitions → Definitions
getATPRole role = Map.filter $ isRole role
  where
    isRole ∷ ATPRole → Definition → Bool
    isRole ATPAxiom      = isATPAxiom
    isRole ATPConjecture = isATPConjecture
    isRole ATPDefinition = isATPDefinition
    isRole ATPHint       = isATPHint

-- getHintsATP ∷ Interface → Definitions
-- getHintsATP i = Map.filter isAxiomATP $ sigDefinitions $ iSignature i

-- Invariant: The Definition must correspond to an ATP conjecture.
getLocalHints ∷ Definition → [QName]
getLocalHints def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Axiom{} → case axATP defn of
                   Just (ATPConjecture, hints) → hints
                   Just _                      → __IMPOSSIBLE__
                   Nothing                     → __IMPOSSIBLE__

       _       → __IMPOSSIBLE__

-- An empty list of relative include directories (Left []) is
-- interpreted as ["."] (from
-- Agda.TypeChecking.Monad.Options). Therefore the default of
-- Options.optAgdaIncludePath is [].
agdaCommandLineOptions ∷ T CommandLineOptions
agdaCommandLineOptions = do

  state ← get

  let agdaIncludePaths ∷ [FilePath]
      agdaIncludePaths = optAgdaIncludePath $ tOpts state

  return $ defaultOptions { optIncludeDirs = Left agdaIncludePaths }

-- TODO: It is not working.
agdaPragmaOptions ∷ PragmaOptions
agdaPragmaOptions =
  -- We do not want any verbosity from the Agda API.
  let agdaOptVerbose ∷ Verbosity
      agdaOptVerbose = Trie.singleton [] 0

  in defaultPragmaOptions { optVerbose = agdaOptVerbose }

myReadInterface ∷ FilePath → T Interface
myReadInterface file = do

  optsCommandLine ← agdaCommandLineOptions

  -- The physical interface file.
  (iFile ∷ FilePath) ← liftIO $ fmap (filePath . toIFile) (absolute file)

  (r ∷ Either TCErr (Maybe Interface)) ← liftIO $ runTCM $
    do setCommandLineOptions optsCommandLine
       setPragmaOptions agdaPragmaOptions
       readInterface iFile

  case r of
    Right (Just i) → return i
    Right Nothing  → throwError $ "Error reading the interface file " ++ iFile
    Left  _        → throwError "Error from runTCM in myReadInterface"

myGetInterface ∷ ModuleName → T (Maybe Interface)
myGetInterface x = do

  optsCommandLine ← agdaCommandLineOptions

  r ← liftIO $ runTCM $ do
    setCommandLineOptions optsCommandLine
    setPragmaOptions agdaPragmaOptions
    getInterface x

  case r of
    Right (i, _) → return (Just i)
    Left  _      → return Nothing

isATPAxiom ∷ Definition → Bool
isATPAxiom def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Axiom{} → case axATP defn of
                   Just (ATPAxiom, _)      → True
                   Just (ATPConjecture, _) → False
                   Just _                  → __IMPOSSIBLE__
                   Nothing                 → False

       Constructor{} → case conATP defn of
                         Just ATPAxiom → True
                         Just _        → __IMPOSSIBLE__
                         Nothing       → False

       _       → False

isATPConjecture ∷ Definition → Bool
isATPConjecture def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Axiom{} → case axATP defn of
                   Just (ATPAxiom, _)      → False
                   Just (ATPConjecture, _) → True
                   Just _                  → __IMPOSSIBLE__
                   Nothing                 → False

       _       → False

isATPDefinition ∷ Definition → Bool
isATPDefinition def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Function{} → case funATP defn of
                      Just ATPDefinition → True
                      Just ATPHint       → False
                      Just _             → __IMPOSSIBLE__
                      Nothing            → False

       _          → False

isATPHint ∷ Definition → Bool
isATPHint def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Function{}    → case funATP defn of
                         Just ATPDefinition → False
                         Just ATPHint       → True
                         Just _             → __IMPOSSIBLE__
                         Nothing            → False

       _             → False

qNameDefinition ∷ QName → T Definition
qNameDefinition qName = do
    state ← get
    return $ fromMaybe (__IMPOSSIBLE__) $ Map.lookup qName $ tAllDefs state

qNameType ∷ QName → T Type
qNameType qName = fmap defType $ qNameDefinition qName

-- The line where a QNname is defined.
qNameLine ∷ QName → Int32
qNameLine q =
  case rangeToInterval $ nameBindingSite $ qnameName q of
    Nothing → __IMPOSSIBLE__
    Just i  → posLine $ iStart i

getClauses ∷ Definition → [Clause]
getClauses def =
  let defn ∷ Defn
      defn = theDef def
  in case defn of
       Function{} → map translatedClause $ funClauses defn
       _          → __IMPOSSIBLE__

-- | Returns the QNames in an entity.
class QNamesIn a where
  qNamesIn ∷ a → [QName]

instance QNamesIn a ⇒ QNamesIn [a] where
  qNamesIn = concatMap qNamesIn

instance QNamesIn a ⇒ QNamesIn (Arg a) where
  qNamesIn (Arg _ _ t) = qNamesIn t

instance QNamesIn a ⇒ QNamesIn (Abs a) where
  qNamesIn (Abs _ b) = qNamesIn b

instance QNamesIn Term where
  qNamesIn (Con qName args) = qName : qNamesIn args
  qNamesIn (Def qName args) = qName : qNamesIn args
  qNamesIn (Fun argTy ty)   = qNamesIn argTy ++ qNamesIn ty
  qNamesIn (Lam _ absTerm)  = qNamesIn absTerm
  qNamesIn (Pi argTy absTy) = qNamesIn argTy ++ qNamesIn absTy
  qNamesIn (Sort _)         = []
  qNamesIn (Var _ args)     = qNamesIn args

  qNamesIn DontCare    = __IMPOSSIBLE__
  qNamesIn (Level _)   = __IMPOSSIBLE__
  qNamesIn (Lit _)     = __IMPOSSIBLE__
  qNamesIn (MetaV _ _) = __IMPOSSIBLE__

instance QNamesIn Type where
  qNamesIn (El _ term) = qNamesIn term

instance QNamesIn ClauseBody where
  qNamesIn (Body term)          = qNamesIn term
  qNamesIn (Bind absClauseBody) = qNamesIn absClauseBody
  qNamesIn (NoBind clauseBody)  = qNamesIn clauseBody
  qNamesIn NoBody               = []

instance QNamesIn Clause where
  qNamesIn (Clause _ _ _ _ body) = qNamesIn body

instance QNamesIn Definition where
  qNamesIn def = qNamesIn $ defType def

------------------------------------------------------------------------------
-- Imported interfaces

importedInterfaces ∷ ModuleName → StateT [ModuleName] T [Interface]
importedInterfaces x = do
  visitedModules ← get

  if x `notElem` visitedModules
    then do
      put $ x : visitedModules

      im ← lift $ myGetInterface x

      let i ∷ Interface
          i = fromMaybe (__IMPOSSIBLE__) im

      let iModules ∷ [ModuleName]
          iModules = iImportedModules i

      is ← fmap concat $ mapM importedInterfaces iModules
      return $ i : is

    else return []

-- Return the interfaces recursively imported by the top level interface.
getImportedInterfaces ∷ Interface → T [Interface]
getImportedInterfaces i = do
  iInterfaces ← fmap concat $
                evalStateT (mapM importedInterfaces $ iImportedModules i) []
  reportSLn "ii" 20 $ "Module names: " ++ show (map iModuleName iInterfaces)
  return iInterfaces
