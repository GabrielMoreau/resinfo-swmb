################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2021 - Gabriel Moreau (CNRS / LEGI)
#  2021 - Olivier de Marchi (Grenoble INP / LEGI)
# Version: v3.13, 2021-11-22
################################################################

# List of Color https://learn.microsoft.com/en-us/dotnet/api/system.windows.media.brushes?view=windowsdesktop-9.0

# Relaunch the script with administrator privileges
Function TweakSysRequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
		Exit
	}
}
TweakSysRequireAdmin

# Define Boot preset on ProgramData
$DataFolder     = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
$BootLog        = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Logs" -ChildPath "LocalMachine-LastBoot.log"))
$PostInstallLog = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Logs" -ChildPath "LocalMachine-PostInstall.log"))
$LogonLog       = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Logs" -ChildPath "CurrentUser-LastLogon.log"))

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

# Default editor
# $Editor = ((Get-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\txtfile\shell\open\command').'(Default)').trimend(" %1")
$Editor = "${Env:SystemRoot}\System32\notepad.exe"
If (Test-Path -LiteralPath "${Env:ProgramFiles}\Notepad++\notepad++.exe") {
	$Editor = "${Env:ProgramFiles}\Notepad++\notepad++.exe"
}

# Main Windows
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$Form = New-Object System.Windows.Forms.Form
$Form.ClientSize = '550,390'
$Form.Text = "SWMB: Secure Windows Mode Batch / $UptimeStr"

# Help
$BtnHelp = New-Object System.Windows.Forms.Button
$BtnHelp.Location = New-Object System.Drawing.Point(300,15)
$BtnHelp.Width = 50
$BtnHelp.Height = 30
$BtnHelp.Text = "Help"
$Form.controls.Add($BtnHelp)
$BtnHelp.Add_Click({
	Start-Process 'https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/docs/'
})

# Logo
$Logo = New-Object System.Windows.Forms.PictureBox
$Logo.Location = New-Object Drawing.Point(320,30)
$Logo.Size = New-Object System.Drawing.Size(200,201)
$Logo.image = [system.drawing.image]::FromFile("$PSScriptRoot\logo-swmb.ico")
$Form.Controls.Add($Logo)
$Logo.Add_Click({
	Start-Process 'https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/'
})

# General ToolTip
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.AutoPopDelay = 5000
$ToolTip.InitialDelay = 500
$ToolTip.ReshowDelay = 500
$ToolTip.ShowAlways = true

################################################################
# Bitlocker Frame

# Bitlocker Status
$BitlockerStatus, $BitlockerColor = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
$BtnBitlockerStatus = New-Object System.Windows.Forms.Label
$BtnBitlockerStatus.Location = New-Object System.Drawing.Size(30,25)
$BtnBitlockerStatus.Width = 220
$BtnBitlockerStatus.Height = 20
$BtnBitlockerStatus.BackColor = "Transparent"
$BtnBitlockerStatus.ForeColor = "$BitlockerColor"
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

# TPM Console
$BtnConsoleTPM = New-Object System.Windows.Forms.Button
$BtnConsoleTPM.Location = New-Object System.Drawing.Point(140,50)
$BtnConsoleTPM.Width = 15
$BtnConsoleTPM.Height = 20
$BtnConsoleTPM.Text = "T"
$Form.controls.Add($BtnConsoleTPM)
$BtnConsoleTPM.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\tpm.msc"
})
$ToolTip.SetToolTip($BtnConsoleTPM, "TPM Console")

# Bitlocker Console
$BtnConsoleBitlocker = New-Object System.Windows.Forms.Button
$BtnConsoleBitlocker.Location = New-Object System.Drawing.Point(140,70)
$BtnConsoleBitlocker.Width = 15
$BtnConsoleBitlocker.Height = 20
$BtnConsoleBitlocker.Text = "B"
$Form.controls.Add($BtnConsoleBitlocker)
$BtnConsoleBitlocker.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\control.exe" -ArgumentList "/name Microsoft.BitLockerDriveEncryption"
})
$ToolTip.SetToolTip($BtnConsoleBitlocker, "Bitlocker Console")

