.PHONY: all
all: compare-test ecsc
	$(info compare-test: $(COMPARE_TEST))
	$(info ecsc: $(ECSC))

.PHONY: local
local: local-compare-test local-ecsc all

.PHONY: clean
clean: clean-compare-test clean-ecsc
	rm -rf toolchain/

include use-compare-test.mk
include use-ecsc.mk