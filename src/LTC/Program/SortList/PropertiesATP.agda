------------------------------------------------------------------------------
-- Properties stated in the Burstall's paper
------------------------------------------------------------------------------

module LTC.Program.SortList.PropertiesATP where

open import LTC.Base

open import Common.Function using ( _$_ )

open import LTC.Data.Bool.PropertiesATP
  using ( &&-proj₁
        ; &&-proj₂
        ; &&₃-proj₃
        ; &&₃-proj₄
        )

open import LTC.Data.Nat.Inequalities using ( _≤_ ; GT ; LE )
open import LTC.Data.Nat.Inequalities.PropertiesATP
   using ( x<y→x≤y
         ; x>y→x≰y
         ; x>y∨x≤y
         ; x≤x
         )
open import LTC.Data.Nat.List.Type
  using ( ListN ; consLN ; nilLN  -- The LTC list of natural numbers type.
        )
open import LTC.Data.Nat.Type
  using ( N  -- The LTC natural numbers type.
        )
open import LTC.Data.List using ( _++_ ; ++-[] ; ++-∷ )

open import LTC.Program.SortList.Properties.Closures.BoolATP
  using ( ≤-ItemList-Bool
        ; ≤-ItemTree-Bool
        ; ≤-Lists-Bool
        ; ≤-TreeItem-Bool
        ; ordList-Bool
        ; ordTree-Bool
        )
open import LTC.Program.SortList.Properties.Closures.ListATP
   using ( flatten-List )
open import LTC.Program.SortList.Properties.Closures.OrdListATP
  using ( ++-OrdList-aux
        ; flatten-OrdList-aux
        ; subList-OrdList
        )
open import LTC.Program.SortList.Properties.Closures.OrdTreeATP
  using ( leftSubTree-OrdTree
        ; rightSubTree-OrdTree
        ; toTree-OrdTree-aux₁
        ; toTree-OrdTree-aux₂
        )
open import LTC.Program.SortList.Properties.Closures.TreeATP
  using ( makeTree-Tree )
open import LTC.Program.SortList.SortList

------------------------------------------------------------------------------
-- Burstall's lemma: If t is ordered then totree(i, t) is ordered.
toTree-OrdTree : {item t : D} → N item → Tree t → OrdTree t →
                 OrdTree (toTree · item · t)
