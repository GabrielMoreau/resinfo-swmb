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

# Relaunch the script with administrator privileges
Function TweakSysRequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
		Exit
	}
}
TweakSysRequireAdmin

# Define Boot preset on ProgramData
$DataFolder  = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$BootLog     = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Logs" -ChildPath "LocalMachine-LastBoot.log"))

Import-Module -Name "$PSScriptRoot\Modules\SWMB.psd1" -ErrorAction Stop
Import-Module -Name "$PSScriptRoot\Modules\WiSeMoUI.psm1" -ErrorAction Stop

$Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$day = 'day'
If ($Uptime.Days -gt 1) { $day = 'days' }
$hour = 'hour'
If ($Uptime.Hours -gt 1) { $hour = 'hours' }

If ($Uptime.Days -ne 0) {
	$UptimeStr = "$($Uptime.Days) $day, $($Uptime.Hours) $hour"
} ElseIf ($Uptime.Hours -ne 0) {
	$UptimeStr = "$($Uptime.Hours) $hour, $($Uptime.Minutes) min"
} Else {
	$UptimeStr = "$($Uptime.Minutes) min"
}

# Main Windows
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$Form = New-Object System.Windows.Forms.Form
$Form.ClientSize = '550,390'
$Form.Text = "SWMB: Secure Windows Mode Batch / $UptimeStr"

# Logo
$Logo = New-Object System.Windows.Forms.PictureBox
$Logo.Location = New-Object Drawing.Point(320,30)
$Logo.Size = New-Object System.Drawing.Size(200,201)
$Logo.image = [system.drawing.image]::FromFile("$PSScriptRoot\logo-swmb.ico")
$Form.Controls.Add($Logo)

################################################################
# Bitlocker Frame

# Bitlocker Status
$BitlockerStatus  = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
$BtnBitlockerStatus = New-Object System.Windows.Forms.label
$BtnBitlockerStatus.Location = New-Object System.Drawing.Size(30,25)
$BtnBitlockerStatus.Width = 220
$BtnBitlockerStatus.Height = 20
$BtnBitlockerStatus.BackColor = "Transparent"
$BtnBitlockerStatus.Text = "Status: $BitlockerStatus"
$Form.Controls.Add($BtnBitlockerStatus)

