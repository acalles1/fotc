------------------------------------------------------------------------------
-- A looping combinator
------------------------------------------------------------------------------

module LTC-PCF.Loop where

open import LTC-PCF.Base

------------------------------------------------------------------------------

loop : D
loop = fix₁ (λ f → f)
