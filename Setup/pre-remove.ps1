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
# Version: v3.13, 2021-11-22
################################################################

# This script must be run as an administrator with privileges.

# Destroy Boot Task
$BootTask = 'SWMB-LocalMachine-Boot'
Unregister-ScheduledTask -TaskName $BootTask -Confirm:$False -ErrorAction SilentlyContinue

# Destroy Logon script for All Users
$LogonTask = 'SWMB-CurrentUser-Logon'
Unregister-ScheduledTask -TaskName $LogonTask -Confirm:$False -ErrorAction SilentlyContinue


# Destroy ProgramData Folders and Recommanded Preset
$DataFolder  = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$DataPresets = (Join-Path -Path $DataFolder     -ChildPath "Presets")

Function _RemovePresetFile {
	Param (
		[Parameter(Mandatory = $True)] [string]$Path
	)

	If (Test-Path -LiteralPath "$Path") {
		$MagicString = (Select-String -Path "$Path" -Pattern "file automatically updated").Line
		If (!([string]::IsNullOrEmpty($MagicString))) {
			Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
		}
	}
}

# Remove data default recommanded preset if not modified
_RemovePresetFile -Path "$DataPresets\LocalMachine-Boot.preset"
_RemovePresetFile -Path "$DataPresets\CurrentUser-Logon.preset"

# Remove data folders
If (Test-Path -LiteralPath $DataPresets) {
	If ((Get-ChildItem $DataPresets).Count -eq 0) {
		Remove-Item -Path $DataPresets -Force -ErrorAction SilentlyContinue
	}
}

If (Test-Path -LiteralPath $DataFolder) {
	If ((Get-ChildItem $DataFolder).Count -eq 0) {
		Remove-Item -Path $DataFolder -Force -ErrorAction SilentlyContinue
	}
}