# Bitlocker Action
$BitlockerAction = "Suspend"
If ($BitlockerStatus -cmatch "Suspend") {
	$BitlockerAction = "Resume"
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
		$BitlockerStatus, $BitlockerColor = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
		$BtnBitlockerAction.Text = "Please Halt for your Maintenance"
		$BtnBitlockerStatus.ForeColor = "$BitlockerColor"
		$BtnBitlockerStatus.Text = "Status: $BitlockerStatus"
	} ElseIf ($BitlockerAction -eq "Halt") {
		Stop-Computer -ComputerName localhost
	} Else {
		Get-BitLockerVolume | Resume-BitLocker
		$BitlockerStatus, $BitlockerColor = SWMB_GetBitLockerStatus -Drive ${Env:SystemDrive}
		If ($BitlockerStatus -cmatch "Running") {
			$BitlockerAction = "Suspend"
			$BtnBitlockerAction.Text = "$BitlockerAction"
			$BtnBitlockerStatus.ForeColor = "$BitlockerColor"
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
$BtnTaskBootStatus = New-Object System.Windows.Forms.Label
$BtnTaskBootStatus.Location = New-Object System.Drawing.Size(40,212)
$BtnTaskBootStatus.Width = 50
$BtnTaskBootStatus.Height = 15
$BtnTaskBootStatus.BackColor = "Transparent"
$BtnTaskBootStatus.Text = ""
$Form.Controls.Add($BtnTaskBootStatus)

$BtnTaskBootLabel = New-Object System.Windows.Forms.Label
$BtnTaskBootLabel.Location = New-Object System.Drawing.Point(40,160)
$BtnTaskBootLabel.Width = 50
$BtnTaskBootLabel.Height = 30
$BtnTaskBootLabel.Text = "LM`nBoot"
$BtnTaskBootLabel.BackColor = 'Moccasin'
$Form.controls.Add($BtnTaskBootLabel)

$BtnTaskBootRun = New-Object System.Windows.Forms.Button
$BtnTaskBootRun.Location = New-Object System.Drawing.Point(30,190)
$BtnTaskBootRun.Width = 44
$BtnTaskBootRun.Height = 20
$BtnTaskBootRun.Text = "Run"
$Form.controls.Add($BtnTaskBootRun)
$BtnTaskBootRun.Add_Click({
	$BtnTaskBootStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-Boot.ps1`"" -WindowStyle Hidden -Wait
	Start-Process -FilePath $Editor -ArgumentList "`"$BootLog`""
	$BtnTaskBootStatus.Text = "Finish!"
})

$BtnTaskBootCheck = New-Object System.Windows.Forms.Button
$BtnTaskBootCheck.Location = New-Object System.Drawing.Point(74,190)
$BtnTaskBootCheck.Width = 15
$BtnTaskBootCheck.Height = 20
$BtnTaskBootCheck.Text = "C"
$Form.controls.Add($BtnTaskBootCheck)
$BtnTaskBootCheck.Add_Click({
#	$BtnTaskBootStatus.Text = "Check..."
#	$Message = @(& $PSScriptRoot\Tasks\LocalMachine-Boot.ps1 -Mode Check)
#	$TempWindow = New-Object System.Windows.Forms.Form -Property @{TopMost = $True}
#	$TextBox                      = New-Object System.Windows.Forms.TextBox
#	$TextBox.Multiline            = $true
#	$TextBox.Text                 = $Message -join "`r`n"
#	$TextBox.Font                 = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Regular)
#	$TextBox.Size                 = New-Object System.Drawing.Size(400,400)
#	$TextBox.Location             = New-Object System.Drawing.Point(20,70)
#	$TextBox.Scrollbars          = "Vertical"
#	$TextBox.BackColor            = "#1F1F1F"
#	$TextBox.ForeColor            = 'Cyan'
#	$TempWindow.Controls.Add($TextBox)
#	$TempWindow.ShowDialog() # | Out-String
	& $PSScriptRoot\Tasks\LocalMachine-Boot.ps1 -Mode Check `
		| Out-GridView -Title "SWMB: Check Boot sequence tweaks on the ${Env:ComputerName} computer - $(Get-Date)"
})

$BtnTaskBootPrint = New-Object System.Windows.Forms.Button
$BtnTaskBootPrint.Location = New-Object System.Drawing.Point(89,150)
$BtnTaskBootPrint.Width = 15
$BtnTaskBootPrint.Height = 20
$BtnTaskBootPrint.Text = "P"
$Form.controls.Add($BtnTaskBootPrint)
$BtnTaskBootPrint.Add_Click({
	& $PSScriptRoot\Tasks\LocalMachine-Boot.ps1 -Mode Print `
		| ForEach-Object -Begin {$CountTweak = 0} -Process {
			$CountTweak++
			$_ | Select-Object -Property @{Name="Num"; Expression={$CountTweak}}, @{Label="Tweak"; Expression={$_}}
			} `
		| Out-GridView -Title "SWMB: Tweaks that will apply to the next Boot sequence on the ${Env:ComputerName} computer - $(Get-Date)"
})
$BtnTaskBootLog = New-Object System.Windows.Forms.Button
$BtnTaskBootLog.Location = New-Object System.Drawing.Point(89,170)
$BtnTaskBootLog.Width = 15
$BtnTaskBootLog.Height = 20
$BtnTaskBootLog.Text = "L"
$Form.controls.Add($BtnTaskBootLog)
$BtnTaskBootLog.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$BootLog`""
})
$BtnTaskBootEdit = New-Object System.Windows.Forms.Button
$BtnTaskBootEdit.Location = New-Object System.Drawing.Point(89,190)
$BtnTaskBootEdit.Width = 15
$BtnTaskBootEdit.Height = 20
$BtnTaskBootEdit.Text = "E"
$Form.controls.Add($BtnTaskBootEdit)
$BtnTaskBootEdit.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$DataFolder\Presets\LocalMachine-Boot.preset`""
})
If (Test-Path -LiteralPath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe") {
	$BtnTaskBootMerge = New-Object System.Windows.Forms.Button
	$BtnTaskBootMerge.Location = New-Object System.Drawing.Point(89,210)
	$BtnTaskBootMerge.Width = 15
	$BtnTaskBootMerge.Height = 20
	$BtnTaskBootMerge.Text = "M"
	$Form.controls.Add($BtnTaskBootMerge)
	$BtnTaskBootMerge.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe" -ArgumentList "/maximize /fr /ignoreeol `"${Env:ProgramFiles}\SWMB\Presets\LocalMachine-All.preset`" `"$DataFolder\Presets\LocalMachine-Boot.preset`""
	})
	$ToolTip.SetToolTip($BtnTaskBootMerge, "Diff and Merge LocalMachine Boot Task Preset File")
}

