# Self-contained Go Project

This is my personal spin on a self-contained Go project, incorporating the
suite of basic tools and linters I like to use.

Since the strength of Golang is static binaries, this project is focused on
shipping the source, vendored source, and source of support binaries all as
one repository. Git cloning it should be enough to build it, and commands to
update all the external dependencies should be obvious.

The default build configuration is set to a safe set of "static binary only"
settings which should work to build pure Go projects, however if you need to
link C libraries you'll need to enable CGO in the Makefile.

# Project Layout and Usage

This repository adopts a few conventions in laying out a project:

* `cmd` should contain a single level hierarchy of binary commands to be
  built for the current project.
  
* `release` gets populated with version tarballs containing platform release
  binaries.
  
* `bin` gets populated with the directory's used to make versioned releases.

* `tools` contains the versioned build tooling of the repo.

`make autogen` is a command which sets up git pre-commit hooks to enforce style
and formatting on commit.

`make binary` will build the current platforms binaries and symlink them into
the root directory of the project for easy use.
