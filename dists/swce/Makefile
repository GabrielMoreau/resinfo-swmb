# Makefile for SWLN (SWMB project)
# Warnning: Do not change variables and rules in this file!

SOFT:=SWCE
VERSION:=$(shell cd ../..; make --quiet version)
REVISION:=1

ZIPFILES:=README.md push-on-gitlab.ps1 push-config.sample.ini $(wildcard push-config.ini)
LOGDIR:=C:\\Temp


.PHONY: all help clean ocs check-exe version

all: tmp/LocalMachine-SWCE.ps1 $(SOFT)-$(VERSION)-$(REVISION).zip ## Create .zip archive package

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

tmp/version-$(VERSION).txt: Makefile
	@mkdir -p tmp
	@echo "$(VERSION)" > $@

tmp/LocalMachine-SWCE.ps1: make-swce extract-swce LocalMachine-SWCE.preset Makefile tmp/version-$(VERSION).txt
	@mkdir -p tmp
	@./make-swce > $@
	@unix2dos $@ 2> /dev/null

clean: ## Clean zip archive and temporary files
	@rm -rf tmp *.zip

version: ## Print software version
	@echo "VERSION: $(VERSION)"

tmp/install.bat: install.bat Makefile
	@mkdir -p tmp
	@sed -e 's/__VERSION__/$(VERSION)/; s#__LOGDIR__#$(LOGDIR)#;' $< > $@
	@unix2dos $@ 2> /dev/null

%.zip: Makefile $(ZIPFILES) tmp/install.bat tmp/LocalMachine-SWCE.ps1 tmp/version-$(VERSION).txt
	@rm -f $@
	@zip --quiet -r ./$@ $(ZIPFILES)
	@(cd tmp ; zip --quiet -r ../$@ install.bat LocalMachine-SWCE.ps1 version-$(VERSION).txt)
	@chmod ug+rw,o+r $@