$BtnTaskBootFrame = New-Object System.Windows.Forms.GroupBox
$BtnTaskBootFrame.Location = New-Object System.Drawing.Size(30,145)
$BtnTaskBootFrame.Width = 60
$BtnTaskBootFrame.Height = 47
$BtnTaskBootFrame.Text = ""
$BtnTaskBootFrame.BackColor = 'Moccasin'
$Form.Controls.Add($BtnTaskBootFrame)

$ToolTip.SetToolTip($BtnTaskBootCheck, "Check LocalMachine Boot Tweaks")
$ToolTip.SetToolTip($BtnTaskBootRun,   "Run LocalMachine Boot Task Now")
$ToolTip.SetToolTip($BtnTaskBootPrint, "Print LocalMachine Boot Tweaks List")
$ToolTip.SetToolTip($BtnTaskBootLog,   "Show LocalMachine Last Boot Task Run")
$ToolTip.SetToolTip($BtnTaskBootEdit,  "Edit LocalMachine Boot Task Preset File")


# Post-Install Task
$BtnTaskPostInstallStatus = New-Object System.Windows.Forms.Label
$BtnTaskPostInstallStatus.Location = New-Object System.Drawing.Size(120,212)
$BtnTaskPostInstallStatus.Width = 50
$BtnTaskPostInstallStatus.Height = 15
$BtnTaskPostInstallStatus.BackColor = "Transparent"
$BtnTaskPostInstallStatus.Text = ""
$Form.Controls.Add($BtnTaskPostInstallStatus)

$BtnTaskPostInstallLabel = New-Object System.Windows.Forms.Label
$BtnTaskPostInstallLabel.Location = New-Object System.Drawing.Point(120,160)
$BtnTaskPostInstallLabel.Width = 50
$BtnTaskPostInstallLabel.Height = 30
$BtnTaskPostInstallLabel.Text = "LM Post`nInstall"
$BtnTaskPostInstallLabel.BackColor = 'Moccasin'
$Form.controls.Add($BtnTaskPostInstallLabel)

