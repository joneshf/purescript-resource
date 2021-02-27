COMPILE_FLAGS ?=
DEPENDENCIES := '.spago/*/*/src/**/*.purs'
NODE := node
NPM := npm
OUTPUT := output
PSA := npx psa
PSCID := npx pscid
PURS := npx purs
PURTY := npx purty
REPL_FLAGS ?=
SPAGO := npx spago
SPAGO_FLAGS ?=
SRC := src
TEST := test

SRCS := $(shell find $(SRC) -name '*.purs' -type f)
TESTS := $(shell find $(TEST) -name '*.purs' -type f)
SRC_OUTPUTS := $(patsubst $(SRC).%.purs,$(OUTPUT)/%/index.js,$(subst /,.,$(SRCS)))
TEST_OUTPUTS := $(patsubst $(TEST).%.purs,$(OUTPUT)/%/index.js,$(subst /,.,$(TESTS)))

define SRC_OUTPUT_RULE
$(patsubst $(SRC).%.purs,$(OUTPUT)/%/index.js,$(subst /,.,$(1))): $(1) .spago
	$(PSA) compile $(COMPILE_FLAGS) $(DEPENDENCIES) $(SRCS)
endef

define TEST_OUTPUT_RULE
$(patsubst $(TEST).%.purs,$(OUTPUT)/%/index.js,$(subst /,.,$(1))): $(1) $(SRC_OUTPUTS) .spago
	$(PSA) compile $(COMPILE_FLAGS) $(DEPENDENCIES) $(SRCS) $(TESTS)
endef

$(foreach source, $(SRCS), $(eval $(call SRC_OUTPUT_RULE, $(source))))

$(foreach test, $(TESTS), $(eval $(call TEST_OUTPUT_RULE, $(test))))

.DEFAULT_GOAL := build

$(OUTPUT):
	mkdir -p $@

$(OUTPUT)/test.js: $(OUTPUT)/Test.Main/index.js | $(OUTPUT)
	$(PURS) bundle \
	  --main Test.Main \
	  --module Test.Main \
	  --output $@ \
	  output/*/index.js \
	  output/*/foreign.js

.spago: node_modules packages.dhall spago.dhall
	rm -rf $@
	$(SPAGO) $(SPAGO_FLAGS) install
	touch $@

.PHONY: build
build: .spago $(SRC_OUTPUTS)

.PHONY: clean
clean:
	rm -rf \
	  .psc-ide-port \
	  .psci_modules \
	  .spago \
	  node_modules \
	  output

.PHONY: format
format: node_modules
	find $(SRC) -name '*.purs' -exec $(PURTY) --write {} \;
	find $(TESTS) -name '*.purs' -exec $(PURTY) --write {} \;

node_modules: package.json
	$(NPM) install
	touch $@

.PHONY: repl
repl: .spago
	$(PURS) repl $(REPL_FLAGS) $(DEPENDENCIES) $(SRCS)

.PHONY: test
test: $(OUTPUT)/test.js .spago $(SRC_OUTPUTS) $(TEST_OUTPUTS)
	$(NODE) $<

.PHONY: variables
variables:
	$(info $$DEPENDENCIES is [$(DEPENDENCIES)])
	$(info $$SRC_OUTPUTS is [$(SRC_OUTPUTS)])
	$(info $$SRCS is [$(SRCS)])
	$(info $$TESTS is [$(TESTS)])

.PHONY: watch
watch:
	$(PSCID) --test
