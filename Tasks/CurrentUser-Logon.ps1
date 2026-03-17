################################################################
# Win 10 / Server 2016 / Server 2019 SWMB Script - Main execution loop
# Project CNRS RESINFO SWMB
# Copyright (C) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2026, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2017 - Disassembler <disassembler@dasm.cz>
#  2021 - Gabriel Moreau (CNRS / LEGI)
#  2021 - Olivier de Marchi (Grenoble INP / LEGI)
# Version: v3.13, 2021-11-22
################################################################

Param (
	# Running Mode: Batch, Print or Check
	[string]$Mode = 'Batch'
)

If ($Mode -eq 'Batch') {
	Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 0 `
		-Message "SWMB: Run Logon Script for User ${Env:UserName} - Begin"
}

# Change Path to the root Installation Folder
$BeforeLocation = Get-Location
$InstallFolder = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
}
If (Test-Path -LiteralPath $InstallFolder) {
	Set-Location $InstallFolder
}

# Define SWMB folder on ProgramData
$DataFolder   = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$PresetFolder = (Join-Path -Path $DataFolder -ChildPath "Presets")
$ModuleFolder = (Join-Path -Path $DataFolder -ChildPath "Modules")
$LogFolder    = (Join-Path -Path $DataFolder -ChildPath "Logs")

# Host extension and Build args
$HostExt="Host-$(${Env:ComputerName}.ToLower())"
$Args = @()
$FlagPreset = $False

# Check mode
If ($Mode -eq 'Batch') {
	# Log action
	$Args += '-log', "$LogFolder\CurrentUser-LastLogon.log"
} ElseIf ($Mode -eq 'Print') {
	$Args += '-print'
} ElseIf ($Mode -eq 'Check') {
	$Args += '-check'
}

# Site and Host Modules
If (Test-Path -LiteralPath "$ModuleFolder\Local-Addon.psm1") {
	$Args += '-import', "$ModuleFolder\Local-Addon.psm1"
}
If (Test-Path -LiteralPath "$ModuleFolder\CurrentUser-Logon.psm1") {
	$Args += '-import', "$ModuleFolder\CurrentUser-Logon.psm1"
}
If (Test-Path -LiteralPath "$ModuleFolder\Local-Addon-$HostExt.psm1") {
	$Args += '-import', "$ModuleFolder\Local-Addon-$HostExt.psm1"
}

# Site and Host presets
If (Test-Path -LiteralPath "$PresetFolder\CurrentUser-Logon.preset") {
	$Args += '-preset', "$PresetFolder\CurrentUser-Logon.preset"
	$FlagPreset = $True
}
If (Test-Path -LiteralPath "$PresetFolder\CurrentUser-Logon-$HostExt.preset") {
	$Args += '-preset', "$PresetFolder\CurrentUser-Logon-$HostExt.preset"
	$FlagPreset = $True
}

# Launch SWMB with this preset
If ($FlagPreset) {
	.\swmb.ps1 @Args
} Else {
	Write-Output "Error: No preset define, No SWMB launch"
}

# Come back to the previous Path
If (Test-Path -LiteralPath $BeforeLocation) {
	Set-Location $BeforeLocation
}

If ($Mode -eq 'Batch') {
	Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 999 `
		-Message "SWMB: Run Logon Script for User ${Env:UserName} - End"
}