$BtnTaskPostInstallRun = New-Object System.Windows.Forms.Button
$BtnTaskPostInstallRun.Location = New-Object System.Drawing.Point(110,190)
$BtnTaskPostInstallRun.Width = 44
$BtnTaskPostInstallRun.Height = 20
$BtnTaskPostInstallRun.Text = "Run"
$Form.controls.Add($BtnTaskPostInstallRun)
$BtnTaskPostInstallRun.Add_Click({
	$BtnTaskPostInstallStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\LocalMachine-PostInstall.ps1`"" -WindowStyle Hidden -Wait
	Start-Process -FilePath $Editor -ArgumentList "`"$PostInstallLog`""
	$BtnTaskPostInstallStatus.Text = "Finish!"
})

$BtnTaskPostInstallCheck = New-Object System.Windows.Forms.Button
$BtnTaskPostInstallCheck.Location = New-Object System.Drawing.Point(154,190)
$BtnTaskPostInstallCheck.Width = 15
$BtnTaskPostInstallCheck.Height = 20
$BtnTaskPostInstallCheck.Text = "C"
$Form.controls.Add($BtnTaskPostInstallCheck)
$BtnTaskPostInstallCheck.Add_Click({
	& $PSScriptRoot\Tasks\LocalMachine-PostInstall.ps1 -Mode Check `
		| Out-GridView -Title "SWMB: Check PostInstall sequence tweaks on the ${Env:ComputerName} computer - $(Get-Date)"
})

$BtnTaskPostInstallPrint = New-Object System.Windows.Forms.Button
$BtnTaskPostInstallPrint.Location = New-Object System.Drawing.Point(169,150)
$BtnTaskPostInstallPrint.Width = 15
$BtnTaskPostInstallPrint.Height = 20
$BtnTaskPostInstallPrint.Text = "P"
$Form.controls.Add($BtnTaskPostInstallPrint)
$BtnTaskPostInstallPrint.Add_Click({
	& $PSScriptRoot\Tasks\LocalMachine-PostInstall.ps1 -Mode Print `
		| ForEach-Object -Begin {$CountTweak = 0} -Process {
			$CountTweak++
			$_ | Select-Object -Property @{Name="Num"; Expression={$CountTweak}}, @{Label="Tweak"; Expression={$_}}
			} `
		| Out-GridView -Title "SWMB: Tweaks that will apply to the next Post-Install sequence on the ${Env:ComputerName} computer - $(Get-Date)"
})
$BtnTaskPostInstallLog = New-Object System.Windows.Forms.Button
$BtnTaskPostInstallLog.Location = New-Object System.Drawing.Point(169,170)
$BtnTaskPostInstallLog.Width = 15
$BtnTaskPostInstallLog.Height = 20
$BtnTaskPostInstallLog.Text = "L"
$Form.controls.Add($BtnTaskPostInstallLog)
$BtnTaskPostInstallLog.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$PostInstallLog`""
})
$BtnTaskPostInstallEdit = New-Object System.Windows.Forms.Button
$BtnTaskPostInstallEdit.Location = New-Object System.Drawing.Point(169,190)
$BtnTaskPostInstallEdit.Width = 15
$BtnTaskPostInstallEdit.Height = 20
$BtnTaskPostInstallEdit.Text = "E"
$Form.controls.Add($BtnTaskPostInstallEdit)
$BtnTaskPostInstallEdit.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$DataFolder\Presets\LocalMachine-PostInstall.preset`""
})
If (Test-Path -LiteralPath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe") {
	$BtnTaskPostInstallMerge = New-Object System.Windows.Forms.Button
	$BtnTaskPostInstallMerge.Location = New-Object System.Drawing.Point(169,210)
	$BtnTaskPostInstallMerge.Width = 15
	$BtnTaskPostInstallMerge.Height = 20
	$BtnTaskPostInstallMerge.Text = "M"
	$Form.controls.Add($BtnTaskPostInstallMerge)
	$BtnTaskPostInstallMerge.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe" -ArgumentList "/maximize /fr /ignoreeol `"${Env:ProgramFiles}\SWMB\Presets\LocalMachine-All.preset`" `"$DataFolder\Presets\LocalMachine-PostInstall.preset`""
	})
	$ToolTip.SetToolTip($BtnTaskPostInstallMerge, "Diff and Merge LocalMachine PostInstall Task Preset File")
}

