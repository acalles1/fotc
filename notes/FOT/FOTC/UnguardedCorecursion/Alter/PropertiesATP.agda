------------------------------------------------------------------------------
-- Properties of the alter list
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOT.FOTC.UnguardedCorecursion.Alter.PropertiesATP where

open import FOT.FOTC.UnguardedCorecursion.Alter.Alter

open import FOTC.Base
open import FOTC.Base.List
open import FOTC.Data.Stream
open import FOTC.Relation.Binary.Bisimilarity

------------------------------------------------------------------------------

alter-Stream : Stream alter
alter-Stream = Stream-coind A h refl
  where
  A : D → Set
  A xs = xs ≡ xs
  {-# ATP definition A #-}

  postulate h : A alter → ∃[ x' ] ∃[ xs' ] alter ≡ x' ∷ xs' ∧ A xs'
  {-# ATP prove h #-}

alter'-Stream : Stream alter'
alter'-Stream = Stream-coind A h refl
  where
  A : D → Set
  A xs = xs ≡ xs
  {-# ATP definition A #-}

  postulate h : A alter' → ∃[ x' ] ∃[ xs' ] alter' ≡ x' ∷ xs' ∧ A xs'
  {-# ATP prove h #-}

alter≈alter' : alter ≈ alter'
alter≈alter' = ≈-coind A h₁ h₂
  where
  A : D → D → Set
  A xs ys = xs ≡ xs
  {-# ATP definition A #-}

  postulate h₁ : A alter alter' → ∃[ x' ] ∃[ xs' ] ∃[ ys' ]
                   alter ≡ x' ∷ xs' ∧ alter' ≡ x' ∷ ys' ∧ A xs' ys'
  {-# ATP prove h₁ #-}

  postulate h₂ : A alter alter'
  {-# ATP prove h₂ #-}
