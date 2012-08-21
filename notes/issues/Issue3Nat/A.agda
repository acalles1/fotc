{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module Issue3Nat.A where

data ℕ : Set where
  zero : ℕ
  succ : ℕ → ℕ