$BtnTaskPostInstallFrame = New-Object System.Windows.Forms.GroupBox
$BtnTaskPostInstallFrame.Location = New-Object System.Drawing.Size(110,145)
$BtnTaskPostInstallFrame.Width = 60
$BtnTaskPostInstallFrame.Height = 47
$BtnTaskPostInstallFrame.Text = ""
$BtnTaskPostInstallFrame.BackColor = 'Moccasin'
$Form.Controls.Add($BtnTaskPostInstallFrame)

$ToolTip.SetToolTip($BtnTaskPostInstallCheck, "Check LocalMachine Post-Install Tweaks")
$ToolTip.SetToolTip($BtnTaskPostInstallRun,   "Run LocalMachine Post-Install Task Now")
$ToolTip.SetToolTip($BtnTaskPostInstallPrint, "Print LocalMachine Post-Install Tweaks List")
$ToolTip.SetToolTip($BtnTaskPostInstallLog,   "Show Last LocalMachine Post-Install Task Run")
$ToolTip.SetToolTip($BtnTaskPostInstallEdit,  "Edit LocalMachine Post-Install Task Preset File")


# Logon Task
$BtnTaskLogonStatus = New-Object System.Windows.Forms.Label
$BtnTaskLogonStatus.Location = New-Object System.Drawing.Size(200,212)
$BtnTaskLogonStatus.Width = 50
$BtnTaskLogonStatus.Height = 15
$BtnTaskLogonStatus.BackColor = "Transparent"
$BtnTaskLogonStatus.Text = ""
$Form.Controls.Add($BtnTaskLogonStatus)

$BtnTaskLogonLabel = New-Object System.Windows.Forms.Label
$BtnTaskLogonLabel.Location = New-Object System.Drawing.Point(200,160)
$BtnTaskLogonLabel.Width = 50
$BtnTaskLogonLabel.Height = 30
$BtnTaskLogonLabel.Text = "CU`nLogon"
$BtnTaskLogonLabel.BackColor = 'Moccasin'
$Form.controls.Add($BtnTaskLogonLabel)

$BtnTaskLogonRun = New-Object System.Windows.Forms.Button
$BtnTaskLogonRun.Location = New-Object System.Drawing.Point(190,190)
$BtnTaskLogonRun.Width = 44
$BtnTaskLogonRun.Height = 20
$BtnTaskLogonRun.Text = "Run"
$Form.controls.Add($BtnTaskLogonRun)
$BtnTaskLogonRun.Add_Click({
	$BtnTaskLogonStatus.Text = "Start..."
	If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
		& eventvwr.exe /c:Application
	}
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\Tasks\CurrentUser-Logon.ps1`"" -WindowStyle Hidden -Wait
	Start-Process -FilePath $Editor -ArgumentList "`"$LogonLog`""
	$BtnTaskLogonStatus.Text = "Finish!"
})

