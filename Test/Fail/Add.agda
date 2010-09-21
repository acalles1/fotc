module Test.Fail.Add where

infix  4 _≡_
infixl 6 _+_

postulate
  D      : Set
  zero   : D
  succ   : D → D
  _≡_    : D → D → Set
  _+_    : D → D → D
  +-0x   : (d : D) → zero + d     ≡ d
  +-Sx   : (d e : D) → succ d + e ≡ succ (d + e)
{-# ATP axiom +-0x #-}
{-# ATP axiom +-Sx #-}

-- The ATPs should not prove this postulate.
postulate
  +-comm : (d e : D) → d + e ≡ e + d
-- E 1.2 success (SZS status CounterSatisfiable).
-- Equinox 5.0alpha (2010-03-29) no-success due to timeout.
-- Metis 2.3 (release 20100920) success (SZS status CounterSatisfiable).
{-# ATP prove +-comm #-}
