################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2026, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

@{
RootModule = 'SWMB.psm1'
NestedModules = @(
	'.\SWMB\Custom.psm1',
	'.\SWMB\CurrentUser-Application.psm1',
	'.\SWMB\CurrentUser-ExplorerUI.psm1',
	'.\SWMB\CurrentUser-Privacy.psm1',
	'.\SWMB\CurrentUser-Service.psm1',
	'.\SWMB\CurrentUser-UI.psm1',
	'.\SWMB\CurrentUser-Uninstall.psm1',
	'.\SWMB\CurrentUser-Unpinning.psm1',
	'.\SWMB\CurrentUser-UWPPrivacy.psm1',
	'.\SWMB\LocalMachine-Application.psm1',
	'.\SWMB\LocalMachine-ExplorerUI.psm1',
	'.\SWMB\LocalMachine-Network.psm1',
	'.\SWMB\LocalMachine-Privacy.psm1',
	'.\SWMB\LocalMachine-Security.psm1',
	'.\SWMB\LocalMachine-Server.psm1',
	'.\SWMB\LocalMachine-Service.psm1',
	'.\SWMB\LocalMachine-UI.psm1',
	'.\SWMB\LocalMachine-Uninstall.psm1',
	'.\SWMB\LocalMachine-UWPPrivacy.psm1',
	'.\SWMB\TemporaryBypass.psm1'
	)
ModuleVersion = '__VERSION__'
GUID = 'ba50acca-ccda-456b-8349-6ff2569dc229'
Author = 'RESINFO / GT SWMB'
CompanyName = 'CNRS'
Copyright = '(C) 2020-2023, CNRS, France'
Description = "
Secure Windows Mode Batch

Source for this module is at IN2P3 GitLab.  Please submit any issues there.
https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
"
}
