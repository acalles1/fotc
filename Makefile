haskell_files = $(shell find src/ -name '*.hs')

AGDA     = agda -v 0
AGDA2ATP = agda2atp  # The defaults ATPs are e, equinox, metis, and vampire.
# AGDA2ATP = agda2atp --atp=e
# AGDA2ATP = agda2atp --atp=equinox
# AGDA2ATP = agda2atp --atp=metis
# AGDA2ATP = agda2atp --atp=vampire

succeed_path  = Test/Succeed
fail_path     = Test/Fail

snapshot_dir = Test/snapshot

succeed_files = $(patsubst %.agda,%, \
	$(shell find $(succeed_path) -name "*.agda"))

fail_files = $(patsubst %.agda,%, \
	$(shell find $(fail_path) -name "*.agda"))

# Ugly hack
# We need to add a fake extension to the file names to avoid repeated
# targets.
snapshot_files_to_create = $(foreach file,$(succeed_files), \
	$(addsuffix .snapshotcreate, $(file)))

snapshot_files_to_test = $(foreach file,$(succeed_files), \
	$(addsuffix .snapshottest, $(file)))

parsing_files = $(foreach file,$(succeed_files), \
	$(addsuffix .parsing, $(file)))

%.agdai : %.agda
	@if ! ( $(AGDA) $< ); then exit 1; fi

$(succeed_files) : % : %.agdai
	@if ! ( $(AGDA2ATP) --time=60 \
                            --unproved-conjecture-error \
                            $*.agda ); then \
		exit 1; \
	fi

$(fail_files) : % : %.agdai
	@if ( $(AGDA2ATP) --time=5 \
                          --unproved-conjecture-error \
                          $*.agda ); then \
              exit 1; \
	fi

# Equinox has the better parser for TPTP files, so we use it to find problems.
$(parsing_files) : %.parsing : %.agdai
	@echo "Parsing file" $*.agda
	@if ! ( $(AGDA2ATP) --time=1 \
			    --atp=equinox \
			    $*.agda \
			    >/tmp/xxx.tmp \
			    2>/tmp/parsing.error); then \
		exit 1; \
	fi

	@if [ -s /tmp/parsing.error ]; then \
		echo "Parsing error in $${file}"; \
		exit 1; \
	fi; \

$(snapshot_files_to_create) : %.snapshotcreate : %.agdai
	@if ! ( $(AGDA2ATP) --only-files \
		            --output-dir=$(snapshot_dir) \
                            $*.agda ); then \
		exit 1; \
	fi

$(snapshot_files_to_test) : %.snapshottest : %.agdai
	@if ! ( $(AGDA2ATP) --snapshot-test \
			    --snapshot-dir=$(snapshot_dir) \
                            $*.agda ); then \
		exit 1; \
	fi

# Snapshot of the succeed TPTP files.
create_snapshot : $(snapshot_files_to_create)

# The tests
succeed  : $(parsing_files) $(succeed_files)
fail     : $(fail_files)
parsing  : $(parsing_files)
snapshot : $(snapshot_files_to_test)

test     : succeed fail

##############################################################################
# Others

TAGS : $(haskell_files)
	hasktags -e $(haskell_files)

# Requires HLint >= 1.8.4.
hlint :
	hlint src/

doc :
	cabal configure
	cabal haddock --executables

.PHONY : TODO
TODO :
	find \( -name '*.hs' -o -name '*.agda' \) | xargs grep TODO

clean :
	find -name '*.agdai' | xargs rm -f
	rm -f /tmp/*.tptp

snapshot_clean :
	rm -r -f $(snapshot_dir)
