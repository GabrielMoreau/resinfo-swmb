################################################################
# Win 10 / Server 2016 / Server 2019 SWMB Script - Main execution loop
# Project CNRS RESINFO SWMB
# Copyright (c) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2021, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb
# Authors:
#  2017 - Disassembler <disassembler@dasm.cz>
#  2021 - Gabriel Moreau (CNRS / LEGI)
# Version: v3.12, 2021-07-10
################################################################


# Installation Folder
$InstallFolder  = (Join-Path -Path $Env:ProgramFile -ChildPath "SWMB")
If (!(Test-Path -LiteralPath $SWMBFolder)) {
	New-Item -Path $SWMBFolder -ItemType Directory
}

$ScriptPath = (Get-Item (Get-PSCallStack)[0].ScriptName).DirectoryName
$MainPath = (Resolve-Path (Join-Path -Path $ScriptPath -ChildPath (Join-Path -Path ".." -ChildPath "..")) -ErrorAction SilentlyContinue)

If (Test-Path $MainPath) {
	Write-Host "Begin installation of SWMB..."
	Copy-Item -Path "$MainPath\*" -Destination "$InstallFolder" -Recurse -Force
	Get-ChildItem -Path "$InstallFolder" -Recurse | Unblock-File
}

# Create ProgramData Folders
$DataFolder  = (Join-Path -Path $Env:ProgramData -ChildPath "SWMB")
$DataPresets = (Join-Path -Path $DataFolder      -ChildPath "Presets")

If (Test-Path -LiteralPath $Env:ProgramData) {
	If (!(Test-Path -LiteralPath $DataFolder)) {
		New-Item -Path $DataFolder -ItemType Directory
	}

	If (!(Test-Path -LiteralPath $DataPresets)) {
		New-Item -Path $DataPresets -ItemType Directory
	}
}

# Create Boot Task
$trigger = New-ScheduledTaskTrigger -AtStartup
$user    = "NT AUTHORITY\SYSTEM"
$key_obj = (Get-BitLockerVolume -MountPoint $letter).KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'} | Select-Object -Property RecoveryPassword
$key     = $key_obj.RecoveryPassword
$task    = 'swmb-localmachine-boot'
$action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command &{$InstallFolder\Scripts\LocalMachine-Boot.ps1}"
Unregister-ScheduledTask $task -Confirm:$false -ErrorAction SilentlyContinue
Register-ScheduledTask -Force -TaskName $task -Trigger $trigger -User $user -Action $action -RunLevel Highest