$BtnTaskLogonCheck = New-Object System.Windows.Forms.Button
$BtnTaskLogonCheck.Location = New-Object System.Drawing.Point(234,190)
$BtnTaskLogonCheck.Width = 15
$BtnTaskLogonCheck.Height = 20
$BtnTaskLogonCheck.Text = "C"
$Form.controls.Add($BtnTaskLogonCheck)
$BtnTaskLogonCheck.Add_Click({
	& $PSScriptRoot\Tasks\CurrentUser-Logon.ps1 -Mode Check `
		| Out-GridView -Title "SWMB: Check CurrentUser Logon sequence tweaks on the ${Env:ComputerName} computer - $(Get-Date)"
})

$BtnTaskLogonPrint = New-Object System.Windows.Forms.Button
$BtnTaskLogonPrint.Location = New-Object System.Drawing.Point(249,150)
$BtnTaskLogonPrint.Width = 15
$BtnTaskLogonPrint.Height = 20
$BtnTaskLogonPrint.Text = "P"
$Form.controls.Add($BtnTaskLogonPrint)
$BtnTaskLogonPrint.Add_Click({
	& $PSScriptRoot\Tasks\CurrentUser-Logon.ps1 -Mode Print `
		| ForEach-Object -Begin {$CountTweak = 0} -Process {
			$CountTweak++
			$_ | Select-Object -Property @{Name="Num"; Expression={$CountTweak}}, @{Label="Tweak"; Expression={$_}}
			} `
		| Out-GridView -Title "SWMB: Tweaks that will apply to the next Logon sequence for CurrentUser ${Env:UserName} - $(Get-Date)"
})
$BtnTaskLogonLog = New-Object System.Windows.Forms.Button
$BtnTaskLogonLog.Location = New-Object System.Drawing.Point(249,170)
$BtnTaskLogonLog.Width = 15
$BtnTaskLogonLog.Height = 20
$BtnTaskLogonLog.Text = "L"
$Form.controls.Add($BtnTaskLogonLog)
$BtnTaskLogonLog.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$LogonLog`""
})
$BtnTaskLogonEdit = New-Object System.Windows.Forms.Button
$BtnTaskLogonEdit.Location = New-Object System.Drawing.Point(249,190)
$BtnTaskLogonEdit.Width = 15
$BtnTaskLogonEdit.Height = 20
$BtnTaskLogonEdit.Text = "E"
$Form.controls.Add($BtnTaskLogonEdit)
$BtnTaskLogonEdit.Add_Click({
	Start-Process -FilePath $Editor -ArgumentList "`"$DataFolder\Presets\CurrentUser-Logon.preset`""
})
If (Test-Path -LiteralPath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe") {
	$BtnTaskLogonMerge = New-Object System.Windows.Forms.Button
	$BtnTaskLogonMerge.Location = New-Object System.Drawing.Point(249,210)
	$BtnTaskLogonMerge.Width = 15
	$BtnTaskLogonMerge.Height = 20
	$BtnTaskLogonMerge.Text = "M"
	$Form.controls.Add($BtnTaskLogonMerge)
	$BtnTaskLogonMerge.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\WinMerge\WinMergeU.exe" -ArgumentList "/maximize /fr /ignoreeol `"${Env:ProgramFiles}\SWMB\Presets\CurrentUser-All.preset`" `"$DataFolder\Presets\CurrentUser-Logon.preset`""
	})
	$ToolTip.SetToolTip($BtnTaskLogonMerge, "Diff and Merge CurrentUser Logon Task Preset File")
}

$BtnTaskLogonFrame = New-Object System.Windows.Forms.GroupBox
$BtnTaskLogonFrame.Location = New-Object System.Drawing.Size(190,145)
$BtnTaskLogonFrame.Width = 60
$BtnTaskLogonFrame.Height = 47
$BtnTaskLogonFrame.Text = ""
$BtnTaskLogonFrame.BackColor = 'Moccasin'
$Form.Controls.Add($BtnTaskLogonFrame)

$ToolTip.SetToolTip($BtnTaskLogonCheck, "Check CurrentUser Logon Tweaks")
$ToolTip.SetToolTip($BtnTaskLogonRun,   "Run CurrentUser Logon Task Now")
$ToolTip.SetToolTip($BtnTaskLogonPrint, "Print CurrentUser Logon Tweaks List")
$ToolTip.SetToolTip($BtnTaskLogonLog,   "Show Last CurrentUser Logon Task Run")
$ToolTip.SetToolTip($BtnTaskLogonEdit,  "Edit CurrentUser Logon Task Preset File")


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
$RunningVersion = (SWMB_GetRunningVersion)
$PublishedVersion = (SWMB_GetLastPublishedVersion)
$BtnVersion = New-Object System.Windows.Forms.Label
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

# System Property
$BtnSystemProperty = New-Object System.Windows.Forms.Button
$BtnSystemProperty.Location = New-Object System.Drawing.Point(210,310)
$BtnSystemProperty.Width = 55
$BtnSystemProperty.Height = 20
$BtnSystemProperty.Text = "Property"
$Form.controls.Add($BtnSystemProperty)
$BtnSystemProperty.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\control.exe" -ArgumentList "sysdm.cpl"
})
$ToolTip.SetToolTip($BtnSystemProperty, "System Property")

# Hostname
$HostId = (SWMB_GetHostId)
$BtnHost = New-Object System.Windows.Forms.Label
$BtnHost.Location = New-Object System.Drawing.Size(30,310)
$BtnHost.Width = 230
$BtnHost.Height = 40
$BtnHost.BackColor = "Transparent"
$BtnHost.Text = "Host: $Env:ComputerName`n`nId: $HostId"
$Form.Controls.Add($BtnHost)

