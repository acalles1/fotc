------------------------------------------------------------------------------
-- Proving properties without using pattern matching on refl
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOT.DistributiveLaws.NoPatternMatchingOnRefl where

open import DistributiveLaws.Base

------------------------------------------------------------------------------
-- From DistributiveLaws.PropertiesI

-- Congruence properties

·-leftCong : ∀ {a b c} → a ≡ b → a · c ≡ b · c
·-leftCong {a} {c = c} h = subst (λ t → a · c ≡ t · c ) h refl

·-rightCong : ∀ {a b c} → b ≡ c → a · b ≡ a · c
·-rightCong {a} {b} h = subst (λ t → a · b ≡ a · t) h refl