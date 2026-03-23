SOFT:=SWMB
VERSION:=$(shell grep '!define VERSION' ../../tmp/package.nsi | cut -f 2 -d '"')
REVISION:=1
DATE:=$(shell date '+%Y-%m-%d')

.PHONY: all help update clean

all: $(SOFT)-WAPT-$(VERSION)-$(REVISION).zip


help:
	@echo "all      create a Zip archive"
	@echo "clean    clean folder"
	@echo "update   make a git pull (update local repository)"


update:
	(cd ../..; git pull)


clean:
	rm -f $(SOFT)-WAPT-$(VERSION)-$(REVISION).zip
	rm -rf tmp


%.zip: Makefile control README.md setup.py icon.png ../../tmp/package.nsi
	@rm -rf ./tmp
	@mkdir -p ./tmp/resinfo-swmb/WAPT
	@sed -e 's/__VERSION__/$(VERSION)/; s/__REVISION__/$(REVISION)/;' control > ./tmp/resinfo-swmb/WAPT/control
	@perl -p -e 's{__DATE__}{$(DATE)};' README.md > ./tmp/resinfo-swmb/README.md
	@cp -f ../../LICENSE.md setup.py ./tmp/resinfo-swmb/
	@cp -f ./icon.png ./tmp/resinfo-swmb/WAPT/
	@rm -f $@
	@(cd ../..; \
		make all; \
		cp SWMB-Setup-$(VERSION).exe ./dists/wapt/tmp/resinfo-swmb/ \
		)
	@(cd tmp; \
		zip -r ../$@ resinfo-swmb)
	@chmod ugo+rw $@