# Bitlocker Crypt
$BtnCrypt = New-Object System.Windows.Forms.Button
$BtnCrypt.Location = New-Object System.Drawing.Point(30,50)
$BtnCrypt.Width = 110
$BtnCrypt.Height = 60
$BtnCrypt.Text = "Crypt all Disks`nwith Bitlocker"
$Form.controls.Add($BtnCrypt)
$BtnCrypt.Add_Click({
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-Crypt-With-Bitlocker.ps1`"" -WindowStyle Normal
})

# Bitlocker Action
$BitlockerAction  = "Suspend"
If ($BitlockerStatus -cmatch "Suspend") {
	$BitlockerAction  = "Resume"
}
$BtnBitlockerAction = New-Object System.Windows.Forms.Button
$BtnBitlockerAction.Location = New-Object System.Drawing.Point(170,50)
$BtnBitlockerAction.Width = 80
$BtnBitlockerAction.Height = 60
$BtnBitlockerAction.BackColor = "Transparent"
$BtnBitlockerAction.Text = "$BitlockerAction"
$Form.Controls.Add($BtnBitlockerAction)
$BtnBitlockerAction.Add_Click({
	If ($BitlockerAction -eq "Suspend") {
		Get-BitLockerVolume | Suspend-BitLocker -RebootCount 0
		$BitlockerAction = "Halt"
		$BitlockerStatus = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
		$BtnBitlockerAction.Text = "Please Halt for your Maintenance"
		$BtnBitlockerStatus.Text = "Status: $BitlockerStatus"
	} ElseIf ($BitlockerAction -eq "Halt") {
		Stop-Computer -ComputerName localhost
	} Else {
		Get-BitLockerVolume | Resume-BitLocker
		$BitlockerStatus = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
		If ($BitlockerStatus -cmatch "Running") {
			$BitlockerAction  = "Suspend"
			$BtnBitlockerAction.Text = "$BitlockerAction"
			$BtnBitlockerStatus.Text = "Status: $BitlockerStatus"
		}
	}
})

# Bitlocker Frame
$BtnBitlockerFrame = New-Object System.Windows.Forms.GroupBox
$BtnBitlockerFrame.Location = New-Object System.Drawing.Size(20,10)
$BtnBitlockerFrame.Width = 250
$BtnBitlockerFrame.Height = 110
#$BtnBitlockerFrame.BackColor = "Transparent"
$BtnBitlockerFrame.Text = "Bitlocker"
$Form.Controls.Add($BtnBitlockerFrame)

################################################################
# Task Frame

# Boot Task
$BtnTaskBootStatus = New-Object System.Windows.Forms.label
$BtnTaskBootStatus.Location = New-Object System.Drawing.Size(40,212)
$BtnTaskBootStatus.Width = 50
$BtnTaskBootStatus.Height = 15
$BtnTaskBootStatus.BackColor = "Transparent"
$BtnTaskBootStatus.Text = ""
$Form.Controls.Add($BtnTaskBootStatus)

$BtnTaskBoot = New-Object System.Windows.Forms.Button
$BtnTaskBoot.Location = New-Object System.Drawing.Point(30,150)
$BtnTaskBoot.Width = 60
$BtnTaskBoot.Height = 60
$BtnTaskBoot.Text = "Boot"
$Form.controls.Add($BtnTaskBoot)
$BtnTaskBoot.Add_Click({
	$BtnTaskBootStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-Boot.ps1`"" -WindowStyle Hidden -Wait
	Start-Process notepad.exe "`"$BootLog`""
	$BtnTaskBootStatus.Text = "Finish!"
})

# Post-Install Task
$BtnTaskPostInstallStatus = New-Object System.Windows.Forms.label
$BtnTaskPostInstallStatus.Location = New-Object System.Drawing.Size(120,212)
$BtnTaskPostInstallStatus.Width = 50
$BtnTaskPostInstallStatus.Height = 15
$BtnTaskPostInstallStatus.BackColor = "Transparent"
$BtnTaskPostInstallStatus.Text = ""
$Form.Controls.Add($BtnTaskPostInstallStatus)

$BtnTaskPostInstall = New-Object System.Windows.Forms.Button
$BtnTaskPostInstall.Location = New-Object System.Drawing.Point(110,150)
$BtnTaskPostInstall.Width = 60
$BtnTaskPostInstall.Height = 60
$BtnTaskPostInstall.Text = "Post Install"
$Form.controls.Add($BtnTaskPostInstall)
$BtnTaskPostInstall.Add_Click({
	$BtnTaskPostInstallStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-PostInstall.ps1`"" -WindowStyle Hidden -Wait
	Start-Process notepad.exe "`"$BootLog`""
	$BtnTaskPostInstallStatus.Text = "Finish!"
})

# Logon Task
$BtnTaskLogonStatus = New-Object System.Windows.Forms.label
$BtnTaskLogonStatus.Location = New-Object System.Drawing.Size(200,212)
$BtnTaskLogonStatus.Width = 50
$BtnTaskLogonStatus.Height = 15
$BtnTaskLogonStatus.BackColor = "Transparent"
$BtnTaskLogonStatus.Text = ""
$Form.Controls.Add($BtnTaskLogonStatus)

$BtnTaskLogon = New-Object System.Windows.Forms.Button
$BtnTaskLogon.Location = New-Object System.Drawing.Point(190,150)
$BtnTaskLogon.Width = 60
$BtnTaskLogon.Height = 60
$BtnTaskLogon.Text = "Logon"
$Form.controls.Add($BtnTaskLogon)
$BtnTaskLogon.Add_Click({
	$BtnTaskLogonStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-PostInstall.ps1`"" -WindowStyle Hidden -Wait
	Start-Process notepad.exe "`"$BootLog`""
	$BtnTaskLogonStatus.Text = "Finish!"
})

# Task Frame
$BtnTaskFrame = New-Object System.Windows.Forms.GroupBox
$BtnTaskFrame.Location = New-Object System.Drawing.Size(20,130)
$BtnTaskFrame.Width = 250
$BtnTaskFrame.Height = 100
#$BtnTaskFrame.BackColor = "Transparent"
$BtnTaskFrame.Text = "Run Scheduled Task Now"
$Form.Controls.Add($BtnTaskFrame)

################################################################

# Version
$RunningVersion  = (SWMB_GetRunningVersion)
$PublishedVersion = (SWMB_GetLastPublishedVersion)
$BtnVersion = New-Object System.Windows.Forms.label
$BtnVersion.Location = New-Object System.Drawing.Size(30,270)
$BtnVersion.Width = 110
$BtnVersion.Height = 40
$BtnVersion.BackColor = "Transparent"
$BtnVersion.Text = "Version: $RunningVersion"
$Form.Controls.Add($BtnVersion)

If ($RunningVersion -ne $PublishedVersion) {
	$BtnUpdate = New-Object System.Windows.Forms.Button
	$BtnUpdate.Location = New-Object System.Drawing.Point(140,255)
	$BtnUpdate.Width = 110
	$BtnUpdate.Height = 50
	$BtnUpdate.BackColor = "PaleGreen"
	$BtnUpdate.Text = "New release available`n$PublishedVersion"
	$Form.controls.Add($BtnUpdate)

	$BtnUpdate.Add_Click({
	    $HomeUrl = (SWMB_GetHomeURL)
		Start-Process "$HomeUrl"
	})
}

# Hostname
$HostId = (SWMB_GetHostId)
$BtnHost = New-Object System.Windows.Forms.label
$BtnHost.Location = New-Object System.Drawing.Size(30,310)
$BtnHost.Width = 230
$BtnHost.Height = 40
$BtnHost.BackColor = "Transparent"
$BtnHost.Text = "Host: $Env:ComputerName`n`nId: $HostId"
$Form.Controls.Add($BtnHost)

# OS Version
$OSVersion = SWMB_GetOSVersionReadable
$OSColor = SWMB_GetOSVersionColor
$BtnOSVersion = New-Object System.Windows.Forms.label
$BtnOSVersion.Location = New-Object System.Drawing.Size(30,350)
$BtnOSVersion.Width = 230
$BtnOSVersion.Height = 15
$BtnOSVersion.ForeColor = "$OSColor"
$BtnOSVersion.Text = "OS: $OSVersion"
$Form.Controls.Add($BtnOSVersion)

# Host features Frame
$BtnVersionFrame = New-Object System.Windows.Forms.GroupBox
$BtnVersionFrame.Location = New-Object System.Drawing.Size(20,240)
$BtnVersionFrame.Width = 250
$BtnVersionFrame.Height = 135
$BtnVersionFrame.Text = "Host features"
$Form.Controls.Add($BtnVersionFrame)

################################################################

# Software
$BtnSoftware = New-Object System.Windows.Forms.Button
$BtnSoftware.Location = New-Object System.Drawing.Point(300,255)
$BtnSoftware.Width = 80
$BtnSoftware.Height = 50
$BtnSoftware.Text = "View All Software"
$Form.controls.Add($BtnSoftware)
$BtnSoftware.Add_Click({
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\View-All-Software.ps1`"" -WindowStyle Hidden
})

################################################################

# Exit
$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Location = New-Object System.Drawing.Point(400,255)
$BtnExit.Width = 80
$BtnExit.Height = 50
$BtnExit.Text = "Exit"
$BtnExit.Add_Click({
	$Form.Close()
})
# https://learn.microsoft.com/fr-fr/dotnet/api/system.windows.media.colors
$BtnExit.BackColor = 'PaleVioletRed'
$Form.controls.Add($BtnExit)

# Main Loop
$Form.ShowDialog()
