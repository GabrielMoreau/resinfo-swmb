# Makefile for SWLN (SWMB project)
# Warnning: Do not change variables and rules in this file!
# Change them in extend-variables.mk and extend-rules.mk include makefiles

SOFT:=SWLN
SWLN_NAME:=SWLN
SWMB_VERSION:=$(shell curl --silent --location --insecure 'https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/version.txt')
SWLN_VERSION:=5.20.$(shell echo $(SWMB_VERSION) | sed -e 's/\./ /g;' | xargs -r printf "%i%02i%02i%03i")
REVISION:=1

LOG_DIR:=%SystemRoot%\\Logs\\Deploy

FILES := logo-swmb.ico
FILES += $(wildcard CurrentUser-Logon.preset)
FILES += $(wildcard LocalMachine-Boot.preset)
FILES += $(wildcard LocalMachine-PostInstall.preset)
FILES += $(wildcard Custom-VarOverload.psm1)
FILES += $(wildcard Custom-VarAutodel.psm1)
FILES += $(wildcard Local-Addon.psm1)
FILES += pre-install-01copy.bat
FILES += post-install-01reg.bat

RESET_FLAG := $(wildcard Group-*.hosts)
RESET_FLAG += $(wildcard LocalMachine-Boot-Group-*.preset        LocalMachine-Boot-Host-*.preset)
RESET_FLAG += $(wildcard LocalMachine-PostInstall-Group-*.preset LocalMachine-PostInstall-Host-*.preset)
RESET_FLAG += $(wildcard CurrentUser-Logon-Group-*.preset        CurrentUser-Logon-Host-*.preset)
RESET_FLAG += $(wildcard Custom-VarOverload-Group-*.psm1         Custom-VarOverload-Host-*.psm1)
RESET_FLAG += $(wildcard Custom-VarAutodel-Group-*.psm1          Custom-VarAutodel-Host-*.psm1)
RESET_FLAG += $(wildcard Local-Addon-Group-*.psm1                Local-Addon-Host-*.psm1)

