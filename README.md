# Description

[Agda](http://wiki.portal.chalmers.se/agda/pmwiki.php) formalization
of FOTC (First-Order Theory of Combinators) which is a programming
logic for functional programs that can deal with **general
recursion**, **higher-order functions**, **termination proofs**,
**partial functions**, and **inductive** and **co-inductive**
predicates. Our implementation includes a translation of Agda
representations of formulae in FOTC into the
[TPTP](http://www.cs.miami.edu/~tptp/) language, which is a standard
format for input and output in automatic theorem provers (ATPs), so
that we can call off-the-shelf ATPs when proving properties of our
programs. See:

* [Combining Interactive and Automatic Reasoning in First Order
  Theories of Functional
  Programs](http://www1.eafit.edu.co/asicard/publications-talks/proceedings_abstracts.html#Bove-Dybjer-SicardRamirez-2012)
  by [Ana Bove](http://www.cse.chalmers.se/~bove/), [Peter
  Dybjer](http://www.cse.chalmers.se/~peterd/), and [Andrés
  Sicard-Ramírez](http://www1.eafit.edu.co/asicard/) (FoSSaCS 2012).

* [Embedding a Logical Theory of Constructions in
  Agda](http://www1.eafit.edu.co/asicard/publications-talks/2009_abstracts.html#Bove-Dybjer-SicardRamirez-2009)
  by [Ana Bove](http://www.cse.chalmers.se/~bove/), [Peter
  Dybjer](http://www.cse.chalmers.se/~peterd/), and [Andrés
  Sicard-Ramírez](http://www1.eafit.edu.co/asicard/) (PLPV'09).

# Prerequisites

* Modified version of Agda

   We have modified the development version of Agda in order to handle
   the new built-in ATP pragma. This version modified of Agda is
   required by the `agda2atp` program.

* The `agda2atp` program

  `agda2atp` is a Haskell program for proving first-order formulae
  written in [Agda](http://wiki.portal.chalmers.se/agda/pmwiki.php)
  using ATPs. Before calling the ATPs, the Agda formulae are
  translated into [TPTP](http://www.cs.miami.edu/~tptp/) language.

* ATPs

  The `agda2atp` program requires at least one of the following ATPs:
  [E](http://www4.informatik.tu-muenchen.de/~schulz/WORK/eprover.html),
  [Equinox](http://www.cse.chalmers.se/~koen/code/),
  [ileanCoP](http://www.leancop.de/ileancop/index.html),
  [Metis](http://www.gilith.com/software/metis/),
  [SPASS](http://www.spass-prover.org/), or
  [Vampire](http://www.vprover.org/). The tested versions of the ATPs
  are: E 1.6 Tiger Hill, Equinox version 5.0alpha (2010-06-29),
  ileanCoP v1.3beta1, Metis 2.3 (release 20110926), SPASS v3.7, and
  Vampire 0.6 (revision 903).

* The `tptp4X` program

  `agda2atp` uses the `tptp4X` program from the [TPTP
  library](http://www.cs.miami.edu/~tptp/) by default. This program
  can be avoided using the command-line option `--no-check`.

# Installation

1. Modified version of Agda

   You can download our modified version of Agda using
   [darcs](http://darcs.net/) with the following command:

   ````bash
   $ darcs get http://patch-tag.com/r/asr/magda
   ````

   This will create a directory called `magda`. Installing our
   modified version is similar to the installation of Agda (see the
   [Agda wiki](http://wiki.portal.chalmers.se/agda/pmwiki.php) for
   more information). In our setup we run the first time the following
   commands:

   ````bash
   $ cd magda
   $ autoconf
   $ ./configure
   $ make install
   ````
   After pulling new patches, we run the following commands:

   ````bash
   $ cd magda
   $ make compile-emacs-mode
   ````

   To test the installation of the modified version of Agda, type-check
   a module which uses the new built-in ATP pragma, for example

   ````Agda
   module Test where

   data _∨_ (A B : Set) : Set where
     inj₁ : A → A ∨ B
     inj₂ : B → A ∨ B

   postulate
     A B    : Set
     ∨-comm : A ∨ B → B ∨ A
   {-# ATP prove ∨-comm #-}
   ````

   Observe that in order to avoid conflicts with other installed
   versions of Agda, we have added extra information to the version
   number of Agda, i.e. if the development version number is A.B.C,
   our modified version number is A.B.C.D.

2. The `agda2atp` program

   You can download the `agda2atp` program using
   [git](http://git-scm.com/). The program can be downloaded and
   installed with the following commands:

   ````bash
   $ git clone git://github.com/asr/fotc.git
   $ cd fotc/src/agda2atp
   $ cabal install
   ````

   In order to test the installation of the program, once (some of)
   the ATPs have been installed, we can try to automatically prove
   all the conjectures in the file above by running the following
   command:

   ````bash
   $ agda2atp Test.agda
   Proving the conjecture in /tmp/Test/9-8744-comm.tptp ...
   E 1.6 Tiger Hill proved the conjecture in /tmp/Test/9-8744-comm.tptp
   ````

   The program will call the installed ATPs and tell which of the ATPs
   was able to first prove a certain conjecture. If none ATP could
   prove a conjecture after 300 seconds, the process of proving that
   particular conjecture is aborted and the ATPs try to prove the next
   conjecture.

   If we want to just use a certain ATP, say Equinox, we can instead
   run the following command:

   ````bash
   $ agda2atp --atp=equinox Test.agda
   Proving the conjecture in /tmp/Test/9-8744-comm.tptp ...
   Equinox, version 5.0alpha, 2010-06-29 proved the conjecture in /tmp/Test/9-8744-comm.tptp
   ````

# Examples in our FoSSaCS-2012 paper

Please note that the code presented here does not match the paper
exactly.

You can follow these links to see the examples shown in our
[FoSSaCS-2012
paper](http://www1.eafit.edu.co/asicard/publications-talks/proceedings_abstracts.html#Bove-Dybjer-SicardRamirez-2012):

* [The McCarthy's 91-function
  example](http://www1.eafit.edu.co/asicard/code/thesis/fotc/fot/FOTC.Program.McCarthy91.PropertiesATP.html)

* [The mirror function
   example](http://www1.eafit.edu.co/asicard/code/thesis/fotc/fot/FOTC.Program.Mirror.PropertiesATP.html)

* [The alternating bit protocol
   example](http://www1.eafit.edu.co/asicard/code/thesis/fotc/fot/FOTC.Program.ABP.ProofSpecificationATP.html)

You can test for example the proofs regarding the mirror function with
the following commands:

````bash
$ cd fotc/src/fot
$ agda FOTC/Program/Mirror/PropertiesATP.agda
$ agda2atp FOTC/Program/Mirror/PropertiesATP.agda
````

# Examples in our PLPV-2009 paper

Please note that the code presented here does not match the paper
exactly. Also note that the code below does not require neither the
version modified of Agda nor the `agda2atp` program.

You can follow [this
link](http://www1.eafit.edu.co/asicard/code/thesis/fotc/fot/LTC-PCF.README.html)
to see the examples shown in our [PLPV-2009
paper](http://www1.eafit.edu.co/asicard/publications-talks/2009_abstracts.html#Bove-Dybjer-SicardRamirez-2009).

You can test for example the verification of the GCD algorithm with
the following commands:

````bash
$ cd fotc/src/fot
$ agda LTC-PCF/Program/GCD/Partial/ProofSpecification.agda
````

# More examples

We also have more examples related with first-order theories like
group theory or Peano arithmetic. In addition there are more examples
related to the verification of functional programs. You can browse all
the examples from the file
[README.html](http://www1.eafit.edu.co/asicard/code/thesis/fotc/fot/README.html).

# Known limitations

* Logical symbols

The following symbols are hard-coded, i.e. they should be used: `⊥`
(falsehood), `⊤` (truth), `¬_` (negation), `_∧_` (conjunction), `_∨_`
(disjunction), the Agda non-dependent function type `→` (implication),
`_↔_` (equivalence), the Agda dependent function type `(x : A) → B`
(universal quantifier), `∃` (existential quantifier), and `_≡_`
(propositional equality).

* Agda version

The `agda2atp` program must be compiled using the same version of Agda that
was used to generate the Agda interface files.
