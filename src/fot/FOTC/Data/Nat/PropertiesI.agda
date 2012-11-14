------------------------------------------------------------------------------
-- Arithmetic properties
------------------------------------------------------------------------------

{-# OPTIONS --no-universe-polymorphism #-}
{-# OPTIONS --without-K #-}

-- References:
--
-- M. J. Beeson. Proving programs and programming proofs. In Ruth
-- Barcan Marcus, George J. W. Dorn, and Paul Weingartner,
-- editors. Logic, Methodology and Philosophy of Science VII (1983),
-- volume 114 of Studies in Logic and the Foundations of
-- Mathematics. North-Holland Publishing Company, 1988, pages 51–82.

module FOTC.Data.Nat.PropertiesI where

open import Common.FOL.Relation.Binary.EqReasoning

open import FOTC.Base
open import FOTC.Base.PropertiesI
open import FOTC.Data.Nat
open import FOTC.Data.Nat.UnaryNumbers

------------------------------------------------------------------------------
-- Congruence properties

succCong : ∀ {m n} → m ≡ n → succ₁ m ≡ succ₁ n
succCong refl = refl

predCong : ∀ {m n} → m ≡ n → pred₁ m ≡ pred₁ n
predCong refl = refl

+-leftCong : ∀ {m n o} → m ≡ n → m + o ≡ n + o
+-leftCong refl = refl

+-rightCong : ∀ {m n o} → n ≡ o → m + n ≡ m + o
+-rightCong refl = refl

∸-leftCong : ∀ {m n o} → m ≡ n → m ∸ o ≡ n ∸ o
∸-leftCong refl = refl

∸-rightCong : ∀ {m n o} → n ≡ o → m ∸ n ≡ m ∸ o
∸-rightCong refl = refl

*-leftCong : ∀ {m n o} → m ≡ n → m * o ≡ n * o
*-leftCong refl = refl

*-rightCong : ∀ {m n o} → n ≡ o → m * n ≡ m * o
*-rightCong refl = refl

------------------------------------------------------------------------------
-- Some proofs are based on the proofs in the standard library.

Sx≢x : ∀ {n} → N n → succ₁ n ≢ n
Sx≢x nzero h      = ⊥-elim (0≢S (sym h))
Sx≢x (nsucc Nn) h = ⊥-elim (Sx≢x Nn (succInjective h))

+-leftIdentity : ∀ n → zero + n ≡ n
+-leftIdentity = +-0x

+-rightIdentity : ∀ {n} → N n → n + zero ≡ n
+-rightIdentity nzero          = +-leftIdentity zero
+-rightIdentity (nsucc {n} Nn) =
  trans (+-Sx n zero) (succCong (+-rightIdentity Nn))

pred-N : ∀ {n} → N n → N (pred₁ n)
pred-N nzero =         subst N (sym pred-0) nzero
pred-N (nsucc {n} Nn) = subst N (sym (pred-S n)) Nn

+-N : ∀ {m n} → N m → N n → N (m + n)
+-N {n = n} nzero          Nn = subst N (sym (+-leftIdentity n)) Nn
+-N {n = n} (nsucc {m} Nm) Nn = subst N (sym (+-Sx m n)) (nsucc (+-N Nm Nn))

∸-N : ∀ {m n} → N m → N n → N (m ∸ n)
∸-N {m} Nm nzero          = subst N (sym (∸-x0 m)) Nm
∸-N {m} Nm (nsucc {n} Nn) = subst N (sym (∸-xS m n)) (pred-N (∸-N Nm Nn))

+-assoc : ∀ {m} → N m → ∀ n o → m + n + o ≡ m + (n + o)
+-assoc nzero n o =
  zero + n + o   ≡⟨ +-leftCong (+-leftIdentity n) ⟩
  n + o          ≡⟨ sym (+-leftIdentity (n + o)) ⟩
  zero + (n + o) ∎

+-assoc (nsucc {m} Nm) n o =
  succ₁ m + n + o     ≡⟨ +-leftCong (+-Sx m n) ⟩
  succ₁ (m + n) + o   ≡⟨ +-Sx (m + n) o ⟩
  succ₁ (m + n + o)   ≡⟨ succCong (+-assoc Nm n o) ⟩
  succ₁ (m + (n + o)) ≡⟨ sym (+-Sx m (n + o)) ⟩
  succ₁ m + (n + o)   ∎

x+Sy≡S[x+y] : ∀ {m} → N m → ∀ n → m + succ₁ n ≡ succ₁ (m + n)
x+Sy≡S[x+y] nzero n =
  zero + succ₁ n   ≡⟨ +-leftIdentity (succ₁ n) ⟩
  succ₁ n          ≡⟨ succCong (sym (+-leftIdentity n)) ⟩
  succ₁ (zero + n) ∎

x+Sy≡S[x+y] (nsucc {m} Nm) n =
  succ₁ m + succ₁ n     ≡⟨ +-Sx m (succ₁ n) ⟩
  succ₁ (m + succ₁ n)   ≡⟨ succCong (x+Sy≡S[x+y] Nm n) ⟩
  succ₁ (succ₁ (m + n)) ≡⟨ succCong (sym (+-Sx m n)) ⟩
  succ₁ (succ₁ m + n)   ∎

+-comm : ∀ {m n} → N m → N n → m + n ≡ n + m
+-comm {n = n} nzero Nn =
  zero + n ≡⟨ +-leftIdentity n ⟩
  n        ≡⟨ sym (+-rightIdentity Nn) ⟩
  n + zero ∎

+-comm {n = n} (nsucc {m} Nm) Nn =
  succ₁ m + n   ≡⟨ +-Sx m n ⟩
  succ₁ (m + n) ≡⟨ succCong (+-comm Nm Nn) ⟩
  succ₁ (n + m) ≡⟨ sym (x+Sy≡S[x+y] Nn m) ⟩
  n + succ₁ m   ∎

private
  0∸S : ∀ {n} → N n → zero ∸ succ₁ n ≡ zero
  0∸S nzero =
    zero ∸ succ₁ zero   ≡⟨ ∸-xS zero zero ⟩
    pred₁ (zero ∸ zero) ≡⟨ predCong (∸-x0 zero) ⟩
    pred₁ zero          ≡⟨ pred-0 ⟩
    zero                ∎

  0∸S (nsucc {n} Nn) =
    zero ∸ succ₁ (succ₁ n)   ≡⟨ ∸-xS zero (succ₁ n) ⟩
    pred₁ (zero ∸ (succ₁ n)) ≡⟨ predCong (0∸S Nn) ⟩
    pred₁ zero               ≡⟨ pred-0 ⟩
    zero                     ∎

0∸x : ∀ {n} → N n → zero ∸ n ≡ zero
0∸x nzero      = ∸-x0 zero
0∸x (nsucc Nn) = 0∸S Nn

S∸S : ∀ {m n} → N m → N n → succ₁ m ∸ succ₁ n ≡ m ∸ n
S∸S {m} _ nzero =
  succ₁ m ∸ succ₁ zero
    ≡⟨ ∸-xS (succ₁ m) zero ⟩
  pred₁ (succ₁ m ∸ zero)
    ≡⟨ predCong (∸-x0 (succ₁ m)) ⟩
  pred₁ (succ₁ m)
    ≡⟨ pred-S m ⟩
  m
    ≡⟨ sym (∸-x0 m) ⟩
  m ∸ zero ∎

S∸S nzero (nsucc {n} Nn) =
  succ₁ zero ∸ succ₁ (succ₁ n)
    ≡⟨ ∸-xS (succ₁ zero) (succ₁ n) ⟩
  pred₁ (succ₁ zero ∸ succ₁ n)
    ≡⟨ predCong (S∸S nzero Nn) ⟩
  pred₁ (zero ∸ n)
    ≡⟨ predCong (0∸x Nn) ⟩
  pred₁ zero
    ≡⟨ pred-0 ⟩
  zero
    ≡⟨ sym (0∸S Nn) ⟩
  zero ∸ succ₁ n ∎

S∸S (nsucc {m} Nm) (nsucc {n} Nn) =
  succ₁ (succ₁ m) ∸ succ₁ (succ₁ n)
    ≡⟨ ∸-xS (succ₁ (succ₁ m)) (succ₁ n) ⟩
  pred₁ (succ₁ (succ₁ m) ∸ succ₁ n)
    ≡⟨ predCong (S∸S (nsucc Nm) Nn) ⟩
  pred₁ (succ₁ m ∸ n)
    ≡⟨ sym (∸-xS (succ₁ m) n) ⟩
  succ₁ m ∸ succ₁ n ∎

x∸x≡0 : ∀ {n} → N n → n ∸ n ≡ zero
x∸x≡0 nzero      = ∸-x0 zero
x∸x≡0 (nsucc Nn) = trans (S∸S Nn Nn) (x∸x≡0 Nn)

Sx∸x≡S0 : ∀ {n} → N n → succ₁ n ∸ n ≡ succ₁ zero
Sx∸x≡S0 nzero      = ∸-x0 (succ₁ zero)
Sx∸x≡S0 (nsucc Nn) = trans (S∸S (nsucc Nn) Nn) (Sx∸x≡S0 Nn)

[x+Sy]∸y≡Sx : ∀ {m n} → N m → N n → m + succ₁ n ∸ n ≡ succ₁ m
[x+Sy]∸y≡Sx {n = n} nzero Nn =
  zero + succ₁ n ∸ n ≡⟨ ∸-leftCong (+-0x (succ₁ n)) ⟩
  succ₁ n ∸ n        ≡⟨ Sx∸x≡S0 Nn ⟩
  succ₁ zero ∎

[x+Sy]∸y≡Sx (nsucc {m} Nm) nzero =
  succ₁ m + succ₁ zero ∸ zero   ≡⟨ ∸-leftCong (+-Sx m (succ₁ zero)) ⟩
  succ₁ (m + succ₁ zero) ∸ zero ≡⟨ ∸-x0 (succ₁ (m + succ₁ zero)) ⟩
  succ₁ (m + succ₁ zero)        ≡⟨ succCong (+-comm Nm (nsucc nzero)) ⟩
  succ₁ (succ₁ zero + m)        ≡⟨ succCong (+-Sx zero m) ⟩
  succ₁ (succ₁ (zero + m))      ≡⟨ succCong (succCong (+-0x m)) ⟩
  succ₁ (succ₁ m) ∎

[x+Sy]∸y≡Sx (nsucc {m} Nm) (nsucc {n} Nn) =
  succ₁ m + succ₁ (succ₁ n) ∸ succ₁ n
    ≡⟨ ∸-leftCong (+-Sx m (succ₁ (succ₁ n))) ⟩
  succ₁ (m + succ₁ (succ₁ n)) ∸ succ₁ n
    ≡⟨ S∸S (+-N Nm (nsucc (nsucc Nn))) Nn ⟩
  m + succ₁ (succ₁ n) ∸ n
    ≡⟨ ∸-leftCong (x+Sy≡S[x+y] Nm (succ₁ n)) ⟩
  succ₁ (m + succ₁ n) ∸ n
    ≡⟨ ∸-leftCong (sym (+-Sx m (succ₁ n))) ⟩
  succ₁ m + succ₁ n ∸ n
    ≡⟨ [x+Sy]∸y≡Sx (nsucc Nm) Nn ⟩
  succ₁ (succ₁ m) ∎

[x+y]∸[x+z]≡y∸z : ∀ {m n o} → N m → N n → N o → (m + n) ∸ (m + o) ≡ n ∸ o
[x+y]∸[x+z]≡y∸z {n = n} {o} nzero _ _ =
  (zero + n) ∸ (zero + o) ≡⟨ ∸-leftCong (+-leftIdentity n) ⟩
    n ∸ (zero + o)        ≡⟨ ∸-rightCong (+-leftIdentity o) ⟩
    n ∸ o                 ∎

[x+y]∸[x+z]≡y∸z {n = n} {o} (nsucc {m} Nm) Nn No =
  (succ₁ m + n) ∸ (succ₁ m + o) ≡⟨ ∸-leftCong (+-Sx m n) ⟩
  succ₁ (m + n) ∸ (succ₁ m + o) ≡⟨ ∸-rightCong (+-Sx m o) ⟩
  succ₁ (m + n) ∸ succ₁ (m + o) ≡⟨ S∸S (+-N Nm Nn) (+-N Nm No) ⟩
  (m + n) ∸ (m + o)             ≡⟨ [x+y]∸[x+z]≡y∸z Nm Nn No ⟩
  n ∸ o                         ∎

*-leftZero : ∀ n → zero * n ≡ zero
*-leftZero = *-0x

*-rightZero : ∀ {n} → N n → n * zero ≡ zero
*-rightZero nzero          = *-leftZero zero
*-rightZero (nsucc {n} Nn) =
  trans (*-Sx n zero)
        (trans (+-leftIdentity (n * zero)) (*-rightZero Nn))

*-N : ∀ {m n} → N m → N n → N (m * n)
*-N {n = n} nzero          Nn = subst N (sym (*-leftZero n)) nzero
*-N {n = n} (nsucc {m} Nm) Nn = subst N (sym (*-Sx m n)) (+-N Nn (*-N Nm Nn))

*-leftIdentity : ∀ {n} → N n → succ₁ zero * n ≡ n
*-leftIdentity {n} Nn =
  succ₁ zero * n ≡⟨ *-Sx zero n ⟩
  n + zero * n   ≡⟨ +-rightCong (*-leftZero n) ⟩
  n + zero       ≡⟨ +-rightIdentity Nn ⟩
  n              ∎

x*Sy≡x+xy : ∀ {m n} → N m → N n → m * succ₁ n ≡ m + m * n
x*Sy≡x+xy {n = n} nzero Nn = sym
  (
    zero + zero * n ≡⟨ +-rightCong (*-leftZero n) ⟩
    zero + zero     ≡⟨ +-leftIdentity zero ⟩
    zero            ≡⟨ sym (*-leftZero (succ₁ n)) ⟩
    zero * succ₁ n  ∎
  )

x*Sy≡x+xy {n = n} (nsucc {m} Nm) Nn =
  succ₁ m * succ₁ n
    ≡⟨ *-Sx m (succ₁ n) ⟩
  succ₁ n + m * succ₁ n
    ≡⟨ +-rightCong (x*Sy≡x+xy Nm Nn) ⟩
  succ₁ n + (m + m * n)
    ≡⟨ +-Sx n (m + m * n) ⟩
  succ₁ (n + (m + m * n))
    ≡⟨ succCong (sym (+-assoc Nn m (m * n))) ⟩
  succ₁ (n + m + m * n)
    ≡⟨ succCong (+-leftCong (+-comm Nn Nm)) ⟩
  succ₁ (m + n + m * n)
    ≡⟨ subst (λ t → succ₁ (m + n + m * n) ≡ succ₁ t)
             (+-assoc Nm n (m * n))
               refl
    ⟩
  succ₁ (m + (n + m * n))
    ≡⟨ sym (+-Sx m (n + m * n)) ⟩
  succ₁ m + (n + m * n)
    ≡⟨ +-rightCong (sym (*-Sx m n)) ⟩
  succ₁ m + succ₁ m * n ∎

*-comm : ∀ {m n} → N m → N n → m * n ≡ n * m
*-comm {n = n} nzero Nn          = trans (*-leftZero n) (sym (*-rightZero Nn))
*-comm {n = n} (nsucc {m} Nm) Nn =
  succ₁ m * n ≡⟨ *-Sx m n ⟩
  n + m * n   ≡⟨ subst (λ t → n + m * n ≡ n + t) (*-comm Nm Nn) refl ⟩
  n + n * m   ≡⟨ sym (x*Sy≡x+xy Nn Nm) ⟩
  n * succ₁ m ∎

*-rightIdentity : ∀ {n} → N n → n * succ₁ zero ≡ n
*-rightIdentity {n} Nn = trans (*-comm Nn (nsucc nzero)) (*-leftIdentity Nn)

*∸-leftDistributive : ∀ {m n o} → N m → N n → N o → (m ∸ n) * o ≡ m * o ∸ n * o
*∸-leftDistributive {m} {o = o} _ nzero _ =
  (m ∸ zero) * o   ≡⟨ *-leftCong (∸-x0 m) ⟩
  m * o            ≡⟨ sym (∸-x0 (m * o)) ⟩
  m * o ∸ zero     ≡⟨ ∸-rightCong (sym (*-leftZero o)) ⟩
  m * o ∸ zero * o ∎

*∸-leftDistributive {o = o} nzero (nsucc {n} Nn) No =
  (zero ∸ succ₁ n) * o   ≡⟨ *-leftCong (0∸S Nn) ⟩
  zero * o               ≡⟨ *-leftZero o ⟩
  zero                   ≡⟨ sym (0∸x (*-N (nsucc Nn) No)) ⟩
  zero ∸ succ₁ n * o     ≡⟨ ∸-leftCong (sym (*-leftZero o)) ⟩
  zero * o ∸ succ₁ n * o ∎

*∸-leftDistributive (nsucc {m} Nm) (nsucc {n} Nn) nzero =
  (succ₁ m ∸ succ₁ n) * zero
    ≡⟨ *-comm (∸-N (nsucc Nm) (nsucc Nn)) nzero ⟩
  zero * (succ₁ m ∸ succ₁ n)
    ≡⟨ *-leftZero (succ₁ m ∸ succ₁ n) ⟩
  zero
    ≡⟨ sym (0∸x (*-N (nsucc Nn) nzero)) ⟩
  zero ∸ succ₁ n * zero
    ≡⟨ ∸-leftCong (sym (*-leftZero (succ₁ m))) ⟩
  zero * succ₁ m ∸ succ₁ n * zero
    ≡⟨ ∸-leftCong (*-comm nzero (nsucc Nm)) ⟩
  succ₁ m * zero ∸ succ₁ n * zero ∎

*∸-leftDistributive (nsucc {m} Nm) (nsucc {n} Nn) (nsucc {o} No) =
  (succ₁ m ∸ succ₁ n) * succ₁ o
    ≡⟨ *-leftCong (S∸S Nm Nn) ⟩
  (m ∸ n) * succ₁ o
     ≡⟨ *∸-leftDistributive Nm Nn (nsucc No) ⟩
  m * succ₁ o ∸ n * succ₁ o
    ≡⟨ sym ([x+y]∸[x+z]≡y∸z (nsucc No) (*-N Nm (nsucc No)) (*-N Nn (nsucc No))) ⟩
  (succ₁ o + m * succ₁ o) ∸ (succ₁ o + n * succ₁ o)
    ≡⟨ ∸-leftCong (sym (*-Sx m (succ₁ o))) ⟩
  (succ₁ m * succ₁ o) ∸ (succ₁ o + n * succ₁ o)
    ≡⟨ ∸-rightCong (sym (*-Sx n (succ₁ o))) ⟩
  (succ₁ m * succ₁ o) ∸ (succ₁ n * succ₁ o) ∎

*+-leftDistributive : ∀ {m n o} → N m → N n → N o → (m + n) * o ≡ m * o + n * o
*+-leftDistributive {m} {n} Nm Nn nzero =
  (m + n) * zero
    ≡⟨ *-comm (+-N Nm Nn) nzero ⟩
  zero * (m + n)
    ≡⟨ *-leftZero (m + n) ⟩
  zero
    ≡⟨ sym (*-leftZero m) ⟩
  zero * m
    ≡⟨ *-comm nzero Nm ⟩
  m * zero
    ≡⟨ sym (+-rightIdentity (*-N Nm nzero)) ⟩
  m * zero + zero
    ≡⟨ +-rightCong (trans (sym (*-leftZero n)) (*-comm nzero Nn)) ⟩
  m * zero + n * zero ∎

*+-leftDistributive {n = n} nzero Nn (nsucc {o} No) =
  (zero + n) * succ₁ o         ≡⟨ *-leftCong (+-leftIdentity n) ⟩
  n * succ₁ o                  ≡⟨ sym (+-leftIdentity (n * succ₁ o)) ⟩
  zero + n * succ₁ o           ≡⟨ +-leftCong (sym (*-leftZero (succ₁ o))) ⟩
  zero * succ₁ o + n * succ₁ o ∎

*+-leftDistributive (nsucc {m} Nm) nzero (nsucc {o} No) =
  (succ₁ m + zero) * succ₁ o
    ≡⟨ *-leftCong (+-rightIdentity (nsucc Nm)) ⟩
  succ₁ m * succ₁ o
    ≡⟨ sym (+-rightIdentity (*-N (nsucc Nm) (nsucc No))) ⟩
  succ₁ m * succ₁ o + zero
    ≡⟨ +-rightCong (sym (*-leftZero (succ₁ o))) ⟩
  succ₁ m * succ₁ o + zero * succ₁ o ∎

*+-leftDistributive (nsucc {m} Nm) (nsucc {n} Nn) (nsucc {o} No) =
  (succ₁ m + succ₁ n) * succ₁ o
    ≡⟨ *-leftCong (+-Sx m (succ₁ n)) ⟩
  succ₁ (m + succ₁ n) * succ₁ o
    ≡⟨ *-Sx (m + succ₁ n) (succ₁ o) ⟩
  succ₁ o + (m + succ₁ n) * succ₁ o
    ≡⟨ +-rightCong (*+-leftDistributive Nm (nsucc Nn) (nsucc No)) ⟩
  succ₁ o + (m * succ₁ o + succ₁ n * succ₁ o)
    ≡⟨ sym (+-assoc (nsucc No) (m * succ₁ o) (succ₁ n * succ₁ o)) ⟩
  succ₁ o + m * succ₁ o + succ₁ n * succ₁ o
    ≡⟨ +-leftCong (sym (*-Sx m (succ₁ o))) ⟩
  succ₁ m * succ₁ o + succ₁ n * succ₁ o ∎

xy≡0→x≡0∨y≡0 : ∀ {m n} → N m → N n → m * n ≡ zero → m ≡ zero ∨ n ≡ zero
xy≡0→x≡0∨y≡0 nzero          _              _      = inj₁ refl
xy≡0→x≡0∨y≡0 (nsucc Nm)     nzero          _      = inj₂ refl
xy≡0→x≡0∨y≡0 (nsucc {m} Nm) (nsucc {n} Nn) SmSn≡0 = ⊥-elim (0≢S prf)
  where
  prf : zero ≡ succ₁ (n + m * succ₁ n)
  prf = zero                    ≡⟨ sym SmSn≡0 ⟩
        succ₁ m * succ₁ n       ≡⟨ *-Sx m (succ₁ n) ⟩
        succ₁ n + m * succ₁ n   ≡⟨ +-Sx n (m * succ₁ n) ⟩
        succ₁ (n + m * succ₁ n) ∎

xy≡1→x≡1 : ∀ {m n} → N m → N n → m * n ≡ [1] → m ≡ [1]
xy≡1→x≡1 {n = n} nzero Nn h = ⊥-elim (0≢S (trans (sym (*-leftZero n)) h))
xy≡1→x≡1 (nsucc nzero) Nn h = refl
xy≡1→x≡1 (nsucc (nsucc {m} Nm)) nzero h =
  ⊥-elim (0≢S (trans (sym (*-rightZero (nsucc (nsucc Nm)))) h))
xy≡1→x≡1 (nsucc (nsucc {m} Nm)) (nsucc {n} Nn) h = ⊥-elim (0≢S prf₂)
  where
  prf₁ : succ₁ zero ≡ succ₁ (succ₁ (m + n * succ₁ (succ₁ m)))
  prf₁ = succ₁ zero
           ≡⟨ sym h ⟩
         succ₁ (succ₁ m) * succ₁ n
           ≡⟨ *-comm (nsucc (nsucc Nm)) (nsucc Nn) ⟩
         succ₁ n * succ₁ (succ₁ m)
           ≡⟨ *-Sx n (succ₁ (succ₁ m)) ⟩
         succ₁ (succ₁ m) + n * succ₁ (succ₁ m)
           ≡⟨ +-Sx (succ₁ m) (n * succ₁ (succ₁ m)) ⟩
         succ₁ (succ₁ m + n * succ₁ (succ₁ m))
           ≡⟨ succCong (+-Sx m (n * succ₁ (succ₁ m))) ⟩
         succ₁ (succ₁ (m + n * succ₁ (succ₁ m))) ∎

  prf₂ : zero ≡ succ₁ (m + n * succ₁ (succ₁ m))
  prf₂ = succInjective prf₁

xy≡1→y≡1 : ∀ {m n} → N m → N n → m * n ≡ [1] → n ≡ [1]
xy≡1→y≡1 Nm Nn h = xy≡1→x≡1 Nn Nm (trans (*-comm Nn Nm) h)

-- Feferman's axiom as presented by (Beeson 1986, p. 74).
succOnto : ∀ {n} → N n → n ≢ zero → succ₁ (pred₁ n) ≡ n
succOnto nzero          h = ⊥-elim (h refl)
succOnto (nsucc {n} Nn) h = succCong (pred-S n)