define GROUP_TO_HOST_TFILES
$(shell \
	for f in $(wildcard $1-Group-*.$2); do \
		g=$${f#$1-Group-}; \
		g=$${g%.$2}; \
		awk '!/^[[:space:]]*#/ && NF {print $$1}' Group-$$g.hosts 2>/dev/null | sort -u | \
		while read -r h; do echo $1-Host-$$h.$2; done; \
	done )
endef
TFILES:=
TFILES += $(wildcard LocalMachine-Boot-Host-*.preset)
TFILES += $(wildcard LocalMachine-PostInstall-Host-*.preset)
TFILES += $(wildcard CurrentUser-Logon-Host-*.preset)
TFILES += $(wildcard Custom-VarOverload-Host-*.psm1)
TFILES += $(wildcard Custom-VarAutodel-Host-*.psm1)
TFILES += $(wildcard Local-Addon-Host-*.psm1)
TFILES += $(call GROUP_TO_HOST_TFILES,LocalMachine-Boot,preset)
TFILES += $(call GROUP_TO_HOST_TFILES,LocalMachine-PostInstall,preset)
TFILES += $(call GROUP_TO_HOST_TFILES,CurrentUser-Logon,preset)
TFILES += $(call GROUP_TO_HOST_TFILES,Custom-VarOverload,psm1)
TFILES += $(call GROUP_TO_HOST_TFILES,Custom-VarAutodel,psm1)
TFILES += $(call GROUP_TO_HOST_TFILES,Local-Addon,psm1)

TFILES+=install.bat
TFILES+=uninstall.bat
TFILES+=installer.ps1

IT_Team:=IT Team
PUBLISHER:=CNRS France, RESINFO, Local Network Area

sinclude extend-variables.mk

BUILD_FLAG := tmp/buildhost-end.flag

FILESTOINSTALL:=$(FILES) $(addprefix tmp/,$(filter-out installer.ps1, $(TFILES)))
ALLINSTALLFILES:=$(shell echo '$(addsuffix ", $(addprefix ", $(FILES) $(TFILES)))' | sed 's/[[:space:]]/, /g;')
TFILES+=SWMB-Setup-$(SWMB_VERSION).exe

TMPFILES:=$(addprefix tmp/,$(TFILES))

.PHONY: help all clean ocs check-exe version

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all: check-exe $(BUILD_FLAG) $(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64.zip ## Create .zip archive package

$(BUILD_FLAG): $(RESET_FLAG) make-group2host Makefile
	@mkdir -p tmp
	@rm -f tmp/*.preset tmp/*.psm1
	@./make-group2host
	@touch $@

version: ## Print software version
	@echo "Soft     $(SOFT)"
	@echo "Name     $(SWLN_NAME)"
	@echo "Version  $(SWLN_VERSION)"
	@echo "Revision $(REVISION)"
	@echo "SWMB     $(SWMB_VERSION)"
	@echo "Files    $(FILES)"
	@echo "TFiles   $(TFILES)"
	@echo "AllFiles $(FILESTOINSTALL)"

clean: ## Clean zip archive, temporary and old files
	@rm -rf tmp $(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64.zip resources
	@find . -name '*.bak' -o -name '*.old' -delete

tmp/install.bat: install.bat Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#;' $< > $@

tmp/installer.ps1: installer.ps1 Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe $(FILESTOINSTALL)
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#; s#__ALLINSTALLFILES__#$(ALLINSTALLFILES)#;' $< > $@

tmp/uninstall.bat: uninstall.bat Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#;' $< > $@

tmp/SWMB-Setup-%.exe: $(wildcard SWMB-Setup-%.exe) Makefile extend-variables.mk
	@mkdir -p tmp
	@hostfile=$$(basename "$@") ; \
	if [ -f "$${hostfile}" ] ; then \
		echo "Use your local SWMB Setup" ; \
		cp -f "$${hostfile}" "$@" ; \
	else \
		(cd tmp ; \
		rm -f SWMB-Setup-*.exe ; \
		echo "Download SWMB Setup from RESINFO SWMB Git Pages" ; \
		curl -# --remote-name --insecure "https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/SWMB-Setup-$(SWMB_VERSION).exe" ; \
		) ; \
	fi

check-exe: tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@(cd tmp ; \
		file "SWMB-Setup-$(SWMB_VERSION).exe" | grep -q "PE32 executable" || { echo "Error: bad format for binary SWMB-Setup-$(SWMB_VERSION).exe" 1>&2 ; exit 1; } ; \
		which peres >/dev/null && { peres -a "SWMB-Setup-$(SWMB_VERSION).exe" | grep -q "^Product Version:[[:space:]]*$(SWMB_VERSION)" || { echo "Error: bad version for binary SWMB-Setup-$(SWMB_VERSION).exe" 1>&2 ; exit 1; } ; } ; \
		)

$(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64.zip: Makefile extend-variables.mk $(BUILD_FLAG) $(FILES) $(TMPFILES)
	@rm -f $@
	@zip --quiet -r $@ $(FILES) -x @zipignore.txt
	@(cd tmp ; zip --quiet -r ../$@ $(TFILES) -x @../zipignore.txt)
	@chmod ug+rw,o+r $@
	@du -sh $@
	@echo $$(($$(unzip -t "$@" | wc -l) - 1)) 'files and folders in Zip package'


ocs: all
	@echo ""
	@echo "Name:     $(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64"
	@echo "priority: *2*"
	@echo "Launch:   install.bat"
	@echo "Message:  yes"
	@echo "Delay:    5"
	@echo "Report:   yes"
	@echo "Sha1sum:  $$(shasum -a 1 tmp/SWMB-Setup-$(SWMB_VERSION).exe | cut -f 1 -d ' ') - $$(date '+%Y/%m/%d %H:%M') SWMB-Setup-$(SWMB_VERSION).exe"
	@echo ""
	@echo "$(IT_Team)"
	@echo " --- "
	@echo "Install and Update: $(SOFT) v$(SWLN_VERSION) (SWMB v$(SWMB_VERSION))"
	@echo ""

sinclude extend-rules.mk
