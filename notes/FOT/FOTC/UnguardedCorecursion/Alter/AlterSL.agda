------------------------------------------------------------------------------
-- Alter: An unguarded co-recursive function
------------------------------------------------------------------------------

{-# OPTIONS --exact-split              #-}
{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

module FOT.FOTC.UnguardedCorecursion.Alter.AlterSL where

open import Data.Bool.Base
open import Data.Stream
open import Coinduction

------------------------------------------------------------------------------

alter : Stream Bool
alter = true ∷ ♯ (false ∷ ♯ alter)

{-# TERMINATING #-}
alter' : Stream Bool
alter' = true ∷ ♯ (map not alter')
