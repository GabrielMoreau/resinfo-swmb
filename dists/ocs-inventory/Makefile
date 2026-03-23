SOFT:=SWMB
VERSION:=$(shell grep '!define VERSION' ../../tmp/package.nsi | cut -f 2 -d '"')
REVISION:=1


.PHONY: help all update clean ocs

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


all: $(SOFT)-OCS-$(VERSION)-$(REVISION).zip ocs ## Create a zip archive


update: ## Make a git pull (update local repository)
	(cd ../..; git pull)


clean: ## Clean zip archive and temporary files
	rm -f $(SOFT)-OCS-$(VERSION)-$(REVISION).zip
	rm -rf tmp


%.zip: Makefile
	mkdir -p tmp
	sed -e 's/__VERSION__/$(VERSION)/; s/__REVISION__/$(REVISION)/;' install.bat > tmp/install.bat
	rm -f $@
	(cd ../..; \
		make all; \
		cp SWMB-Setup-$(VERSION).exe ./dists/ocs-inventory/tmp/ \
		)
	(cd tmp; \
		cp ../README.md ./; \
		zip -r ../$@ install.bat README.md SWMB-Setup-$(VERSION).exe)
	chmod ugo+rw $@


ocs: ## Help for upload the Zip archive in OCS server
	@echo ""
	@echo "Name:     $(SOFT)-$(VERSION)-$(REVISION)"
	@echo "priority: 2"
	@echo "Launch:   install.bat"
	@echo "Message:  no"
	@echo ""
	@echo "RESINFO GT SWMB"
	@echo " --- "
	@echo "Installation et/ou mise à jour de $(SOFT)"
	@echo ""
