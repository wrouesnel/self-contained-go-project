
COVERDIR = .coverage
TOOLDIR = tools
BINDIR = bin
RELEASEDIR = release

DIRS = $(BINDIR) $(RELEASEDIR)

GO_SRC := $(shell find . -name '*.go' ! -path '*/vendor/*' ! -path 'tools/*' ! -path 'bin/*' ! -path 'release/*' )
GO_DIRS := $(shell find . -type d -name '*.go' ! -path '*/vendor/*' ! -path 'tools/*' ! -path 'bin/*' ! -path 'release/*' )
GO_PKGS := $(shell go list ./... | grep -v '/vendor/')

BINARY := $(shell basename $(shell pwd))
VERSION ?= $(shell git describe --dirty 2>/dev/null)
VERSION_SHORT ?= $(shell git describe --abbrev=0 2>/dev/null)

ifeq ($(VERSION),)
VERSION := v0.0.0
endif

ifeq ($(VERSION_SHORT),)
VERSION_SHORT := v0.0.0
endif

# By default this list is filtered down to some common platforms.
platforms := $(subst /,-,$(shell go tool dist list | grep -e linux -e windows -e darwin | grep -e 386 -e amd64))
PLATFORM_BINS := $(patsubst %,$(BINDIR)/$(BINARY)_$(VERSION_SHORT)_%/$(BINARY),$(platforms))
PLATFORM_DIRS := $(patsubst %,$(BINDIR)/$(BINARY)_$(VERSION_SHORT)_%,$(platforms))
PLATFORM_TARS := $(patsubst %,$(RELEASEDIR)/$(BINARY)_$(VERSION_SHORT)_%.tar.gz,$(platforms))

# These are evaluated on use, and so will have the correct values in the build
# rule (https://vic.demuzere.be/articles/golang-makefile-crosscompile/)
PLATFORMS_TEMP = $(subst -, ,$(patsubst $(BINDIR)/$(BINARY)_$(VERSION_SHORT)_%/$(BINARY),%,$@))
GOOS = $(word 1, $(PLATFORMS_TEMP))
GOARCH = $(word 2, $(PLATFORMS_TEMP))

CURRENT_PLATFORM := $(BINDIR)/$(BINARY)_$(VERSION_SHORT)_$(shell go env GOOS)-$(shell go env GOARCH)/$(BINARY)

CONCURRENT_LINTERS ?=
ifeq ($(CONCURRENT_LINTERS),)
CONCURRENT_LINTERS = $(shell gometalinter --help | grep -o 'concurrency=\w*' | cut -d= -f2 | cut -d' ' -f1)
endif

LINTER_DEADLINE ?= 30s

$(shell mkdir -p $(DIRS))

export PATH := $(TOOLDIR)/bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

all: style lint test binary

binary: $(BINARY)

$(BINARY): $(CURRENT_PLATFORM)
	ln -sf $< $@

$(PLATFORM_BINS): $(GO_SRC)
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -a \
		-ldflags "-extldflags '-static' -X main.Version=$(VERSION)" \
		-o $@ .

$(PLATFORM_DIRS): $(PLATFORM_BINS)

$(PLATFORM_TARS): $(RELEASEDIR)/%.tar.gz : $(BINDIR)/%
	tar -czf $@ -C $(BINDIR) $$(basename $<)
	
release-bin: $(PLATFORM_BINS)

release: $(PLATFORM_TARS)

style: tools
	gometalinter --disable-all --enable=gofmt --vendor

lint: tools
	@echo Using $(CONCURRENT_LINTERS) processes
	gometalinter -j $(CONCURRENT_LINTERS) --deadline=$(LINTER_DEADLINE) --disable=gotype $(GO_DIRS)

fmt: tools
	gofmt -s -w $(GO_SRC)

test: tools
	@mkdir -p $(COVERDIR)
	@rm -f $(COVERDIR)/*
	for pkg in $(GO_PKGS) ; do \
		go test -v -covermode count -coverprofile=$(COVERDIR)/$$(echo $$pkg | tr '/' '-').out $$pkg ; || exit 1 \
	done
	gocovmerge $(shell find $(COVERDIR) -name '*.out') > cover.out

clean:
	[ ! -z $(BINDIR) ] && [ -e $(BINDIR) ] && find $(BINDIR) -print -delete || /bin/true
	[ ! -z $(COVERDIR) ] && [ -e $(COVERDIR) ] && find $(COVERDIR) -print -delete || /bin/true
	[ ! -z $(RELEASEDIR) ] && [ -e $(RELEASEDIR) ] && find $(RELEASEDIR) -print -delete || /bin/true
	
tools:
	$(MAKE) -C $(TOOLDIR)
	
.PHONY: tools style fmt test all release binary clean
