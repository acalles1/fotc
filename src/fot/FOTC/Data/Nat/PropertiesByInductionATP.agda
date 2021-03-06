------------------------------------------------------------------------------
-- Arithmetic properties (using induction on the FOTC natural numbers type)
------------------------------------------------------------------------------

{-# OPTIONS --exact-split              #-}
{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

-- Usually our proofs use pattern matching instead of the induction
-- principle associated with the FOTC natural numbers. The following
-- examples show some proofs using it.

module FOTC.Data.Nat.PropertiesByInductionATP where

open import FOTC.Base
open import FOTC.Data.Nat

------------------------------------------------------------------------------

+-leftIdentity : ∀ n → zero + n ≡ n
+-leftIdentity n = +-0x n

+-rightIdentity : ∀ {n} → N n → n + zero ≡ n
+-rightIdentity Nn = N-ind A A0 is Nn
  where
  A : D → Set
  A i = i + zero ≡ i
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is #-}

+-N : ∀ {m n} → N m → N n → N (m + n)
+-N {n = n} Nm Nn = N-ind A A0 is Nm
  where
  A : D → Set
  A i = N (i + n)
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is #-}

+-assoc : ∀ {m} → N m → ∀ n o → m + n + o ≡ m + (n + o)
+-assoc Nm n o = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + n + o ≡ i + (n + o)
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is #-}

-- A proof without use ATPs definitions.
+-assoc' : ∀ {m} → N m → ∀ n o → m + n + o ≡ m + (n + o)
+-assoc' Nm n o = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + n + o ≡ i + (n + o)

  postulate A0 : zero + n + o ≡ zero + (n + o)
  {-# ATP prove A0 #-}

  postulate is : ∀ {i} →
                 i + n + o ≡ i + (n + o) →
                 succ₁ i + n + o ≡ succ₁ i + (n + o)
  {-# ATP prove is #-}

x+Sy≡S[x+y] : ∀ {m} → N m → ∀ n → m + succ₁ n ≡ succ₁ (m + n)
x+Sy≡S[x+y] Nm n = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + succ₁ n ≡ succ₁ (i + n)
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is #-}

+-comm : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm {n = n} Nm Nn = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + n ≡ n + i
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 +-rightIdentity #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is x+Sy≡S[x+y] #-}
