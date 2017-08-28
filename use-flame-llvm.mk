# This file defines an 'flame-llvm' target on which makefiles can rely.
# If the flame-llvm compiler is not installed, then it is automatically
# installed locally. The 'FLAME_LLVM' variable is set to a command that
# runs flame-llvm.
#
# Rules depending on the 'flame-llvm' target defined by this file should
# use an order-only dependency. Here's some example usage. Use a
# tab for indentation instead of spaces if you include this in a
# makefile.
#
#     include /path/to/use-flame-llvm.mk
#
#     out.ll: obj.flo | flame-llvm
#         $(FLAME_LLVM) obj.flo -platform llvm -o out.ll
#
# You may also want to extend your 'make clean' target by adding
# a dependency on 'clean-flame-llvm'. That'll ensure that a local 'flame-llvm'
# install is deleted when 'make clean' is run.
#
#     include /path/to/use-flame-llvm.mk
#
#     .PHONY: clean
#     clean: clean-flame-llvm
#         ...
#

FLAME_LLVM_GIT_REPO:=https://github.com/jonathanvdc/flame-llvm

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLCHAIN_DIR:=$(ROOT_DIR)/toolchain
LOCAL_FLAME_LLVM_DIR:=$(TOOLCHAIN_DIR)/flame-llvm
LOCAL_FLAME_LLVM_SLN:=$(LOCAL_FLAME_LLVM_DIR)/src/flame-llvm.sln
LOCAL_FLAME_LLVM_EXE:=$(LOCAL_FLAME_LLVM_DIR)/src/flame-llvm/bin/Release/flame-llvm.exe

# Only try to define FLAME_LLVM if it hasn't been defined already.
# A user might want to set FLAME_LLVM explicitly from the command-line
# or an environment variable and we should respect that.
ifeq ($(FLAME_LLVM),)
ifneq ($(wildcard $(LOCAL_FLAME_LLVM_EXE)),)
# If we have a local flame-llvm install, then we'll use that.
FLAME_LLVM_DEPENDENCIES=local-flame-llvm
FLAME_LLVM=mono "$(LOCAL_FLAME_LLVM_EXE)"
else
ifneq ($(shell which flame-llvm),)
# If flame-llvm is installed globally, then that's fine too.
FLAME_LLVM_DEPENDENCIES=
FLAME_LLVM=flame-llvm
else
# Otherwise, we'll install flame-llvm locally.
FLAME_LLVM_DEPENDENCIES=local-flame-llvm
FLAME_LLVM=mono "$(LOCAL_FLAME_LLVM_EXE)"
endif
endif
endif

# TODO: maybe try harder to find libLLVM
ifeq ($(LIBLLVM_PATH),)
LIBLLVM_PATH=/usr/lib/llvm-3.8/lib/libLLVM.so
endif

# 'flame-llvm' uses a global flame-llvm command if possible and installs a local
# copy of flame-llvm if necessary.
.PHONY: flame-llvm
flame-llvm: $(FLAME_LLVM_DEPENDENCIES)

# 'local-flame-llvm' explicitly installs a local copy of flame-llvm.
.PHONY: local-flame-llvm
local-flame-llvm: $(LOCAL_FLAME_LLVM_EXE)

$(LOCAL_FLAME_LLVM_EXE):
	if [ ! -d "$(LOCAL_FLAME_LLVM_DIR)" ]; then \
		git clone --recursive --depth=1 $(FLAME_LLVM_GIT_REPO) "$(LOCAL_FLAME_LLVM_DIR)"; \
	fi
	cd "$(LOCAL_FLAME_LLVM_DIR)"; ./build-libs.sh $(LIBLLVM_PATH)
	make -C "$(LOCAL_FLAME_LLVM_DIR)" nuget
	make -C "$(LOCAL_FLAME_LLVM_DIR)"
	make -C "$(LOCAL_FLAME_LLVM_DIR)" stdlib

# 'clean-flame-llvm' deletes a local copy of flame-llvm, if one has been created.
.PHONY: clean-flame-llvm
clean-flame-llvm:
ifneq ($(wildcard $(LOCAL_FLAME_LLVM_DIR)),)
	rm -rf "$(LOCAL_FLAME_LLVM_DIR)"
endif
