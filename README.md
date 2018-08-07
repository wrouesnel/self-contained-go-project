# Self-contained Go Project

This is my personal spin on a self-contained Go project, incorporating the
suite of basic tools and linters I like to use.

Since the strength of Golang is static binaries, this project is focused on
shipping the source, vendored source, and source of support binaries all as
one repository. Git cloning it should be enough to build it, and commands to
update all the external dependencies should be obvious.

The default build configuration is set to a safe set of "static binary only"
settings which should work to build pure Go projects, however if you need to
link C libraries you'll need to enable CGO in the `magefile.go` file.

## How to build

```
$ go run mage.go
```
will trigger the build system and provide list of options. `go run mage.go binary`
will build the sample app.

## Included Tools

These tools will work with go generate during builds due to path overrides in the
magefile:

* `github.com/cheekybits/genny`
* `github.com/alvaroloes/enumer`
* `github.com/fatih/gomodifytags`

## Notes

* `gometalinter` doesn't cleanly update with `updateTools` due to the incompatible
  changes with `kingpin.v3-unstable`. This repository has a patched version
  committed to the lint tools.
  

