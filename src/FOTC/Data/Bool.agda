------------------------------------------------------------------------------
-- The booleans
------------------------------------------------------------------------------

module FOTC.Data.Bool where

open import FOTC.Base

-- We add 3 to the fixities of the standard library.
infixr 9 _&&_

------------------------------------------------------------------------------
-- The FOTC booleans type.
open import FOTC.Data.Bool.Type public

------------------------------------------------------------------------------
-- Basic functions

-- The conjunction.
postulate
  _&&_  : D → D → D
  &&-tt : true  && true  ≡ true
  &&-tf : true  && false ≡ false
  &&-ft : false && true  ≡ false
  &&-ff : false && false ≡ false
{-# ATP axiom &&-tt #-}
{-# ATP axiom &&-tf #-}
{-# ATP axiom &&-ft #-}
{-# ATP axiom &&-ff #-}

-- The negation.
postulate
  not : D → D
  not-t : not true ≡ false
  not-f : not false ≡ true
