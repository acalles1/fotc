------------------------------------------------------------------------------
-- Streams properties
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Data.Stream.PropertiesI where

open import FOTC.Base
open import FOTC.Base.List
open import FOTC.Base.List.PropertiesI
open import FOTC.Data.Conat
open import FOTC.Data.Conat.Equality
open import FOTC.Data.Colist
open import FOTC.Data.Colist.PropertiesI
open import FOTC.Data.List
open import FOTC.Data.List.PropertiesI
open import FOTC.Data.Stream

-----------------------------------------------------------------------------
-- Because a greatest post-fixed point is a fixed-point, then the
-- Stream predicate is also a pre-fixed point of the functional
-- StreamF, i.e.
--
-- StreamF Stream ≤ Stream (see FOTC.Data.Stream.Type).
Stream-pre-fixed : ∀ {xs} →
                   (∃[ x' ] ∃[ xs' ] xs ≡ x' ∷ xs' ∧ Stream xs') →
                   Stream xs
Stream-pre-fixed {xs} h = Stream-coind (λ ys → ys ≡ ys) h' refl
  where
  h' : xs ≡ xs → ∃[ x' ] ∃[ xs' ] xs ≡ x' ∷ xs' ∧ xs' ≡ xs'
  h' _ with h
  ... | x' , xs' , prf , _ = x' , xs' , prf , refl

∷-Stream : ∀ {x xs} → Stream (x ∷ xs) → Stream xs
∷-Stream h with Stream-unf h
... | x' , xs' , prf , Sxs' =
  subst Stream (sym (∧-proj₂ (∷-injective prf))) Sxs'

Stream→Colist : ∀ {xs} → Stream xs → Colist xs
Stream→Colist Sxs with Stream-unf Sxs
... | x' , xs' , prf , Sxs' =
  Colist-coind
    (λ ys → ys ≡ ys)
    (λ _ → inj₂ (x' , xs' , prf , refl))
    refl

++-Stream : ∀ {xs ys} → Colist xs → Stream ys → Stream (xs ++ ys)
++-Stream {xs} {ys} CLxs Sys with Colist-unf CLxs
... | inj₁ prf = subst Stream (sym prf₁) Sys
  where
  prf₁ : xs ++ ys ≡ ys
  prf₁ = trans (++-leftCong prf) (++-[] ys)

... | inj₂ (x' , xs' , prf , CLxs') = subst Stream (sym prf₁) prf₂
  where
  prf₁ : xs ++ ys ≡ x' ∷ (xs' ++ ys)
  prf₁ = trans (++-leftCong prf) (++-∷ x' xs' ys)

  prf₂ : Stream (x' ∷ xs' ++ ys)
  prf₂ = Stream-coind
           (λ zs → zs ≡ zs)
           (λ _ → x' , xs' ++ ys , refl , refl)
           refl

-- A different proof.
++-Stream' : ∀ {xs ys} → Colist xs → Stream ys → Stream (xs ++ ys)
++-Stream' {xs} {ys} CLxs Sys with Colist-unf CLxs
... | inj₁ prf = subst Stream (sym prf₁) Sys
  where
  prf₁ : xs ++ ys ≡ ys
  prf₁ = trans (++-leftCong prf) (++-[] ys)

... | inj₂ (x' , xs' , prf , CLxs') = subst Stream (sym prf₁) prf₂
  where
  prf₁ : xs ++ ys ≡ x' ∷ (xs' ++ ys)
  prf₁ = trans (++-leftCong prf) (++-∷ x' xs' ys)

  -- TODO (15 December 2013): Why the termination checker accepts the
  -- recursive called ++-Stream_CLxs'_Sys?
  prf₂ : Stream (x' ∷ xs' ++ ys)
  prf₂ = Stream-pre-fixed
           (x' , (xs' ++ ys) , refl , ++-Stream CLxs' Sys)

streamLength : ∀ {xs} → Stream xs → length xs ≈N ∞
streamLength {xs} Sxs = ≈N-coind (λ m _ → m ≡ m) h refl
  where

  h : length xs ≡ length xs → length xs ≡ zero ∧ ∞ ≡ zero
        ∨ (∃[ m ] ∃[ n ] length xs ≡ succ₁ m ∧ ∞ ≡ succ₁ n ∧ m ≡ m)
  h _ with Stream-unf Sxs
  ... | x' , xs' , xs≡x'∷xs' , _ = inj₂ (length xs' , ∞ , prf , ∞-eq , refl)
    where
    prf : length xs ≡ succ₁ (length xs')
    prf = trans (lengthCong xs≡x'∷xs') (length-∷ x' xs')
