------------------------------------------------------------------------------
-- The map-iterate property
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- The map-iterate property (Gibbons and Hutton 2005):
-- map f (iterate f x) = iterate f (f · x)

module FOT.FOTC.Program.MapIterate.MapIterateStrongerInductionPrincipleATP
  where

open import FOT.FOTC.Relation.Binary.Bisimilarity.Type

open import FOTC.Base
open import FOTC.Base.List
open import FOTC.Data.List
open import FOTC.Data.Stream.Type
open import FOTC.Relation.Binary.Bisimilarity.Type

------------------------------------------------------------------------------
-- The map-iterate property using a stronger (maybe invalid) induction
-- principle.
≈-map-iterate : ∀ f x → map f (iterate f x) ≈ iterate f (f · x)
≈-map-iterate f x = ≈-coind-stronger (λ xs _ → xs ≡ xs) h refl
  where
  postulate
    h : map f (iterate f x) ≡ map f (iterate f x) →
        ∃[ x' ] ∃[ xs' ] ∃[ ys' ]
          map f (iterate f x) ≡ x' ∷ xs'
          ∧ iterate f (f · x) ≡ x' ∷ ys'
          ∧ xs' ≡ xs'
  {-# ATP prove h #-}

------------------------------------------------------------------------------
-- References
--
-- Gibbons, Jeremy and Hutton, Graham (2005). Proof Methods for
-- Corecursive Programs. In: Fundamenta Informaticae XX, pp. 1–14.