# Windows Update
$BtnWindowsUpdate = New-Object System.Windows.Forms.Button
$BtnWindowsUpdate.Location = New-Object System.Drawing.Point(210,350)
$BtnWindowsUpdate.Width = 55
$BtnWindowsUpdate.Height = 20
$BtnWindowsUpdate.Text = "Update"
$Form.controls.Add($BtnWindowsUpdate)
$BtnWindowsUpdate.Add_Click({
	# control.exe /name Microsoft.WindowsUpdate
	Start-Process -FilePath "${Env:SystemRoot}\System32\control.exe" -ArgumentList "update"
})
$ToolTip.SetToolTip($BtnWindowsUpdate, "Windows Update")

# OS Version
$OSVersion = SWMB_GetOSVersionReadable
$OSColor = SWMB_GetOSVersionColor
$BtnOSVersion = New-Object System.Windows.Forms.Label
$BtnOSVersion.Location = New-Object System.Drawing.Size(30,352)
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

$BtnAddDelProgram = New-Object System.Windows.Forms.Button
$BtnAddDelProgram.Location = New-Object System.Drawing.Point(379,255)
$BtnAddDelProgram.Width = 15
$BtnAddDelProgram.Height = 20
$BtnAddDelProgram.Text = "R"
$Form.controls.Add($BtnAddDelProgram)
$BtnAddDelProgram.Add_Click({
	# control.exe /name Microsoft.ProgramsAndFeatures
	Start-Process -FilePath "${Env:SystemRoot}\System32\control.exe" -ArgumentList "appwiz.cpl"
})
$ToolTip.SetToolTip($BtnAddDelProgram, "Install / Remove programs")

$ProgramCounter = 0
If (Test-Path -LiteralPath "${Env:ProgramFiles(x86)}\BleachBit\bleachbit.exe") {
	$BtnBleachBit = New-Object System.Windows.Forms.Button
	$BtnBleachBit.Location = New-Object System.Drawing.Point(379,275)
	$BtnBleachBit.Width = 15
	$BtnBleachBit.Height = 20
	$BtnBleachBit.Text = "B"
	$Form.controls.Add($BtnBleachBit)
	$BtnBleachBit.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles(x86)}\BleachBit\bleachbit.exe"
	})
	$ToolTip.SetToolTip($BtnBleachBit, "BleachBit Program")
	$ProgramCounter++
}
If (Test-Path -LiteralPath "${Env:ProgramFiles}\WinDirStat\WinDirStat.exe") {
	$BtnWinDirStat = New-Object System.Windows.Forms.Button
	$BtnWinDirStat.Location = New-Object System.Drawing.Point((379 + $ProgramCounter * 16),275)
	$BtnWinDirStat.Width = 15
	$BtnWinDirStat.Height = 20
	$BtnWinDirStat.Text = "S"
	$Form.controls.Add($BtnWinDirStat)
	$BtnWinDirStat.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\WinDirStat\WinDirStat.exe"
	})
	$ToolTip.SetToolTip($BtnWinDirStat, "WinDirStat Program")
	$ProgramCounter++
}
If (Test-Path -LiteralPath "${Env:ProgramFiles}\CCleaner\CCleaner64.exe") {
	$BtnSoftCCleaner = New-Object System.Windows.Forms.Button
	$BtnSoftCCleaner.Location = New-Object System.Drawing.Point((379 + $ProgramCounter * 16),275)
	$BtnSoftCCleaner.Width = 15
	$BtnSoftCCleaner.Height = 20
	$BtnSoftCCleaner.Text = "C"
	$Form.controls.Add($BtnSoftCCleaner)
	$BtnSoftCCleaner.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\CCleaner\CCleaner64.exe"
	})
	$ToolTip.SetToolTip($BtnSoftCCleaner, "CCleaner Program")
	$ProgramCounter++
}

################################################################

# Secpol Console
$BtnConsoleSecpol = New-Object System.Windows.Forms.Button
$BtnConsoleSecpol.Location = New-Object System.Drawing.Point(300,335)
$BtnConsoleSecpol.Width = 50
$BtnConsoleSecpol.Height = 30
$BtnConsoleSecpol.Text = "GPO"
$Form.controls.Add($BtnConsoleSecpol)
$BtnConsoleSecpol.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\secpol.msc"
})
$ToolTip.SetToolTip($BtnConsoleSecpol, "Local Security Policy Console")

