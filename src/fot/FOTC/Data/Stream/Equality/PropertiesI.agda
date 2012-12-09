------------------------------------------------------------------------------
-- Properties for the equality on streams
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Data.Stream.Equality.PropertiesI where

open import FOTC.Base
open import FOTC.Base.List
open import FOTC.Data.Stream
open import FOTC.Relation.Binary.Bisimilarity

------------------------------------------------------------------------------

≈-Stream-refl : ∀ {xs} → Stream xs → xs ≈ xs
≈-Stream-refl {xs} Sxs = ≈-coind R h₁ h₂
  where
  R : D → D → Set
  R xs ys = Stream xs ∧ Stream xs ∧ xs ≡ ys

  h₁ : ∀ {xs ys} → R xs ys → ∃[ x' ] ∃[ xs' ] ∃[ ys' ]
       R xs' ys' ∧ xs ≡ x' ∷ xs' ∧ ys ≡ x' ∷ ys'
  h₁ (Sxs , Sys , refl) with (Stream-unf Sxs)
  ... | x' , xs' , Sxs' , prf = x' , xs' , xs' , (Sxs' , Sxs' , refl) , prf , prf

  h₂ : R xs xs
  h₂ = Sxs , Sxs , refl

≡→≈-Stream : ∀ {xs ys} → Stream xs → Stream ys → xs ≡ ys → xs ≈ ys
≡→≈-Stream Sxs _ refl = ≈-Stream-refl Sxs

≈→Stream : ∀ {xs ys} → xs ≈ ys → Stream xs ∧ Stream ys
≈→Stream {xs} {ys} h = Stream-coind P₁ h₁ (ys , h) , Stream-coind P₂ h₂ (xs , h)
  where
  P₁ : D → Set
  P₁ ws = ∃[ zs ] ws ≈ zs

  h₁ : ∀ {ws} → P₁ ws → ∃[ w' ] ∃[ ws' ] P₁ ws' ∧ ws ≡ w' ∷ ws'
  h₁ {ws} (zs , h₁) with ≈-unf h₁
  ... | w' , ws' , zs' , prf₁ , prf₂ , _ = w' , ws' , (zs' , prf₁) , prf₂

  P₂ : D → Set
  P₂ zs = ∃[ ws ] ws ≈ zs

  h₂ : ∀ {zs} → P₂ zs → ∃[ z' ] ∃[ zs' ] P₂ zs' ∧ zs ≡ z' ∷ zs'
  h₂  {zs} (ws , h₁) with ≈-unf h₁
  ... | w' , ws' , zs' , prf₁ , _ , prf₂ = w' , zs' , (ws' , prf₁) , prf₂