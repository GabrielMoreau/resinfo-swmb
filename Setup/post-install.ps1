################################################################
# Win 10 / Server 2016 / Server 2019 SWMB Script - Main execution loop
# Project CNRS RESINFO SWMB
# Copyright (c) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2021, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2017 - Disassembler <disassembler@dasm.cz>
#  2021 - Gabriel Moreau (CNRS / LEGI)
# Version: v3.12, 2021-07-10
################################################################

# This script must be run as an administrator with privileges.
# It copies all SWMB files to the local computer's application installation
# folder and creates a scheduled task that runs the script when the
# computer starts.

# Installation Folder
$InstallFolder = (Join-Path -Path $Env:ProgramFiles -ChildPath "SWMB")
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
}

# Create ProgramData Folders
$DataFolder  = (Join-Path -Path $Env:ProgramData -ChildPath "SWMB")
$DataPresets = (Join-Path -Path $DataFolder      -ChildPath "Presets")
$DataModules = (Join-Path -Path $DataFolder      -ChildPath "Modules")
$DataLogs    = (Join-Path -Path $DataFolder      -ChildPath "Logs")
$DataCaches  = (Join-Path -Path $DataFolder      -ChildPath "Caches")

If (Test-Path -LiteralPath $Env:ProgramData) {
	If (!(Test-Path -LiteralPath $DataFolder)) {
		New-Item -Path $DataFolder -ItemType Directory
	}

	If (!(Test-Path -LiteralPath $DataPresets)) {
		New-Item -Path $DataPresets -ItemType Directory
	}

	If (!(Test-Path -LiteralPath $DataModules)) {
		New-Item -Path $DataModules -ItemType Directory
	}

	If (!(Test-Path -LiteralPath $DataLogs)) {
		New-Item -Path $DataLogs -ItemType Directory
	}
	# ACL on Logs for Users (Read / Write)
	icacls.exe $DataLogs --% /Grant:r "*S-1-5-32-545:(OI)(CI)(GR,GW,DE,RD)" /T
	icacls.exe $DataLogs /InheritanceLevel:e

	If (!(Test-Path -LiteralPath $DataCaches)) {
		New-Item -Path $DataCaches -ItemType Directory
	}
}

# Create Boot Task
If (Test-Path -LiteralPath "$InstallFolder\Tasks\LocalMachine-Boot.ps1") {
	$BootTrigger = New-ScheduledTaskTrigger -AtStartup
	$User        = "NT AUTHORITY\SYSTEM"
	$BootTask    = 'SWMB-LocalMachine-Boot'
	$BootAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
		-Argument "-File `"$InstallFolder\Tasks\LocalMachine-Boot.ps1`"" `
		-WorkingDirectory "$InstallFolder"
	Unregister-ScheduledTask -TaskName $BootTask -Confirm:$false -ErrorAction SilentlyContinue
	Register-ScheduledTask -Force -TaskName $BootTask -Trigger $BootTrigger -User $User -Action $BootAction `
		-RunLevel Highest -Description "SWMB tweaks action at boot"
	$BootObject = Get-ScheduledTask $BootTask
	$BootObject.Author = "CNRS RESINFO / GT SWMB"
	$BootObject | Set-ScheduledTask
}

# Create Logon Task for All Users
If (Test-Path -LiteralPath "$InstallFolder\Tasks\CurrentUser-Logon.ps1") {
	$LogonTrigger = New-ScheduledTaskTrigger -AtLogon
	$LogonTask    = 'SWMB-CurrentUser-Logon'
	$LogonAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
		-Argument "-NoProfile -WindowStyle Hidden -File `"$InstallFolder\Tasks\CurrentUser-Logon.ps1`"" `
		-WorkingDirectory "$InstallFolder"
	$STPrin = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Highest
	Unregister-ScheduledTask -TaskName $LogonTask -Confirm:$false -ErrorAction SilentlyContinue
	Register-ScheduledTask -Force -TaskName $LogonTask -Trigger $LogonTrigger -Action $LogonAction `
		-Principal $STPrin -Description "SWMB tweaks action at user logon"
	$LogonObject = Get-ScheduledTask $LogonTask
	$LogonObject.Author = "CNRS RESINFO / GT SWMB"
	$LogonObject | Set-ScheduledTask
}

# Copy recommanded preset
Function _UpdatePresetFile {
	Param (
		[Parameter(Mandatory = $true)] [string]$New,
		[Parameter(Mandatory = $true)] [string]$Actual
	)

	If (Test-Path -LiteralPath "$New") {
		If (Test-Path -LiteralPath "$Actual") {
			$MagicString = (Select-String -Path "$Actual" -Pattern "file automatically updated").Line
			If (-not ([string]::IsNullOrEmpty($MagicString))) {
				Copy-Item -Path "$New" -Destination "$Actual" -Force
				}
		} Else {
			Copy-Item -Path "$New" -Destination "$Actual" -Force
		}
	}
}

$ActivatedPreset = 1
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$ActivatedPreset = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "ActivatedPreset").ActivatedPreset
}
If ($ActivatedPreset -eq 1) {
	_UpdatePresetFile -New "$InstallFolder\Presets\LocalMachine-Boot-Recommanded.preset" -Actual "$DataPresets\LocalMachine-Boot.preset"
	_UpdatePresetFile -New "$InstallFolder\Presets\CurrentUser-Logon-Recommanded.preset" -Actual "$DataPresets\CurrentUser-Logon.preset"
}

# Bitlocker Script in Start Menu
#$StartMenu = "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\SWMB"
#If (!(Test-Path -LiteralPath $StartMenu)) {
#	New-Item -Path $StartMenu -ItemType Directory
#}
#If ((Test-Path -LiteralPath $StartMenu) -And (Test-Path -LiteralPath "$InstallFolder\Tasks\LocalMachine-Crypt-With-Bitlocker.ps1")) {
#	If (Test-Path -LiteralPath "$StartMenu\SWMB-Crypt-With-Bitlocker.lnk") {
#		Remove-Item "$StartMenu\SWMB-Crypt-With-Bitlocker.lnk" -Force -ErrorAction SilentlyContinue
#	}
#	$WshShell = New-Object -ComObject WScript.Shell
#	$Shortcut = $WshShell.CreateShortcut("$StartMenu\SWMB-Crypt-With-Bitlocker.lnk")
#	$Shortcut.TargetPath = "powershell.exe"
#	$ShortCut.Arguments = "-ExecutionPolicy Bypass -File `"$InstallFolder\Tasks\LocalMachine-Crypt-With-Bitlocker.ps1`""
#	$ShortCut.WorkingDirectory = "$InstallFolder";
#	$ShortCut.WindowStyle = 1;
#	$ShortCut.IconLocation = "$InstallFolder\logo-swmb.ico";
#	$ShortCut.Description = "SWMB - Crypt disk with Bitlocker";
#	$Shortcut.Save()
#}

# Create EventLog for our Source
If ([System.Diagnostics.EventLog]::SourceExists("SWMB") -eq $False) {
	New-EventLog -LogName "Application" -Source "SWMB"
}

# Unblock Powershell Script
#If (Test-Path $InstallFolder) {
#	Get-ChildItem -Path "$InstallFolder" -Recurse | Unblock-File
#}
