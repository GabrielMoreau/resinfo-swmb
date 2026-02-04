################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################

Function SWMB_GetInstallFolder {
	$InstallFolder = (Join-Path -Path ${Env:ProgramFiles} -ChildPath "SWMB")
	If (Test-Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB") {
		$InstallFolder = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SWMB" -Name "InstallFolder").InstallFolder
	}
	Return $InstallFolder
}

################################################################

Function SWMB_GetRunningVersion {
	$InstallFolder = (SWMB_GetInstallFolder)
	$VersionModule = (Join-Path -Path "$InstallFolder" -ChildPath (Join-Path -Path "Modules" (Join-Path -Path "SWMB" -ChildPath "Version.psd1")))
	$Version = ''
	If (Test-Path $VersionModule) {
		Import-Module -Name $VersionModule -ErrorAction Stop
		$Version = (Get-Module -Name Version).Version.ToString()
	}
	Return $Version
}

################################################################

Function SWMB_GetHomeURL {
	Return 'https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb'
}

################################################################

Function SWMB_GetDownloadURL {
	Return 'https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb'
}

################################################################

Function SWMB_GetHostId {
	$HostId = (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\SWMB' -Name 'HostId' -ErrorAction SilentlyContinue).HostId
	If ($HostId) {
		Return $HostId.ToUpper()
	}
	Return (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID.ToUpper()
}

################################################################

Function SWMB_GetLastPublishedVersion {
	$Url = (SWMB_GetDownloadURL)
	[System.Net.ServicePointManager]::MaxServicePointIdleTime = 3000
	Try {
		If ($PSVersionTable.PSVersion.Major -lt 6) {
			# Windows PowerShell 5.1 and before
			$NextVersion = ((Invoke-WebRequest -Uri "$Url/version.txt" -Method Get -TimeoutSec 3 -UseBasicParsing).Content)
		} Else {
			# PowerShell 6 / 7+
			$NextVersion = ((Invoke-WebRequest -Uri "$Url/version.txt" -Method Get -TimeoutSec 3).Content)
		}
	} Catch {
		$NextVersion = ""
	}
	Return $NextVersion
}

################################################################
# ProtectionStatus
#   On
#   Off
# VolumeStatus
#   FullyDecrypted
#   FullyEncrypted
#   EncryptionInProgress
#   DecryptionInProgress
# EncryptionMethod
#   XtsAes256
#   XtsAes128

Function SWMB_GetBitLockerStatus {
	Param (
		[Parameter(Mandatory = $True)] [string]$Drive
	)

	#$DriveLetter  = $Drive.Substring(0, 1)
	$DrivePStatus = (Get-BitLockerVolume $Drive).ProtectionStatus
	$DriveVStatus = (Get-BitLockerVolume $Drive).VolumeStatus
	$DriveEMethod = (Get-BitLockerVolume $Drive).EncryptionMethod

	If (($DrivePStatus -eq "On") -or ($DriveVStatus -eq "EncryptionInProgress")) {
		$Color = "Orange"
		If ($DriveEMethod -eq "XtsAeS256") { $Color = "Green" }
		Return "Running / $DriveEMethod", $Color
	}
	If (($DrivePStatus -eq "Off") -or ($DriveVStatus -eq "FullyEncrypted")) {
		Return "Suspend / $DriveEMethod", "Orange"
	}
	If (($DrivePStatus -eq "Off") -or ($DriveVStatus -eq "FullyDecrypted")) {
		Return "NotConfigured", "Red"
	}
	Return "$DrivePStatus / $DriveVStatus / $DriveEMethod", "Red"
}

################################################################

# Return OS version in a readable format
Function SWMB_GetOSVersionReadable {
	$OSVersion = SWMB_GetOSVersion
	$DisplayVersion = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DisplayVersion).DisplayVersion
	$UBR = $OSVersion.Revision
	If ($OSVersion -ge [version]"10.0.22000.0") {
		$Text = "Windows 11 / $DisplayVersion.$UBR"
	} ElseIf ($OSVersion -ge [version]"10.0.10240.0") {
		$Text = "Windows 10 / $DisplayVersion.$UBR"
	} Else {
		$Text = "Windows version unknown"
	}
	Return $Text
}

################################################################

# Return OS version in a readable format
Function SWMB_GetOSVersionColor {
	$OSVersion = SWMB_GetOSVersion
	$Build = $OSVersion.Build
	$MajorMinorBuild = "$($OSVersion.Major).$($OSVersion.Minor).$Build"
	$UBR = $OSVersion.Revision

	# Last OS revision
	# See ./get-ubr
	$UBR = @(
		# BeginAutoEdit - UBR - 1b63feca65de6cd7f3affaa998d43d95
		@{Os = '11'; DisplayVersion = '25H2'; MajorMinor = '10.0'; Build = 26200; UBR = 7705; Level = 0} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '25H2'; MajorMinor = '10.0'; Build = 26200; UBR = 7628; Level = 1} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '25H2'; MajorMinor = '10.0'; Build = 26200; UBR = 7627; Level = 2} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '25H2'; MajorMinor = '10.0'; Build = 26200; UBR = 7623; Level = 3} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '24H2'; MajorMinor = '10.0'; Build = 26100; UBR = 7705; Level = 0} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '24H2'; MajorMinor = '10.0'; Build = 26100; UBR = 7628; Level = 1} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '24H2'; MajorMinor = '10.0'; Build = 26100; UBR = 7627; Level = 2} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '23H2'; MajorMinor = '10.0'; Build = 22631; UBR = 6495; Level = 0} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '23H2'; MajorMinor = '10.0'; Build = 22631; UBR = 6494; Level = 1} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '11'; DisplayVersion = '22H2'; MajorMinor = '10.0'; Build = 22621; UBR = 6060; Level = 3} # https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
		@{Os = '10'; DisplayVersion = '22H2'; MajorMinor = '10.0'; Build = 19045; UBR = 6812; Level = 3} # https://learn.microsoft.com/en-us/windows/release-health/release-information
		@{Os = '10'; DisplayVersion = '21H2'; MajorMinor = '10.0'; Build = 19044; UBR = 6812; Level = 3} # https://learn.microsoft.com/en-us/windows/release-health/release-information
		# EndAutoEdit
	)

	$Color = @("Green", "Yellow", "Orange", "Red")

	ForEach ($Item in $UBR) {
		If ([version]"$MajorMinorBuild.0" -eq [version]"$($Item.MajorMinor).$($Item.Build).0") {
			If ($OSVersion -ge [version]"$($Item.MajorMinor).$($Item.Build).$($Item.UBR)") {
				$Level = $Item.Level
				If ($Level -ge $Color.Count) {
					$Level = $Color.Count - 1
				}
				Return $Color[$Level]
			}
		}
	}

	Return $Color[$Color.Count - 1]
}

