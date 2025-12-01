# Makefile for SWLN (SWMB project)
# Warnning: Do not change variables and rules in this file!
# Change them in extend-variables.mk and extend-rules.mk include makefiles

SOFT:=SWLN
SWLN_NAME:=SWLN
SWMB_VERSION:=$(shell curl --silent --location --insecure 'https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/version.txt')
SWLN_VERSION:=5.20.$(shell echo $(SWMB_VERSION) | sed -e 's/\./ /g;' | xargs -r printf "%i%02i%02i%03i")
REVISION:=1

LOG_DIR:=%SystemRoot%\\Logs\\Deploy

FILES:=logo-swmb.ico
FILES+=$(shell ls -1 CurrentUser-Logon.preset        CurrentUser-Logon-Host-*.preset        2> /dev/null)
FILES+=$(shell ls -1 LocalMachine-Boot.preset        LocalMachine-Boot-Host-*.preset        2> /dev/null)
FILES+=$(shell ls -1 LocalMachine-PostInstall.preset LocalMachine-PostInstall-Host-*.preset 2> /dev/null)
FILES+=$(shell ls -1 Custom-VarOverload.psm1         Custom-VarOverload-Host-*.psm1         2> /dev/null)
FILES+=$(shell ls -1 Local-Addon.psm1                Local-Addon-Host-*.psm1                2> /dev/null)
FILES+=pre-install-01copy.bat
FILES+=post-install-01reg.bat

TFILES:=install.bat
TFILES+=uninstall.bat
TFILES+=installer.ps1

IT_Team:=IT Team
PUBLISHER:=CNRS France, RESINFO, Local Network Area

sinclude extend-variables.mk

ALLINSTALLFILES:=$(shell echo '$(addsuffix ", $(addprefix ", $(FILES) $(TFILES)))' | sed 's/[[:space:]]/, /g;')
TFILES+=SWMB-Setup-$(SWMB_VERSION).exe

TMPFILES:=$(addprefix tmp/,$(TFILES))

.PHONY: all clean ocs check-exe version

all: check-exe $(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64.zip

version:
	@echo "Soft     $(SOFT)"
	@echo "Name     $(SWLN_NAME)"
	@echo "Version  $(SWLN_VERSION)"
	@echo "Revision $(REVISION)"
	@echo "SWMB     $(SWMB_VERSION)"
	@echo "Files    $(FILES)"
	@echo "TFiles   $(TFILES)"

clean:
	@rm -rf tmp $(SOFT)_$(SWLN_VERSION)-$(REVISION)_x64.zip resources
	@find . -name '*.bak' -delete

tmp/install.bat: install.bat Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#;' $< > $@

tmp/installer.ps1: installer.ps1 Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#; s#__ALLINSTALLFILES__#$(ALLINSTALLFILES)#;' $< > $@

tmp/uninstall.bat: uninstall.bat Makefile extend-variables.mk tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@mkdir -p tmp
	@sed -e 's/__SWLN_NAME__/$(SWLN_NAME)/; s#__PUBLISHER__#$(PUBLISHER)#; s/__SWLN_VERSION__/$(SWLN_VERSION)/; s/__REVISION__/$(REVISION)/; s/__SWMB_VERSION__/$(SWMB_VERSION)/; s#__LOG_DIR__#$(LOG_DIR)#;' $< > $@

tmp/SWMB-Setup-%.exe: Makefile extend-variables.mk
	@mkdir -p tmp
	@(cd tmp ; \
		curl -# --remote-name --insecure "https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/SWMB-Setup-$(SWMB_VERSION).exe" ; \
		)

check-exe: tmp/SWMB-Setup-$(SWMB_VERSION).exe
	@(cd tmp ; \
		file "SWMB-Setup-$(SWMB_VERSION).exe" | grep -q "PE32 executable" || { echo "Error: bad format for binary SWMB-Setup-$(SWMB_VERSION).exe" 1>&2 ; exit 1; } ; \
		which peres >/dev/null && { peres -a "SWMB-Setup-$(SWMB_VERSION).exe" | grep -q "^Product Version:[[:space:]]*$(SWMB_VERSION)" || { echo "Error: bad version for binary SWMB-Setup-$(SWMB_VERSION).exe" 1>&2 ; exit 1; } ; } ; \
		)

%.zip: Makefile extend-variables.mk $(FILES) $(TMPFILES)
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
