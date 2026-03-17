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
$InstallFolder = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
	$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
}

# Create ProgramData Folders
$DataFolder  = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$DataPresets = (Join-Path -Path $DataFolder      -ChildPath "Presets")
$DataModules = (Join-Path -Path $DataFolder      -ChildPath "Modules")
$DataLogs    = (Join-Path -Path $DataFolder      -ChildPath "Logs")
$DataCaches  = (Join-Path -Path $DataFolder      -ChildPath "Caches")

If (Test-Path -LiteralPath ${Env:ProgramData}) {
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
	$BootSetting = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 90)
	$BootUser    = "NT AUTHORITY\SYSTEM"
	$BootTask    = 'SWMB-LocalMachine-Boot'
	$BootAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
		-Argument "-File `"$InstallFolder\Tasks\LocalMachine-Boot.ps1`"" `
		-WorkingDirectory "$InstallFolder"
	Unregister-ScheduledTask -TaskName $BootTask -Confirm:$False -ErrorAction SilentlyContinue
	Register-ScheduledTask -Force -TaskName $BootTask -Trigger $BootTrigger -User $BootUser -Action $BootAction `
		-RunLevel Highest -Description "SWMB tweaks action at boot" -Settings $BootSetting
	$BootObject = Get-ScheduledTask $BootTask
	$BootObject.Author = "CNRS RESINFO / GT SWMB"
	$BootObject | Set-ScheduledTask
}

# Create Weekly Task
#If (Test-Path -LiteralPath "$InstallFolder\Tasks\LocalMachine-Boot.ps1") {
#	$Days = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")
#	$RandDay = (Get-Random -InputObject $Days -Count 1)
#	$Hours = @("8am", "9am", "10am", "11am", "12am", "1pm", "2pm", "3pm")
#	$RandHour = (Get-Random -InputObject $Hours -Count 1)
#	#$WeeklyTrigger = New-ScheduledTaskTrigger -Weekly -At 11am -RandomDelay (New-TimeSpan -Day 6)
#	$WeeklyTrigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek $RandDay -At $RandHour -RandomDelay (New-TimeSpan -Hour 24)
#	$WeeklySetting = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2)
#	$User          = "NT AUTHORITY\SYSTEM"
#	$WeeklyTask    = 'SWMB-LocalMachine-Weekly'
#	$WeeklyAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
#		-Argument "-File `"$InstallFolder\Tasks\LocalMachine-Boot.ps1`"" `
#		-WorkingDirectory "$InstallFolder"
#	Unregister-ScheduledTask -TaskName $WeeklyTask -Confirm:$False -ErrorAction SilentlyContinue
#	Register-ScheduledTask -Force -TaskName $WeeklyTask -Trigger $WeeklyTrigger -User $User -Action $WeeklyAction `
#		-RunLevel Highest -Description "SWMB weekly tweaks action" -Settings $WeeklySetting
#	$WeeklyObject = Get-ScheduledTask $WeeklyTask
#	$WeeklyObject.Author = "CNRS RESINFO / GT SWMB"
#	$WeeklyObject | Set-ScheduledTask
#}

# Create Logon Task for All Users
If (Test-Path -LiteralPath "$InstallFolder\Tasks\CurrentUser-Logon.ps1") {
	$LogonTrigger = New-ScheduledTaskTrigger -AtLogon
	$LogonSetting = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 20)
	$LogonTask    = 'SWMB-CurrentUser-Logon'
	$LogonAction  = New-ScheduledTaskAction -Execute "powershell.exe" `
		-Argument "-NoProfile -WindowStyle Hidden -File `"$InstallFolder\Tasks\CurrentUser-Logon.ps1`"" `
		-WorkingDirectory "$InstallFolder"
	$LogonPrincipal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Highest
	Unregister-ScheduledTask -TaskName $LogonTask -Confirm:$False -ErrorAction SilentlyContinue
	Register-ScheduledTask -Force -TaskName $LogonTask -Trigger $LogonTrigger -Action $LogonAction `
		-Principal $LogonPrincipal -Description "SWMB tweaks action at user logon" -Settings $LogonSetting
	$LogonObject = Get-ScheduledTask $LogonTask
	$LogonObject.Author = "CNRS RESINFO / GT SWMB"
	$LogonObject | Set-ScheduledTask
}

# Copy recommanded preset
Function _UpdatePresetFile {
	Param (
		[Parameter(Mandatory = $True)] [string]$New,
		[Parameter(Mandatory = $True)] [string]$Actual
	)

	If (Test-Path -LiteralPath "$New") {
		If (Test-Path -LiteralPath "$Actual") {
			$MagicString = (Select-String -Path "$Actual" -Pattern "file automatically updated").Line
			If (!([string]::IsNullOrEmpty($MagicString))) {
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
#$StartMenu = "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\SWMB"
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

# Create PostInstall Task
If (Test-Path -LiteralPath "$InstallFolder\Tasks\LocalMachine-PostInstall.ps1") {
	$PostInstallUser    = "NT AUTHORITY\SYSTEM"
	$PostInstallTask    = 'SWMB-LocalMachine-PostInstall'
	$PostInstallTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(10)
	$PostInstallTrigger.EndBoundary = (Get-Date).AddSeconds(60).ToString('s')
	$PostInstallSetting = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter 00:00:01 -ExecutionTimeLimit (New-TimeSpan -Minutes 120)
	$PostInstallAction = New-ScheduledTaskAction -Execute "powershell.exe" `
		-Argument "-NoProfile -WindowStyle Hidden -File `"$InstallFolder\Tasks\LocalMachine-PostInstall.ps1`"" `
		-WorkingDirectory "$InstallFolder"
	Register-ScheduledTask -Force -TaskName $PostInstallTask -Trigger $PostInstallTrigger -User $PostInstallUser -Action $PostInstallAction `
		-Description "SWMB tweaks action PostInstall" -Settings $PostInstallSetting
	$PostInstallObject = Get-ScheduledTask $PostInstallTask
	$PostInstallObject.Author = "CNRS RESINFO / GT SWMB"
	$PostInstallObject | Set-ScheduledTask
}

# Create EventLog for our Source
If ([System.Diagnostics.EventLog]::SourceExists("SWMB") -eq $False) {
	New-EventLog -LogName "Application" -Source "SWMB"
}

# Unblock Powershell Script
#If (Test-Path $InstallFolder) {
#	Get-ChildItem -Path "$InstallFolder" -Recurse | Unblock-File
#}
