------------------------------------------------------------------------------
-- Properties related with the forest type
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

module FOTC.Program.Mirror.Forest.PropertiesATP where

open import Common.FOL.Relation.Binary.EqReasoning

open import FOTC.Base
open FOTC.Base.BList
open import FOTC.Data.List
open import FOTC.Data.List.PropertiesI hiding
 ( ++-assoc
 ; ++-rightIdentity
 ; map-++-commute
 ; rev-++-commute
 ; reverse-++-commute
 ; reverse-∷
 )
open import FOTC.Program.Mirror.Forest.TotalityATP
open import FOTC.Program.Mirror.Type

------------------------------------------------------------------------------

++-rightIdentity : ∀ {xs} → Forest xs → xs ++ [] ≡ xs
++-rightIdentity fnil                    = ++-leftIdentity []
++-rightIdentity (fcons {x} {xs} Tx Fxs) = prf (++-rightIdentity Fxs)
  where postulate prf : xs ++ [] ≡ xs → (x ∷ xs) ++ [] ≡ x ∷ xs
        {-# ATP prove prf #-}

++-assoc : ∀ {xs} → Forest xs → ∀ ys zs → (xs ++ ys) ++ zs ≡ xs ++ (ys ++ zs)
++-assoc fnil ys zs = prf
  where postulate prf : ([] ++ ys) ++ zs ≡ [] ++ ys ++ zs
        {-# ATP prove prf #-}

++-assoc (fcons {x} {xs} Tx Fxs) ys zs = prf (++-assoc Fxs ys zs)
  where postulate prf : (xs ++ ys) ++ zs ≡ xs ++ ys ++ zs →
                        ((x ∷ xs) ++ ys) ++ zs ≡ (x ∷ xs) ++ ys ++ zs
        {-# ATP prove prf #-}

-- We don't use an automatic proof, because it is necessary to erase a
-- proof term which we don't know how to erase.
map-++-commute : ∀ f {xs} → (∀ {x} → Tree x → Tree (f · x)) →
                 Forest xs → ∀ ys →
                 map f (xs ++ ys) ≡ map f xs ++ map f ys
map-++-commute f h fnil ys =
  map f ([] ++ ys)
    ≡⟨ mapRightCong (++-leftIdentity ys) ⟩
  map f ys
    ≡⟨ sym (++-leftIdentity (map f ys)) ⟩
  [] ++ map f ys
     ≡⟨ ++-leftCong (sym (map-[] f)) ⟩
  map f [] ++ map f ys ∎

map-++-commute f h (fcons {x} {xs} Tx Fxs) ys =
  map f ((x ∷ xs) ++ ys)
    ≡⟨ mapRightCong (++-∷ x xs ys) ⟩
  map f (x ∷ xs ++ ys)
    ≡⟨ map-∷ f x (xs ++ ys) ⟩
  f · x ∷ map f (xs ++ ys)
    ≡⟨ ∷-rightCong (map-++-commute f h Fxs ys) ⟩
  f · x ∷ (map f xs ++ map f ys)
    ≡⟨ sym (++-∷ (f · x) (map f xs) (map f ys)) ⟩
  (f · x ∷ map f xs) ++ map f ys
     ≡⟨ ++-leftCong (sym (map-∷ f x xs)) ⟩
  map f (x ∷ xs) ++ map f ys ∎

rev-++-commute : ∀ {xs} → Forest xs → ∀ ys → rev xs ys ≡ rev xs [] ++ ys
rev-++-commute fnil ys = prf
  where postulate prf : rev [] ys ≡ rev [] [] ++ ys
        {-# ATP prove prf #-}

rev-++-commute (fcons {x} {xs} Tx Fxs) ys =
  prf (rev-++-commute Fxs (x ∷ ys))
      (rev-++-commute Fxs (x ∷ []))
  where postulate prf : rev xs (x ∷ ys) ≡ rev xs [] ++ x ∷ ys →
                        rev xs (x ∷ []) ≡ rev xs [] ++ x ∷ [] →
                        rev (x ∷ xs) ys ≡ rev (x ∷ xs) [] ++ ys
        {-# ATP prove prf ++-assoc rev-Forest #-}

reverse-++-commute : ∀ {xs ys} → Forest xs → Forest ys →
                     reverse (xs ++ ys) ≡ reverse ys ++ reverse xs
reverse-++-commute {ys = ys} fnil Fys = prf
  where postulate prf : reverse ([] ++ ys) ≡ reverse ys ++ reverse []
        {-# ATP prove prf ++-rightIdentity reverse-Forest #-}

reverse-++-commute (fcons {x} {xs} Tx Fxs) fnil = prf
  where
  postulate prf : reverse ((x ∷ xs) ++ []) ≡ reverse [] ++ reverse (x ∷ xs)
  {-# ATP prove prf ++-rightIdentity #-}

reverse-++-commute (fcons {x} {xs} Tx Fxs) (fcons {y} {ys} Ty Fys) =
  prf (reverse-++-commute Fxs (fcons Ty Fys))
  where
  postulate prf : reverse (xs ++ y ∷ ys) ≡ reverse (y ∷ ys) ++
                                           reverse xs →
                  reverse ((x ∷ xs) ++ y ∷ ys) ≡ reverse (y ∷ ys) ++
                                                 reverse (x ∷ xs)
  {-# ATP prove prf reverse-Forest ++-Forest rev-++-commute ++-assoc #-}

reverse-∷ : ∀ {x ys} → Tree x → Forest ys →
            reverse (x ∷ ys) ≡ reverse ys ++ (x ∷ [])
reverse-∷ {x} Tx fnil = prf
  where postulate prf : reverse (x ∷ []) ≡ reverse [] ++ x ∷ []
        {-# ATP prove prf #-}

reverse-∷ {x} Tx (fcons {y} {ys} Ty Fys) = prf
  where postulate prf : reverse (x ∷ y ∷ ys) ≡ reverse (y ∷ ys) ++ x ∷ []
        {-# ATP prove prf reverse-[x]≡[x] reverse-++-commute #-}
