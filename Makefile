SOFT:=SWMB
NB_COMMIT=$(shell git log $$(git tag | tail -1)..HEAD --oneline | wc -l)
VERSION_NSI:=$(shell grep '!define VERSION' ./package.nsi | cut -f 2 -d '"')
VERSION:=$(shell echo $(VERSION_NSI) | sed -e "s/\.0$$/.$(NB_COMMIT)/;")
DATE:=$(shell date '+%Y-%m-%d')

# Host IP for WSL2 under Windows
IP_SERVE:=$(shell (echo 127.0.0.1 ; uname -a | grep -q 'microsoft' && hostname -I | cut -f 1 -d ' ') | tail -1)

.PHONY: all help pkg version check clean doc serve-start serve-stop

all: $(SOFT)-Setup-$(VERSION).exe ## Create .exe installer

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

pkg: $(SOFT)-Setup-$(VERSION).exe

version: ## Print software version
	@echo -n $(VERSION)

%.exe:
	@mkdir -p tmp
	sed -e 's/__VERSION__/$(VERSION)/;' Modules/SWMB.psd1 > tmp/SWMB.psd1
	@echo "@{ ModuleVersion = '$(VERSION)' }" > tmp/Version.psd1
	@(which unix2dos && unix2dos tmp/Version.psd1) > /dev/null 2>&1
	@sed -e 's/$(VERSION_NSI)/$(VERSION)/;' package.nsi > tmp/package.nsi
	@(cd dists/swce; make --quiet all 2> /dev/null)
	makensis -NOCD tmp/package.nsi

check: ## Check tweaks and code quality
	@./check-project

clean: ## Clean setup.exe and temporary files
	@rm -rf SWMB*.exe tmp resources 2> /dev/null
	@(cd dists/swce; make --quiet clean 2> /dev/null)

doc: env ## Build documentation
	mkdir -p /tmp/swmb/site
	sed -e 's|__HERE__|$(CURDIR)|; s|__DATE__|$(DATE)|;' mkdocs.yml > /tmp/swmb/mkdocs.yml
	. /tmp/swmb/venv/bin/activate; mkdocs build -f /tmp/swmb/mkdocs.yml

env: ## Install Python virtual environment
	mkdir -p /tmp/swmb
	python3 -m venv /tmp/swmb/venv
	. /tmp/swmb/venv/bin/activate; pip install mkdocs-macros-plugin mkdocs-material mkdocs-material-extensions mkdocs-with-pdf # mkdocs-git-revision-date-localized-plugin

serve-start: ## Start local instance mkdocs server on port 8010
	. /tmp/swmb/venv/bin/activate; mkdocs serve --dev-addr $(IP_SERVE):8010 -f /tmp/swmb/mkdocs.yml &

serve-stop: ## Stop local instance mkdocs server
	pgrep -f 'mkdocs serve --dev-addr $(IP_SERVE):8010 ' | xargs -r kill