# GPedit Console
$BtnConsoleGPedit = New-Object System.Windows.Forms.Button
$BtnConsoleGPedit.Location = New-Object System.Drawing.Point(350,335)
$BtnConsoleGPedit.Width = 15
$BtnConsoleGPedit.Height = 20
$BtnConsoleGPedit.Text = "E"
$Form.controls.Add($BtnConsoleGPedit)
$BtnConsoleGPedit.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\gpedit.msc"
})
$ToolTip.SetToolTip($BtnConsoleGPedit, "GPedit Console")

# Process Monitor Program
If (Test-Path -LiteralPath "${Env:ProgramFiles}\Sysinternals\Procmon64.exe") {
	$BtnSoftProcessMonitor = New-Object System.Windows.Forms.Button
	$BtnSoftProcessMonitor.Location = New-Object System.Drawing.Point(365,335)
	$BtnSoftProcessMonitor.Width = 15
	$BtnSoftProcessMonitor.Height = 20
	$BtnSoftProcessMonitor.Text = "P"
	$Form.controls.Add($BtnSoftProcessMonitor)
	$BtnSoftProcessMonitor.Add_Click({
		Start-Process -FilePath "${Env:ProgramFiles}\\Sysinternals\Procmon64.exe"
	})
	$ToolTip.SetToolTip($BtnSoftProcessMonitor, "Process Monitor Program")
}

# Task Manager Console
$BtnConsoleTaskMgr = New-Object System.Windows.Forms.Button
$BtnConsoleTaskMgr.Location = New-Object System.Drawing.Point(380,335)
$BtnConsoleTaskMgr.Width = 15
$BtnConsoleTaskMgr.Height = 20
$BtnConsoleTaskMgr.Text = "T"
$Form.controls.Add($BtnConsoleTaskMgr)
$BtnConsoleTaskMgr.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\Taskmgr.exe"
})
$ToolTip.SetToolTip($BtnConsoleTaskMgr, "Task Manager")

# Computer Managment Console
$BtnConsoleMgmt = New-Object System.Windows.Forms.Button
$BtnConsoleMgmt.Location = New-Object System.Drawing.Point(395,335)
$BtnConsoleMgmt.Width = 80
$BtnConsoleMgmt.Height = 30
$BtnConsoleMgmt.Text = "Managment"
$Form.controls.Add($BtnConsoleMgmt)
$BtnConsoleMgmt.Add_Click({
	Start-Process -FilePath "${Env:SystemRoot}\System32\compmgmt.msc"
})

# Network Interfaces Console
$BtnConsoleNet = New-Object System.Windows.Forms.Button
$BtnConsoleNet.Location = New-Object System.Drawing.Point(490,335)
$BtnConsoleNet.Width = 40
$BtnConsoleNet.Height = 30
$BtnConsoleNet.Text = "Net Cards"
$Form.controls.Add($BtnConsoleNet)
$BtnConsoleNet.Add_Click({
	# control.exe ncpa.cpl
	# control.exe /name Microsoft.NetworkAndSharingCenter
	Start-Process -FilePath "${Env:SystemRoot}\System32\control.exe" -ArgumentList "netconnections"
})

# Console Frame
$BtnConsoleFrame = New-Object System.Windows.Forms.GroupBox
$BtnConsoleFrame.Location = New-Object System.Drawing.Size(285,315)
$BtnConsoleFrame.Width = 255
$BtnConsoleFrame.Height = 60
$BtnConsoleFrame.Text = "Consoles"
$Form.Controls.Add($BtnConsoleFrame)

################################################################

# Exit
$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Location = New-Object System.Drawing.Point(450,255)
$BtnExit.Width = 80
$BtnExit.Height = 50
$BtnExit.Text = "Exit"
$BtnExit.Add_Click({
	$Form.Close()
})
# https://learn.microsoft.com/fr-fr/dotnet/api/system.windows.media.colors
$BtnExit.BackColor = 'PaleVioletRed'
$Form.controls.Add($BtnExit)

################################################################

# Main Loop
$Form.ShowDialog()

################################################################
