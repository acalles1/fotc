------------------------------------------------------------------------------
-- Testing the translation of definitions
------------------------------------------------------------------------------

module Test.Succeed.Definition2 where

postulate
  D   : Set
  _≡_ : D → D → Set

-- We test the translation of the definition of a 1-ary function.
foo : D → D
foo d = d
{-# ATP definition foo #-}

postulate bar : ∀ d → d ≡ foo d
{-# ATP prove bar #-}
