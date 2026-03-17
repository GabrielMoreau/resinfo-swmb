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

Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 0 `
	-Message "SWMB: Run Crypt-With-Bitlocker Script for LocalMachine ${Env:ComputerName} - Begin"

# Relaunch the script with administrator privileges
Function TweakSysRequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
		Exit
	}
}
TweakSysRequireAdmin

# Change Path to the root Installation Folder
$InstallFolder = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
}
Set-Location $InstallFolder

# Main SWMB Module
Import-Module .\Modules\SWMB.psd1

# Initialize
SWMB_Init

# Load one tweak (can be called multiple times)
# Unloads the tweak if it starts with the exclamation mark (!)
SWMB_AddOrRemoveTweak "EnableBitlocker"

# Execute all loaded tweaks (presets)
SWMB_RunTweaks


Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 999 `
	-Message "SWMB: Run Crypt-With-Bitlocker Script for LocalMachine ${Env:ComputerName} - End"
