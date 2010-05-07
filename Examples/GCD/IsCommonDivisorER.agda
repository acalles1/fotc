------------------------------------------------------------------------------
-- The gcd is a common divisor
------------------------------------------------------------------------------

module Examples.GCD.IsCommonDivisorER where

open import LTC.Minimal
open import LTC.MinimalER

open import Examples.GCD.Equations
open import Examples.GCD.IsN-ER
open import Examples.GCD.Types

open import LTC.Data.N
open import LTC.Data.N.Induction.Lexicographic
open import LTC.Function.Arithmetic
open import LTC.Function.Arithmetic.PropertiesER
open import LTC.Relation.Divisibility
open import LTC.Relation.Divisibility.PropertiesER
open import LTC.Relation.Equalities.PropertiesER
open import LTC.Relation.Inequalities
open import Postulates
  using ( Sx>Sy→[Sx-Sy,Sy]<[Sx,Sy]
        ; Sx≤Sy→[Sx,Sy-Sx]<[Sx,Sy]
        )
open import LTC.Relation.Inequalities.PropertiesER

open import MyStdLib.Function
import MyStdLib.Induction.Lexicographic
open module IsCommonDivisor-ER-LT₂ = MyStdLib.Induction.Lexicographic LT LT

---------------------------------------------------------------------------
-- Common divisor.

CD : D → D → D → Set
CD a b c = (c ∣ a) ∧ (c ∣ b)

-- We will prove that 'gcd-CD : ... → CD m n (gcd m n).

---------------------------------------------------------------------------
-- Some cases of the gcd-∣₁
---------------------------------------------------------------------------

-- We don't prove that 'gcd-∣₁ : ... → (gcd m n) ∣ m'
-- because this proof should be defined mutually recursive with the proof
-- 'gcd-∣₂ : ... → (gcd m n) ∣ n'. Therefore, instead of prove
-- 'gcd-CD : ... → CD m n (gcd m n)' using these proofs (i.e. the conjunction
-- of them), we proved it using well-founded induction.

---------------------------------------------------------------------------
-- 'gcd 0 (succ n) ∣ 0'.

gcd-0S-∣₁ : {n : D} → N n → gcd zero (succ n) ∣ zero
gcd-0S-∣₁ {n} Nn = subst (λ x → x ∣ zero )
                         (sym (gcd-0S n))
                         (S∣0 Nn)

-----------------------------------------------------------------------
-- 'gcd (succ m) 0 ∣ succ m'.

gcd-S0-∣₁ : {m : D} → N m → gcd (succ m) zero ∣ succ m
gcd-S0-∣₁ {m} Nm = subst (λ x → x ∣ (succ m ))
                         (sym (gcd-S0 m))
                         (∣-refl-S Nm)

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ m', when 'succ m ≤ succ n'.

