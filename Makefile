THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
BUILD_TOP_DIR = $(abspath $(dir ${THIS_MAKEFILE_PATH}))

# Retrieve all sources from this repo's parent
REPO = $(dir $(shell cd ${BUILD_TOP_DIR}; git config remote.origin.url))
BRANCH = develop
BUILD_TYPE = Release
BUILD_TARGET = "VE;X86"
TARGET = ve-linux
OMPARCH = ve
# DEST and SRCDIR requires to use an abosolute path
DEST = ${BUILD_TOP_DIR}/install
SRCDIR = ${BUILD_TOP_DIR}
# RESDIR requires trailing '/'.
RESDIR = ${DEST}/lib/clang/9.0.0/
LIBSUFFIX = /linux/ve/
CSUDIR = ${RESDIR}lib/linux/ve
OPTFLAGS = -O3 -fno-vectorize -fno-slp-vectorize \
	-mllvm -combiner-use-vector-store=false
# llvm test tools are not installed, so need to specify them independently
TOOLDIR = ${BUILD_TOP_DIR}/build/bin

RM = rm
CMAKE = cmake3
NINJA = ninja-build
THREADS = -j8
CLANG = ${DEST}/bin/clang

all: check-source cmake install libraries
libraries: ve-csu compiler-rt libunwind libcxxabi libcxx openmp

musl:
	make TARGET=ve-linux-musl all

check-source:
	@test -d llvm || echo Need to prepare source code by \"make shallow\"
	@test -d llvm || exit 1

cmake:
	mkdir -p build
	cd build; CMAKE=${CMAKE} DEST=${DEST} TARGET=${BUILD_TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-llvm.sh

build:
	@test -d build || echo Need to cmake first by \"make cmake\"
	@test -d build || exit 1
	cd build; ${NINJA} ${THREADS}

install: build
	cd build; ${NINJA} ${THREADS} install

installall: install ve-csu compiler-rt libunwind libcxxabi libcxx openmp

build-debug:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${BUILD_TARGET} \
	    BUILD_TYPE=Debug SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-llvm.sh
	cd $@; ${NINJA} ${THREADS}

check-llvm: build
	cd build; ${NINJA} ${THREADS} check-llvm

check-clang: build
	cd build; ${NINJA} ${THREADS} check-clang

ve-csu:
	cd $@; make CLANG=${CLANG} DEST=${CSUDIR} TARGET=${TARGET} \
	    install

compiler-rt:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-compiler-rt.sh
	cd $@; ${NINJA} ${THREADS} install

libunwind:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-libunwind.sh
	cd $@; ${NINJA} ${THREADS} install

libcxxabi:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-libcxxabi.sh
	cd $@; ${NINJA} ${THREADS} install

check-libcxxabi: libcxxabi
	cd libcxxabi; ${NINJA} ${THREADS} check-libcxxabi

libcxx:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/cmake-libcxx.sh
	cd $@; ${NINJA} ${THREADS} install

openmp:
	mkdir -p $@
	cd $@; CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} OMPARCH=${OMPARCH} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${SRCDIR}/scripts/cmake-openmp.sh
	cd $@; ${NINJA} ${THREADS} install

check-openmp: openmp
	cd openmp; ${NINJA} ${THREADS} check-openmp

shallow:
	REPO=${REPO} BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/clone-source.sh --depth 1

deep:
	REPO=${REPO} BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/clone-source.sh

shallow-update:
	BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/update-source.sh --depth 1

deep-update:
	BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${SRCDIR}/scripts/update-source.sh

clean:
	${RM} -rf build compiler-rt libunwind libcxxabi libcxx openmp \
	    build-debug
	-cd ve-csu && make clean

distclean: clean
	${RM} -rf llvm ve-csu
	${RM} -rf ${DEST}

FORCE:

.PHONY: FORCE shallow deep clean dist clean check-source cmake build install \
	libraries ve-csu compiler-rt libunwind libcxxabi libcxx openmp \
	build-debug musl installall
