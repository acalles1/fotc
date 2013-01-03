------------------------------------------------------------------------------
-- Stream properties using the standard library
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOT.FOTC.Data.Stream.PropertiesSL where

open import Data.Nat
open import Data.Stream

open import Coinduction

------------------------------------------------------------------------------

zeros : Stream ℕ
zeros = zero ∷ ♯ zeros