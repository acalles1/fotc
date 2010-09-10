------------------------------------------------------------------------------
-- The gcd is a common divisor
------------------------------------------------------------------------------

module Examples.GCD.IsCommonDivisor where

open import LTC.Minimal

open import Examples.GCD.GCD using ( gcd )
open import Examples.GCD.IsN using ( gcd-N )
open import Examples.GCD.Types using ( ¬x≡0∧y≡0 )

open import LTC.Data.Nat using
  ( _+_ ; _-_
  ; N ; sN ; zN -- The LTC natural numbers type
  )
open import LTC.Data.Nat.Divisibility using ( _∣_ )
open import LTC.Data.Nat.Divisibility.Properties using
  ( ∣-refl-S
  ; x∣y→x∣z→x∣y+z
  )
open import LTC.Data.Nat.Induction.Lexicographic using ( wfIndN-LT₂ )
open import LTC.Data.Nat.Inequalities using ( GT ; LE ; LT₂ )
open import LTC.Data.Nat.Inequalities.Properties using
  ( ¬0>x
  ; ¬S≤0
  ; x>y→x-y+y≡x
  ; x≤y→y-x+x≡y
  ; x>y∨x≤y
  ; [Sx-Sy,Sy]<[Sx,Sy]
  ; [Sx,Sy-Sx]<[Sx,Sy]
  )
open import LTC.Data.Nat.Properties using ( minus-N )
open import LTC.Relation.Equalities.Properties using ( ¬S≡0 )

open import MyStdLib.Function using ( _$_)

---------------------------------------------------------------------------
-- Common divisor.
---------------------------------------------------------------------------

