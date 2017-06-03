# Makefile to build the tools used in the build system.
# If recreating from scratch, you will need a local install of govendor
# and to run govendor init in this folder before running govendor fetch.
GO_SRC := $(shell find $(SOURCEDIR) -name '*.go')

GO := GOPATH=$(shell pwd) go

export PATH := bin:$(PATH)
SHELL := env PATH=$(PATH) /bin/bash

THIS_FILE := $(lastword $(MAKEFILE_LIST))

all: bin/gometalinter bin/gocovmerge bin/govendor bin/goveralls

bin/govendor: $(GO_SRC)
	$(GO) install github.com/kardianos/govendor

bin/gocovmerge: $(GO_SRC)
	$(GO) install github.com/wadey/gocovmerge

bin/gometalinter: $(GO_SRC)
	$(GO) install github.com/alecthomas/gometalinter

.gometalinters.dep: bin/gometalinter
	gometalinter --help | grep -oP '  \w+  \(.+\)' | \
	tr -s ' ' | cut -d' ' -f3 | grep -oP '[^()]+' | while read l ; do \
		echo -e "bin/$$(basename l): $$l\n\t"
	done > .gometalinters.dep

# This rule builds the gometalinters from the list generated above.
$(addprefix bin/,$(notdir $(cat .gometalinters))): $(cat .gometalinters)
	$(GO) install $<

bin/goveralls: $(GO_SRC)
	$(GO) install github.com/mattn/goveralls

# First stage update rule.
update: bin/govendor
	govendor fetch -v github.com/kardianos/govendor
	govendor fetch -v github.com/wadey/gocovmerge
	govendor fetch -v github.com/mattn/goveralls
	govendor fetch -v github.com/alecthomas/gometalinter
	# This ugliness is so we can explicitely extract the metalinters and build
	# .gometalinter before executing update linters.
	$(MAKE) -f $(THIS_FILE) .gometalinters
	$(MAKE) -f $(THIS_FILE) update-linters

# Second stage rule which updates the gometalinters.
update-linters: $(shell cat .gometalinters)
	govendor fetch -v $<

clean:
	rm -rf bin pkg

.PHONY: all update clean update-linters
