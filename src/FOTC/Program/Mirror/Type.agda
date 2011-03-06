------------------------------------------------------------------------------
-- Types used by the mirror function
------------------------------------------------------------------------------

module FOTC.Program.Mirror.Type where

open import FOTC.Base

open import FOTC.Data.List

------------------------------------------------------------------------------
-- Tree terms.
postulate
  node : D → D → D

mutual
  -- The list of trees type.
  data ListTree : D → Set where
    nilLT  : ListTree []
    consLT : ∀ {t ts} → Tree t → ListTree ts → ListTree (t ∷ ts)

  -- The tree type.
  data Tree : D → Set where
    treeT : ∀ d {ts} → ListTree ts → Tree (node d ts)

{-# ATP hint nilLT #-}
{-# ATP hint consLT #-}
{-# ATP hint treeT #-}

-- Induction principle for Tree.
indTree : (P : D → Set) →
          (∀ d {ts} → ListTree ts → P (node d ts)) →
          ∀ {t} → Tree t → P t
indTree P h (treeT d LTts) = h d LTts

-- Induction principle for ListTree.
indListTree : (P : D → Set) →
              P [] →
              (∀ {t ts} → Tree t → ListTree ts → P ts → P (t ∷ ts)) →
              ∀ {ts} → ListTree ts → P ts
indListTree P P[] h nilLT            = P[]
indListTree P P[] h (consLT Tt LTts) = h Tt LTts (indListTree P P[] h LTts)
