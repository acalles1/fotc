------------------------------------------------------------------------------
-- Translation from Agda *internal* terms to FOL formulas
------------------------------------------------------------------------------

{-# LANGUAGE CPP #-}
{-# LANGUAGE UnicodeSyntax #-}

module FOL.Translation.Internal.Terms ( termToFormula, termToFOLTerm ) where

------------------------------------------------------------------------------
-- Haskell imports

-- import Control.Monad.IO.Class ( liftIO )
import Control.Monad.Trans.Class ( lift )
import Control.Monad.Trans.State ( evalState, get, put )

------------------------------------------------------------------------------
-- Agda library imports

import Agda.Syntax.Abstract.Name ( nameConcrete, QName(QName) )
import Agda.Syntax.Common
    ( Arg(Arg)
    , argHiding
    , Hiding(Hidden, NotHidden)
    , unArg
    )
import qualified Agda.Syntax.Concrete.Name as C
    ( Name(Name, NoName)
    , NamePart(Id, Hole)
    )
import Agda.Syntax.Internal
    ( Abs(Abs)
    , Args
    , Sort(Type)
    , Term(Con, Def, DontCare, Fun, Lam, Lit, MetaV, Pi, Sort, Var)
    , Type(El)
    )
import Agda.Syntax.Literal ( Literal(LitLevel) )
import Agda.Syntax.Position ( noRange )
import Agda.Utils.Impossible ( Impossible(Impossible), throwImpossible )

------------------------------------------------------------------------------
-- Local imports

import FOL.Constants
    ( folTrue, folFalse, folNot, folAnd, folOr
    , folImplies, folEquiv, folExists, folForAll, folEquals
    )
import FOL.Monad ( T )
import FOL.Primitives ( app, equal )
import FOL.Translation.Concrete.Name ( concatName )
import {-# source #-} FOL.Translation.Internal.Types ( typeToFormula )
import FOL.Types ( FOLFormula(..), FOLTerm(..) )
import Reports ( reportSLn )
import Utils.Names ( freshName )

#include "../../../undefined.h"

------------------------------------------------------------------------------
argTermToFormula :: Arg Term → T FOLFormula
argTermToFormula Arg {argHiding = NotHidden, unArg = term} = termToFormula term
argTermToFormula Arg {argHiding = Hidden} =
    error "argTermToFormula: not implemented"

binConst :: (FOLFormula → FOLFormula → FOLFormula) →
            Arg Term →
            Arg Term →
            T FOLFormula
binConst op arg1 arg2 = do f1 ← argTermToFormula arg1
                           f2 ← argTermToFormula arg2
                           return $ op f1 f2

termToFormula :: Term → T FOLFormula
termToFormula term@(Def (QName _ name) args) = do
    lift $ lift $ reportSLn "t2f" 10 $ "termToFormula Def:\n" ++ show term

    let cName :: C.Name
        cName = nameConcrete name

    case cName of
      C.NoName{} → __IMPOSSIBLE__

      C.Name _ [] → __IMPOSSIBLE__

      C.Name{} →
          case args of
            [] | isCNameFOLConst folTrue  → return TRUE

               | isCNameFOLConst folFalse → return FALSE

               | otherwise                → return $ Predicate (show cName) []

            (a:[]) | isCNameFOLConstHoleRight folNot → do
                       f ← argTermToFormula a
                       return $ Not f

                   | ( isCNameFOLConst folExists ||
                       isCNameFOLConst folForAll ) → do

                       fm ← termToFormula $ unArg a


                       vars ← lift get

                       let freshVar :: String
                           freshVar = evalState freshName vars

                       if isCNameFOLConst folExists
                          then return $ Exists freshVar $ \_ → fm
                          else return $ ForAll freshVar $ \_ → fm

                   | otherwise → do
                      -- In this guard we translate predicates with
                      -- one argument (e.g. P : D → Set).

                      -- TODO: To test if 'termToFOLTerm (unArg a)'
                      -- works with implicit arguments.
                      t ← termToFOLTerm $ unArg a
                      return $ Predicate (show cName) [t]

            (a1:a2:[])
                | isCNameFOLConstTwoHoles folAnd → binConst And a1 a2

                | isCNameFOLConstTwoHoles folOr → binConst Or a1 a2

                | isCNameFOLConstTwoHoles folImplies → binConst Implies a1 a2

                | isCNameFOLConstTwoHoles folEquiv → binConst Equiv a1 a2

                | isCNameFOLConstTwoHoles folEquals → do
                    lift $ lift $ reportSLn "t2f" 20 "Processing equals"
                    t1 ← termToFOLTerm $ unArg a1
                    t2 ← termToFOLTerm $ unArg a2
                    return $ equal t1 t2

                | otherwise → do
                      lift $ lift $ reportSLn "t2f" 20 $
                               "Processing a definition with two arguments which " ++
                               "is not a FOL constant: " ++ show cName
                      t1 ← termToFOLTerm $ unArg a1
                      t2 ← termToFOLTerm $ unArg a2
                      return $ Predicate (show cName) [t1, t2]

            threeOrMore → do
                      terms ← mapM (termToFOLTerm . unArg ) threeOrMore
                      return $ Predicate (show cName) terms

          where
            isCNameFOLConst :: String → Bool
            isCNameFOLConst constFOL =
                -- The equality on the data type C.Name is defined
                -- to ignore ranges, so we use noRange.
                cName == C.Name noRange [C.Id constFOL]

            isCNameFOLConstHoleRight :: String → Bool
            isCNameFOLConstHoleRight constFOL =
                -- The operators are represented by a list with Hole's.
                -- See the documentation for C.Name.
                cName == C.Name noRange [C.Id constFOL, C.Hole]

            isCNameFOLConstTwoHoles :: String → Bool
            isCNameFOLConstTwoHoles constFOL =
                -- The operators are represented by a list with Hole's.
                -- See the documentation for C.Name.
                cName == C.Name noRange [C.Hole, C.Id constFOL, C.Hole]

termToFormula term@(Fun tyArg ty) = do
  lift $ lift $ reportSLn "t2f" 10 $ "termToFormula Fun:\n" ++ show term
  f1 ← typeToFormula $ unArg tyArg
  f2 ← typeToFormula ty
  return $ Implies f1 f2

-- TODO: To add test for this case.
termToFormula term@(Lam _ (Abs _ termLam)) = do
  lift $ lift $ reportSLn "t2f" 10 $ "termToFormula Lam:\n" ++ show term

  vars ← lift get

  let freshVar :: String
      freshVar = evalState freshName vars

  -- See the reason for the order in the enviroment in
  -- termToFormula term@(Pi ... ).
  lift $ put (freshVar : vars)
  f ← termToFormula termLam
  lift $ put vars
  return f

termToFormula term@(Pi tyArg (Abs _ tyAbs)) = do
  lift $ lift $ reportSLn "t2f" 10 $ "termToFormula Pi:\n" ++ show term

  vars ← lift get

  let freshVar :: String
      freshVar = evalState freshName vars

  lift $ lift $ reportSLn "t2f" 20 $
    "Starting processing in local enviroment with type:\n" ++ show tyAbs

  -- The de Bruijn indexes are assigned from right to left,
  --
  -- e.g. in '(A B C : Set) → ...', A is 2, B is 1, and C is 0,
  --
  -- so we need create the list in the same order.
  lift $ put (freshVar : vars)
  f2 ← typeToFormula tyAbs
  lift $ put vars

  lift $ lift $ reportSLn "t2f" 20 $
    "Finalized processing in local enviroment with type:\n" ++ show tyAbs

  case unArg tyArg of
    -- The bounded variable is quantified on a Set,
    --
    -- e.g. the bounded variable is 'd : D' where D : Set,
    --
    -- so we can create a fresh variable and quantify on it without
    -- any problem. N.B. the pattern matching on (Def _ []).
    El (Type (Lit (LitLevel _ 0))) (Def _ []) →
        do lift $ lift $ reportSLn "t2f" 20 $
             "Adding universal quantification on variable: " ++ freshVar
           return $ ForAll freshVar (\_ → f2)

    -- The bounded variable is quantified on a proof,
    --
    -- e.g. the bounded variable is 'Nn : N n', where D : Set, n : D
    -- and N : D → Set.
    --
    -- In this case, we erase the quantification on the bounded
    -- variable and we try it as a function type. This solve the
    -- problem of the translation of
    --
    -- sN : {n : D} → (Nn : N n) → N (succ n).
    --
    -- N.B. the pattern matching on (Def _ _ ).
    El (Type (Lit (LitLevel _ 0))) def@(Def _ _ ) → do
       lift $ lift $ reportSLn "t2f" 20 $
           "Removing a quantification on the proof:\n" ++ show def
       f1 ← typeToFormula $ unArg tyArg
       return $ Implies f1 f2

    -- Hack: The bounded variable is quantified on a function of a Set
    -- to a Set,
    --
    -- e.g. the bounded variable is f : D → D, where D : Set.
    --
    -- In this case we handle the bounded variable/function as a FOL
    -- variable (see termToFOLTerm term@(Var n args)), and we
    -- quantified on this variable.
    El (Type (Lit (LitLevel _ 0)))
       (Fun (Arg _ _ (El (Type (Lit (LitLevel _ 0))) (Def _ [])))
            (El (Type (Lit (LitLevel _ 0))) (Def _ []))
       ) → do
      lift $ lift $ reportSLn "t2f" 20
         "Removing a quantification on a function of a Set to a Set"
      return $ ForAll freshVar (\_ → f2)

    El (Type (Lit (LitLevel _ 0))) _ → __IMPOSSIBLE__

    -- Old version
    -- TODO: Check it
    -- The bounded variable has type Set, i.e. a propositional constant.
    -- El (Type (Lit (LitLevel _ 1))) _ →
        -- return $ ForAll freshVar (\_ → f2)

    -- The bounded variable is quantified on a Set₁,
    --
    -- e.g. the bounded variable is 'A : Set'.
    --
    -- In this case, we forgot it.
    El (Type (Lit (LitLevel _ 1))) (Sort _ )  → do
       lift $ lift $ reportSLn "t2f" 20 $ "The type tyArg is: " ++ show tyArg
       return f2

    El (Type (Lit (LitLevel _ 1))) _ → __IMPOSSIBLE__

    _                                → __IMPOSSIBLE__

-- TODO: To add test for this case.
termToFormula term@(Var n _ ) = do
  lift $ lift $ reportSLn "t2f" 10 $ "termToFormula Var: " ++ show term

  vars ← lift get

  if length vars <= fromIntegral n
     then __IMPOSSIBLE__
     else return $ Predicate (vars !! fromIntegral n) []

termToFormula DontCare     = __IMPOSSIBLE__
termToFormula (Con _ _ )   = __IMPOSSIBLE__
termToFormula (Lit _ )     = __IMPOSSIBLE__
termToFormula (MetaV _ _ ) = __IMPOSSIBLE__
termToFormula (Sort _ )    = __IMPOSSIBLE__

-- Translate 'foo x1 ... xn' to 'kApp (... kApp (kApp(foo, x1), x2), ..., xn)'.
appArgs :: String → Args → T FOLTerm
appArgs fn args = do
  termsFOL ← mapM (termToFOLTerm . unArg) args
  return $ foldl app (FOLFun fn []) termsFOL

-- Translate an Agda term to an FOL term.
termToFOLTerm :: Term → T FOLTerm
termToFOLTerm term@(Con (QName _ name) args)  = do
  lift $ lift $ reportSLn "t2t" 10 $ "termToFOLTerm Con:\n" ++ show term

  let cName :: C.Name
      cName = nameConcrete name

  case cName of
    C.NoName{}  → __IMPOSSIBLE__

    C.Name _ [] → __IMPOSSIBLE__

    -- The term Con doesn't have holes. It should be translated as a
    -- FOL function.
    -- TODO: Added test case
    C.Name _ [C.Id _ ] → __IMPOSSIBLE__
    -- C.Name _ [C.Id str] →
    --     case args of
    --       [] → return $ FOLFun str []
    --       _ →  appArgs str args

    -- The term Con has holes. It is translated as a FOL function.
    C.Name _ parts →
      case args of
        [] → __IMPOSSIBLE__
        _  → appArgs (concatName parts) args

termToFOLTerm term@(Def (QName _ name) args) = do
  lift $ lift $ reportSLn "t2t" 10 $ "termToFOLTerm Def:\n" ++ show term

  let cName :: C.Name
      cName = nameConcrete name

  case cName of
    C.NoName{}  → __IMPOSSIBLE__

    C.Name _ [] → __IMPOSSIBLE__

    -- The term Def doesn't have holes. It is translated as a FOL function.
    C.Name _ [C.Id str] →
        case args of
          [] → return $ FOLFun str []
          _  → appArgs str args

    -- The term Def has holes. It is translated as a FOL function.
    C.Name _ parts →
      case args of
        [] → __IMPOSSIBLE__
        _  → appArgs (concatName parts) args

termToFOLTerm term@(Var n args) = do
  lift $ lift $ reportSLn "t2t" 10 $ "termToFOLTerm Var:\n" ++ show term

  vars ← lift get

  if length vars <= fromIntegral n
     then __IMPOSSIBLE__
     else
       case args of
         [] → return $ FOLVar (vars !! fromIntegral n)

         -- Hack: If we have a bounded variable quantified on a
         -- function of a Set to a Set, for example, the variable 'f'
         -- in '(f : D → D) → (a : D) → (lam f) ∙ a ≡ f a'
         -- we are quantifying on this variable
         -- (see termToFormula term@(Pi tyArg (Abs _ tyAbs))),
         -- therefore we need to apply this
         -- variable/function to a term.

         (a1 : []) → do
             t ← termToFOLTerm $ unArg a1
             return $ app (FOLVar (vars !! fromIntegral n)) t

         _  → __IMPOSSIBLE__

termToFOLTerm DontCare     = __IMPOSSIBLE__
termToFOLTerm (Fun _ _ )   = __IMPOSSIBLE__
termToFOLTerm (Lam _ _ )   = __IMPOSSIBLE__
termToFOLTerm (Lit _ )     = __IMPOSSIBLE__
termToFOLTerm (MetaV _ _ ) = __IMPOSSIBLE__
termToFOLTerm (Pi _ _ )    = __IMPOSSIBLE__
termToFOLTerm (Sort _ )    = __IMPOSSIBLE__
