------------------------------------------------------------------------------
-- Testing Agda internal term: @Var Nat Args@ when @Args ≠ []@
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- Requires option @--non-fol-function@.

module Test.Succeed.NonFOL.AgdaInternalTerms.VarNonEmptyArguments where

postulate
  D   : Set
  _≡_ : D → D → Set

-- TODO: 2012-04-29. Are we using Koen's approach in the translation?
postulate f-refl : (f : D → D) → ∀ x → f x ≡ f x
{-# ATP prove f-refl #-}