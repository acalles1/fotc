module Postulates where

open import LTC.Minimal

open import LTC.Data.N
open import LTC.Function.Arithmetic
open import LTC.Relation.Inequalities

open import MyStdLib.Induction.WellFounded

postulate
  wf-LT  : WellFounded LT
  wf-LT₂ : WellFounded₂ LT₂

postulate
  trans-LT : {m n o : D} → N m → N n → N o → LT m n → LT n o → LT m o

postulate
  Sx>Sy→[Sx-Sy,Sy]<[Sx,Sy] :
    {m n : D} → N m → N n →
    GT (succ m) (succ n) →
    LT₂ (succ m - succ n) (succ n) (succ m) (succ n)

postulate
  Sx≤Sy→[Sx,Sy-Sx]<[Sx,Sy] : {m n : D} → N m → N n → LE (succ m) (succ n) →
                             LT₂ (succ m) (succ n - succ m) (succ m) (succ n)

