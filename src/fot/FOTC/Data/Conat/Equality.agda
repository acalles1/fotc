------------------------------------------------------------------------------
-- Equality on Conat
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- References:
--
-- • Herbert P. Sander. A logic of functional programs with an
--   application to concurrency. PhD thesis, Chalmers University of
--   Technology and University of Gothenburg, Department of Computer
--   Sciences, 1992.

module FOTC.Data.Conat.Equality where

open import FOTC.Base

-- We add 3 to the fixities of the standard library.
infix 7 _≈N_

------------------------------------------------------------------------------
-- Functional for the relation _≈N_ (adapted from (Sander 1992,
-- p. 58)).
--
-- ≈NF : (D → D → Set) → D → D → Set
-- ≈NF _R_ m n =
-- (m ≡ zero ∧ n ≡ zero) ∨ (∃[ m' ] ∃[ n' ] m' R n' ∧ m ≡ succ m' ∧ n ≡ succ n')

-- The relation _≈N_ is the greatest post-fixed point of the
-- functional ≈NF (by ≈N-gfp₁ and ≈N-gfp₂).

-- The equality on Conat.
postulate
  _≈N_ : D → D → Set

-- The relation _≈N_ is a post-fixed point of the functional ≈NF, i.e.
--
-- _≈N_ ≤ ≈NF _≈N_.
postulate
  ≈N-gfp₁ : ∀ {m n} → m ≈N n →
            m ≡ zero ∧ n ≡ zero
            ∨ (∃[ m' ] ∃[ n' ] m' ≈N n' ∧ m ≡ succ₁ m' ∧ n ≡ succ₁ n')
{-# ATP axiom ≈N-gfp₁ #-}

-- The relation _N≈_ is the greatest post-fixed point of _N≈_, i.e
--
-- ∀ R. R ≤ ≈NF R ⇒ R ≤ _N≈_.
--
-- N.B. This is an axiom schema. Because in the automatic proofs we
-- *must* use an instance, we do not add this postulate as an ATP
-- axiom.
postulate
  ≈N-gfp₂ : (_R_ : D → D → Set) →
            -- R is a post-fixed point of the functional ≈NF.
           (∀ {m n} → m R n →
            m ≡ zero ∧ n ≡ zero
            ∨ (∃[ m' ] ∃[ n' ] m' R n' ∧ m ≡ succ₁ m' ∧ n ≡ succ₁ n')) →
           -- _≈N_ is greater than R.
           ∀ {m n} → m R n → m ≈N n

-- Because a greatest post-fixed point is a fixed-point, then the
-- relation _≈N_ is also a pre-fixed point of the functional ≈NF, i.e.
--
-- ≈NF _≈N_ ≤ _≈N_.
≈N-gfp₃ : ∀ {m n} →
          (m ≡ zero ∧ n ≡ zero
           ∨ (∃[ m' ] ∃[ n' ] m' ≈N n' ∧ m ≡ succ₁ m' ∧ n ≡ succ₁ n')) →
          m ≈N n
≈N-gfp₃ h = ≈N-gfp₂ _R_ helper h
  where
  _R_ : D → D → Set
  _R_ m n = m ≡ zero ∧ n ≡ zero
            ∨ (∃[ m' ] ∃[ n' ] m' ≈N n' ∧ m ≡ succ₁ m' ∧ n ≡ succ₁ n')

  helper : ∀ {m n} → m R n →
           m ≡ zero ∧ n ≡ zero
           ∨ (∃[ m' ] ∃[ n' ] m' R n' ∧ m ≡ succ₁ m' ∧ n ≡ succ₁ n')
  helper (inj₁ prf) = inj₁ prf
  helper (inj₂ (m' , n' , m'≈Nn' , prf)) = inj₂ (m' , n' , ≈N-gfp₁ m'≈Nn' , prf)