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

## Notable Makefile Targets

* `autogen` : autogen sets up a pre-commit hook in the local `.git` repository
  which automatically runs gofmt on code before committing it. You might like
  to change this to run `make style` instead to just do a style check, rather
  then modifying files (though I find this less convenient).
