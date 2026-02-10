# Makefile for SWLN (SWMB project)
# Warnning: Do not change variables and rules in this file!

SOFT:=SWCE
VERSION:=$(shell cd ../..; make --quiet version)
REVISION:=1

.PHONY: all clean ocs check-exe version

all: swce.ps1 $(SOFT)_$(VERSION)-$(REVISION)_x64.zip

tmp/version-$(VERSION).txt: Makefile
	@mkdir -p tmp
	@echo "$(VERSION)" > tmp/version-$(VERSION).txt

swce.ps1: make-swce extract-swce LocalMachine-SWCE.preset Makefile tmp/version-$(VERSION).txt
	@./make-swce > swce.ps1

clean:
	rm -rf swce.ps1 tmp

version:
	@echo "VERSION: $(VERSION)"

%.zip: Makefile README.md swce.ps1 tmp/version-$(VERSION).txt
	@rm -f $@
	@zip --quiet -r ./$@ README.md swce.ps1
	@(cd tmp ; zip --quiet -r ../$@ version-$(VERSION).txt)
	@chmod ug+rw,o+r $@
