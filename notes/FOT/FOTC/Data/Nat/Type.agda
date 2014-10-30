------------------------------------------------------------------------------
-- Induction principles for the total natural numbers inductive predicate
------------------------------------------------------------------------------

{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

module FOT.FOTC.Data.Nat.Type where

open import FOTC.Base hiding ( succ₁ )

------------------------------------------------------------------------------
-- We define succ₁ outside an abstract block.

succ₁ : D → D
succ₁ n = succ · n

module ConstantAndUnaryFunction where

  -- N using the constant succ.
  data N : D → Set where
    nzero : N zero
    nsucc : ∀ {n} → N n → N (succ · n)

  N-ind : (A : D → Set) →
          A zero →
          (∀ {n} → A n → A (succ · n)) →
          ∀ {n} → N n → A n
  N-ind A A0 h nzero      = A0
  N-ind A A0 h (nsucc Nn) = h (N-ind A A0 h Nn)

  -- N using the unary function succ₁.
  data N₁ : D → Set where
    nzero₁ : N₁ zero
    nsucc₁ : ∀ {n} → N₁ n → N₁ (succ₁ n)

  N-ind₁ : (A : D → Set) →
           A zero →
           (∀ {n} → A n → A (succ₁ n)) →
           ∀ {n} → N₁ n → A n
  N-ind₁ A A0 h nzero₁      = A0
  N-ind₁ A A0 h (nsucc₁ Nn) = h (N-ind₁ A A0 h Nn)

  ----------------------------------------------------------------------------
  -- From N/N₁ to N₁/N.

  N→N₁ : ∀ {n} → N n → N₁ n
  N→N₁ nzero          = nzero₁
  N→N₁ (nsucc {n} Nn) = nsucc₁ (N→N₁ Nn)

  N₁→N : ∀ {n} → N₁ n → N n
  N₁→N nzero₁           = nzero
  N₁→N (nsucc₁ {n} N₁n) = nsucc (N₁→N N₁n)

  ----------------------------------------------------------------------------
  -- From N-ind → N-ind₁.
  N-ind₁' : (A : D → Set) →
            A zero →
            (∀ {n} → A n → A (succ₁ n)) →
            ∀ {n} → N₁ n → A n
  N-ind₁' A A0 h Nn₁ = N-ind A A0 h' (N₁→N Nn₁)
    where
    h' : ∀ {n} → A n → A (succ · n)
    h' {n} An = h An

  ----------------------------------------------------------------------------
  -- From N-ind₁ → N-ind.
  N-ind' : (A : D → Set) →
           A zero →
           (∀ {n} → A n → A (succ · n)) →
           ∀ {n} → N n → A n
  N-ind' A A0 h Nn = N-ind₁ A A0 h' (N→N₁ Nn)
    where
    h' : ∀ {n} → A n → A (succ₁ n)
    h' {n} An = h An

------------------------------------------------------------------------------

module AdditionalHypotheis where

  data N : D → Set where
    nzero : N zero
    nsucc : ∀ {n} → N n → N (succ₁ n)

  -- The induction principle generated by Coq 8.4pl4 when we define
  -- the data type N in Prop.
  N-ind₁ : (A : D → Set) →
           A zero →
           (∀ {n} → N n → A n → A (succ₁ n)) →
           ∀ {n} → N n → A n
  N-ind₁ A A0 h nzero      = A0
  N-ind₁ A A0 h (nsucc Nn) = h Nn (N-ind₁ A A0 h Nn)

  -- The induction principle removing the hypothesis N n from the
  -- inductive step (see Martin-Löf 1971, p. 190).
  N-ind₂ : (A : D → Set) →
            A zero →
           (∀ {n} → A n → A (succ₁ n)) →
           ∀ {n} → N n → A n
  N-ind₂ A A0 h nzero      = A0
  N-ind₂ A A0 h (nsucc Nn) = h (N-ind₂ A A0 h Nn)

  ----------------------------------------------------------------------------
  -- N-ind₂ from N-ind₁.
  N-ind₂' : (A : D → Set) →
            A zero →
            (∀ {n} → A n → A (succ₁ n)) →
            ∀ {n} → N n → A n
  N-ind₂' A A0 h = N-ind₁ A A0 (λ _ → h)

  ----------------------------------------------------------------------------
  -- N-ind₁ from N-ind₂.
  N-ind₁' : (A : D → Set) →
            A zero →
            (∀ {n} → N n → A n → A (succ₁ n)) →
            ∀ {n} → N n → A n
  N-ind₁' A A0 h {n} Nn = ∧-proj₂ (N-ind₂ B B0 h' Nn)
    where
    B : D → Set
    B n = N n ∧ A n

    B0 : B zero
    B0 = nzero , A0

    h' : ∀ {m} → B m → B (succ₁ m)
    h' (Nm , Am) = nsucc Nm , h Nm Am

------------------------------------------------------------------------------
-- References
--
-- Martin-Löf, P. (1971). Hauptsatz for the Intuitionistic Theory of
-- Iterated Inductive Definitions. In: Proceedings of the Second
-- Scandinavian Logic Symposium. Ed. by Fenstad,
-- J. E. Vol. 63. Studies in Logic and the Foundations of
-- Mathematics. North-Holland Publishing Company, pp. 179–216.
