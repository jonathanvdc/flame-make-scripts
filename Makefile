.PHONY: all
all: compare-test ecsc flame-llvm
	$(info compare-test: $(COMPARE_TEST))
	$(info ecsc: $(ECSC))
	$(info flame-llvm: $(FLAME_LLVM))

.PHONY: local
local: local-compare-test local-ecsc local-flame-llvm all

.PHONY: clean
clean: clean-compare-test clean-ecsc clean-flame-llvm
	rm -rf toolchain/

include use-compare-test.mk
include use-ecsc.mk
include use-flame-llvm.mk
