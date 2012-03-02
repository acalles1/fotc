------------------------------------------------------------------------------
-- FOL theorems
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- This module contains some examples showing the use of the ATPs for
-- proving FOL theorems.

module FOL.TheoremsATP where

open import FOL.Base

------------------------------------------------------------------------------
-- We postulate some formulae and propositional functions.
postulate
  A     : Set
  A¹ B¹ : D → Set
  A²    : D → D → Set

-- The introduction and elimination rules for the quantifiers are theorems.
{-
      φ(x)
  -----------  ∀-intro
    ∀x.φ(x)

    ∀x.φ(x)
  -----------  ∀-elim
     φ(t)

      φ(t)
  -----------  ∃-intro
    ∃x.φ(x)

   ∃x.φ(x)   φ(x) → ψ
 ----------------------  ∃-elim
           ψ
-}

postulate
  ∀-intro : ((x : D) → A¹ x) → ⋀ A¹
  ∀-elim  : ⋀ A¹ → (t : D) → A¹ t
  -- It is necessary to assume a non-empty domain. See
  -- FOL.NonEmptyDomain.TheoremsI/ATP.∃I.
  --
  -- TODO: 2012-02-28. Fix the existential introduction rule.
  -- ∃-intro : ((t : D) → A¹ t) → ∃ A¹
  ∃-elim'  : ∃ A¹ → ((x : D) → A¹ x → A) → A
{-# ATP prove ∀-intro #-}
{-# ATP prove ∀-elim #-}
-- {-# ATP prove ∃-intro #-}
{-# ATP prove ∃-elim' #-}

-- Generalization of De Morgan's laws.
postulate
  gDM₁ : ¬ (⋀ A¹) ↔ (∃[ x ] ¬ (A¹ x))
  gDM₂ : ¬ (∃ A¹) ↔ ⋀ (λ x → ¬ (A¹ x))
  gDM₃ : ⋀ A¹     ↔ ¬ (∃[ x ] ¬ (A¹ x))
  gDM₄ : ∃ A¹     ↔ ¬ (⋀ (λ x → ¬ (A¹ x)))
{-# ATP prove gDM₁ #-}
{-# ATP prove gDM₂ #-}
{-# ATP prove gDM₃ #-}
{-# ATP prove gDM₄ #-}

-- The order of quantifiers of the same sort is irrelevant.
postulate
  ∀-ord : ⋀ (λ x → ⋀ (λ y → A² x y)) ↔ ⋀ (λ y → ⋀ (λ x → A² x y))
  ∃-ord : (∃[ x ] ∃[ y ] A² x y) ↔ (∃[ y ] ∃[ x ] A² x y)
{-# ATP prove ∀-ord #-}
{-# ATP prove ∃-ord #-}

-- Quantification over a variable that does not occur can be erased or
-- added.
postulate
  ∀-erase-add : ⋀ (λ _ → A) ↔ A
  ∃-erase-add : (∃[ x ] A ∧ A¹ x) ↔ A ∧ (∃[ x ] A¹ x)
{-# ATP prove ∀-erase-add #-}
{-# ATP prove ∃-erase-add #-}

-- Distributes laws for the quantifiers.
postulate
  ∀-dist : ⋀ (λ x → A¹ x ∧ B¹ x) ↔ (⋀ A¹ ∧ ⋀ B¹)
  ∃-dist : (∃[ x ] A¹ x ∨ B¹ x) ↔ (∃ A¹ ∨ ∃ B¹)
{-# ATP prove ∀-dist #-}
{-# ATP prove ∃-dist #-}

-- Interchange of quantifiers.
-- The related theorem ∀x∃y.Axy → ∃y∀x.Axy is not (classically) valid.
postulate ∃∀ : ∃[ x ] (⋀ λ y → A² x y) → ⋀ λ y → ∃[ x ] A² x y
{-# ATP prove ∃∀ #-}
