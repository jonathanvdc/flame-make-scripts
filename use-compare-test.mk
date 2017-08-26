# This file defines a 'compare-test' target on which makefiles can rely.
# If the compare-test tool is not installed, then it is automatically
# installed locally. The 'COMPARE_TEST' variable is set to a command that
# runs compare-test.
#
# Rules depending on the 'compare-test' target defined by this file should
# use an order-only dependency. Here's some example usage. Use a
# tab for indentation instead of spaces if you include this in a
# makefile.
#
#     include /path/to/use-compare-test.mk
#
#     test: | compare-test
#         $(COMPARE_TEST) all.test
#
# You may also want to extend your 'make clean' target by adding
# a dependency on 'clean-compare-test'. That'll ensure that a local
# 'compare-test' install is deleted when 'make clean' is run.
#
#     include /path/to/use-compare-test.mk
#
#     .PHONY: clean
#     clean: clean-compare-test
#         ...
#

COMPARE_TEST_ZIP_URL:=https://github.com/jonathanvdc/compare-test/releases/download/v0.1.5/compare-test.zip

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLCHAIN_DIR:=$(ROOT_DIR)/toolchain
LOCAL_COMPARE_TEST_ZIP:=$(TOOLCHAIN_DIR)/compare-test.zip
LOCAL_COMPARE_TEST_DIR:=$(TOOLCHAIN_DIR)/compare-test
LOCAL_COMPARE_TEST_EXE:=$(LOCAL_COMPARE_TEST_DIR)/compare-test.exe

# Only try to define COMPARE_TEST if it hasn't been defined already.
# A user might want to set COMPARE_TEST explicitly from the command-line
# or an environment variable and we should respect that.
ifeq ($(COMPARE_TEST),)
ifneq ($(wildcard $(LOCAL_COMPARE_TEST_DIR)),)
# If we have a local compare-test install, then we'll use that.
COMPARE_TEST_DEPENDENCIES=local-compare-test
COMPARE_TEST=mono "$(LOCAL_COMPARE_TEST_EXE)"
else
ifneq ($(shell which compare-test),)
# If compare-test is installed globally, then that's fine too.
COMPARE_TEST_DEPENDENCIES=
COMPARE_TEST=compare-test
else
# Otherwise, we'll install compare-test locally.
COMPARE_TEST_DEPENDENCIES=local-compare-test
COMPARE_TEST=mono "$(LOCAL_COMPARE_TEST_EXE)"
endif
endif
endif

# 'compare-test' uses a global compare-test command if possible and
# installs a local copy of compare-test if necessary.
.PHONY: compare-test
compare-test: $(COMPARE_TEST_DEPENDENCIES)

# 'local-compare-test' explicitly installs a local copy of compare-test.
.PHONY: local-compare-test
local-compare-test: $(LOCAL_COMPARE_TEST_EXE)

$(LOCAL_COMPARE_TEST_EXE):
	mkdir -p $(TOOLCHAIN_DIR)
	wget $(COMPARE_TEST_ZIP_URL) -O $(LOCAL_COMPARE_TEST_ZIP)
	unzip -d $(LOCAL_COMPARE_TEST_DIR) $(LOCAL_COMPARE_TEST_ZIP)
	rm $(LOCAL_COMPARE_TEST_ZIP)

# 'clean-compare-test' deletes a local copy of compare-test, if one has been created.
.PHONY: clean-compare-test
clean-compare-test:
ifneq ($(wildcard $(LOCAL_COMPARE_TEST_ZIP)),)
	rm "$(LOCAL_COMPARE_TEST_ZIP)"
endif
ifneq ($(wildcard $(LOCAL_COMPARE_TEST_DIR)),)
	rm -rf "$(LOCAL_COMPARE_TEST_DIR)"
endif
