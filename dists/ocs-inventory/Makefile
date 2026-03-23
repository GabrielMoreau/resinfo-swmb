SOFT:=SWMB
VERSION:=$(shell grep '!define VERSION' ../../tmp/package.nsi | cut -f 2 -d '"')
REVISION:=1


.PHONY: all help update clean ocs

all: $(SOFT)-OCS-$(VERSION)-$(REVISION).zip ocs


help:
	@echo "all      create a zip archive"
	@echo "ocs      help for upload the Zip archive in OCS server"
	@echo "clean    clean folder"
	@echo "update   make a git pull (update local repository)"


update:
	(cd ../..; git pull)


clean:
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


ocs:
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