gcd-S≤S-∣₁ :
  {m n : D} → N m → N n →
  (gcd (succ m) (succ n - succ m) ∣ succ m) →
  LE (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ m
gcd-S≤S-∣₁ {m} {n} Nm Nn ih Sm≤Sn =
  subst (λ x → x ∣ succ m )
        (sym (gcd-S≤S m n Sm≤Sn))
        ih

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ m' when 'succ m > succ n'.

-- We use gcd-∣₂
-- We apply the theorem that if 'm∣n' and 'm∣o' then 'm∣(n+o)'.

gcd-S>S-∣₁ :
  {m n : D} → N m → N n →
  (gcd (succ m - succ n) (succ n) ∣ (succ m - succ n)) →
  (gcd (succ m - succ n) (succ n) ∣ succ n) →
  GT (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ m

{- Proof:
1. gcd (Sm - Sn) Sn | (Sm - Sn)        IH
2. gcd (Sm - Sn) Sn | Sn               gcd-∣₂
3. gcd (Sm - Sn) Sn | (Sm - Sn) + Sn   m∣n→m∣o→m∣n+o 1,2
4. Sm > Sn                             Hip
5. gcd (Sm - Sn) Sn | Sm               arith-gcd-m>n₂ 3,4
6. gcd Sm Sn = gcd (Sm - Sn) Sn        gcd eq. 4
7. gcd Sm Sn | Sm                      subst 5,6
-}

gcd-S>S-∣₁ {m} {n} Nm Nn ih gcd-∣₂ Sm>Sn =
  -- The first substitution is based on
  -- 'gcd (succ m) (succ n) = gcd (succ m - succ n) (succ n)'.
  subst (λ x → x ∣ (succ m) )
        (sym (gcd-S>S m n Sm>Sn))
        -- The second substitution is based on
        -- 'm = (m - n) + n'.
        (subst (λ y → gcd (succ m - succ n) (succ n) ∣ y )
               ( x>y→x-y+y≡x (sN Nm) (sN Nn) Sm>Sn)
               ( x∣y→x∣z→x∣y+z
                 {gcd (succ m - succ n) (succ n)}
                 {succ m - succ n}
                 {succ n}
                 (gcd-N (Sm-Sn-N , sN Nn ) (λ p → ⊥-elim (¬S≡0 (∧-proj₂ p))))
                 Sm-Sn-N
                 (sN Nn)
                 ih
                 gcd-∣₂
               )
       )
  where Sm-Sn-N : N (succ m - succ n)
        Sm-Sn-N = minus-N (sN Nm) (sN Nn)

---------------------------------------------------------------------------
-- Some case of the gcd-∣₂
---------------------------------------------------------------------------

-- We don't prove that 'gcd-∣₂ : ... → gcd m n ∣ n'. The reason is
-- the same to don't prove 'gcd-∣₁ : ... → gcd m n ∣ m'.

---------------------------------------------------------------------------
-- 'gcd 0 (succ n) ∣₂ succ n'.

gcd-0S-∣₂ : {n : D} → N n → gcd zero (succ n) ∣ succ n
gcd-0S-∣₂ {n} Nn = subst (λ x → x ∣ (succ n ))
                         (sym (gcd-0S n))
                         (∣-refl-S Nn)

---------------------------------------------------------------------------
-- 'gcd (succ m) 0 ∣ 0'.

gcd-S0-∣₂ : {m : D} → N m → gcd (succ m) zero ∣ zero
gcd-S0-∣₂  {m} Nm = subst (λ x → x ∣ zero )
                          (sym (gcd-S0 m))
                          (S∣0 Nm)

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ n' when 'succ m > succ n'.

gcd-S>S-∣₂ :
  {m n : D} → N m → N n →
  (gcd (succ m - succ n) (succ n) ∣ succ n) →
  GT (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ n

gcd-S>S-∣₂ {m} {n} Nm Nn ih Sm>Sn =
  subst (λ x → x ∣ (succ n) )
        (sym (gcd-S>S m n Sm>Sn))
        ih

---------------------------------------------------------------------------
-- 'gcd (succ m) (succ n) ∣ succ n' when 'succ m ≤ succ n'.

-- We use gcd-∣₁.
-- We apply the theorem that if 'm∣n' and 'm∣o' then 'm∣(n+o)'.
gcd-S≤S-∣₂ :
  {m n : D} → N m → N n →
  (gcd (succ m) (succ n - succ m) ∣ (succ n - succ m)) →
  (gcd (succ m) (succ n - succ m) ∣ succ m) →
  LE (succ m) (succ n) →
  gcd (succ m) (succ n) ∣ succ n

{- Proof:
1. gcd Sm (Sn - Sm) | (Sn - Sm)        IH
2  gcd Sm (Sn - Sm) | Sm               gcd-∣₁
3. gcd Sm (Sn - Sm) | (Sn - Sm) + Sm   m∣n→m∣o→m∣n+o 1,2
4. Sm ≤ Sn                             Hip
5. gcd (Sm - Sn) Sn | Sm               arith-gcd-m≤n₂ 3,4
6. gcd Sm Sn = gcd Sm (Sn - Sm)        gcd eq. 4
7. gcd Sm Sn | Sn                      subst 5,6
-}

gcd-S≤S-∣₂ {m} {n} Nm Nn ih gcd-∣₁ Sm≤Sn =
  -- The first substitution is based on 'gcd m n = gcd m (n - m)'.
  subst (λ x → x ∣ succ n )
        (sym (gcd-S≤S m n Sm≤Sn ))
         -- The second substitution is based on.
         -- 'n = (n - m) + m'
        (subst (λ y → gcd (succ m) (succ n - succ m) ∣ y )
               ( x≤y→y-x+x≡y (sN Nm) (sN Nn) Sm≤Sn )
               ( x∣y→x∣z→x∣y+z
                   {gcd (succ m) (succ n - succ m)}
                   {succ n - succ m}
                   {succ m}
                   (gcd-N (sN Nm , Sn-Sm-N)
                          (λ p → ⊥-elim (¬S≡0 (∧-proj₁ p))))
                   Sn-Sm-N
                   (sN Nm )
                   ih
                   gcd-∣₁
               )
        )

  where Sn-Sm-N : N (succ n - succ m)
        Sn-Sm-N = minus-N (sN Nn) (sN Nm)

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
  {mn : D × D} → N₂ mn →
  ((op : D × D ) → LT₂ op mn →
       N₂ op →
       ¬x≡0∧y≡0 (×-proj₁ op) (×-proj₂ op) →
       CD (×-proj₁ op) (×-proj₂ op) (gcd (×-proj₁ op) (×-proj₂ op))) →
  GT (×-proj₁ mn) (×-proj₂ mn) →
  ¬x≡0∧y≡0 (×-proj₁ mn) (×-proj₂ mn) →
  CD (×-proj₁ mn) (×-proj₂ mn) (gcd (×-proj₁ mn) (×-proj₂ mn))

gcd-x>y-CD (zN , zN ) _ _ ¬0≡0∧0≡0   = ⊥-elim $ ¬0≡0∧0≡0 (refl , refl)
gcd-x>y-CD (zN , sN Nn ) _ 0>Sn _  = ⊥-elim (¬0>x (sN Nn) 0>Sn)
gcd-x>y-CD (sN Nm , zN ) _ _  _    = gcd-S0-CD Nm
gcd-x>y-CD (sN {m} Nm , sN {n} Nn ) allAcc Sm>Sn _  =
  gcd-S>S-CD Nm Nn ih Sm>Sn
  where
    -- Inductive hypothesis.
    ih : CD (succ m - succ n) (succ n) (gcd (succ m - succ n) (succ n))
    ih  = allAcc (succ m - succ n , succ n)
                 (Sx>Sy→[Sx-Sy,Sy]<[Sx,Sy] Nm Nn Sm>Sn)
                 (minus-N (sN Nm) (sN Nn) , sN Nn)
                 (λ p → ⊥-elim $ ¬S≡0 $ ∧-proj₂ p)

---------------------------------------------------------------------------
-- The 'gcd m n' when 'm ≤ n' is CD.

-- N.B. If '≤' were an inductive data type, we would use the absurd pattern
-- to prove the third case.

gcd-x≤y-CD :
  {mn : D × D} → N₂ mn →
  ((op : D × D ) → LT₂ op mn →
       N₂ op →
       ¬x≡0∧y≡0 (×-proj₁ op) (×-proj₂ op) →
       CD (×-proj₁ op) (×-proj₂ op) (gcd (×-proj₁ op) (×-proj₂ op))) →
  LE (×-proj₁ mn) (×-proj₂ mn) →
  ¬x≡0∧y≡0 (×-proj₁ mn) (×-proj₂ mn) →
  CD (×-proj₁ mn) (×-proj₂ mn) (gcd (×-proj₁ mn) (×-proj₂ mn))

gcd-x≤y-CD (zN , zN )_ _ ¬0≡0∧0≡0   = ⊥-elim $ ¬0≡0∧0≡0 (refl , refl)
gcd-x≤y-CD (zN , sN Nn ) _ _ _     = gcd-0S-CD Nn
gcd-x≤y-CD (sN _ , zN ) _ Sm≤0 _  = ⊥-elim $ ¬S≤0 Sm≤0
gcd-x≤y-CD (sN {m} Nm , sN {n} Nn ) allAcc Sm≤Sn _ =
  gcd-S≤S-CD Nm Nn ih Sm≤Sn
  where
    -- Inductive hypothesis
    ih : CD (succ m) (succ n - succ m)  (gcd (succ m) (succ n - succ m))
    ih = allAcc (succ m , succ n - succ m)
                (Sx≤Sy→[Sx,Sy-Sx]<[Sx,Sy] Nm Nn Sm≤Sn)
                (sN Nm , minus-N (sN Nn) (sN Nm))
                (λ p → ⊥-elim $ ¬S≡0 $ ∧-proj₁ p )

---------------------------------------------------------------------------
-- The 'gcd' is CD.

gcd-CD : {mn : D × D } → N₂ mn →
         ¬x≡0∧y≡0 (×-proj₁ mn) (×-proj₂ mn) →
         CD (×-proj₁ mn) (×-proj₂ mn) (gcd (×-proj₁ mn) (×-proj₂ mn))
gcd-CD = wellFoundedInd-N₂ P istep
  where
    P : D × D → Set
    P ij = ¬x≡0∧y≡0 i j → CD i j  (gcd i j )
      where i : D
            i = ×-proj₁ ij
            j : D
            j = ×-proj₂ ij

    istep :
      (ij : D × D) → ((kl : D × D) → LT₂ kl ij → N₂ kl → P kl) → N₂ ij → P ij
    istep ij allAcc N₂ij =
      [ gcd-x>y-CD N₂ij allAcc
      , gcd-x≤y-CD N₂ij allAcc
      ] (x>y∨x≤y (N₂-proj₁ N₂ij) (N₂-proj₂ N₂ij))
