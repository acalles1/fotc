------------------------------------------------------------------------------
-- Commutativity of addition of total natural numbers
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOT.FOTC.Data.Nat.AddComm where

open import Common.FOL.Relation.Binary.EqReasoning

open import FOTC.Base
open import FOTC.Data.Nat

------------------------------------------------------------------------------
-- Auxiliary properties

succCong : ∀ {m n} → m ≡ n → succ₁ m ≡ succ₁ n
succCong refl = refl

+-leftIdentity : ∀ n → zero + n ≡ n
+-leftIdentity n = +-0x n

+-rightIdentity : ∀ {n} → N n → n + zero ≡ n
+-rightIdentity Nn = N-ind A A0 is Nn
  where
  A : D → Set
  A i = i + zero ≡ i

  A0 : A zero
  A0 = +-leftIdentity zero

  is : ∀ {i} → A i → A (succ₁ i)
  is {i} Ai = trans (+-Sx i zero) (succCong Ai)

x+Sy≡S[x+y] : ∀ {m} → N m → ∀ n → m + succ₁ n ≡ succ₁ (m + n)
x+Sy≡S[x+y] Nm n = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + succ₁ n ≡ succ₁ (i + n)

  A0 : A zero
  A0 = zero + succ₁ n   ≡⟨ +-leftIdentity (succ₁ n) ⟩
       succ₁ n          ≡⟨ succCong (sym (+-leftIdentity n)) ⟩
       succ₁ (zero + n) ∎

  is : ∀ {i} → A i → A (succ₁ i)
  is {i} Ai = succ₁ i + succ₁ n     ≡⟨ +-Sx i (succ₁ n) ⟩
              succ₁ (i + succ₁ n)   ≡⟨ succCong Ai ⟩
              succ₁ (succ₁ (i + n)) ≡⟨ succCong (sym (+-Sx i n)) ⟩
              succ₁ (succ₁ i + n)   ∎

------------------------------------------------------------------------------
-- Approach 1: Interactive proof using pattern matching

+-comm₁ : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm₁ {n = n} nzero Nn =
  zero + n ≡⟨ +-leftIdentity n ⟩
  n        ≡⟨ sym (+-rightIdentity Nn) ⟩
  n + zero ∎

+-comm₁ {n = n} (nsucc {m} Nm) Nn =
  succ₁ m + n   ≡⟨ +-Sx m n ⟩
  succ₁ (m + n) ≡⟨ succCong (+-comm₁ Nm Nn) ⟩
  succ₁ (n + m) ≡⟨ sym (x+Sy≡S[x+y] Nn m) ⟩
  n + succ₁ m   ∎

------------------------------------------------------------------------------
-- Approach 2: Interactive proof using the induction principle

+-comm₂ : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm₂ {n = n} Nm Nn = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + n ≡ n + i

  A0 : A zero
  A0 = zero + n ≡⟨ +-leftIdentity n ⟩
       n        ≡⟨ sym (+-rightIdentity Nn) ⟩
       n + zero ∎

  is : ∀ {i} → A i → A (succ₁ i)
  is {i} Ai = succ₁ i + n   ≡⟨ +-Sx i n ⟩
              succ₁ (i + n) ≡⟨ succCong Ai ⟩
              succ₁ (n + i) ≡⟨ sym (x+Sy≡S[x+y] Nn i) ⟩
              n + succ₁ i   ∎

------------------------------------------------------------------------------
-- Approach 3: Combined proof using pattern matching

+-comm₃ : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm₃ {n = n} nzero Nn = prf
  where postulate prf : zero + n ≡ n + zero
        {-# ATP prove prf +-rightIdentity #-}
+-comm₃ {n = n} (nsucc {m} Nm) Nn = prf (+-comm₃ Nm Nn)
  where postulate prf : m + n ≡ n + m → succ₁ m + n ≡ n + succ₁ m
        {-# ATP prove prf x+Sy≡S[x+y] #-}

------------------------------------------------------------------------------
-- Approach 4: Combined proof using the induction principle

+-comm₄ : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm₄ {n = n} Nm Nn = N-ind A A0 is Nm
  where
  A : D → Set
  A i = i + n ≡ n + i
  {-# ATP definition A #-}

  postulate A0 : A zero
  {-# ATP prove A0 +-rightIdentity #-}

  postulate is : ∀ {i} → A i → A (succ₁ i)
  {-# ATP prove is x+Sy≡S[x+y] #-}

------------------------------------------------------------------------------
-- Approach 5: Combined proof using an instance of the induction
-- principle

+-comm-ind-instance :
  ∀ n →
  zero + n ≡ n + zero →
  (∀ {m} → m + n ≡ n + m → succ₁ m + n ≡ n + succ₁ m) →
  ∀ {m} → N m → m + n ≡ n + m
+-comm-ind-instance n = N-ind (λ i → i + n ≡ n + i)

-- TODO (25 October 2012): Why is it not necessary the hypothesis
-- +-rightIdentity?
postulate +-comm₅ : ∀ {m n} → N m → N n → m + n ≡ n + m
{-# ATP prove +-comm₅ +-comm-ind-instance x+Sy≡S[x+y] #-}
