------------------------------------------------------------------------------
-- The McCarthy 91 function: A function with nested recursion
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Program.McCarthy91.McCarthy91 where

open import FOTC.Base
open import FOTC.Data.Nat
open import FOTC.Data.Nat.Inequalities
open import FOTC.Data.Nat.UnaryNumbers

------------------------------------------------------------------------------
-- The McCarthy 91 function.
postulate
  mc91    : D → D
  mc91-eq : ∀ n → mc91 n ≡ if (gt n [100])
                              then n ∸ [10]
                              else mc91 (mc91 (n + [11]))
{-# ATP axiom mc91-eq #-}
