------------------------------------------------------------------------------
-- Eta expansion of Agda internal types
------------------------------------------------------------------------------

{-# LANGUAGE UnicodeSyntax #-}

module MyAgda.EtaExpansion where

-- Haskell imports
import Control.Monad.IO.Class ( liftIO )
import Control.Monad.Trans.State ( evalState, get, StateT, put )

-- Agda library imports
-- import Agda.Syntax.Abstract.Name ( QName )
import Agda.Syntax.Common ( Arg(Arg), Hiding(NotHidden), Nat )
import Agda.Syntax.Internal
    ( Abs(Abs)
    , Args
    , arity
    , Term(Def, Con, Fun, Lam, Lit, MetaV, Pi, Sort, Var)
    , Sort(Type)
    , Type(El)
    )
import Agda.Syntax.Literal ( Literal(LitLevel) )
import Agda.Utils.Impossible ( Impossible(..), throwImpossible )

-- Local imports
import Common ( Vars )
import MyAgda.Interface ( getQNameInterface, getQNameType )
import MyAgda.Syntax.Internal ( incTermVariables )
import Utils.Names ( freshName )

#include "../undefined.h"

------------------------------------------------------------------------------
-- The eta-expansion monad.
type EE = StateT Vars IO

class EtaExpandible a where
    etaExpand :: a → EE a

instance EtaExpandible Type where
    etaExpand (El (Type (Lit (LitLevel r n))) term)
        | n `elem` [ 0, 1 ] =
            do termEtaExpanded ← etaExpand term
               return $ El (Type (Lit (LitLevel r n))) termEtaExpanded
        | otherwise = __IMPOSSIBLE__

    etaExpand _ = __IMPOSSIBLE__

instance EtaExpandible Term where
    etaExpand (Def qName args) = do
      vars ← get

      interface ← liftIO $ getQNameInterface qName

      let qNameArity :: Nat
          qNameArity = arity $ getQNameType interface qName

      argsEtaExpanded ← mapM etaExpand args

      let newVar :: Arg Term
          newVar = Arg NotHidden (Var 0 [])

      let freshVar :: String
          freshVar = evalState freshName vars

      -- The eta-contraction *only* reduces by 1 the number of arguments
      -- of a term, for example:

      -- Given P : D → Set,
      -- λ x → P x eta-contracts to P or

      -- Given _≡_ : D → D → Set,
      -- (x : D) → (λ y → x ≡ y) eta-contracts to (x : D) → _≡_ x

      -- therefore we only applied the eta-expansion in this case.

      if qNameArity == fromIntegral (length args)
        then return $ Def qName argsEtaExpanded
        else if qNameArity - 1 == fromIntegral (length args)
               then do
                 put (freshVar : vars)
                 -- Because we are going to add a new abstraction, we
                 -- need increase by one the numbers associated with the
                 -- variables in the arguments.
                 let incVarsEtaExpanded :: Args
                     incVarsEtaExpanded = map incTermVariables argsEtaExpanded
                 return $
                   Lam NotHidden (Abs freshVar
                                      (Def qName
                                           (incVarsEtaExpanded ++ [newVar])))
               else __IMPOSSIBLE__

    -- We don't know an example of eta-contraction with Con, therefore we
    -- don't do anything.
    etaExpand term@(Con _ _) = return term

    etaExpand (Fun tyArg ty) = do
      tyArgEtaExpanded ← etaExpand tyArg
      tyEtaExpanded    ← etaExpand ty
      return $ Fun tyArgEtaExpanded tyEtaExpanded

    etaExpand (Lam h (Abs name termAbs)) = do
      -- We add the variable 'name' to the enviroment.
      vars ← get
      put (name : vars)

      termAbsEtaExpanded ← etaExpand termAbs
      return $ Lam h (Abs name termAbsEtaExpanded)

    -- It seems it is not necessary to eta-expand the tyArg like in the
    -- case of Fun (Arg Type) Type.
    etaExpand (Pi tyArg (Abs name tyAbs)) = do
      -- We add the variable 'name' to the enviroment.
      vars ← get
      put (name : vars)

      tyAbsEtaExpanded ← etaExpand tyAbs
      return $ Pi tyArg (Abs name tyAbsEtaExpanded)

    etaExpand (Var n args) = do
      argsEtaExpanded ← mapM etaExpand args
      return $ Var n argsEtaExpanded

    etaExpand (Lit _)     = __IMPOSSIBLE__
    etaExpand (MetaV _ _) = __IMPOSSIBLE__
    etaExpand (Sort _)    = __IMPOSSIBLE__

instance EtaExpandible a => EtaExpandible (Arg a) where
    etaExpand (Arg h t) = do
      tEtaExpanded ← etaExpand t
      return (Arg h tEtaExpanded)