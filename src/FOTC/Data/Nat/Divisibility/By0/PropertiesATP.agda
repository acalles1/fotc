------------------------------------------------------------------------------
-- Properties of the divisibility relation
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Data.Nat.Divisibility.By0.PropertiesATP where

open import Common.Function

open import FOTC.Base
open import FOTC.Base.Properties
open import FOTC.Data.Nat
open import FOTC.Data.Nat.Divisibility.By0
open import FOTC.Data.Nat.Inequalities
open import FOTC.Data.Nat.Inequalities.PropertiesATP
open import FOTC.Data.Nat.PropertiesATP

------------------------------------------------------------------------------
-- The divisibility relation is reflexive.
postulate
  ∣-refl : ∀ {n} → N n → n ∣ n
{-# ATP prove ∣-refl *-leftIdentity #-}

-- If x divides y and z then x divides y ∸ z.
postulate
  x∣y→x∣z→x∣y∸z-helper : ∀ {m n o k₁ k₂} → N m → N k₁ → N k₂ →
                         n ≡ k₁ * m →
                         o ≡ k₂ * m →
                         n ∸ o ≡ (k₁ ∸ k₂) * m
{-# ATP prove x∣y→x∣z→x∣y∸z-helper *∸-leftDistributive #-}

x∣y→x∣z→x∣y∸z : ∀ {m n o} → N m → N n → N o → m ∣ n → m ∣ o → m ∣ n ∸ o
x∣y→x∣z→x∣y∸z Nm Nn No (k₁ , Nk₁ , h₁) (k₂ , Nk₂ , h₂) =
  k₁ ∸ k₂ , ∸-N Nk₁ Nk₂ , x∣y→x∣z→x∣y∸z-helper Nm Nk₁ Nk₂ h₁ h₂

-- If x divides y and z then x divides y + z.
postulate
  x∣y→x∣z→x∣y+z-helper : ∀ {m n o k₁ k₂} → N m → N k₁ → N k₂ →
                         n ≡ k₁ * m →
                         o ≡ k₂ * m →
                         n + o ≡ (k₁ + k₂) * m
{-# ATP prove x∣y→x∣z→x∣y+z-helper *+-leftDistributive #-}

x∣y→x∣z→x∣y+z : ∀ {m n o} → N m → N n → N o → m ∣ n → m ∣ o → m ∣ n + o
x∣y→x∣z→x∣y+z Nm Nn No (k₁ , Nk₁ , h₁) (k₂ , Nk₂ , h₂) =
  k₁ + k₂ , +-N Nk₁ Nk₂ , x∣y→x∣z→x∣y+z-helper Nm Nk₁ Nk₂ h₁ h₂

-- If x divides y, and y is positive, then x ≤ y.
postulate x∣Sy→x≤Sy-helper₁ : ∀ {m n} → succ₁ n ≡ zero * m → ⊥
{-# ATP prove x∣Sy→x≤Sy-helper₁ #-}

-- Nice proof by the ATP.
postulate
  x∣Sy→x≤Sy-helper₂ : ∀ {m n o} → N m → N n → N o →
                      succ₁ n ≡ succ₁ o * m →
                      LE m (succ₁ n)
{-# ATP prove x∣Sy→x≤Sy-helper₂ x≤x+y *-N #-}

x∣Sy→x≤Sy : ∀ {m n} → N m → N n → m ∣ (succ₁ n) → LE m (succ₁ n)
x∣Sy→x≤Sy Nm Nn (.zero , zN , Sn≡0*m) = ⊥-elim $ x∣Sy→x≤Sy-helper₁ Sn≡0*m
x∣Sy→x≤Sy Nm Nn (.(succ₁ k) , sN {k} Nk , Sn≡Sk*m) =
  x∣Sy→x≤Sy-helper₂ Nm Nn Nk Sn≡Sk*m
