------------------------------------------------------------------------------
-- All the distributive laws modules
------------------------------------------------------------------------------

{-# OPTIONS --exact-split              #-}
{-# OPTIONS --no-sized-types           #-}
{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K                #-}

module DistributiveLaws.Everything where

open import DistributiveLaws.Base
open import DistributiveLaws.Base.Consistency.Axioms
open import DistributiveLaws.PropertiesI

open import DistributiveLaws.Lemma3-ATP
open import DistributiveLaws.Lemma4-ATP
open import DistributiveLaws.Lemma5-ATP
open import DistributiveLaws.Lemma6-ATP

open import DistributiveLaws.TaskB-AllStepsATP
open import DistributiveLaws.TaskB-HalvedStepsATP
open import DistributiveLaws.TaskB-I
open import DistributiveLaws.TaskB-TopDownATP
open import DistributiveLaws.TaskB.UnprovedATP