################################################################

# GUI Task
# SWMB_GUI_Task -TaskPath $PSScriptRoot\Tasks\LocalMachine-Boot.ps1 -Name Boot -LogPath $DataFolder\Logs\LocalMachine-LastBoot.log -PosX 30 -PosY 150 -PresetPath $DataFolder\Presets\LocalMachine-Boot.preset -Form $Form
<#
Function SWMB_GUI_Task {
	Param (
		[Parameter(Mandatory = $True)] [string]$Name,
		[Parameter(Mandatory = $True)] [string]$TaskPath,
		[Parameter(Mandatory = $True)] [string]$LogPath,
		[Parameter(Mandatory = $True)] [string]$PresetPath,
		[Parameter(Mandatory = $True)] [int]$PosX,
		[Parameter(Mandatory = $True)] [int]$PosY,
		[Parameter(Mandatory = $True)] [System.Windows.Forms.Form]$Form
		[Parameter(Mandatory = $True)] [System.Windows.Forms.Label]$BtnStatus
	)

	$Editor = "${Env:SystemRoot}\System32\notepad.exe"
	If (Test-Path -LiteralPath "${Env:ProgramFiles}\Notepad++\notepad++.exe") {
		$Editor = "${Env:ProgramFiles}\Notepad++\notepad++.exe"
	}

	$BtnTaskStatus = New-Object System.Windows.Forms.Label
	$BtnTaskStatus.Location = New-Object System.Drawing.Size(($PosX+10), ($PosY+62))
	$BtnTaskStatus.Width = 50
	$BtnTaskStatus.Height = 15
	$BtnTaskStatus.BackColor = "Transparent"
	$BtnTaskStatus.Text = ""
	$Form.Controls.Add($BtnTaskStatus)

	$BtnTaskRun = New-Object System.Windows.Forms.Button
	$BtnTaskRun.Location = New-Object System.Drawing.Point($PosX, $PosY)
	$BtnTaskRun.Width = 60
	$BtnTaskRun.Height = 60
	$BtnTaskRun.Text = "$Name"
	$Form.controls.Add($BtnTaskRun)
	$BtnTaskRun.Add_Click({
		$BtnTaskStatus.Text = "Start..."
		If (((Get-Process -ProcessName 'mmc' -ErrorAction SilentlyContinue).Modules | Select-String 'EventViewer' | Measure-Object -Line).Lines -eq 0) {
			& eventvwr.exe /c:Application
		}
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$TaskPath`"" -WindowStyle Hidden -Wait
		Start-Process $Editor "`"$LogPath`""
		$BtnTaskStatus.Text = "Finish!"
	})

	$BtnTaskP = New-Object System.Windows.Forms.Button
	$BtnTaskP.Location = New-Object System.Drawing.Point(($PosX+59), $PosY)
	$BtnTaskP.Width = 15
	$BtnTaskP.Height = 20
	$BtnTaskP.Text = "P"
	$Form.controls.Add($BtnTaskP)
	$BtnTaskP.Add_Click({
		$CountTweak = 0
		& $TaskPath -Mode Print `
			| ForEach-Object {
				$CountTweak++
				$_ | Select-Object -Property @{Name="Num"; Expression={$CountTweak}}, @{Label="Tweak"; Expression={$_}}
				} `
			| Out-GridView -Title "SWMB: List of $CountTweak tweaks that will apply to the next $Name sequence on the ${Env:ComputerName} computer - $(Get-Date)"
	})
	$BtnTaskL = New-Object System.Windows.Forms.Button
	$BtnTaskL.Location = New-Object System.Drawing.Point(($PosX+59), ($PosY+20))
	$BtnTaskL.Width = 15
	$BtnTaskL.Height = 20
	$BtnTaskL.Text = "L"
	$Form.controls.Add($BtnTaskL)
	$BtnTaskL.Add_Click({
		Start-Process $Editor "`"$LogPath`""
	})
	$BtnTaskE = New-Object System.Windows.Forms.Button
	$BtnTaskE.Location = New-Object System.Drawing.Point(($PosX+59), ($PosY+40))
	$BtnTaskE.Width = 15
	$BtnTaskE.Height = 20
	$BtnTaskE.Text = "E"
	$Form.controls.Add($BtnTaskE)
	$BtnTaskE.Add_Click({
		Start-Process $Editor "`"$PresetPath`""
	})
	$BtnTaskC = New-Object System.Windows.Forms.Button
	$BtnTaskC.Location = New-Object System.Drawing.Point(($PosX+59), ($PosY+60))
	$BtnTaskC.Width = 15
	$BtnTaskC.Height = 20
	$BtnTaskC.Text = "C"
	$Form.controls.Add($BtnTaskC)
	$BtnTaskC.Add_Click({
		$BtnTaskStatus.Text = "Check..."
		$Message = @(& $TaskPath -Mode Check)
		$SubForm = New-Object 'System.Windows.Forms.Form' # -Property @{TopMost = $True}
		$SubForm.ClientSize = '550,375'
		$SubForm.Text = "SWMB: Check $Name tweaks"

		$SFTextBox            = New-Object system.Windows.Forms.TextBox
		$SFTextBox.Multiline  = $true
		$SFTextBox.Text       = $Message -join "`r`n"
		$SFTextBox.Font       = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Regular)
		$SFTextBox.Size       = New-Object System.Drawing.Size(500,300)
		$SFTextBox.Location   = New-Object System.Drawing.Point(20,20)
		$SFTextBox.Scrollbars = "Vertical"
		$SFTextBox.BackColor  = "#1F1F1F"
		$SFTextBox.ForeColor  = 'Cyan'
		$SFButton = New-Object system.Windows.Forms.Button
		$SFButton.Location = New-Object System.Drawing.Point(420,330)
		$SFButton.Width = 80
		$SFButton.Height = 30
		$SFButton.Text = "Close"
		$SFButton.Add_Click({
			$SubForm.Close()
			})
		$SubForm.Controls.AddRange(@($SFTextBox, $SFButton))
		$SubForm.Show()
		#& $TaskPath -Mode Check ` | Out-String
		#	| Out-GridView -Title "SWMB: Check $Name sequence tweaks on the ${Env:ComputerName} computer - $(Get-Date)"
	})
}
 #>

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function SWMB_*
