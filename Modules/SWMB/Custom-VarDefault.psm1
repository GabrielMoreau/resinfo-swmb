################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
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
# $Global:SWMB_Custom.LocalAdminNameEffective = 'mysysadmin'

$Global:SWMB_Custom = @{
	# AdminAccountLogin
	# Use by tweak: SetAdminAccountLogin, UnsetAdminAccountLogin
	LocalAdminNameEffective = "sas-swmb"
	LocalAdminNameOriginal  = "administrateur"

	# SessionLockTimeout
	# Use by tweak: EnableSessionLockTimeout, DisableSessionLockTimeout
	InactivityTimeoutSecs  = 900 # max 900 seconds

	# SecurityParamAccountPolicy
	# Use by tweak: SetSecurityParamAccountPolicy, EnablePasswordPolicy
	PasswordHistorySize    = 2
	MinimumPasswordAge     = 1
	MaximumPasswordAge     = -1
	MinimumPasswordLength  = 14
	PasswordComplexity     = 1
	LockoutBadCount        = 5
	ResetLockoutCount      = 30
	LockoutDuration        = 30
	EnableGuestAccount     = 0

	# NTP
	# Use by tweak: SetNTPConfig
	NTP_ManualPeerList     = "0.pool.ntp.org, 1.pool.ntp.org, 2.pool.ntp.org, 3.pool.ntp.org"

	# Target Release
	# Use by tweak: SetTargetRelease
	Windows10 = @{
		ProductVersion           = "Windows 10"
		TargetReleaseVersionInfo = "22H2"
	}
	Windows11 = @{
		ProductVersion           = "Windows 11"
		TargetReleaseVersionInfo = "23H2"
	}

	# Kaspersky Endpoint Security and Network Agent
	# Use by tweak: UninstallKasperskyEndpoint
	KesLogin     = "KLAdmin"
	KesPassword  = ""
	KesAgentPass = ""
	KesKeyFile   = ""

	# Workgroup Name
	# Use by tweak: SetWorkgroupName
	WorkgroupName          = "WORKGROUP"

	# RemoteDesktop Port
	# Use by tweak: SetRemoteDesktopPort
	RemoteDesktop_PortNumber = 1234

	# Interface Metric
	# Use by tweak: SetInterfaceMetricOn1Gbps, SetInterfaceMetricOn10Gbps
	InterfaceMetricOn1Gbps  = 40
	InterfaceMetricOn10Gbps = 50

	# Storage Sense
	# Use by tweak: StorageSense, StorageSenseTrashCleanup
	# Global cadence in days - Every day = 1 - Every week = 7 - Every month = 30 - During low free disk space = 0
	StorageSenseCadence      =  30 # every month
	StorageSenseTrashCleanup = 120 # delete files in recycle bin that are more than 120 days

	# AutoLogon
	# Use by tweak : EnableAutoLogon
	# Inactive if empty
	AutoLogon_UserName = ""

	# Dell Builtin Apps
	# Use by tweak : UninstallDellBuiltInApps
	DellAppx = @(
		"DellInc.DellSupportAssistforPCs"
		"DellInc.DellOptimizer"
		#"DellInc.DellCommandUpdate"
		"MSWP.DellTypeCStatus"
		"DellInc.DellDigitalDelivery"
		"PortraitDisplays.DellPremierColor"
	)

	# Dell Software (not Appx)
	# Use by tweak : UninstallDellSoftware
	# Get-package |  Where-Object {  $_.Name -match "Dell"  } | Select Name
	DellPackage = @(
		"Dell Display Manager 2.1"
		"Dell Display Manager 2.2"
		"Dell Peripheral Manager"
		"Dell Trusted Device Agent"
		"Dell Core Services"
		"Dell Optimizer Core"
		"Dell Optimizer Service"
		"Dell Optimizer"
		"DellOptimizerUI"
		"Dell SupportAssist"
		"Dell SupportAssist Remediation"
		"Dell SupportAssist OS Recovery Plugin for Dell Update"
		"Dell Digital Delivery"
		"Dell Digital Delivery Services"
		"Dell Power Manager Service"
		#"Dell Command | Update for Windows Universal"
		#"Intel(R) Connectivity Performance Suite for Dell"
		#"Dell Touchpad"
	)

}
