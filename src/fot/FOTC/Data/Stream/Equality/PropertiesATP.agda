------------------------------------------------------------------------------
-- Properties for the equality on streams
------------------------------------------------------------------------------

{-# OPTIONS --exact-split              #-}
{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

module FOTC.Data.Stream.Equality.PropertiesATP where

open import FOTC.Base
open import FOTC.Base.List
open import FOTC.Data.Stream.Type
open import FOTC.Relation.Binary.Bisimilarity.PropertiesATP
open import FOTC.Relation.Binary.Bisimilarity.Type

------------------------------------------------------------------------------

postulate stream-≡→≈ : ∀ {xs ys} → Stream xs → Stream ys → xs ≡ ys → xs ≈ ys
{-# ATP prove stream-≡→≈ ≈-refl #-}

≈→Stream₁ : ∀ {xs ys} → xs ≈ ys → Stream xs
≈→Stream₁ {xs} {ys} h = Stream-coind A h' (ys , h)
  where
  A : D → Set
  A ws = ∃[ zs ] ws ≈ zs
  {-# ATP definition A #-}

  postulate h' : ∀ {xs} → A xs → ∃[ x' ] ∃[ xs' ] xs ≡ x' ∷ xs' ∧ A xs'
  {-# ATP prove h' #-}

≈→Stream₂ : ∀ {xs ys} → xs ≈ ys → Stream ys
≈→Stream₂ {xs} {ys} h = Stream-coind A h' (xs , h)
  where
  A : D → Set
  A zs = ∃[ ws ] ws ≈ zs
  {-# ATP definition A #-}

  postulate h' : ∀ {ys} → A ys → ∃[ y' ] ∃[ ys' ] ys ≡ y' ∷ ys' ∧ A ys'
  {-# ATP prove h' #-}

≈→Stream : ∀ {xs ys} → xs ≈ ys → Stream xs ∧ Stream ys
≈→Stream {xs} {ys} h = ≈→Stream₁ h , ≈→Stream₂ h
