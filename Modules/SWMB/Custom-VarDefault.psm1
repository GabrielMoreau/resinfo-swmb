################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2021, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

# Variables utilisées dans le module Custom.psm1
# Ne modifier pas directement ce fichier !
# Vous pouvez surcharger ces variables en les redéfinissant dans un fichier Custom-VarOverload.psm1
# Exemple :
# $Global:SWMB_Custom.LocalAdminNameToSet = 'mysysadmin'

$Global:SWMB_Custom = @{
	# AdminAccountLogin
	LocalAdminNameToSet    = "sas-swmb"
	LocalAdminNameOriginal = "administrateur"

	# SessionLockTimeout
	InactivityTimeoutSecs  = 1200

	# SecurityParamAccountPolicy
	MinimumPasswordAge     = 1
	MaximumPasswordAge     = -1
	MinimumPasswordLength  = 12
	PasswordComplexity     = 1
	PasswordHistorySize    = 2
	LockoutBadCount        = 5
	ResetLockoutCount      = 30
	LockoutDuration        = 30
	EnableGuestAccount     = 0
}