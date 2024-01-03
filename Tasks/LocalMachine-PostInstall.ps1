################################################################
# Win 10 / Server 2016 / Server 2019 SWMB Script - Main execution loop
# Project CNRS RESINFO SWMB
# Copyright (c) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2024, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2017 - Disassembler <disassembler@dasm.cz>
#  2021 - Gabriel Moreau (CNRS / LEGI)
#  2021 - Olivier de Marchi (Grenoble INP / LEGI)
# Version: v3.13, 2021-11-22
################################################################

Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 0 `
	-Message "SWMB: Run PostInstall Script for LocalMachine ${Env:ComputerName} - Begin"

# Change Path to the root Installation Folder
$InstallFolder = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
}
Set-Location $InstallFolder

# Define SWMB folder on ProgramData
$DataFolder   = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$PresetFolder = (Join-Path -Path $DataFolder -ChildPath "Presets")
$ModuleFolder = (Join-Path -Path $DataFolder -ChildPath "Modules")
$LogFolder    = (Join-Path -Path $DataFolder -ChildPath "Logs")
$CacheFolder  = (Join-Path -Path $DataFolder -ChildPath "Caches")

# Host extension and Build args
$HostExt="Host-$(${Env:ComputerName}.ToLower())"
$Args = @()
$FlagPreset = $False

# Log action
$Args += '-log', "$LogFolder\LocalMachine-PostInstall.log"

# Site and Host Modules
If (Test-Path -LiteralPath "$ModuleFolder\Local-Addon.psm1") {
	$Args += '-import', "$ModuleFolder\Local-Addon.psm1"
}
If (Test-Path -LiteralPath "$ModuleFolder\LocalMachine-PostInstall.psm1") {
	$Args += '-import', "$ModuleFolder\LocalMachine-PostInstall.psm1"
}
If (Test-Path -LiteralPath "$ModuleFolder\Local-Addon-$HostExt.psm1") {
	$Args += '-import', "$ModuleFolder\Local-Addon-$HostExt.psm1"
}

# Site and Host presets
If (Test-Path -LiteralPath "$PresetFolder\LocalMachine-PostInstall.preset") {
	$Args += '-preset', "$PresetFolder\LocalMachine-PostInstall.preset"
	$FlagPreset = $True
}
If (Test-Path -LiteralPath "$PresetFolder\LocalMachine-PostInstall-$HostExt.preset") {
	$Args += '-preset', "$PresetFolder\LocalMachine-PostInstall-$HostExt.preset"
	$FlagPreset = $True
}

# Hash checkpoint
$Args += '-hash', "$CacheFolder\LocalMachine-LastBoot.hash"

# Launch SWMB with this preset
If ($FlagPreset) {
	.\swmb.ps1 @Args
} Else {
	Write-Output "Error: No preset define, No SWMB launch"
}

Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 999 `
	-Message "SWMB: Run PostInstall Script for LocalMachine ${Env:ComputerName} - End"