toTree-OrdTree {item} Nitem nilT _ = prf
  where
    postulate prf : OrdTree (toTree · item · nilTree)
    {-# ATP prove prf #-}

toTree-OrdTree {item} Nitem (tipT {i} Ni) _ =
  [ prf₁ , prf₂ ] (x>y∨x≤y Ni Nitem)
  where
    postulate prf₁ : GT i item → OrdTree (toTree · item · tip i)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    -- Vampire 0.6 (revision 903): No-success (using timeout 180 sec).
    {-# ATP prove prf₁ x≤x x<y→x≤y x>y→x≰y #-}

    postulate prf₂ : LE i item → OrdTree (toTree · item · tip i)
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    -- Vampire 0.6 (revision 903): No-success (using timeout 180 sec).
    {-# ATP prove prf₂ x≤x #-}

toTree-OrdTree {item} Nitem (nodeT {t₁} {i} {t₂} Tt₁ Ni Tt₂) OTnodeT =
  [ prf₁ (toTree-OrdTree Nitem Tt₁ (leftSubTree-OrdTree Tt₁ Ni Tt₂ OTnodeT))
         (rightSubTree-OrdTree Tt₁ Ni Tt₂ OTnodeT)
  , prf₂ (toTree-OrdTree Nitem Tt₂ (rightSubTree-OrdTree Tt₁ Ni Tt₂ OTnodeT))
         (leftSubTree-OrdTree Tt₁ Ni Tt₂ OTnodeT)
  ] (x>y∨x≤y Ni Nitem)
  where
    postulate prf₁ : ordTree (toTree · item · t₁) ≡ true →  -- IH.
                     OrdTree t₂ →
                     GT i item →
                     OrdTree (toTree · item · node t₁ i t₂)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    -- Vampire 0.6 (revision 903): No-success (using timeout 180 sec).
    {-# ATP prove prf₁ ≤-ItemTree-Bool ≤-TreeItem-Bool ordTree-Bool
                       x>y→x≰y &&₃-proj₃ &&₃-proj₄
                       ordTree-Bool toTree-OrdTree-aux₁
    #-}

    postulate prf₂ : ordTree (toTree · item · t₂) ≡ true → -- IH.
                     OrdTree t₁ →
                     LE i item →
                     OrdTree (toTree · item · node t₁ i t₂)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove prf₂ ≤-ItemTree-Bool ≤-TreeItem-Bool ordTree-Bool
                       &&₃-proj₃ &&₃-proj₄
                       toTree-OrdTree-aux₂
    #-}

------------------------------------------------------------------------------
-- Burstall's lemma: ord(maketree(is)).

-- makeTree-TreeOrd : {is : D} → ListN is → OrdTree (makeTree is)
-- makeTree-TreeOrd LNis =
--   ind-lit OrdTree toTree nilTree LNis ordTree-nilTree
--           (λ Nx y TOy → toTree-OrdTree Nx {!!} TOy)

makeTree-OrdTree : {is : D} → ListN is → OrdTree (makeTree is)
makeTree-OrdTree nilLN = prf
  where
    postulate prf : OrdTree (makeTree [])
    {-# ATP prove prf #-}

makeTree-OrdTree (consLN {i} {is} Ni Lis) = prf $ makeTree-OrdTree Lis
  where
    postulate prf : OrdTree (makeTree is) →  -- IH.
                    OrdTree (makeTree (i ∷ is))
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove prf makeTree-Tree toTree-OrdTree #-}

------------------------------------------------------------------------------
-- Burstall's lemma: If ord(is1) and ord(is2) and is1 ≤ is2 then
-- ord(concat(is1, is2)).
++-OrdList : {is js : D} → ListN is → ListN js → OrdList is → OrdList js →
             LE-Lists is js → OrdList (is ++ js)

++-OrdList {js = js} nilLN LNjs LOis LOjs is≤js =
  subst (λ t → OrdList t) (sym $ ++-[] js) LOjs

++-OrdList {js = js} (consLN {i} {is} Ni LNis) LNjs OLi∷is OLjs i∷is≤js =
  subst (λ t → OrdList t)
        (sym $ ++-∷ i is js)
        (lemma (++-OrdList LNis LNjs
                           (subList-OrdList Ni LNis OLi∷is)
                           OLjs
                           (&&-proj₂ (≤-ItemList-Bool Ni LNjs)
                                     (≤-Lists-Bool LNis LNjs)
                                     (trans (sym $ ≤-Lists-∷ i is js) i∷is≤js))))
  where
    postulate lemma : OrdList (is ++ js) →  -- IH
                      OrdList (i ∷ is ++ js)
    -- E 1.2: Non-tested.
    -- Metis 2.3 : Non-tested.
    -- Vampire 0.6 (revision 903): Non-tested.
    {-# ATP prove lemma ≤-ItemList-Bool ≤-Lists-Bool ordList-Bool
                        &&-proj₁ &&-proj₂
                        ++-OrdList-aux
    #-}

------------------------------------------------------------------------------
-- Burstall's lemma: If t is ordered then (flatten t) is ordered.
flatten-OrdList : {t : D} → Tree t → OrdTree t → OrdList (flatten t)
flatten-OrdList nilT OTt =
  subst (λ t → OrdList t) (sym flatten-nilTree) ordList-[]

flatten-OrdList (tipT {i} Ni) OTt = prf
  where
    postulate prf : OrdList (flatten (tip i))
    -- E 1.2: Non-tested.
    -- Equinox 5.0alpha (2010-06-29): Non-tested.
    -- Metis 2.3 (release 20101019): Non-tested.
    -- {-# ATP prove prf #-}

flatten-OrdList (nodeT {t₁} {i} {t₂} Tt₁ Ni Tt₂) OTt = prf
  where
    postulate prf : OrdList (flatten (node t₁ i t₂))
    -- Equinox 5.0alpha (2010-06-29): Non-tested.
    -- Metis 2.3 (release 20101019): Non-tested.
    -- Vampire 0.6 (revision 903): Non-tested.
    {-# ATP prove prf ++-OrdList flatten-List flatten-OrdList
                      leftSubTree-OrdTree rightSubTree-OrdTree
    #-}
