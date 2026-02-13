# Makefile for SWLN (SWMB project)
# Warnning: Do not change variables and rules in this file!

SOFT:=SWCE
VERSION:=$(shell cd ../..; make --quiet version)
REVISION:=1

.PHONY: all clean ocs check-exe version

all: tmp/LocalMachine-SWCE.ps1 $(SOFT)-$(VERSION)-$(REVISION).zip

tmp/version-$(VERSION).txt: Makefile
	@mkdir -p tmp
	@echo "$(VERSION)" > $@

tmp/LocalMachine-SWCE.ps1: make-swce extract-swce LocalMachine-SWCE.preset Makefile tmp/version-$(VERSION).txt
	@mkdir -p tmp
	@./make-swce > $@

clean:
	@rm -rf tmp *.zip

version:
	@echo "VERSION: $(VERSION)"

%.zip: Makefile README.md tmp/LocalMachine-SWCE.ps1 tmp/version-$(VERSION).txt
	@rm -f $@
	@zip --quiet -r ./$@ README.md
	@(cd tmp ; zip --quiet -r ../$@ LocalMachine-SWCE.ps1 version-$(VERSION).txt)
	@chmod ug+rw,o+r $@
