Easy to create a developing environment for LLVM for NEC SX-Aurora VE
=====================================================================

This repository contains Makefile and scripts to create a developing
environment for LLVM for NEC SX-Aurora VE.

LLVM requires multiple repositories to combine and LLVM for VE requires
multiple libraries' cross-compile.  Those are little difficult to handle
at the beginning.  So, I made this easy to use developing environment.

Prerequisites
=============

  - cmake (cmake3 in RHEL7)
  - ninja (ninja-build in RHEL7)

Repositories
============

We maintain multiple repositories, one for public and one for internal.
We prepare multiple branches for multiple repositoris, so please clone
correct one.

    $ git clone git@socsv218.svp.cl.nec.co.jp:ve-llvm/llvm-dev.git -b gitea

Prepare source codes
====================

There are two ways to clone source code, shallow one and deep one.  If
you simply want to git it try, please use shallow one.  If you are
developing for LLVM for VE, please use deep one.  Recent git, 1.9 or
above, allows fetch and push to/from shallow repositories, so shallow
may work for developing.

    $ make shallow
    $ ls llvm

or

    $ make deep
    $ ls llvm

Compile and install
====================

Compile clang/llvm for VE, install clang/llvm under ./install directory,
cross-compile libraries using installed clang/llvm for VE, and install
generated cross-compiled libraries under ./install directory by following
command.

    $ make

You can install everything to your favorite place by following command.

    $ make DEST=~/.local      # need to use an absolute path

Compile without installation
============================

You can compile clang/llvm without installation by following command.

    $ make build

Clang/llvm requires installed header files, so please install them
by following command before use them.

    $ make install

Debug mode compile
==================

Compile clang/llvm in debug mode by following command.  Compiled
clang/llvm are left in independent directory named build-debug.

    $ make build-debug

Debug mode everything
=====================

It is also possible to compile and install everything under debug mode
by following command.

    $ make clean                   # remove compiled binaries first
    $ make BUILD_TYPE=Debug

Run tests
=========

Tests are never executed by above commands.  It is required to
run them explicitly like below if you want to perform tests.

You can test compiled clang by following command.

    $ make check-clang

You can test compiled llvm by following command.

    $ make check-llvm
