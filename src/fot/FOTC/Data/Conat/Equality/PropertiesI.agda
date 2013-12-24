------------------------------------------------------------------------------
-- Properties for the equality on Conat
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Data.Conat.Equality.PropertiesI where

open import FOTC.Base
open import FOTC.Data.Conat
open import FOTC.Data.Conat.Equality.Type

------------------------------------------------------------------------------
-- Because a greatest post-fixed point is a fixed-point, then the
-- relation _≈N_ is also a pre-fixed point of the functional ≈NatF,
-- i.e.
--
-- ≈NatF _≈N_ ≤ _≈N_ (see FOTC.Data.Conat.Equality).
≈N-pre-fixed : (∀ {m n} → m ≡ zero ∧ n ≡ zero
                 ∨ (∃[ m' ] ∃[ n' ] m ≡ succ₁ m' ∧ n ≡ succ₁ n' ∧ m' ≈N n')) →
               ∀ {m n} → m ≈N n
≈N-pre-fixed h = ≈N-coind (λ o _ → o ≡ o) h' refl
  where
  h' : ∀ {m n} → m ≡ m →
       m ≡ zero ∧ n ≡ zero
         ∨ (∃[ m' ] ∃[ n' ] m ≡ succ₁ m' ∧ n ≡ succ₁ n' ∧ m' ≡ m')
  h' _ with h
  ... | inj₁ prf                         = inj₁ prf
  ... | inj₂ (m' , n' , prf₁ , prf₂ , _) = inj₂ (m' , n' , prf₁ , prf₂ , refl)

≈N-refl : ∀ {n} → Conat n → n ≈N n
≈N-refl {n} Cn = ≈N-coind R h₁ h₂
  where
  R : D → D → Set
  R a b = Conat a ∧ Conat b ∧ a ≡ b

  h₁ : ∀ {a b} → R a b →
       a ≡ zero ∧ b ≡ zero
         ∨ (∃[ a' ] ∃[ b' ] a ≡ succ₁ a' ∧ b ≡ succ₁ b' ∧ R a' b')
  h₁ (Ca , Cb , h) with Conat-unf Ca
  ... | inj₁ prf              = inj₁ (prf , trans (sym h) prf)
  ... | inj₂ (a' , prf , Ca') =
    inj₂ (a' , a' , prf , trans (sym h) prf , (Ca' , Ca' , refl))

  h₂ : R n n
  h₂ = Cn , Cn , refl

≡→≈N : ∀ {m n} → Conat m → Conat n → m ≡ n → m ≈N n
≡→≈N Cm _ refl = ≈N-refl Cm
