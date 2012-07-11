------------------------------------------------------------------------------
-- The gcd program satisfies the specification
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- This module proves the correctness of the gcd program using
-- the Euclid's algorithm.

-- N.B This module does not contain combined proofs, but it imports
-- modules which contain combined proofs.

module FOTC.Program.GCD.Partial.ProofSpecificationATP where

open import FOTC.Base
open import FOTC.Data.Nat.Divisibility.NotBy0.PropertiesATP using ( 0∤x ; x∣S→x≤S )
open import FOTC.Data.Nat.Type
open import FOTC.Program.GCD.Partial.CommonDivisorATP using ( gcd-CD )
open import FOTC.Program.GCD.Partial.Definitions using ( x≢0≢y ; GCD )
open import FOTC.Program.GCD.Partial.DivisibleATP using ( gcd-Divisible )
open import FOTC.Program.GCD.Partial.GCD using ( gcd )

import FOTC.Program.GCD.Partial.GreatestAnyCommonDivisor
open module GreatestAnyCommonDivisorATP =
  FOTC.Program.GCD.Partial.GreatestAnyCommonDivisor x∣S→x≤S 0∤x
  using ( gcd-GACD )

open import FOTC.Program.GCD.Partial.TotalityATP using ( gcd-N )

------------------------------------------------------------------------------
-- The gcd is the GCD.
postulate gcd-GCD : ∀ {m n} → N m → N n → x≢0≢y m n → GCD m n (gcd m n)
{-# ATP prove gcd-GCD gcd-CD gcd-GACD gcd-N gcd-Divisible #-}

-- gcd-GCD Nm Nn m≢0≢n = gcd-CD Nm Nn m≢0≢n
--                     , gcd-GACD (gcd-N Nm Nn m≢0≢n)
--                                (gcd-CD Nm Nn m≢0≢n)
--                                (gcd-Divisible Nm Nn m≢0≢n)