------------------------------------------------------------------------------
-- Parametrized preorder reasoning
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module Common.Relation.Binary.PreorderReasoning
  {D     : Set}
  (_∼_   : D → D → Set)
  (refl  : ∀ {x} → x ∼ x)
  (trans : ∀ {x y z} → x ∼ y → y ∼ z → x ∼ z)
  where

-- We add 3 to the fixities of the standard library.
infixr 5 _∼⟨_⟩_
infix  5 _∎

------------------------------------------------------------------------------
-- From: Shin-Cheng Mu, Hsiang-Shang Ko, and Patrick Jansson. Algebra
-- of programming in Agda: Dependent types for relational program
-- derivation. Journal of Functional Programming, 19(5):545–579, 2009.

-- N.B. Unlike Ulf's thesis (and the Agda standard library) this set
-- of combinators do not need a wrapper data type.

_∼⟨_⟩_ : ∀ x {y z} → x ∼ y → y ∼ z → x ∼ z
_ ∼⟨ x∼y ⟩ y∼z = trans x∼y y∼z

_∎ : ∀ x → x ∼ x
_∎ _ = refl