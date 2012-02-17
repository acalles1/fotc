------------------------------------------------------------------------------
-- ABP lemma 2
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- From Dybjer and Sander's paper: The second lemma states that given
-- a state of the latter kind (see lemma 1) we will arrive at a new
-- start state, which is identical to the old start state except that
-- the bit has alternated and the first item in the input stream has
-- been removed.

module FOTC.Program.ABP.Lemma2ATP where

open import FOTC.Base
open import FOTC.Data.Bool
open import FOTC.Data.Bool.PropertiesATP
open import FOTC.Data.List
open import FOTC.Program.ABP.ABP
open import FOTC.Program.ABP.Fair
open import FOTC.Program.ABP.Fair.PropertiesATP
open import FOTC.Program.ABP.Terms
open import FOTC.Relation.Binary.EqReasoning

------------------------------------------------------------------------------
-- Helper function for the ABP lemma 1

module Helper where
  -- We have these TPTP definitions outside the where clause to keep
  -- them simple for the ATPs.

  ds⁵ : D → D → D
  ds⁵ cs' fs₁⁵ = corrupt · fs₁⁵ · cs'
  {-# ATP definition ds⁵ #-}

  as⁵ : D → D → D → D → D → D
  as⁵ b i' is' cs' fs₁⁵ = await b i' is' (ds⁵ cs' fs₁⁵)
  {-# ATP definition as⁵ #-}

  bs⁵ : D → D → D → D → D → D → D
  bs⁵ b i' is' cs' fs₀⁵ fs₁⁵ = corrupt · fs₀⁵ · as⁵ b i' is' cs' fs₁⁵
  {-# ATP definition bs⁵ #-}

  cs⁵ : D → D → D → D → D → D → D
  cs⁵ b i' is' cs' fs₀⁵ fs₁⁵ = abpack · (not b) · bs⁵ b i' is' cs' fs₀⁵ fs₁⁵
  {-# ATP definition cs⁵ #-}

  fs₀⁵ : D → D
  fs₀⁵ fs₀' = tail₁ fs₀'
  {-# ATP definition fs₀⁵ #-}

  fs₁⁵ : D → D → D
  fs₁⁵ ft₁ fs₁'' = ft₁ ++ fs₁''
  {-# ATP definition fs₁⁵ #-}

  helper : ∀ {b i' is' fs₀' fs₁' as' bs' cs' ds' js'} →
           Bit b →
           Fair fs₀' →
           Abp' b i' is' fs₀' fs₁' as' bs' cs' ds' js' →
           ∃[ ft₁ ] ∃[ fs₁'' ] F*T ft₁ ∧ Fair fs₁'' ∧ fs₁' ≡ ft₁ ++ fs₁'' →
           ∃[ fs₀'' ] ∃[ fs₁'' ] ∃[ as'' ] ∃[ bs'' ] ∃[ cs'' ] ∃[ ds'' ]
           Fair fs₀''
           ∧ Fair fs₁''
           ∧ Abp (not b) is' fs₀'' fs₁'' as'' bs'' cs'' ds'' js'
  helper {b} {i'} {is'} {js' = js'} Bb Ffs₀' abp'
         (.(T ∷ []) , fs₁'' , nilF*T , Ffs₁'' , fs₁'-eq) = prf
    where
    postulate
      prf : ∃[ fs₀'' ] ∃[ fs₁'' ] ∃[ as'' ] ∃[ bs'' ] ∃[ cs'' ] ∃[ ds'' ]
            Fair fs₀''
            ∧ Fair fs₁''
            ∧ as'' ≡ abpsend · not b · is' · ds''
            ∧ bs'' ≡ corrupt · fs₀'' · as''
            ∧ cs'' ≡ abpack · not b · bs''
            ∧ ds'' ≡ corrupt · fs₁'' · cs''
            ∧ js' ≡ abpout · not b · bs''
    {-# ATP prove prf #-}

  helper {b} {i'} {is'} {fs₀'} {fs₁'} {as'} {bs'} {cs'} {ds'} {js'}
         Bb Ffs₀' abp'
         (.(F ∷ ft₁) , fs₁'' , consF*T {ft₁} FTft₁ , Ffs₁'' , fs₁'-eq)
         = helper Bb (tail-Fair Ffs₀') Abp'IH (ft₁ , fs₁'' , FTft₁ , Ffs₁'' , refl)
    where
    postulate fs₁'-eq-helper : fs₁' ≡ F ∷ fs₁⁵ ft₁ fs₁''
    {-# ATP prove fs₁'-eq-helper #-}

    postulate ds'-eq : ds' ≡ error ∷ ds⁵ cs' (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove ds'-eq fs₁'-eq-helper #-}

    postulate as'-eq : as' ≡ < i' , b > ∷ as⁵ b i' is' cs' (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove as'-eq #-}

    postulate
      bs'-eq-helper₁ : fs₀' ≡ T ∷ tail₁ fs₀' →
                       bs' ≡ ok < i' , b > ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove bs'-eq-helper₁ as'-eq #-}

    postulate
      bs'-eq-helper₂ : fs₀' ≡ F ∷ tail₁ fs₀' →
                       bs' ≡ error ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove bs'-eq-helper₁ as'-eq #-}

    bs'-eq : bs' ≡ ok < i' , b > ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
             ∨ bs' ≡ error ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    bs'-eq = [ (λ h → inj₁ (bs'-eq-helper₁ h))
             , (λ h → inj₂ (bs'-eq-helper₂ h))
             ] (head-tail-Fair Ffs₀')

    postulate
      cs'-eq-helper₁ : bs' ≡ ok < i' , b > ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'') →
                       cs' ≡ b ∷ cs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove cs'-eq-helper₁ not-x≠x not² #-}

    postulate
      cs'-eq-helper₂ : bs' ≡ error ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'') →
                       cs' ≡ b ∷ cs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove cs'-eq-helper₂ not² #-}

    cs'-eq : cs' ≡ b ∷ cs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    cs'-eq = [ cs'-eq-helper₁ , cs'-eq-helper₂ ] bs'-eq

    postulate
      js'-eq-helper₁ : bs' ≡ ok < i' , b > ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'') →
                       js' ≡ abpout · (not b)
                                    · bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove js'-eq-helper₁ not-x≠x #-}

    postulate
      js'-eq-helper₂ : bs' ≡ error ∷ bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'') →
                       js' ≡ abpout · (not b)
                                    · bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    {-# ATP prove js'-eq-helper₂ #-}

    js'-eq : js' ≡ abpout · (not b) · bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁'')
    js'-eq = [ js'-eq-helper₁ , js'-eq-helper₂ ] bs'-eq

    postulate
      ds⁵-eq : ds⁵ cs' (fs₁⁵ ft₁ fs₁'') ≡
               corrupt · (fs₁⁵ ft₁ fs₁'')
                       · (b ∷ cs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁''))

    Abp'IH : Abp' b i' is'
                  (fs₀⁵ fs₀')
                  (fs₁⁵ ft₁ fs₁'')
                  (as⁵ b i' is' cs' (fs₁⁵ ft₁ fs₁''))
                  (bs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁''))
                  (cs⁵ b i' is' cs' (fs₀⁵ fs₀') (fs₁⁵ ft₁ fs₁''))
                  (ds⁵ cs' (fs₁⁵ ft₁ fs₁''))
                  js'
    Abp'IH = ds⁵-eq , refl , refl , refl , js'-eq

------------------------------------------------------------------------------
-- From Dybjer and Sander's paper: From the assumption that fs₁ ∈
-- Fair, and hence by unfolding Fair we conclude that there are ft₁ :
-- F*T and fs₁'' : Fair, such that fs₁' = ft₁ ++ fs₁''.
--
-- We proceed by induction on ft₁ : F*T using helper.

open Helper
lemma₂ : ∀ {b i' is' fs₀' fs₁' as' bs' cs' ds' js'} →
         Bit b →
         Fair fs₀' →
         Fair fs₁' →
         Abp' b i' is' fs₀' fs₁' as' bs' cs' ds' js' →
         ∃[ fs₀'' ] ∃[ fs₁'' ] ∃[ as'' ] ∃[ bs'' ] ∃[ cs'' ] ∃[ ds'' ]
         Fair fs₀''
         ∧ Fair fs₁''
         ∧ Abp (not b) is' fs₀'' fs₁'' as'' bs'' cs'' ds'' js'
lemma₂ Bb Ffs₀' Ffs₁' abp' = helper Bb Ffs₀' abp' (Fair-gfp₁ Ffs₁')
