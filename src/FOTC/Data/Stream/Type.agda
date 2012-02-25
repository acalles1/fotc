------------------------------------------------------------------------------
-- The FOTC stream type
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Data.Stream.Type where

open import FOTC.Base

------------------------------------------------------------------------------

-- Functional for the FOTC Stream type.
-- StreamF : (D → Set) → D → Set
-- StreamF P ds = ∃[ e ] ∃[ es ] P es ∧ ds ≡ e ∷ es

-- Stream is the greatest post-fixed of StreamF (by Stream-gfp₁ and
-- Stream-gfp₂).

postulate
  Stream : D → Set

-- Stream is post-fixed point of StreamF (d ≤ f d)postulate
  Stream-gfp₁ : ∀ {xs} → Stream xs →
                ∃[ x' ] ∃[ xs' ] Stream xs' ∧ xs ≡ x' ∷ xs'
{-# ATP axiom Stream-gfp₁ #-}

-- ∀ e. e ≤ f e => e ≤ d
--
-- N.B. This is a second-order axiom. In the automatic proofs, we
-- *must* use an instance. Therefore, we do not add this postulate as
-- an ATP axiom.
postulate
  Stream-gfp₂ : (P : D → Set) →
                -- P is post-fixed point of StreamF.
                (∀ {xs} → P xs → ∃[ x' ] ∃[ xs' ] P xs' ∧ xs ≡ x' ∷ xs') →
                -- Stream is greater than P.
                ∀ {xs} → P xs → Stream xs

-- Because a greatest post-fixed point is a fixed point, then the
-- Stream predicate is also a pre-fixed point of the functor StreamF
-- (f d ≤ d).
Stream-gfp₃ : ∀ {xs} →
              (∃[ x' ] ∃[ xs' ] Stream xs' ∧ xs ≡ x' ∷ xs') →
              Stream xs
Stream-gfp₃ h = Stream-gfp₂ P helper h
  where
  P : D → Set
  P ws = ∃[ w' ] ∃[ ws' ] Stream ws' ∧ ws ≡ w' ∷ ws'

  helper : ∀ {xs} → P xs → ∃[ x' ] ∃[ xs' ] P xs' ∧ xs ≡ x' ∷ xs'
  helper (x' ,, xs' ,, Sxs' , xs≡x'∷xs') =
    x' ,, xs' ,, (Stream-gfp₁ Sxs') , xs≡x'∷xs'
