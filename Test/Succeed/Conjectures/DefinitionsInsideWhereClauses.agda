module Test.Succeed.Conjectures.DefinitionsInsideWhereClauses where

infixl 6 _+_
infix  4 _≡_

postulate
  D      : Set
  zero   : D
  succ   : D → D
  _≡_    : D → D → Set

-- The LTC natural numbers type.
data N : D → Set where
  zN : N zero
  sN : ∀ {n} → N n → N (succ n)

-- Induction principle for N (elimination rule).
indN : (P : D → Set) →
       P zero →
       (∀ {n} → N n → P n → P (succ n)) →
       ∀ {n} → N n → P n
indN P P0 h zN      = P0
indN P P0 h (sN Nn) = h Nn (indN P P0 h Nn)

postulate
  _+_  : D → D → D
  +-0x : ∀ d → zero + d     ≡ d
  +-Sx : ∀ d e → succ d + e ≡ succ (d + e)
{-# ATP axiom +-0x #-}
{-# ATP axiom +-Sx #-}

+-rightIdentity : ∀ {n} → N n → n + zero ≡ n
+-rightIdentity Nn = indN P P0 iStep Nn
  where
  P : D → Set
  P i = i + zero ≡ i
  {-# ATP definition P #-}

  postulate P0 : P zero
  {-# ATP prove P0 #-}

  postulate iStep : ∀ {i} → N i → P i → P (succ i)
  {-# ATP prove iStep #-}

+-assoc : ∀ {m n o} → N m → N n → N o → m + n + o ≡ m + (n + o)
+-assoc {n = n} {o} Nm Nn No = indN P P0 iStep Nm
  where
  P : D → Set
  P i = i + n + o ≡ i + (n + o)
  {-# ATP definition P #-}

  postulate P0 : P zero
  {-# ATP prove P0 #-}

  postulate iStep : ∀ {i} → N i → P i → P (succ i)
  {-# ATP prove iStep #-}
