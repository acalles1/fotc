------------------------------------------------------------------------------
-- The gcd is divisible by any common divisor
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Program.GCD.Total.DivisibleATP where

open import Common.Function

open import FOTC.Base
open import FOTC.Base.Properties
open import FOTC.Data.Nat
open import FOTC.Data.Nat.Divisibility.By0
open import FOTC.Data.Nat.Divisibility.By0.PropertiesATP
open import FOTC.Data.Nat.Induction.NonAcc.LexicographicATP
open import FOTC.Data.Nat.Inequalities
open import FOTC.Data.Nat.Inequalities.EliminationProperties
open import FOTC.Data.Nat.Inequalities.PropertiesATP
open import FOTC.Data.Nat.PropertiesATP
open import FOTC.Program.GCD.Total.Definitions
open import FOTC.Program.GCD.Total.GCD

------------------------------------------------------------------------------
-- The gcd 0 0 is Divisible.
postulate
  gcd-00-Divisible : Divisible zero zero (gcd zero zero)
{-# ATP prove gcd-00-Divisible #-}

-- The gcd 0 (succ n) is Divisible.
postulate
  gcd-0S-Divisible : ∀ {n} → N n → Divisible zero (succ₁ n) (gcd zero (succ₁ n))
{-# ATP prove gcd-0S-Divisible #-}

postulate
  gcd-S0-Divisible : ∀ {n} → N n → Divisible (succ₁ n) zero (gcd (succ₁ n) zero)
{-# ATP prove gcd-S0-Divisible #-}

------------------------------------------------------------------------------
-- The gcd (succ₁ m) (succ₁ n) when succ₁ m > succ₁ n is Divisible.
-- For the proof using the ATP we added the helper hypothesis
-- c | succ₁ m → c | succ₁ c → c | succ₁ m ∸ succ₁ n.
postulate
  gcd-S>S-Divisible-ah :
    ∀ {m n} → N m → N n →
    (Divisible (succ₁ m ∸ succ₁ n) (succ₁ n) (gcd (succ₁ m ∸ succ₁ n) (succ₁ n))) →
    GT (succ₁ m) (succ₁ n) →
    ∀ c → N c → CD (succ₁ m) (succ₁ n) c →
    (c ∣ succ₁ m ∸ succ₁ n) →
    c ∣ gcd (succ₁ m) (succ₁ n)
{-# ATP prove gcd-S>S-Divisible-ah #-}

gcd-S>S-Divisible :
  ∀ {m n} → N m → N n →
  (Divisible (succ₁ m ∸ succ₁ n) (succ₁ n) (gcd (succ₁ m ∸ succ₁ n) (succ₁ n))) →
  GT (succ₁ m) (succ₁ n) →
  Divisible (succ₁ m) (succ₁ n) (gcd (succ₁ m) (succ₁ n))
gcd-S>S-Divisible {m} {n} Nm Nn acc Sm>Sn c Nc (c∣Sm , c∣Sn) =
    gcd-S>S-Divisible-ah Nm Nn acc Sm>Sn c Nc (c∣Sm , c∣Sn)
                         (x∣y→x∣z→x∣y∸z Nc (nsucc Nm) (nsucc Nn) c∣Sm c∣Sn)

------------------------------------------------------------------------------
-- The gcd (succ₁ m) (succ₁ n) when succ₁ m ≯ succ₁ n is Divisible.
-- For the proof using the ATP we added the helper hypothesis
-- c | succ₁ n → c | succ₁ m → c | succ₁ n ∸ succ₁ m.
postulate
  gcd-S≯S-Divisible-ah :
    ∀ {m n} → N m → N n →
    (Divisible (succ₁ m) (succ₁ n ∸ succ₁ m) (gcd (succ₁ m) (succ₁ n ∸ succ₁ m))) →
    NGT (succ₁ m) (succ₁ n) →
    ∀ c → N c → CD (succ₁ m) (succ₁ n) c →
    (c ∣ succ₁ n ∸ succ₁ m) →
    c ∣ gcd (succ₁ m) (succ₁ n)
{-# ATP prove gcd-S≯S-Divisible-ah #-}

gcd-S≯S-Divisible :
  ∀ {m n} → N m → N n →
  (Divisible (succ₁ m) (succ₁ n ∸ succ₁ m) (gcd (succ₁ m) (succ₁ n ∸ succ₁ m))) →
  NGT (succ₁ m) (succ₁ n) →
  Divisible (succ₁ m) (succ₁ n) (gcd (succ₁ m) (succ₁ n))
gcd-S≯S-Divisible {m} {n} Nm Nn acc Sm≯Sn c Nc (c∣Sm , c∣Sn) =
    gcd-S≯S-Divisible-ah Nm Nn acc Sm≯Sn c Nc (c∣Sm , c∣Sn)
                         (x∣y→x∣z→x∣y∸z Nc (nsucc Nn) (nsucc Nm) c∣Sn c∣Sm)

------------------------------------------------------------------------------
-- The gcd m n when m > n is Divisible.
gcd-x>y-Divisible :
  ∀ {m n} → N m → N n →
  (∀ {o p} → N o → N p → Lexi o p m n → Divisible o p (gcd o p)) →
  GT m n →
  Divisible m n (gcd m n)
gcd-x>y-Divisible nzero Nn _ 0>n _ _ = ⊥-elim $ 0>x→⊥ Nn 0>n
gcd-x>y-Divisible (nsucc Nm) nzero _ _ c Nc = gcd-S0-Divisible Nm c Nc
gcd-x>y-Divisible (nsucc {m} Nm) (nsucc {n} Nn) accH Sm>Sn c Nc =
  gcd-S>S-Divisible Nm Nn ih Sm>Sn c Nc
  where
  -- Inductive hypothesis.
  ih : Divisible (succ₁ m ∸ succ₁ n) (succ₁ n) (gcd (succ₁ m ∸ succ₁ n) (succ₁ n))
  ih = accH {succ₁ m ∸ succ₁ n}
            {succ₁ n}
            (∸-N (nsucc Nm) (nsucc Nn))
            (nsucc Nn)
            ([Sx∸Sy,Sy]<[Sx,Sy] Nm Nn)

------------------------------------------------------------------------------
-- The gcd m n when m ≯ n is Divisible.
gcd-x≯y-Divisible :
  ∀ {m n} → N m → N n →
  (∀ {o p} → N o → N p → Lexi o p m n → Divisible o p (gcd o p)) →
  NGT m n →
  Divisible m n (gcd m n)
gcd-x≯y-Divisible nzero nzero _ _ c Nc = gcd-00-Divisible c Nc
gcd-x≯y-Divisible nzero (nsucc Nn) _ _ c Nc = gcd-0S-Divisible Nn c Nc
gcd-x≯y-Divisible (nsucc _) nzero _ Sm≯0 _ _ = ⊥-elim $ S≯0→⊥ Sm≯0
gcd-x≯y-Divisible (nsucc {m} Nm) (nsucc {n} Nn) accH Sm≯Sn c Nc =
  gcd-S≯S-Divisible Nm Nn ih Sm≯Sn c Nc
  where
  -- Inductive hypothesis.
  ih : Divisible (succ₁ m) (succ₁ n ∸ succ₁ m) (gcd (succ₁ m) (succ₁ n ∸ succ₁ m))
  ih = accH {succ₁ m}
            {succ₁ n ∸ succ₁ m}
            (nsucc Nm)
            (∸-N (nsucc Nn) (nsucc Nm))
            ([Sx,Sy∸Sx]<[Sx,Sy] Nm Nn)

------------------------------------------------------------------------------
-- The gcd is Divisible.
gcd-Divisible : ∀ {m n} → N m → N n → Divisible m n (gcd m n)
gcd-Divisible = Lexi-wfind A istep
  where
  A : D → D → Set
  A i j = Divisible i j (gcd i j)

  istep : ∀ {i j} → N i → N j → (∀ {k l} → N k → N l → Lexi k l i j → A k l) →
          A i j
  istep Ni Nj accH = case (gcd-x>y-Divisible Ni Nj accH)
                          (gcd-x≯y-Divisible Ni Nj accH)
                          (x>y∨x≯y Ni Nj)
