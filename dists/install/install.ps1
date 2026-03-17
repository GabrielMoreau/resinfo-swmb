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
# It copies all SWMB files to the local computer's application installation
# folder and creates a scheduled task that runs the script when the
# computer starts.


# Installation Folder
$InstallFolder  = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
If (!(Test-Path -LiteralPath $InstallFolder)) {
	New-Item -Path $InstallFolder -ItemType Directory
}

$ScriptPath = (Get-Item (Get-PSCallStack)[0].ScriptName).DirectoryName
$MainPath = (Resolve-Path (Join-Path -Path $ScriptPath -ChildPath (Join-Path -Path ".." -ChildPath "..")) -ErrorAction SilentlyContinue)

If (Test-Path $MainPath) {
	Write-Output "Begin installation of SWMB..."
	Copy-Item -Path "$MainPath\*" -Destination "$InstallFolder" -Recurse -Force
	Get-ChildItem -Path "$InstallFolder" -Recurse | Unblock-File
}

# Create ProgramData Folders
$DataFolder  = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$DataPresets = (Join-Path -Path $DataFolder      -ChildPath "Presets")

If (Test-Path -LiteralPath ${Env:ProgramData}) {
	If (!(Test-Path -LiteralPath $DataFolder)) {
		New-Item -Path $DataFolder -ItemType Directory
	}

	If (!(Test-Path -LiteralPath $DataPresets)) {
		New-Item -Path $DataPresets -ItemType Directory
	}
}

# Create Boot Task
$Trigger = New-ScheduledTaskTrigger -AtStartup
$User    = "NT AUTHORITY\SYSTEM"
$BootTask   = 'SWMB-LocalMachine-Boot'
$BootAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command &{$InstallFolder\Tasks\LocalMachine-Boot.ps1}"
Unregister-ScheduledTask -TaskName $BootTask -Confirm:$False -ErrorAction SilentlyContinue
Register-ScheduledTask -Force -TaskName $BootTask -Trigger $Trigger -User $User -Action $BootAction -RunLevel Highest
