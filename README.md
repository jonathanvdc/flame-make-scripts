# Flame Makefile scripts

[![Build Status](https://travis-ci.org/jonathanvdc/flame-make-scripts.svg?branch=master)](https://travis-ci.org/jonathanvdc/flame-make-scripts)

This repository contains a collection of GNU Make scripts that locate and/or install Flame-based projects. The goal of these scripts is to minimize the amount of hassle users experience when building your project: they either find an existing install of a tool or automatically build it from source. Running `make` should Just Work.

You can simply copy the scripts and put them in your own repository or&mdash;better yet&mdash;include this repository as a git submodule.

## `ecsc`

[`use-ecsc.mk`](use-ecsc.mk) tries to find the `ecsc` compiler and exposes it using the `ECSC` variable. If there's no global `ecsc` command, then `use-ecsc.mk` builds `ecsc` from source and makes `$(ECSC)` expand to a command that runs the local `ecsc` build.

Here's an example Makefile that uses `use-ecsc.mk` to provide `ecsc`.

```makefile
include /path/to/use-ecsc.mk

out.exe: code.cs | ecsc
    $(ECSC) code.cs -platform clr -o out.exe
```

Read the comments at the top of `use-ecsc.mk` for a more complete description.