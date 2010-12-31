------------------------------------------------------------------------------
-- PA properties
------------------------------------------------------------------------------

module AxiomaticPA.PropertiesATP where

open import AxiomaticPA.Base

open import AxiomaticPA.Relation.Binary.PropositionalEqualityI
  using ()  -- We include this module due to its general hints.

------------------------------------------------------------------------------

+-rightIdentity : ∀ n → n + zero ≣ n
+-rightIdentity = S₉ P P0 iStep
  where
    P : ℕ → Set
    P i = i + zero ≣ i
    {-# ATP definition P #-}

    P0 : P zero
    P0 = S₅ zero

    postulate
      iStep : ∀ i → P i → P (succ i)
    {-# ATP prove iStep #-}

x+Sy≣S[x+y] : ∀ m n → m + succ n ≣ succ (m + n)
x+Sy≣S[x+y] m n = S₉ P P0 iStep m
  where
    P : ℕ → Set
    P i = i + succ n ≣ succ (i + n)
    {-# ATP definition P #-}

    postulate
      P0 : P zero
    -- E 1.2: CPU time limit exceeded (180 sec).
    {-# ATP prove P0 #-}

    postulate
      iStep : ∀ i → P i → P (succ i)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove iStep #-}

+-comm : ∀ m n → m + n ≣ n + m
+-comm m n = S₉ P P0 iStep m
  where
    P : ℕ → Set
    P i = i + n ≣ n + i
    {-# ATP definition P #-}

    postulate
      P0 : P zero
    -- E 1.2: CPU time limit exceeded (180 sec).
    {-# ATP prove P0 +-rightIdentity #-}

    postulate
      iStep : ∀ i → P i → P (succ i)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Equinox 5.0alpha (2010-06-29): TIMEOUT (180 seconds)
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove iStep x+Sy≣S[x+y] #-}

x≣y→x+z≣y+z : ∀ {m n} o → m ≣ n → m + o ≣ n + o
x≣y→x+z≣y+z {m} {n} o m≣n = S₉ P P0 iStep o
  where
    P : ℕ → Set
    P i = m + i ≣ n + i
    {-# ATP definition P #-}

    postulate
      P0 : P zero
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove P0 +-rightIdentity #-}

    postulate
      iStep : ∀ i → P i → P (succ i)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Equinox 5.0alpha (2010-06-29): TIMEOUT (180 seconds)
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove iStep x+Sy≣S[x+y] #-}

+-asocc : ∀ m n o → m + n + o ≣ m + (n + o)
+-asocc m n o = S₉ P P0 iStep m
  where
    P : ℕ → Set
    P i = i + n + o ≣ i + (n + o)
    {-# ATP definition P #-}

    postulate
      P0 : P zero
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    {-# ATP prove P0 x≣y→x+z≣y+z #-}

    postulate
      iStep : ∀ i → P i → P (succ i)
    -- E 1.2: CPU time limit exceeded (180 sec).
    -- Equinox 5.0alpha (2010-06-29): TIMEOUT (180 seconds)
    -- Metis 2.3 (release 20101019): SZS status Unknown (using timeout 180 sec).
    -- Vampire 0.6 (revision 903): Time limit (180 sec).
    -- {-# ATP prove iStep x≣y→x+z≣y+z #-}
