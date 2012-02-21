------------------------------------------------------------------------------
-- FOL with equality
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- This module exported all the logical constants and the
-- propositional equality. This module is re-exported by the "base"
-- modules whose theories are defined on FOL + equality.

module FOL.FOL-Eq where

-- FOL (without equality).
open import FOL.FOL public

-- The propositional equality.
import FOL.Relation.Binary.PropositionalEquality
open module Eq =
  FOL.Relation.Binary.PropositionalEquality.Inductive public
