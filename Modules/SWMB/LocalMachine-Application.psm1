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
	Write-Output "View OneDrive product..."
	Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
		Get-ItemProperty |
		Where-Object {$_.DisplayName -like 'Microsoft OneDrive*' } |
		Select-Object -Property DisplayName, DisplayVersion, PSChildName
}

################################################################

# Uninstall default Microsoft applications
Function TweakUninstallMsftBloat {
	Write-Output "Uninstalling default Microsoft applications..."
	Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingFoodAndDrink" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingHealthAndFitness" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingMaps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingTranslator" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingTravel" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.FreshPaint" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.GetHelp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.HelpAndTips" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Media.PlayReadyClient.2" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Microsoft3DViewer" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MinecraftUWP" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MixedReality.Portal" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MoCamera" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.NetworkSpeedTest" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.OfficeLens" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Print3D" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Reader" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.RemoteDesktop" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Todos" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Wallet" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WebMediaExtensions" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Whiteboard" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
	Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsReadingList" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsScan" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WinJS.1.0" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WinJS.2.0" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.YourPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Advertising.Xaml" | Remove-AppxPackage # Dependency for microsoft.windowscommunicationsapps, Microsoft.BingWeather
}

# Install default Microsoft applications
Function TweakInstallMsftBloat {
	Write-Output "Installing default Microsoft applications..."
	Get-AppxPackage -AllUsers "Microsoft.3DBuilder" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Advertising.Xaml" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} # Dependency for microsoft.windowscommunicationsapps, Microsoft.BingWeather
	Get-AppxPackage -AllUsers "Microsoft.AppConnector" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingFinance" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingFoodAndDrink" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingHealthAndFitness" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingMaps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingNews" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingSports" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingTranslator" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingTravel" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingWeather" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.CommsPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ConnectivityStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.FreshPaint" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.GetHelp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Getstarted" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.HelpAndTips" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Media.PlayReadyClient.2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Messaging" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Microsoft3DViewer" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftPowerBIForWindows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftSolitaireCollection" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftStickyNotes" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MinecraftUWP" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MixedReality.Portal" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MoCamera" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MSPaint" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.NetworkSpeedTest" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.OfficeLens" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Office.OneNote" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Office.Sway" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.OneConnect" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.People" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Print3D" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Reader" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.RemoteDesktop" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.SkypeApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Todos" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Wallet" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WebMediaExtensions" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Whiteboard" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsAlarms" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsCamera" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.windowscommunicationsapps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsFeedbackHub" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsMaps" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Windows.Photos" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsReadingList" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsScan" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsSoundRecorder" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WinJS.1.0" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WinJS.2.0" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.YourPhone" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ZuneMusic" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ZuneVideo" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}
# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse

################################################################

# Uninstall default third party applications
Function TweakUninstallThirdPartyBloat {
	Write-Output "Uninstalling default third party applications..."
	Get-AppxPackage "2414FC7A.Viber" | Remove-AppxPackage
	Get-AppxPackage "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage
	Get-AppxPackage "46928bounde.EclipseManager" | Remove-AppxPackage
	Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
	Get-AppxPackage "64885BlueEdge.OneCalendar" | Remove-AppxPackage
	Get-AppxPackage "7EE7776C.LinkedInforWindows" | Remove-AppxPackage
	Get-AppxPackage "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage
	Get-AppxPackage "89006A2E.AutodeskSketchBook" | Remove-AppxPackage
	Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DragonManiaLegends" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.MarchofEmpires" | Remove-AppxPackage
	Get-AppxPackage "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.GettingStartedwithWindows8" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.HPJumpStart" | Remove-AppxPackage
	Get-AppxPackage "AD2F1837.HPRegistration" | Remove-AppxPackage
	Get-AppxPackage "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage
	Get-AppxPackage "Amazon.com.Amazon" | Remove-AppxPackage
	Get-AppxPackage "C27EB4BA.DropboxOEM" | Remove-AppxPackage
	Get-AppxPackage "CAF9E577.Plex" | Remove-AppxPackage
	Get-AppxPackage "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | Remove-AppxPackage
	Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
	Get-AppxPackage "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage
	Get-AppxPackage "DB6EA5DB.CyberLinkMediaSuiteEssentials" | Remove-AppxPackage
	Get-AppxPackage "DolbyLaboratories.DolbyAccess" | Remove-AppxPackage
	Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
	Get-AppxPackage "Facebook.Facebook" | Remove-AppxPackage
	Get-AppxPackage "Fitbit.FitbitCoach" | Remove-AppxPackage
	Get-AppxPackage "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage
	Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
	Get-AppxPackage "KeeperSecurityInc.Keeper" | Remove-AppxPackage
	Get-AppxPackage "king.com.BubbleWitch3Saga" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushFriends" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSaga" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
	Get-AppxPackage "king.com.FarmHeroesSaga" | Remove-AppxPackage
	Get-AppxPackage "Nordcurrent.CookingFever" | Remove-AppxPackage
	Get-AppxPackage "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage
	Get-AppxPackage "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | Remove-AppxPackage
	Get-AppxPackage "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
	Get-AppxPackage "ThumbmunkeysLtd.PhototasticCollage" | Remove-AppxPackage
	Get-AppxPackage "WinZipComputing.WinZipUniversal" | Remove-AppxPackage
	Get-AppxPackage "XINGAG.XING" | Remove-AppxPackage
}

# Install default third party applications
Function TweakInstallThirdPartyBloat {
	Write-Output "Installing default third party applications..."
	Get-AppxPackage -AllUsers "2414FC7A.Viber" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "41038Axilesoft.ACGMediaPlayer" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "46928bounde.EclipseManager" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "4DF9E0F8.Netflix" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "64885BlueEdge.OneCalendar" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "7EE7776C.LinkedInforWindows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "828B5831.HiddenCityMysteryofShadows" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "89006A2E.AutodeskSketchBook" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "9E2F88E3.Twitter" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "A278AB0D.DisneyMagicKingdoms" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "A278AB0D.DragonManiaLegends" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "A278AB0D.MarchofEmpires" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "ActiproSoftwareLLC.562882FEEB491" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "AD2F1837.GettingStartedwithWindows8" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "AD2F1837.HPJumpStart" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "AD2F1837.HPRegistration" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "AdobeSystemsIncorporated.AdobePhotoshopExpress" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Amazon.com.Amazon" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "C27EB4BA.DropboxOEM" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "CAF9E577.Plex" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "D52A8D61.FarmVille2CountryEscape" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "D5EA27B7.Duolingo-LearnLanguagesforFree" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "DB6EA5DB.CyberLinkMediaSuiteEssentials" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "DolbyLaboratories.DolbyAccess" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Drawboard.DrawboardPDF" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Facebook.Facebook" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Fitbit.FitbitCoach" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "flaregamesGmbH.RoyalRevolt2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "GAMELOFTSA.Asphalt8Airborne" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "KeeperSecurityInc.Keeper" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.BubbleWitch3Saga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.CandyCrushFriends" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.CandyCrushSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.CandyCrushSodaSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.FarmHeroesSaga" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Nordcurrent.CookingFever" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "PandoraMediaInc.29680B314EFC2" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "SpotifyAB.SpotifyMusic" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "ThumbmunkeysLtd.PhototasticCollage" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "WinZipComputing.WinZipUniversal" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "XINGAG.XING" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

################################################################

# Uninstall Windows Store
Function TweakUninstallWindowsStore {
	Write-Output "Uninstalling Windows Store..."
	Get-AppxPackage "Microsoft.DesktopAppInstaller" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Services.Store.Engagement" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.StorePurchaseApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsStore" | Remove-AppxPackage
}

# Install Windows Store
Function TweakInstallWindowsStore {
	Write-Output "Installing Windows Store..."
	Get-AppxPackage -AllUsers "Microsoft.DesktopAppInstaller" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Services.Store.Engagement" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.StorePurchaseApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

################################################################

# Disable Xbox features - Not applicable to Server
Function TweakDisableXboxFeatures {
	Write-Output "Disabling Xbox features. See DisableXboxFeatures_CU..."
	Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -ErrorAction SilentlyContinue
	Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
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
	Get-AppxPackage -AllUsers "Microsoft.XboxApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxIdentityProvider" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxSpeechToTextOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxGameOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxGamingOverlay" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Xbox.TCUI" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
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
	Write-Output "Clear Edge cache on exit..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -Type DWord -Value 1
}

# Disable - Default
# Do not clear Edge cached images and files on exit
Function TweakDisableEdgeClearCacheOnExit { # RESINFO
	Write-Output "Don't clear Edge cache on exit..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeClearCacheOnExit { # RESINFO
	Write-Output "View Edge clear cache on exit (0 or not exist: Not clear, 1: Clear cached images and files on exit )"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ClearCachedImagesAndFilesOnExit" -ErrorAction SilentlyContinue
}

################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.MicrosoftEdge::AllowDoNotTrack
# Enable Do Not Tracker
Function TweakEnableEdgeDoNtoTrack { # RESINFO
	Write-Output "Do Not Tracker requests are sent to websites asking for tracking info..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -Type DWord -Value 1
}

# Default
# By default, Do Not Track requests aren't sent, but employees can choose to turn on and send requests
Function TweakDisableEdgeDoNtoTrack { # RESINFO
	Write-Output "Don't Configure Do Not Track..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -ErrorAction SilentlyContinue
}

# View
Function TweakViewEdgeDoNtoTrack { # RESINFO
	Write-Output "View Edge Configure Do Not Track (0:Do Not Tracker requests are always sent to websites asking for tracking info, 1:Do Not Track requests are never sent to websites asking for tracking info, error: Default )"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\" -Name "ConfigureDoNotTrack" -ErrorAction SilentlyContinue
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
	Write-Output "Wiew Edge auto update (0 or not exist: Auto update, 1: No update)"
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
	Write-Output "Disabling Internet Explorer first run wizard..."
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
	Write-Output "Adding Photo Viewer to 'Open with...'"
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
	Write-Output "Removing Photo Viewer from 'Open with...'"
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
	Write-Output "View Visual Studio Cache (0: disable, 1: enable (default), nothing: not install..."
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
	Write-Output "Allow Storage sense...and Configure Storage Sense cadence $($Global:SWMB_Custom.StorageSenseCadence) day"
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseGlobal" -Type DWord -Value 1
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseGlobalCadence" -Type DWord -Value $Global:SWMB_Custom.StorageSenseCadence
}

# Not Configured:
# By default, Storage Sense is turned off until the user runs into low disk space or the user enables it manually. Users can configure this setting in Storage settings.
Function TweakDisableStorageSense { # RESINFO
	Write-Output "Storage Sense Not Configured"
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -ErrorAction SilentlyContinue
}

# View
Function TweakViewStorageSense { # RESINFO
	Write-Output "View if Storage Sense is turned on for the machine"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseGlobal" -ErrorAction SilentlyContinue
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseGlobalCadence" -ErrorAction SilentlyContinue
}

################################################################

# Allow storage sense tempory files Cleanup
# Storage Sense will delete the user's temporary files that are not in use. Users cannot disable this setting in Storage settings.
Function TweakEnableStorageSenseTempCleanup { # RESINFO
	Write-Output "Allow Storage sense Temporary Files Cleanup"
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -Type DWord -Value 1
}

# Disabled:
# Storage Sense will not delete the user's temporary files. Users cannot enable this setting in Storage settings.
Function TweakDisableStorageSenseTempCleanup { # RESINFO
	Write-Output "Disable Storage sense Temporary Files Cleanup"
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -Type DWord -Value 0
}

# View
Function TweakViewStorageSenseTempCleanup { # RESINFO
	Write-Output "View if Storage Sense Temporary Files Cleanup is turned on"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseTemporaryFilesCleanup" -ErrorAction SilentlyContinue
}

################################################################

# Configure Storage Sense Recycle Bin cleanup threshold
# minimum age threshold (in days) of a file in the Recycle Bin before Storage Sense will delete it
Function TweakEnableStorageSenseTrashCleanup { # RESINFO
	Write-Output "Files in the recycle bin that are more than $($Global:SWMB_Custom.StorageSenseTrashCleanup) days old will be deleted automatically"
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -Type DWord -Value $Global:SWMB_Custom.StorageSenseTrashCleanup
}

# Disabled:
# By default, Storage Sense will delete files in the user's Recycle Bin that have been there for over 30 days.
Function TweakDisableStorageSenseTrashCleanup { # RESINFO
	Write-Output "Disable Storage sense Temporary Files Cleanup"
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -ErrorAction SilentlyContinue
}

# View
Function TweakViewStorageSenseTrashCleanup { # RESINFO
	Write-Output "View Storage Sense Bin automatically Cleanup"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "ConfigStorageSenseRecycleBinCleanupThreshold" -ErrorAction SilentlyContinue
}

################################################################

# Disable
Function TweakDisableWindowsCopilot { # RESINFO
	Write-Output "Turn Off Windows Copilot..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot")) {
		New-Item -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
}

# Enable Copilot
Function TweakEnableWindowsCopilot { # RESINFO
	Write-Output "Turn On for Windows Copilot (Default)..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
}

# View Copilot
Function TweakViewWindowsCopilot { # RESINFO
	Write-Output "View Windows Copilot"
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
}

################################################################

# Computer Configuration / Administrative Templates / Windows Components / News and interests
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Feeds::EnableFeeds&Language=fr-fr
# https://www.tenforums.com/tutorials/178178-how-enable-disable-news-interests-taskbar-windows-10-a.html
# Disable
Function TweakDisableWindowsFeeds { # RESINFO
	Write-Output "Turn off windows feeds (news and interests)..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
}

# Enable
Function TweakEnableWindowsFeeds { # RESINFO
	Write-Output "Turn on windows feeds (news and interests)..."
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
	Write-Output "Block Windows Hello Authentification..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions" -Name "value" -Type DWord -Value 0
}

# Enable
Function TweakEnableWindowsHello { # RESINFO
	Write-Output "Enable Windows Hello Authentification..."
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
	Write-Output "Disable PrivateStoreOnly..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RequirePrivateStoreOnly" -Type DWord -Value 0
}

# Enable
Function TweakEnablePrivateStoreOnly { # RESINFO
	Write-Output "Enable PrivateStoreOnly..."
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
	Write-Output "Disable Windows Store..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Type DWord -Value 1
}

# Enable
Function TweakEnableWindowsStoreAccess { # RESINFO
	Write-Output "Enable Windows Store..."
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
	Write-Output "Disable StoreApps..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "DisableStoreApps" -Type DWord -Value 1
}

# Enable
Function TweakEnableStoreApps { # RESINFO
	Write-Output "Enable StoreApps..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "DisableStoreApps" -Type DWord -Value 0
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
