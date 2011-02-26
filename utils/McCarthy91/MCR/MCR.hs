{-# LANGUAGE UnicodeSyntax #-}

-- We test some properties of the relation MCR with QuickCheck.

-- Tested with GHC 7.01 and QuickCheck 2.4.0.1.

module Main where

import Test.QuickCheck

------------------------------------------------------------------------------

-- From http://byorgey.wordpress.com/2010/11/:
-- Note that the auto-derived Ord instance have exactly the right
-- behavior due to the fact that we happened to list the Zero
-- constructor first.

data Nat = Zero | Succ Nat
           deriving (Eq, Ord)

fromNat ∷ Nat → Integer
fromNat Zero     = 0
fromNat (Succ n) = 1 + fromNat n

instance Show Nat where
    show = show . fromNat

-- The truncated subtraction.
(∸) ∷ Nat → Nat → Nat
m      ∸ Zero   = m
Zero   ∸ Succ _ = Zero
Succ m ∸ Succ n = m ∸ n

-- Adapted from http://byorgey.wordpress.com/2010/11/.
instance Num Nat where
  Zero   + n = n
  Succ m + n = Succ (m + n)

  Zero   * _ = Zero
  Succ m * n = n + m * n

  -- Is it necessary?
  -- (-) = (∸)

  fromInteger n | n < 0 = error "No can do."
  fromInteger 0         = Zero
  fromInteger n         = Succ (fromInteger (n - 1))

  negate = error "negate is not required"
  abs    = error "abs is not required"
  signum = error "signum is not required"

instance Arbitrary Nat where
  arbitrary = (fromInteger . unNN) `fmap` arbitrary
      where
        unNN ∷ NonNegative Integer → Integer
        unNN (NonNegative x) = x

------------------------------------------------------------------------------

-- We want to copy-paste from the Agda code.
(≡) :: Eq a ⇒ a → a → Bool
(≡) = (==)

-- The MCR relation.
mcr ∷ Nat → Nat → Bool
mcr m n = (101 ∸ m) < (101 ∸ n)

-- Some properties of the relation MCR

prop1 ∷ Nat → Nat → Property
prop1 m n = mcr (Succ m) (Succ n) ==> mcr m n

prop2 ∷ Nat → Nat → Property
prop2 m n = mcr m n ==> mcr (Succ m) (Succ n)

prop3 ∷ Nat → Nat → Property
prop3 m n = m > 95 && n > 95 && mcr m n ==>
            mcr (Succ m) (Succ n)

main ∷ IO ()
main = do
  -- quickCheck prop3
  quickCheckWith (stdArgs { maxDiscard = 75000 }) prop3
