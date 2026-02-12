##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

################################################################
###### Application Tweaks
################################################################

# Disable OneDrive
Function TweakDisableOneDriveSync {
	Write-Output "Disabling OneDrive..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
}

# Enable OneDrive
Function TweakEnableOneDriveSync {
	Write-Output "Enabling OneDrive..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue
}

################################################################

# Uninstall OneDrive - Not applicable to Server
Function TweakUninstallOneDrive {
	Write-Output "Uninstalling OneDrive..."
	@(Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') |
		Get-ItemProperty |
		Where-Object { $_.DisplayName -like 'Microsoft OneDrive*' } |
		ForEach {
			$UninstallString = $_.UninstallString
			$Version = $_.DisplayVersion
			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe'
			$Args = $UninstallSplit[1].Trim()
			If (Test-Path -Path "$Exe") {
				Write-Output "Uninstalling OneDrive version $Version"
				Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
				Start-Sleep -Seconds 1
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru
				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill OneDrive uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: OneDrive uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
			Start-Sleep -Seconds 1
		}
}

# Install OneDrive - Not applicable to Server
Function TweakInstallOneDrive {
	Write-Output "Installing OneDrive..."
	$Exe = "${Env:SystemRoot}\SysWOW64\OneDriveSetup.exe"
	$Args = '/silent /allusers'
	If (!(Test-Path $Exe)) {
		$Exe = "${Env:SystemRoot}\System32\OneDriveSetup.exe"
	}
	Start-Process -FilePath "$Exe" -ArgumentList "$Args" -NoNewWindow -ErrorAction 'SilentlyContinue'
}

# View
Function TweakViewOneDrive {
	Write-Output "Viewing OneDrive product..."
	Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
		Get-ItemProperty |
		Where-Object {$_.DisplayName -like 'Microsoft OneDrive*' } |
		Select-Object -Property DisplayName, DisplayVersion, PSChildName
}

################################################################

# Uninstall default Microsoft applications
Function TweakUninstallMsftBloat {
	Write-Output "Uninstalling default Microsoft applications..."
	Get-AppxPackage -AllUsers -Name "Microsoft.3DBuilder" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.AppConnector" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingFinance" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingFoodAndDrink" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingHealthAndFitness" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingMaps" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingNews" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingSports" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingTranslator" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingTravel" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.BingWeather" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.CommsPhone" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.ConnectivityStore" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.FreshPaint" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.GetHelp" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Getstarted" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.HelpAndTips" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Media.PlayReadyClient.2" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Messaging" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Microsoft3DViewer" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue  # Microsoft 365 Copilot
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MinecraftUWP" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MixedReality.Portal" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MoCamera" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.MSPaint" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.NetworkSpeedTest" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.OfficeLens" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Office.OneNote" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Office.Sway" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.OneConnect" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.People" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Print3D" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Reader" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.RemoteDesktop" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.SkypeApp" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Todos" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Wallet" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WebMediaExtensions" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Whiteboard" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsAlarms" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsCamera" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "microsoft.windowscommunicationsapps" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsMaps" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsPhone" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	# Get-AppxPackage -AllUsers -Name "Microsoft.Windows.Photos" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsReadingList" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsScan" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WinJS.1.0" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WinJS.2.0" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.YourPhone" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.ZuneMusic" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.ZuneVideo" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Advertising.Xaml" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue # Dependency for microsoft.windowscommunicationsapps, Microsoft.BingWeather
}

# Install default Microsoft applications
Function TweakInstallMsftBloat {
	Write-Output "Installing default Microsoft applications..."
	Get-AppxPackage -AllUsers -Name "Microsoft.3DBuilder" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Advertising.Xaml" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} # Dependency for microsoft.windowscommunicationsapps, Microsoft.BingWeather
	Get-AppxPackage -AllUsers -Name "Microsoft.AppConnector" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingFinance" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingFoodAndDrink" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingHealthAndFitness" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingMaps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingNews" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingSports" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingTranslator" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingTravel" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.BingWeather" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.CommsPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.ConnectivityStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.FreshPaint" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.GetHelp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Getstarted" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.HelpAndTips" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Media.PlayReadyClient.2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Messaging" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Microsoft3DViewer" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftOfficeHub" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftPowerBIForWindows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftSolitaireCollection" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MicrosoftStickyNotes" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MinecraftUWP" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MixedReality.Portal" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MoCamera" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.MSPaint" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.NetworkSpeedTest" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.OfficeLens" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Office.OneNote" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Office.Sway" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.OneConnect" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.People" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Print3D" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Reader" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.RemoteDesktop" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.SkypeApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Todos" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Wallet" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WebMediaExtensions" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Whiteboard" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsAlarms" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsCamera" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.windowscommunicationsapps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsFeedbackHub" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsMaps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	# Get-AppxPackage -AllUsers -Name "Microsoft.Windows.Photos" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsReadingList" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsScan" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsSoundRecorder" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WinJS.1.0" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WinJS.2.0" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.YourPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.ZuneMusic" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.ZuneVideo" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}
# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse
# Uninstall default third party applications

################################################################

# Removing Appx Microsoft OfficeHub (Microsoft 365 Copilot)

# Remove
Function TweakRemoveAppxMsOfficeHub { # RESINFO
	SWMB_RemoveAppx -Name "Microsoft.MicrosoftOfficeHub" -Message "Removing Appx Microsoft OfficeHub (Microsoft 365 Copilot)..." -Verbose
	}

# Add
Function TweakAddAppxMsOfficeHub { # RESINFO
	SWMB_AddAppx -Name "Microsoft.MicrosoftOfficeHub" -Message "Adding Appx Microsoft OfficeHub (Microsoft 365 Copilot)..." -Verbose
	}

# View
Function TweakViewAppxMsOfficeHub { # RESINFO
	SWMB_ViewAppx -Name "Microsoft.MicrosoftOfficeHub" -Message "Viewing Appx Microsoft OfficeHub (Microsoft 365 Copilot)..." -Verbose
	}

################################################################

# Uninstall default third party applications
Function TweakUninstallThirdPartyBloat {
	Write-Output "Uninstalling default third party applications..."
	Get-AppxPackage -AllUsers -Name "2414FC7A.Viber" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "46928bounde.EclipseManager" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "4DF9E0F8.Netflix" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "64885BlueEdge.OneCalendar" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "7EE7776C.LinkedInforWindows" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "89006A2E.AutodeskSketchBook" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "9E2F88E3.Twitter" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "A278AB0D.DragonManiaLegends" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "A278AB0D.MarchofEmpires" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "AD2F1837.GettingStartedwithWindows8" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "AD2F1837.HPJumpStart" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "AD2F1837.HPRegistration" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Amazon.com.Amazon" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "C27EB4BA.DropboxOEM" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "CAF9E577.Plex" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "DB6EA5DB.CyberLinkMediaSuiteEssentials" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "DolbyLaboratories.DolbyAccess" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Drawboard.DrawboardPDF" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Facebook.Facebook" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Fitbit.FitbitCoach" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "KeeperSecurityInc.Keeper" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "king.com.BubbleWitch3Saga" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushFriends" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushSaga" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushSodaSaga" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "king.com.FarmHeroesSaga" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Nordcurrent.CookingFever" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "SpotifyAB.SpotifyMusic" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "ThumbmunkeysLtd.PhototasticCollage" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "WinZipComputing.WinZipUniversal" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "XINGAG.XING" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Install default third party applications
Function TweakInstallThirdPartyBloat {
	Write-Output "Installing default third party applications..."
	Get-AppxPackage -AllUsers -Name "2414FC7A.Viber" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "41038Axilesoft.ACGMediaPlayer" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "46928bounde.EclipseManager" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "4DF9E0F8.Netflix" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "64885BlueEdge.OneCalendar" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "7EE7776C.LinkedInforWindows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "828B5831.HiddenCityMysteryofShadows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "89006A2E.AutodeskSketchBook" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "9E2F88E3.Twitter" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "A278AB0D.DisneyMagicKingdoms" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "A278AB0D.DragonManiaLegends" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "A278AB0D.MarchofEmpires" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "ActiproSoftwareLLC.562882FEEB491" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "AD2F1837.GettingStartedwithWindows8" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "AD2F1837.HPJumpStart" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "AD2F1837.HPRegistration" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "AdobeSystemsIncorporated.AdobePhotoshopExpress" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Amazon.com.Amazon" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "C27EB4BA.DropboxOEM" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "CAF9E577.Plex" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "D52A8D61.FarmVille2CountryEscape" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "D5EA27B7.Duolingo-LearnLanguagesforFree" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "DB6EA5DB.CyberLinkMediaSuiteEssentials" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "DolbyLaboratories.DolbyAccess" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Drawboard.DrawboardPDF" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Facebook.Facebook" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Fitbit.FitbitCoach" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "flaregamesGmbH.RoyalRevolt2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "GAMELOFTSA.Asphalt8Airborne" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "KeeperSecurityInc.Keeper" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "king.com.BubbleWitch3Saga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushFriends" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "king.com.CandyCrushSodaSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "king.com.FarmHeroesSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Nordcurrent.CookingFever" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "PandoraMediaInc.29680B314EFC2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "SpotifyAB.SpotifyMusic" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "ThumbmunkeysLtd.PhototasticCollage" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "WinZipComputing.WinZipUniversal" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "XINGAG.XING" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

################################################################

# Uninstall Windows Store
Function TweakUninstallWindowsStore {
	Write-Output "Uninstalling Windows Store..."
	Get-AppxPackage -AllUsers -Name "Microsoft.DesktopAppInstaller" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Services.Store.Engagement" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.StorePurchaseApp" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsStore" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Install Windows Store
Function TweakInstallWindowsStore {
	Write-Output "Installing Windows Store..."
	Get-AppxPackage -AllUsers -Name "Microsoft.DesktopAppInstaller" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Services.Store.Engagement" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.StorePurchaseApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.WindowsStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

################################################################

# Disable Xbox features - Not applicable to Server
Function TweakDisableXboxFeatures {
	Write-Output "Disabling Xbox features. See DisableXboxFeatures_CU..."
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxApp" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxGameOverlay" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxGamingOverlay" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Xbox.TCUI" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	#Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 0
	#Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

# Enable Xbox features - Not applicable to Server
Function TweakEnableXboxFeatures {
	Write-Output "Enabling Xbox features. See EnableXboxFeatures_CU..."
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxIdentityProvider" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxSpeechToTextOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxGameOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.XboxGamingOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers -Name "Microsoft.Xbox.TCUI" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	#Remove-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue
	#Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue
}

################################################################

### Edge policies
## https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies
## https://admx.help/?Category=EdgeChromium

# Enable
# Clear Edge cached images and files on exit
Function TweakEnableEdgeClearCacheOnExit { # RESINFO
	Write-Output "Enabling clear Edge cache on exit..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -Type DWord -Value 1
}

# Disable - Default
# Do not clear Edge cached images and files on exit
Function TweakDisableEdgeClearCacheOnExit { # RESINFO
	Write-Output "Disabling clear Edge cache on exit..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeClearCacheOnExit { # RESINFO
	Write-Output "Viewing Edge clear cache on exit (0 or not exist: Not clear, 1: Clear cached images and files on exit )..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -ErrorAction SilentlyContinue
}

################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.MicrosoftEdge::AllowDoNotTrack
# Enable Do Not Tracker
Function TweakEnableEdgeDoNtoTrack { # RESINFO
	Write-Output "Enabling Do Not Tracker requests are sent to websites asking for tracking info..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -Type DWord -Value 1
}

# Default
# By default, Do Not Track requests aren't sent, but employees can choose to turn on and send requests
Function TweakDisableEdgeDoNtoTrack { # RESINFO
	Write-Output "Disabling (don't Configure) Do Not Track..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeDoNtoTrack { # RESINFO
	Write-Output "Viewing Edge Configure Do Not Track - Do not send trackers to websites that request tracking information (0: Enable (Not send), 1: Disable, not exist: Default)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -ErrorAction SilentlyContinue
}

################################################################

# https://admx.help/?Category=EdgeChromium&Policy=Microsoft.Policies.Edge::PersonalizationReportingEnabled
# This policy prevents Microsoft from collecting a user's Microsoft Edge browsing history
# Disable
Function TweakDisableEdgeSendBrowsingHistory { # RESINFO
	Write-Output "Disabling sending browsing history to Microsoft..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "PersonalizationReportingEnabled" -Type DWord -Value 0
}

# Default
# By default, Allow personalization of ads, search and news by sending browsing history to Microsoft
Function TweakEnableEdgeSendBrowsingHistory { # RESINFO
	Write-Output "Enabling sending browsing history to Microsoft..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "PersonalizationReportingEnabled" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeSendBrowsingHistory { # RESINFO
	Write-Output "Viewing Edge Configure Do Not Track - Sending browsing history to Microsoft (0: Disable, 1 or not exist: Enable (Default))..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "PersonalizationReportingEnabled" -ErrorAction SilentlyContinue
}

################################################################

# Disable built-in Adobe Flash in IE and Edge
Function TweakDisableAdobeFlash {
	Write-Output "Disabling built-in Adobe Flash in IE and Edge..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWord -Value 0
}

# Enable built-in Adobe Flash in IE and Edge
Function TweakEnableAdobeFlash {
	Write-Output "Enabling built-in Adobe Flash in IE and Edge..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -ErrorAction SilentlyContinue
}

################################################################

# Disable Edge preload after Windows startup - Applicable since Win10 1809
Function TweakDisableEdgePreload {
	Write-Output "Disabling Edge preload..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -Type DWord -Value 0
}

# Enable Edge preload after Windows startup
Function TweakEnableEdgePreload {
	Write-Output "Enabling Edge preload..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -ErrorAction SilentlyContinue
}

################################################################

# Disable Edge desktop shortcut creation after certain Windows updates are applied
Function TweakDisableEdgeShortcutCreation {
	Write-Output "Disabling Edge shortcut creation..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1
}

# Enable Edge desktop shortcut creation after certain Windows updates are applied
Function TweakEnableEdgeShortcutCreation {
	Write-Output "Enabling Edge shortcut creation..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -ErrorAction SilentlyContinue
}

################################################################

# Microsoft Edge Auto Update
# https://admx.help/?Category=EdgeChromium_Blocker&Policy=Microsoft.Policies.EdgeUpdate::NoUpdate
# Disable
Function TweakDisableEdgeUpdate { # RESINFO
	Write-Output "Disabling Edge auto update..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -Type DWord -Value 1
}

# Enable (default)
Function TweakEnableEdgeUpdate { # RESINFO
	Write-Output "Enabling Edge auto update..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeUpdate { # RESINFO
	Write-Output "Viewing Edge auto update (0 or not exist: Auto update, 1: No update)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -ErrorAction SilentlyContinue
}

################################################################

# Disable Internet Explorer first run wizard
Function TweakDisableIEFirstRun {
	Write-Output "Disabling Internet Explorer first run wizard..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Type DWord -Value 1
}

# Enable Internet Explorer first run wizard
Function TweakEnableIEFirstRun {
	Write-Output "Enabling Internet Explorer first run wizard..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -ErrorAction SilentlyContinue
}

################################################################

# Disable "Hi!" First Logon Animation (it will be replaced by "Preparing Windows" message)
Function TweakDisableFirstLogonAnimation {
	Write-Output "Disabling First Logon Animation..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableFirstLogonAnimation" -Type DWord -Value 0
}

# Enable "Hi!" First Logon Animation
Function TweakEnableFirstLogonAnimation {
	Write-Output "Enabling First Logon Animation..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableFirstLogonAnimation" -ErrorAction SilentlyContinue
}

################################################################

# Disable Windows Media Player's media sharing feature
Function TweakDisableMediaSharing {
	Write-Output "Disabling Windows Media Player media sharing..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventLibrarySharing" -Type DWord -Value 1
}

# Enable Windows Media Player's media sharing feature
Function TweakEnableMediaSharing {
	Write-Output "Enabling Windows Media Player media sharing..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventLibrarySharing" -ErrorAction SilentlyContinue
}

################################################################

# Disable Windows Media Player online access - audio file metadata download, radio presets, DRM.
Function TweakDisableMediaOnlineAccess {
	Write-Output "Disabling Windows Media Player online access. See DisableMediaOnlineAccess_CU..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM" -Name "DisableOnline" -Type DWord -Value 1
}

# Enable Windows Media Player online access
Function TweakEnableMediaOnlineAccess {
	Write-Output "Enabling Windows Media Player online access. See EnableMediaOnlineAccess_CU..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM" -Name "DisableOnline" -ErrorAction SilentlyContinue
}

################################################################

# Enable Developer Mode
Function TweakEnableDeveloperMode {
	Write-Output "Enabling Developer Mode..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
}

# Disable Developer Mode
Function TweakDisableDeveloperMode {
	Write-Output "Disabling Developer Mode..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -ErrorAction SilentlyContinue
}

################################################################

# Uninstall Windows Media Player
Function TweakUninstallMediaPlayer {
	Write-Output "Uninstalling Windows Media Player..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WindowsMediaPlayer" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Media.WindowsMediaPlayer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Media Player
Function TweakInstallMediaPlayer {
	Write-Output "Installing Windows Media Player..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WindowsMediaPlayer" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Media.WindowsMediaPlayer*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Uninstall Internet Explorer
Function TweakUninstallInternetExplorer {
	Write-Output "Uninstalling Internet Explorer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Internet Explorer
Function TweakInstallInternetExplorer {
	Write-Output "Installing Internet Explorer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Uninstall Work Folders Client - Not applicable to Server
Function TweakUninstallWorkFolders {
	Write-Output "Uninstalling Work Folders Client..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WorkFolders-Client" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Work Folders Client - Not applicable to Server
Function TweakInstallWorkFolders {
	Write-Output "Installing Work Folders Client..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WorkFolders-Client" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

################################################################

# Uninstall Windows Hello Face - Not applicable to Server
Function TweakUninstallHelloFace {
	Write-Output "Uninstalling Windows Hello Face..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Hello.Face*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Hello Face - Not applicable to Server
Function TweakInstallHelloFace {
	Write-Output "Installing Windows Hello Face..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Hello.Face*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Uninstall Math Recognizer - Not applicable to Server
Function TweakUninstallMathRecognizer {
	Write-Output "Uninstalling Math Recognizer..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "MathRecognizer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Math Recognizer - Not applicable to Server
Function TweakInstallMathRecognizer {
	Write-Output "Installing Math Recognizer..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "MathRecognizer*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Uninstall PowerShell 2.0 Environment
# PowerShell 2.0 is deprecated since September 2018. This doesn't affect PowerShell 5 or newer which is the default PowerShell environment.
# May affect Microsoft Diagnostic Tool and possibly other scripts. See https://blogs.msdn.microsoft.com/powershell/2017/08/24/windows-powershell-2-0-deprecation/
Function TweakUninstallPowerShellV2 {
	Write-Output "Uninstalling PowerShell 2.0 Environment..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "MicrosoftWindowsPowerShellV2Root" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Uninstall-WindowsFeature -Name "PowerShell-V2" -WarningAction SilentlyContinue | Out-Null
	}
}

# Install PowerShell 2.0 Environment
Function TweakInstallPowerShellV2 {
	Write-Output "Installing PowerShell 2.0 Environment..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "MicrosoftWindowsPowerShellV2Root" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Install-WindowsFeature -Name "PowerShell-V2" -WarningAction SilentlyContinue | Out-Null
	}
}

################################################################

# Uninstall PowerShell Integrated Scripting Environment - Applicable since 2004
# Note: Also removes built-in graphical methods like Out-GridView
Function TweakUninstallPowerShellISE {
	Write-Output "Uninstalling PowerShell Integrated Scripting Environment..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Microsoft.Windows.PowerShell.ISE*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install PowerShell Integrated Scripting Environment - Applicable since 2004
Function TweakInstallPowerShellISE {
	Write-Output "Installing PowerShell Integrated Scripting Environment..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Microsoft.Windows.PowerShell.ISE*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Install Linux Subsystem - Applicable since Win10 1607 and Server 1709
# Note: 1607 requires also EnableDevelopmentMode for WSL to work
# For automated Linux distribution installation, see https://docs.microsoft.com/en-us/windows/wsl/install-on-server
Function TweakInstallLinuxSubsystem {
	Write-Output "Installing Linux Subsystem..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Linux Subsystem - Applicable since Win10 1607 and Server 1709
Function TweakUninstallLinuxSubsystem {
	Write-Output "Uninstalling Linux Subsystem..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

################################################################

# Install Hyper-V - Not applicable to Home
Function TweakInstallHyperV {
	Write-Output "Installing Hyper-V..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall Hyper-V - Not applicable to Home
Function TweakUninstallHyperV {
	Write-Output "Uninstalling Hyper-V..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	}
}

################################################################

# Uninstall OpenSSH Client - Applicable since 1803
Function TweakUninstallSSHClient {
	Write-Output "Uninstalling OpenSSH Client..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install OpenSSH Client - Applicable since 1803
Function TweakInstallSSHClient {
	Write-Output "Installing OpenSSH Client..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Install OpenSSH Server - Applicable since 1809
Function TweakInstallSSHServer {
	Write-Output "Installing OpenSSH Server..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" } | Add-WindowsCapability -Online | Out-Null
	Write-Output "Start the sshd service..."
	Start-Service sshd -WarningAction SilentlyContinue
	Write-Output "Automatic startup..."
	Set-Service -Name sshd -StartupType 'Automatic' -WarningAction SilentlyContinue
}

# Uninstall OpenSSH Server - Applicable since 1809
Function TweakUninstallSSHServer {
	Write-Output "Uninstalling OpenSSH Server..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" } | Remove-WindowsCapability -Online | Out-Null
}

################################################################

# Install Telnet Client
Function TweakInstallTelnetClient {
	Write-Output "Installing Telnet Client..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "TelnetClient" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Install-WindowsFeature -Name "Telnet-Client" -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall Telnet Client
Function TweakUninstallTelnetClient {
	Write-Output "Uninstalling Telnet Client..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "TelnetClient" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Uninstall-WindowsFeature -Name "Telnet-Client" -WarningAction SilentlyContinue | Out-Null
	}
}

################################################################

# Install .NET Framework 2.0, 3.0 and 3.5 runtimes - Requires internet connection
Function TweakInstallNET23 {
	Write-Output "Installing .NET Framework 2.0, 3.0 and 3.5 runtimes..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "NetFx3" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Install-WindowsFeature -Name "NET-Framework-Core" -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall .NET Framework 2.0, 3.0 and 3.5 runtimes
Function TweakUninstallNET23 {
	Write-Output "Uninstalling .NET Framework 2.0, 3.0 and 3.5 runtimes..."
	If ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "NetFx3" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} Else {
		Uninstall-WindowsFeature -Name "NET-Framework-Core" -WarningAction SilentlyContinue | Out-Null
	}
}

################################################################

# Set Photo Viewer association for bmp, gif, jpg, png and tif
Function TweakSetPhotoViewerAssociation {
	Write-Output "Setting Photo Viewer association for bmp, gif, jpg, png and tif..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
		New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
		New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
		Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
		Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	}
}

# Unset Photo Viewer association for bmp, gif, jpg, png and tif
Function TweakUnsetPhotoViewerAssociation {
	Write-Output "Unsetting Photo Viewer association for bmp, gif, jpg, png and tif..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\Paint.Picture\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "MuiVerb" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "CommandId" -Type String -Value "IE.File"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "(Default)" -Type String -Value "`"${Env:SystemDrive}\Program Files\Internet Explorer\iexplore.exe`" %1"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "DelegateExecute" -Type String -Value "{17FE9752-0B5A-4665-84CD-569794602F5C}"
	Remove-Item -Path "HKCR:\jpegfile\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\pngfile\shell\open" -Recurse -ErrorAction SilentlyContinue
}

################################################################

# Add Photo Viewer to 'Open with...'
Function TweakAddPhotoViewerOpenWith {
	Write-Output "Adding Photo Viewer to Open with..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
}

# Remove Photo Viewer from 'Open with...'
Function TweakRemovePhotoViewerOpenWith {
	Write-Output "Removing Photo Viewer from Open with..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Recurse -ErrorAction SilentlyContinue
}

################################################################

# Uninstall Microsoft Print to PDF
Function TweakUninstallPDFPrinter {
	Write-Output "Uninstalling Microsoft Print to PDF..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-PrintToPDFServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft Print to PDF
Function TweakInstallPDFPrinter {
	Write-Output "Installing Microsoft Print to PDF..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-PrintToPDFServices-Features" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

################################################################

# Uninstall Microsoft XPS Document Writer
Function TweakUninstallXPSPrinter {
	Write-Output "Uninstalling Microsoft XPS Document Writer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft XPS Document Writer
Function TweakInstallXPSPrinter {
	Write-Output "Installing Microsoft XPS Document Writer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

################################################################

# Remove Default Fax Printer
Function TweakRemoveFaxPrinter {
	Write-Output "Removing Default Fax Printer..."
	Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue
}

# Add Default Fax Printer
Function TweakAddFaxPrinter {
	Write-Output "Adding Default Fax Printer..."
	Add-Printer -Name "Fax" -DriverName "Microsoft Shared Fax Driver" -PortName "SHRFAX:" -ErrorAction SilentlyContinue
}

################################################################

# Uninstall Windows Fax and Scan Services - Not applicable to Server
Function TweakUninstallFaxAndScan {
	Write-Output "Uninstalling Windows Fax and Scan Services..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "FaxServicesClientPackage" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Print.Fax.Scan*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Fax and Scan Services - Not applicable to Server
Function TweakInstallFaxAndScan {
	Write-Output "Installing Windows Fax and Scan Services..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "FaxServicesClientPackage" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Print.Fax.Scan*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# https://devblogs.microsoft.com/setup/moving-or-disabling-the-package-cache-for-visual-studio-2017/
# https://answers.microsoft.com/en-us/windows/forum/all/is-it-safe-to-delete-files-in-cprogramdatapackage/8b5897cd-9d7f-4b07-bc17-e46461b728c7
# Package are cache in folder 'C:\ProgramData\Package Cache\'
# & "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe" --nocache

# Disable Visual Studio Cache
Function TweakDisableVisualStudioCache { # RESINFO
	Write-Output "Disabling Visual Studio Cache..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup" -Name "KeepDownloadedPayloads" -Type DWord -Value 0
}

# Enable Visual Studio Cache
Function TweakEnableVisualStudioCache { # RESINFO
	Write-Output "Enabling Visual Studio Cache..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup" -Force | Out-Null
	}
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup" -Name "KeepDownloadedPayloads" -Type DWord -Value 1
}

# View Visual Studio Cache
Function TweakViewVisualStudioCache { # RESINFO
	Write-Output "Viewing Visual Studio Cache (0: Disable, 1: Enable (default), not exist: Not install)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup"    -Name "KeepDownloadedPayloads"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\Setup"             -Name "KeepDownloadedPayloads"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\Setup" -Name "KeepDownloadedPayloads"
}


################################################################

### Automatic clean files - see issues #59 - Storage sense
## https://support.microsoft.com/en-us/windows/manage-drive-space-with-storage-sense-654f6ada-7bfc-45e5-966b-e24aded96ad5
## https://admx.help/HKLM/Software/Policies/Microsoft/Windows/StorageSense

# Allow StorageSense
Function TweakEnableStorageSense { # RESINFO
	Write-Output "Enabling Storage sense and Configure Storage Sense cadence $($Global:SWMB_Custom.StorageSenseCadence) day..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseGlobal" -Type DWord -Value 1
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseGlobalCadence" -Type DWord -Value $Global:SWMB_Custom.StorageSenseCadence
}

# Not Configured:
# By default, Storage Sense is turned off until the user runs into low disk space or the user enables it manually. Users can configure this setting in Storage settings.
Function TweakDisableStorageSense { # RESINFO
	Write-Output "Disabling Storage Sense Not Configured..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -ErrorAction SilentlyContinue
}

# View
Function TweakViewStorageSense { # RESINFO
	Write-Output "Viewing if Storage Sense is turned on for the machine..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseGlobal" -ErrorAction SilentlyContinue
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseGlobalCadence" -ErrorAction SilentlyContinue
}

################################################################

# Allow storage sense tempory files Cleanup
# Storage Sense will delete the user's temporary files that are not in use. Users cannot disable this setting in Storage settings.
Function TweakEnableStorageSenseTempCleanup { # RESINFO
	Write-Output "Enabling Storage Sense Temporary Files Cleanup: Allow Storage Sense Temporary Files Cleanup..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -Type DWord -Value 1
}

# Disabled:
# Storage Sense will not delete the user's temporary files. Users cannot enable this setting in Storage settings.
Function TweakDisableStorageSenseTempCleanup { # RESINFO
	Write-Output "Disabling Storage Sense Temporary Files Cleanup..."
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -Type DWord -Value 0
}

# View
Function TweakViewStorageSenseTempCleanup { # RESINFO
	Write-Output "Viewing if Storage Sense Temporary Files Cleanup is turned on..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -ErrorAction SilentlyContinue
}

################################################################

# Configure Storage Sense Recycle Bin cleanup threshold
# minimum age threshold (in days) of a file in the Recycle Bin before Storage Sense will delete it
Function TweakEnableStorageSenseTrashCleanup { # RESINFO
	Write-Output "Enabling Storage Sense Trash Cleanup: Files in the recycle bin that are more than $($Global:SWMB_Custom.StorageSenseTrashCleanup) days old will be deleted automatically..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -Type DWord -Value $Global:SWMB_Custom.StorageSenseTrashCleanup
}

# Disabled:
# By default, Storage Sense will delete files in the user's Recycle Bin that have been there for over 30 days.
Function TweakDisableStorageSenseTrashCleanup { # RESINFO
	Write-Output "Disabling Storage Sense Trash Cleanup..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -ErrorAction SilentlyContinue
}

# View
Function TweakViewStorageSenseTrashCleanup { # RESINFO
	Write-Output "Viewing Storage Sense Trash Cleanup..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -ErrorAction SilentlyContinue
}

################################################################

# Disable
Function TweakDisableWindowsCopilot { # RESINFO
	Write-Output "Disabling (Turn Off) Windows Copilot and uninstall appx..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
	Get-AppxPackage -AllUsers | Where-Object {$_.Name -like 'Microsoft.Copilot'} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Enable Copilot
Function TweakEnableWindowsCopilot { # RESINFO
	Write-Output "Enabling (Turn On) for Windows Copilot (Default) and install appx..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Copilot" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

# View Copilot
Function TweakViewWindowsCopilot { # RESINFO
	Write-Output "Viewing Windows Copilot..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.Copilot"
}

################################################################

# Computer Configuration / Administrative Templates / Windows Components / News and interests
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Feeds::EnableFeeds&Language=fr-fr
# https://www.tenforums.com/tutorials/178178-how-enable-disable-news-interests-taskbar-windows-10-a.html
# Disable
Function TweakDisableWindowsFeeds { # RESINFO
	Write-Output "Disabling (Turn Off) windows feeds (news and interests)..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
}

# Enable
Function TweakEnableWindowsFeeds { # RESINFO
	Write-Output "Enabling (Turn On) windows feeds (news and interests)..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -ErrorAction SilentlyContinue
}

################################################################

## https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.AppPrivacy::LetAppsAccessLocation&Language=fr-fr
# Disable access to location from UWP apps
Function TweakDisableUWPAccessLocation { # RESINFO
	Write-Output "Disabling access to location from UWP apps..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation" -Type DWord -Value 2
}

# Enable access to location from UWP apps
Function TweakEnableUWPAccessLocation { # RESINFO
	Write-Output "Enabling access to location from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation" -ErrorAction SilentlyContinue
}

################################################################

# Windows Hello Authentification
# https://answers.microsoft.com/en-us/windows/forum/windows_10-hello/how-to-disable-windows-hello/05ab5492-19c7-4d44-b762-d93b44a9cf65
# https://www.minitool.com/news/disable-windows-hello.html
# Computer Configuration -> Administrative Templates -> System -> Logon : Turn on PIN sign-in and select Disabled.
# Disable
Function TweakDisableWindowsHello { # RESINFO
	Write-Output "Disabling (Block) Windows Hello Authentification..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Name "value" -Type DWord -Value 0
}

# Enable
Function TweakEnableWindowsHello { # RESINFO
	Write-Output "Enabling Windows Hello Authentification..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Name "value" -Type DWord -Value 1
}

################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / WindowsStore /Afficher uniquement le magasin privé dans l'application du windows store / activé
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsStore::RequirePrivateStoreOnly_2&Language=fr-fr
# Disable
Function TweakDisablePrivateStoreOnly { # RESINFO
	Write-Output "Disabling PrivateStoreOnly..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RequirePrivateStoreOnly" -Type DWord -Value 0
}

# Enable
Function TweakEnablePrivateStoreOnly { # RESINFO
	Write-Output "Enabling PrivateStoreOnly..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RequirePrivateStoreOnly" -Type DWord -Value 1
}

################################################################

### Déactiver le Windows Store
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsStore::RemoveWindowsStore_2
# Configuration ordinateur / Modèles d'administration / Composants Windows / WindowsStore / Desactiver l'application / active
# Disable
Function TweakDisableWindowsStoreAccess { # RESINFO
	Write-Output "Disabling Windows Store..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Type DWord -Value 1
}

# Enable
Function TweakEnableWindowsStoreAccess { # RESINFO
	Write-Output "Enabling Windows Store..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Type DWord -Value 0
}

################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / WindowsStore / Désactiver toutes les applications du Windows Store / activé
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsStore::DisableStoreApps&Language=fr-fr
# Disable
Function TweakDisableStoreApps { # RESINFO
	Write-Output "Disabling StoreApps..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "DisableStoreApps" -Type DWord -Value 1
}

# Enable
Function TweakEnableStoreApps { # RESINFO
	Write-Output "Enabling StoreApps..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "DisableStoreApps" -Type DWord -Value 0
}

################################################################

# https://www.secpod.com/blog/how-to-enable-automatic-update-for-ms-office-2013-and-2016-click-to-run-installations/
# Microsoft Office Standard 2013 Click-To-Run installations

# Enable
Function TweakEnableOffice2013AutoUpdate { # RESINFO
	Write-Output "Enabling MS Office2013 AutoUpdate..."
	$RefName = 'Microsoft Office Standard 2013'
	$IsInstalled = $False
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$IsInstalled = $True
			}
		}

	If ($IsInstalled -eq $True) {
		If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -Type DWord -Value 1
	}
}

# Disable
Function TweakDisableOffice2013AutoUpdate { # RESINFO
	Write-Output "Disabling MS Office2013 AutoUpdate..."
	$RefName = 'Microsoft Office Standard 2013'
	$IsInstalled = $False
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$IsInstalled = $True
			}
		}

	If ($IsInstalled -eq $True) {
		If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -Type DWord -Value 0
	}
}

# View
Function TweakViewOffice2013AutoUpdate {
	Write-Output "Viewing MS Office2013 AutoUpdate (0 or not exist: No auto update, 1: auto update)..."
	Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\15.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -ErrorAction SilentlyContinue
}

################################################################

# https://www.secpod.com/blog/how-to-enable-automatic-update-for-ms-office-2013-and-2016-click-to-run-installations/
# Microsoft Office Standard 2016 Click-To-Run installations

# Enable
Function TweakEnableOffice2016AutoUpdate { # RESINFO
	Write-Output "Enabling MS Office2016 AutoUpdate..."
	$RefName = 'Microsoft Office Standard 2016'
	$IsInstalled = $False
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$IsInstalled = $True
			}
		}

	If ($IsInstalled -eq $True) {
		If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -Type DWord -Value 1
	}
}

# Disable
Function TweakDisableOffice2016AutoUpdate { # RESINFO
	Write-Output "Disabling MS Office2016 AutoUpdate..."
	$RefName = 'Microsoft Office Standard 2016'
	$IsInstalled = $False
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$IsInstalled = $True
			}
		}

	If ($IsInstalled -eq $True) {
		If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -Type DWord -Value 0
	}
}

# View
Function TweakViewOffice2016AutoUpdate {
	Write-Output "Viewing MS Office2016 AutoUpdate (0 or not exist: No auto update, 1: auto update)..."
	Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -ErrorAction SilentlyContinue
}

################################################################

# https://community.adobe.com/t5/acrobat-discussions/permanently-disable-adobe-collab-sync/m-p/14939077/page/2?profile.language=fr
# https://techdiy.info/fr/commencez/puis-je-desactiver-adobecollabsync-au-demarrage/
# Disable AdobeCollabSync binary

# Disable
Function TweakDisableAdobeCollabSync { # RESINFO
	Write-Output "Disabling AdobeCollabSync..."
	$Name = "AdobeCollabSync.exe"
	$FullPath = "$Env:ProgramFiles\Adobe\Acrobat DC\Acrobat\$Name"
	$BackupPath = "$FullPath.org"

	If (Test-Path -Path $FullPath) {
		If (Test-Path -Path $BackupPath) {
			Remove-Item $BackupPath -Force -ErrorAction SilentlyContinue
		}
		Write-Output " Rename AdobeCollabSync.exe"
		Rename-Item -Path $FullPath -NewName "$Name.org" -Force
	}
}

# Enable
Function TweakEnableAdobeCollabSync { # RESINFO
	Write-Output "Enabling AdobeCollabSync..."
	$Name = "AdobeCollabSync.exe"
	$FullPath = "$Env:ProgramFiles\Adobe\Acrobat DC\Acrobat\$Name"
	$BackupPath = "$FullPath.org"

	If (Test-Path -Path $FullPath) {
		Return
	}
	If (Test-Path -Path $BackupPath) {
		Write-Output " Rename AdobeCollabSync.exe.org"
		Rename-Item -Path $BackupPath -NewName "$Name" -Force
	}
}

# View
Function TweakViewAdobeCollabSync { # RESINFO
	Write-Output "Viewing AdobeCollabSync..."
	$Name = "AdobeCollabSync.exe"
	$FullPath = "$Env:ProgramFiles\Adobe\Acrobat DC\Acrobat\$Name"
	$BackupPath = "$FullPath.org"

	if (Test-Path -Path $FullPath) {
		Write-Output " AdobeCollabSync is enabled"
	} Else {
		Write-Output " AdobeCollabSync is disabled"
	}
}

################################################################

# Disables automatic updates service from Adobe
# (enabled by default after a new installation)

# Disable
Function TweakDisableAdobeAutoUpdate { # RESINFO
	Write-Output "Disabling Adobe AutoUpdate (ARM) Service..."
	$ServiceName = "AdobeARMservice"
	# Status  | Name            | DisplayName
	# Running | AdobeARMservice | Adobe Acrobat Update Service
	Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Stop-Service -Force
	Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
	#Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Select-Object Name, StartType, Status
}

# Enable
Function TweakEnableAdobeAutoUpdate { # RESINFO
	Write-Output "Enabling Adobe AutoUpdate (ARM) Service..."
	$ServiceName = "AdobeARMservice"
	#Set-Service "$ServiceName" -StartupType Automatic
	#Start-Service "$ServiceName" -WarningAction SilentlyContinue
	Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
	Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Start-Service -WarningAction SilentlyContinue
	#Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Select-Object Name, StartType, Status
}

# View
Function TweakViewAdobeAutoUpdate { # RESINFO
	Write-Output "Viewing Adobe AutoUpdate (ARM) Service..."
	$ServiceName = "AdobeARMservice"
	Get-Service -Name "$ServiceName" -ErrorAction SilentlyContinue | Select-Object Name, StartType, Status
}

################################################################

# Adobe Reader DC must enable Enhanced Security in a Standalone Application or In Browser
# STIG V-213168 https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213168
# STIG V-213169 https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213169
# https://helpx.adobe.com/fr/acrobat/using/enhanced-security-setting-pdfs.html
# https://www.adobe.com/devnet-docs/acrobatetk/tools/QuickKeys/EnhancedSecurityQuickKeyAll.pdf

# Enable
Function TweakEnableAdobeEnhancedSecurity { # RESINFO
	Write-Output "Enabling Adobe EnhancedSecurity (Standalone and InBrowser)..."
	$RegPath = 'HKLM:\Software\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
	$RegFields = @("bEnhancedSecurityStandalone", "bEnhancedSecurityInBrowser")

	If (!(Test-Path $RegPath)) {
		New-Item -Path $RegPath -Force | Out-Null
	}
	ForEach ($Field in $RegFields) {
		Set-ItemProperty -Path $RegPath -Name $Field -Type DWord -Value 1
	}
}

# Disable
Function TweakDisableAdobeEnhancedSecurity { # RESINFO
	Write-Output "Disabling Adobe EnhancedSecurity (Standalone and InBrowser)..."
	$RegPath = 'HKLM:\Software\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
	$RegFields = @("bEnhancedSecurityStandalone", "bEnhancedSecurityInBrowser")

	If (Test-Path $RegPath) {
		ForEach ($Field in $RegFields) {
			Remove-ItemProperty -Path $RegPath -Name $Field -ErrorAction SilentlyContinue
		}
	}
}

# View
Function TweakViewAdobeEnhancedSecurity { # RESINFO
	Write-Output "Viewing Adobe EnhancedSecurity (Standalone and InBrowser) (0 or not exist: Disable, 1: Enable)..."
	$RegPath = 'HKLM:\Software\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
	$RegFields = @("bEnhancedSecurityStandalone", "bEnhancedSecurityInBrowser")
	$RegFields = @{
		bEnhancedSecurityStandalone = @{
			OkValues = @(1)
			Description = "Remote Assistance"
			Remediation = "EnableAdobeEnhancedSecurity (STIG V-213168)"
		}
		bEnhancedSecurityInBrowser = @{
			OkValues = @(1)
			Description = "Remote Assistance"
			Remediation = "EnableAdobeEnhancedSecurity (STIG V-213169)"
		}
	}
	SWMB_GetRegistrySettings -Path $RegPath -Rules $RegFields | SWMB_WriteSettings
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
