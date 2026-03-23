SOFT:=SWMB
VERSION:=$(shell grep '!define VERSION' ../../tmp/package.nsi | cut -f 2 -d '"')
REVISION:=1
DATE:=$(shell date '+%Y-%m-%d')

.PHONY: help all update clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


all: $(SOFT)-WAPT-$(VERSION)-$(REVISION).zip ## Create .zip archive package


update: ## Make a git pull (update local repository)
	(cd ../..; git pull)


clean: ## Clean zip archive and temporary files
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
