#! /bin/bash

axiomsTPTP='/tmp/axioms.tptp'

AGDA='agda -v 0'

# filesWithAxioms=$(find . -name '*.ax')
filesWithAxioms='
  Examples/GCD
  LTC/Data/List
  LTC/Function/Arithmetic
  LTC/Minimal
  LTC/Relation/Inequalities
  '
for file in ${filesWithAxioms} ; do
    if ! ( ${AGDA} ${file}.agda ); then exit 1; fi
    if ! ( agda2atp --only-create-files ${file}.agda ); then exit 1; fi
    if ! ( cat ${file}.ax | while read -r line; do
                if ! ( grep --silent "${line}" $axiomsTPTP ) ; then
                    echo "Testing error. Translation to: $line"
                    exit 1
                fi
            done
         ) ; then exit 1; fi
done
