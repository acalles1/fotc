------------------------------------------------------------------------------
-- Group theory base
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module GroupTheory.Base where

-- We add 3 to the fixities of the standard library.
infix  11 _⁻¹
infixl 10 _·_  -- The symbol is '\cdot'.

------------------------------------------------------------------------------
-- The group universe
open import FOL.Universe public renaming ( D to G )

-- FOL with equality.
open import FOL.FOL-Eq public

-- Group theory axioms
postulate
  ε   : G          -- The identity element.
  _·_ : G → G → G  -- The binary operation.
  _⁻¹ : G → G      -- The inverse function.

  -- We choose a mininal set of axioms. See for example Saunders Mac
  -- Lane and Garret Birkhoff. Algebra. AMS Chelsea Publishing, 3rd
  -- edition, 1999. exercises 5-7, p. 50-51.
  assoc         : ∀ a b c → a · b · c ≡ a · (b · c)
  leftIdentity  : ∀ a → ε · a         ≡ a
  leftInverse   : ∀ a → a ⁻¹ · a      ≡ ε
{-# ATP axiom assoc leftIdentity leftInverse  #-}
