---------------------------------------------------------------------------
-- The gcd is greatest that any common divisor
---------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

open import LTC-PCF.Base
open import LTC-PCF.Data.Nat.Divisibility.NotBy0
open import LTC-PCF.Data.Nat.Inequalities
open import LTC-PCF.Data.Nat.Type

module LTC-PCF.Program.GCD.Partial.GreatestAnyCommonDivisor
  (x∣Sy→x≤Sy : ∀ {m n} → N m → N n → m ∣ (succ₁ n) → LE m (succ₁ n))
  where

open import Common.Function

open import LTC-PCF.Data.Nat.Divisibility.NotBy0.Properties
open import LTC-PCF.Program.GCD.Partial.Definitions

---------------------------------------------------------------------------
-- Knowing that gcd is a common divisor of m and n, and that any other
-- common divisor of m and n divides it, we can prove that gcd is the
-- largest common divisor.

-- We need N d.
gcd-GACD : ∀ {m n gcd} → N gcd → CD m n gcd → Divisible m n gcd → GACD m n gcd
gcd-GACD zN              (0∣m , _) = ⊥-elim $ 0∤x 0∣m
gcd-GACD (sN {gcd} Ngcd) _         =
  λ Divisible-mnSgcd c Nc CDmnc → x∣Sy→x≤Sy Nc Ngcd
                     (Divisible-mnSgcd c Nc CDmnc)
