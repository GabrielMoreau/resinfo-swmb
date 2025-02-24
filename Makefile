SOFT:=SWMB
NB_COMMIT=$(shell git log $$(git tag | tail -1)..HEAD --oneline | wc -l)
VERSION_NSI:=$(shell grep '!define VERSION' ./package.nsi | cut -f 2 -d '"')
VERSION:=$(shell echo $(VERSION_NSI) | sed -e "s/\.0$$/.$(NB_COMMIT)/;")
DATE:=$(shell date '+%Y-%m-%d')

.PHONY: all help pkg version check clean doc

all: $(SOFT)-Setup-$(VERSION).exe

help:
	@echo "all      create .exe installer"
	@echo "check    check tweaks"
	@echo "clean    clean setup.exe file"
	@echo "version  write version"
	@echo "doc      build documentation"
	@echo ""
	@echo "VersionNSI: $(VERSION_NSI)"
	@echo "Version:    $(VERSION)"

pkg: $(SOFT)-Setup-$(VERSION).exe

version:
	@echo -n $(VERSION)

%.exe:
	@mkdir -p tmp
	sed -e 's/__VERSION__/$(VERSION)/;' Modules/SWMB.psd1 > tmp/SWMB.psd1
	@echo "@{ ModuleVersion = '$(VERSION)' }" > tmp/Version.psd1
	@(which unix2dos && unix2dos tmp/Version.psd1) > /dev/null 2>&1
	@sed -e 's/$(VERSION_NSI)/$(VERSION)/;' package.nsi > tmp/package.nsi
	makensis -NOCD tmp/package.nsi

check:
	@./check-project

clean:
	@rm -rf SWMB*.exe tmp resources 2> /dev/null

doc:
	mkdir -p /tmp/swmb/site
	sed -e 's|__HERE__|$(CURDIR)|; s|__DATE__|$(DATE)|;' mkdocs.yml > /tmp/swmb/mkdocs.yml
	. /tmp/swmb/venv/bin/activate; mkdocs build -f /tmp/swmb/mkdocs.yml

env:
	mkdir -p /tmp/swmb
	python3 -m venv /tmp/swmb/venv
	. /tmp/swmb/venv/bin/activate; pip install mkdocs-macros-plugin mkdocs-material mkdocs-material-extensions mkdocs-with-pdf # mkdocs-git-revision-date-localized-plugin