CD : D → D → D → Set
CD m n d = (d ∣ m) ∧ (d ∣ n)
{-# ATP definition CD #-}

-- We will prove that 'gcd-CD : ... → CD m n (gcd m n).

---------------------------------------------------------------------------
-- Some cases of the gcd-∣₁
---------------------------------------------------------------------------

-- We don't prove that 'gcd-∣₁ : ... → (gcd m n) ∣ m'
-- because this proof should be defined mutually recursive with the proof
-- 'gcd-∣₂ : ... → (gcd m n) ∣ n'. Therefore, instead of prove
-- 'gcd-CD : ... → CD m n (gcd m n)' using these proof (i.e. the conjunction
-- of them), we proved it using well-found induction.

---------------------------------------------------------------------------
-- 'gcd 0 (succ n) ∣ 0'.

postulate gcd-0S-∣₁ : {n : D} → N n → gcd zero (succ n) ∣ zero
{-# ATP prove gcd-0S-∣₁ zN #-}

-----------------------------------------------------------------------
-- 'gcd (succ m) 0 ∣ succ m'.

postulate gcd-S0-∣₁ : {n : D} → N n → gcd (succ n) zero ∣ succ n
{-# ATP prove gcd-S0-∣₁ ∣-refl-S #-}

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ m', when 'succ m ≤ succ n'.

postulate
  gcd-S≤S-∣₁ :
    {m n : D} → N m → N n →
    (gcd (succ m) (succ n - succ m) ∣ succ m) →
    LE (succ m) (succ n) →
    gcd (succ m) (succ n) ∣ succ m
-- Equinox 5.0alpha (2010-03-29) proved this conjecture very fast.
-- E 1.2 no-success due to timeout (180).
{-# ATP prove gcd-S≤S-∣₁ #-}

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ m' when 'succ m > succ n'.

{- Proof:
1. gcd (Sm - Sn) Sn | (Sm - Sn)        IH
2. gcd (Sm - Sn) Sn | Sn               gcd-∣₂
3. gcd (Sm - Sn) Sn | (Sm - Sn) + Sn   m∣n→m∣o→m∣n+o 1,2
4. Sm > Sn                             Hip
5. gcd (Sm - Sn) Sn | Sm               arith-gcd-m>n₂ 3,4
6. gcd Sm Sn = gcd (Sm - Sn) Sn        gcd eq. 4
7. gcd Sm Sn | Sm                      subst 5,6
-}

-- For the proof using the ATP we added the auxiliary hypothesis:
-- 1. gcd (succ m - succ n) (succ n) ∣ (succ m - succ n) + succ n.
-- 2. (succ m - succ n) + succ n ≡ succ m.

postulate
  gcd-S>S-∣₁-ah :
    {m n : D} → N m → N n →
    (gcd (succ m - succ n) (succ n) ∣ (succ m - succ n)) →
    (gcd (succ m - succ n) (succ n) ∣ succ n) →
    GT (succ m) (succ n) →
    gcd (succ m - succ n) (succ n) ∣ (succ m - succ n) + succ n →
    ((succ m - succ n) + succ n ≡ succ m) →
    gcd (succ m) (succ n) ∣ succ m
-- E 1.2 no-success due to timeout (180).
{-# ATP prove gcd-S>S-∣₁-ah #-}

gcd-S>S-∣₁ :
  {m n : D} → N m → N n →
  (gcd (succ m - succ n) (succ n) ∣ (succ m - succ n)) →
  (gcd (succ m - succ n) (succ n) ∣ succ n) →
  GT (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ m
gcd-S>S-∣₁ {m} {n} Nm Nn ih gcd-∣₂ Sm>Sn =
  gcd-S>S-∣₁-ah Nm Nn ih gcd-∣₂ Sm>Sn
    (x∣y→x∣z→x∣y+z gcd-Sm-Sn,Sn-N Sm-Sn-N (sN Nn) ih gcd-∣₂)
    (x>y→x-y+y≡x (sN Nm) (sN Nn) Sm>Sn)

  where
  Sm-Sn-N : N (succ m - succ n)
  Sm-Sn-N = minus-N (sN Nm) (sN Nn)

  gcd-Sm-Sn,Sn-N : N (gcd (succ m - succ n) (succ n))
  gcd-Sm-Sn,Sn-N = gcd-N Sm-Sn-N (sN Nn) (λ p → ⊥-elim (¬S≡0 (∧-proj₂ p)))

---------------------------------------------------------------------------
-- Some case of the gcd-∣₂
---------------------------------------------------------------------------

-- We don't prove that 'gcd-∣₂ : ... → gcd m n ∣ n'. The reason is
-- the same to don't prove 'gcd-∣₁ : ... → gcd m n ∣ m'.

---------------------------------------------------------------------------
-- 'gcd 0 (succ n) ∣₂ succ n'.

postulate gcd-0S-∣₂ : {n : D} → N n → gcd zero (succ n) ∣ succ n
{-# ATP prove gcd-0S-∣₂ ∣-refl-S #-}

---------------------------------------------------------------------------
-- 'gcd (succ m) 0 ∣ 0'.

postulate gcd-S0-∣₂ : {m : D} → N m → gcd (succ m) zero ∣ zero
{-# ATP prove gcd-S0-∣₂ zN #-}

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ n' when 'succ m ≤ succ n'.

{- Proof:
1. gcd Sm (Sn - Sm) | (Sn - Sm)        IH
2  gcd Sm (Sn - Sm) | Sm               gcd-∣₁
3. gcd Sm (Sn - Sm) | (Sn - Sm) + Sm   m∣n→m∣o→m∣n+o 1,2
4. Sm ≤ Sn                             Hip
5. gcd (Sm - Sn) Sn | Sm               arith-gcd-m≤n₂ 3,4
6. gcd Sm Sn = gcd Sm (Sn - Sm)        gcd eq. 4
7. gcd Sm Sn | Sn                      subst 5,6
-}

-- For the proof using the ATP we added the auxiliary hypothesis:
-- 1. gcd (succ m) (succ n - succ m) ∣ (succ n - succ m) + succ m.
-- 2 (succ n - succ m) + succ m ≡ succ n.

postulate
  gcd-S≤S-∣₂-ah :
    {m n : D} → N m → N n →
    (gcd (succ m) (succ n - succ m) ∣ (succ n - succ m)) →
    (gcd (succ m) (succ n - succ m) ∣ succ m) →
    LE (succ m) (succ n) →
    (gcd (succ m) (succ n - succ m) ∣ (succ n - succ m) + succ m) →
    ((succ n - succ m) + succ m ≡ succ n) →
    gcd (succ m) (succ n) ∣ succ n
-- E 1.2 no-success due to timeout (180).
{-# ATP prove gcd-S≤S-∣₂-ah #-}

gcd-S≤S-∣₂ :
  {m n : D} → N m → N n →
  (gcd (succ m) (succ n - succ m) ∣ (succ n - succ m)) →
  (gcd (succ m) (succ n - succ m) ∣ succ m) →
  LE (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ n
gcd-S≤S-∣₂ {m} {n} Nm Nn ih gcd-∣₁ Sm≤Sn =
  gcd-S≤S-∣₂-ah Nm Nn ih gcd-∣₁ Sm≤Sn
    (x∣y→x∣z→x∣y+z gcd-Sm,Sn-Sm-N Sn-Sm-N (sN Nm) ih gcd-∣₁)
    (x≤y→y-x+x≡y (sN Nm) (sN Nn) Sm≤Sn)

  where
  Sn-Sm-N : N (succ n - succ m)
  Sn-Sm-N = minus-N (sN Nn) (sN Nm)

  gcd-Sm,Sn-Sm-N : N (gcd (succ m) (succ n - succ m))
  gcd-Sm,Sn-Sm-N = gcd-N (sN Nm) (Sn-Sm-N) (λ p → ⊥-elim (¬S≡0 (∧-proj₁ p)))

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ n' when 'succ m > succ n'.

postulate
  gcd-S>S-∣₂ :
    {m n : D} → N m → N n →
    (gcd (succ m - succ n) (succ n) ∣ succ n) →
    GT (succ m) (succ n) →
    gcd (succ m) (succ n) ∣ succ n
{-# ATP prove gcd-S>S-∣₂ #-}

---------------------------------------------------------------------------
-- The gcd is CD
---------------------------------------------------------------------------

-- We will prove that 'gcd-CD : ... → CD m n (gcd m n).

---------------------------------------------------------------------------
-- The 'gcd 0 (succ n)' is CD.

gcd-0S-CD : {n : D} → N n → CD zero (succ n) (gcd zero (succ n))
gcd-0S-CD Nn = ( gcd-0S-∣₁ Nn , gcd-0S-∣₂ Nn )

-----------------------------------------------------------------------
-- The 'gcd (succ m) 0 ' is CD.

gcd-S0-CD : {m : D} → N m → CD (succ m) zero (gcd (succ m) zero)
gcd-S0-CD Nm = ( gcd-S0-∣₁ Nm , gcd-S0-∣₂ Nm )

---------------------------------------------------------------------------
-- The 'gcd (succ m) (succ n)' when 'succ m > succ n' is CD.

gcd-S>S-CD :
  {m n : D} → N m → N n →
  (CD (succ m - succ n) (succ n) (gcd (succ m - succ n) (succ n))) →
  GT (succ m) (succ n) →
  CD (succ m) (succ n) (gcd (succ m) (succ n))
gcd-S>S-CD {m} {n} Nm Nn acc Sm>Sn =
   ( gcd-S>S-∣₁ Nm Nn acc-∣₁ acc-∣₂ Sm>Sn , gcd-S>S-∣₂ Nm Nn acc-∣₂ Sm>Sn )
  where
    acc-∣₁ : gcd (succ m - succ n) (succ n) ∣ (succ m - succ n)
    acc-∣₁ = ∧-proj₁ acc

    acc-∣₂ : gcd (succ m - succ n) (succ n) ∣ succ n
    acc-∣₂ = ∧-proj₂ acc

---------------------------------------------------------------------------
-- The 'gcd (succ m) (succ n)' when 'succ m ≤ succ n' is CD.

gcd-S≤S-CD :
  {m n : D} → N m → N n →
  (CD (succ m) (succ n - succ m) (gcd (succ m) (succ n - succ m))) →
  LE (succ m) (succ n) →
  CD (succ m) (succ n) (gcd (succ m) (succ n))
gcd-S≤S-CD {m} {n} Nm Nn acc Sm≤Sn =
  ( gcd-S≤S-∣₁ Nm Nn acc-∣₁ Sm≤Sn , gcd-S≤S-∣₂ Nm Nn acc-∣₂ acc-∣₁ Sm≤Sn )
  where
    acc-∣₁ : gcd (succ m) (succ n - succ m) ∣ succ m
    acc-∣₁ = ∧-proj₁ acc

    acc-∣₂ : gcd (succ m) (succ n - succ m) ∣ (succ n - succ m)
    acc-∣₂ = ∧-proj₂ acc

---------------------------------------------------------------------------
-- The 'gcd m n' when 'm > n' is CD

-- N.B. If '>' were an inductive data type, we would use the absurd pattern
-- to prove the second case.

gcd-x>y-CD :
  {m n : D} → N m → N n →
  ({o p : D} → N o → N p → LT₂ o p m n → ¬x≡0∧y≡0 o p → CD o p (gcd o p)) →
  GT m n →
  ¬x≡0∧y≡0 m n →
  CD m n (gcd m n)
gcd-x>y-CD zN zN _ _ ¬0≡0∧0≡0   = ⊥-elim $ ¬0≡0∧0≡0 (refl , refl)
gcd-x>y-CD zN (sN Nn) _ 0>Sn _  = ⊥-elim (¬0>x (sN Nn) 0>Sn)
gcd-x>y-CD (sN Nm) zN _ _  _    = gcd-S0-CD Nm
gcd-x>y-CD (sN {m} Nm) (sN {n} Nn) accH Sm>Sn _  =
  gcd-S>S-CD Nm Nn ih Sm>Sn
  where
    -- Inductive hypothesis.
    ih : CD (succ m - succ n) (succ n) (gcd (succ m - succ n) (succ n))
    ih  = accH {succ m - succ n}
               {succ n}
               (minus-N (sN Nm) (sN Nn))
               (sN Nn)
               ([Sx-Sy,Sy]<[Sx,Sy] Nm Nn)
               (λ p → ⊥-elim $ ¬S≡0 $ ∧-proj₂ p)

---------------------------------------------------------------------------
-- The 'gcd m n' when 'm ≤ n' is CD.

-- N.B. If '≤' were an inductive data type, we would use the absurd pattern
-- to prove the third case.

gcd-x≤y-CD :
  {m n : D} → N m → N n →
  ({o p : D} → N o → N p → LT₂ o p m n → ¬x≡0∧y≡0 o p → CD o p (gcd o p)) →
  LE m n →
  ¬x≡0∧y≡0 m n →
  CD m n (gcd m n)
gcd-x≤y-CD zN zN _ _ ¬0≡0∧0≡0   = ⊥-elim $ ¬0≡0∧0≡0 (refl , refl)
gcd-x≤y-CD zN (sN Nn) _ _ _     = gcd-0S-CD Nn
gcd-x≤y-CD (sN Nm) zN _ Sm≤0 _  = ⊥-elim $ ¬S≤0 Nm Sm≤0
gcd-x≤y-CD (sN {m} Nm) (sN {n} Nn) accH Sm≤Sn _ =
  gcd-S≤S-CD Nm Nn ih Sm≤Sn
  where
    -- Inductive hypothesis
    ih : CD (succ m) (succ n - succ m)  (gcd (succ m) (succ n - succ m))
    ih = accH {succ m}
              {succ n - succ m}
              (sN Nm)
              (minus-N (sN Nn) (sN Nm))
              ([Sx,Sy-Sx]<[Sx,Sy] Nm Nn)
              (λ p → ⊥-elim $ ¬S≡0 $ ∧-proj₁ p)

---------------------------------------------------------------------------
-- The 'gcd' is CD.

gcd-CD : {m n : D} → N m → N n → ¬x≡0∧y≡0 m n → CD m n (gcd m n)
gcd-CD = wfIndN-LT₂ P istep
  where
    P : D → D → Set
    P i j = ¬x≡0∧y≡0 i j → CD i j (gcd i j)

    istep :
      {i j : D} → N i → N j →
      ({k l : D} → N k → N l → LT₂ k l i j → P k l) →
      P i j
    istep Ni Nj accH =
      [ gcd-x>y-CD Ni Nj accH
      , gcd-x≤y-CD Ni Nj accH
      ] (x>y∨x≤y Ni Nj)
