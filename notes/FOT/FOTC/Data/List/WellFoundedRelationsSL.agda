------------------------------------------------------------------------------
-- Well-founded relation on lists
------------------------------------------------------------------------------

{-# OPTIONS --exact-split              #-}
{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

module FOT.FOTC.Data.List.WellFoundedRelationsSL {A : Set} where

open import Data.Product
open import Data.List hiding ( length )
open import Data.Nat

open import Induction.Nat
open import Induction.WellFounded

open import Relation.Binary.PropositionalEquality

------------------------------------------------------------------------------
-- We use our own version of the function length because we have
-- better reductions.
length : List A → ℕ
length []       = 0
length (x ∷ xs) = 1 + length xs

open module II = Induction.WellFounded.Inverse-image {_<_ = _<′_} length

-- Well-founded relation on lists based on their length.
LTL : List A → List A → Set
LTL xs ys = length xs <′ length ys

-- The relation LTL is well-founded (using the image inverse
-- combinator).
wfLTL : Well-founded LTL
wfLTL = II.well-founded <-well-founded

-- Well-founded relation on lists based on their structure.
LTC : List A → List A → Set
LTC xs ys = Σ A (λ a → ys ≡ a ∷ xs)

LTC→LTL : ∀ {xs ys} → LTC xs ys → LTL xs ys
LTC→LTL (x , refl) = ≤′-refl

open module S = Induction.WellFounded.Subrelation {_<₁_ = LTC} LTC→LTL

-- The relation LTC is well-founded (using the subrelation combinator).
wfLTC : Well-founded LTC
wfLTC = S.well-founded wfLTL
