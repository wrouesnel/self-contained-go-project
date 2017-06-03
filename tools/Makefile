# Makefile to build the tools used in the build system.
# If recreating from scratch, you will need a local install of govendor
# and to run govendor init in this folder before running govendor fetch.
GO_SRC := $(shell find $(SOURCEDIR) -name '*.go')

export PATH := bin:$(PATH)

all: bin/gometalinter bin/gocovmerge bin/govendor bin/goveralls

bin/govendor: $(GO_SRC)
	GOPATH=$(shell pwd) go install github.com/kardianos/govendor

bin/gocovmerge: $(GO_SRC)
	GOPATH=$(shell pwd) go install github.com/wadey/gocovmerge

bin/gometalinter: $(GO_SRC)
	GOPATH=$(shell pwd) go install github.com/alecthomas/gometalinter
	linters=`gometalinter --help | grep -oP '  \w+  \(.+\)' | tr -s ' ' | cut -d' ' -f3 | grep -oP '[^()]+'` ; \
	for linter in $$linters ; do \
		GOPATH=$(shell pwd) go install -v $$linter ; \
	done

bin/goveralls: $(GO_SRC)
	GOPATH=$(shell pwd) go install github.com/mattn/goveralls

update: bin/govendor
	govendor fetch -v github.com/kardianos/govendor
	govendor fetch -v github.com/wadey/gocovmerge
	govendor fetch -v github.com/mattn/goveralls
	govendor fetch -v github.com/alecthomas/gometalinter
	make update-2nd-pass
	
update-2nd-pass: bin/gometalinter
	linters=`gometalinter --help | grep -oP '  \w+  \(.+\)' | tr -s ' ' | cut -d' ' -f3 | grep -oP '[^()]+'` ; \
	for linter in $$linters ; do \
		govendor fetch -v $$linter ; \
	done

clean:
	rm -rf bin pkg

.PHONY: all update update-2nd-pass clean
