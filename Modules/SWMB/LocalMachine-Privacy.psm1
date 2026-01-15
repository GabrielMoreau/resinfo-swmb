##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Privacy Tweaks
##########

################################################################

# Disable Telemetry
# Note: This tweak also disables the possibility to join Windows Insider Program and breaks Microsoft Intune enrollment/deployment, as these feaures require Telemetry data.
# Windows Update control panel may show message "Your device is at risk because it's out of date and missing important security and quality updates. Let's get you back on track so Windows can run more securely. Select this button to get going".
# In such case, enable telemetry, run Windows update and then disable telemetry again.
# See also https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/57 and https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/92
Function TweakDisableTelemetry {
	Write-Output "Disabling Telemetry..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Name "NoGenTicket" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP" -Name "CEIPEnable" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Type DWord -Value 0
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Microsoft Compatibility Appraiser"}) { Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "ProgramDataUpdater"}) {Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Proxy"}) {Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Consolidator"}) {Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "UsbCeip"}) {Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Microsoft-Windows-DiskDiagnosticDataCollector"}) {Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null}
	# Office 2016 / 2019
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Office ClickToRun Service Monitor"}) {Disable-ScheduledTask -TaskName "Microsoft\Office\Office ClickToRun Service Monitor" -ErrorAction SilentlyContinue | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "OfficeTelemetryAgentFallBack2016"}) {Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentFallBack2016" -ErrorAction SilentlyContinue | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "OfficeTelemetryAgentLogOn2016"}) {Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentLogOn2016" -ErrorAction SilentlyContinue | Out-Null}
}

# Enable Telemetry
Function TweakEnableTelemetry {
	Write-Output "Enabling Telemetry..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Name "NoGenTicket" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP" -Name "CEIPEnable" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -ErrorAction SilentlyContinue
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Microsoft Compatibility Appraiser"}) {Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "ProgramDataUpdater"}) {Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Proxy"}) {Enable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Consolidator"})  {Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "UsbCeip"}) {Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Microsoft-Windows-DiskDiagnosticDataCollector"}) {Enable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null}
	# Office 2016 / 2019
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "Office ClickToRun Service Monitor"}) {Enable-ScheduledTask -TaskName "Microsoft\Office\Office ClickToRun Service Monitor" -ErrorAction SilentlyContinue | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "OfficeTelemetryAgentFallBack2016"}) {Enable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentFallBack2016" -ErrorAction SilentlyContinue | Out-Null}
	If (Get-ScheduledTask | Where-Object {$_.Taskname -eq "OfficeTelemetryAgentLogOn2016"}) {Enable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentLogOn2016" -ErrorAction SilentlyContinue | Out-Null}
}

################################################################

# Disable Cortana
Function TweakDisableCortana {
	Write-Output "Disabling Cortana. See DisableCortana_CU..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Type DWord -Value 0
	Get-AppxPackage -AllUsers -Name "Microsoft.549981C3F5F10" | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Enable Cortana
Function TweakEnableCortana {
	Write-Output "Enabling Cortana. See EnableCortana_CU..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name "Value" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers -Name "Microsoft.549981C3F5F10" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

################################################################

# Recall is a feature that allows you to quickly access your documents, applications, and personal information through indexing
# Disable Disable-WindowsOptionalFeature -Online -FeatureName "Recall" -Norestart -WarningAction SilentlyContinue
# Enable   Enable-WindowsOptionalFeature -online -FeatureName "Recall" -NoRestart -WarningAction SilentlyContinue
# View     Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -eq 'Recall'}
# https://www.malekal.com/desactiver-recall-windows-11/
# https://www.justgeek.fr/windows-11-desactiver-recall-141674/

# Disable Recall
Function TweakDisableRecall { # RESINFO
	Write-Output "Disabling Recall..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall" -Name "AllowRecall" -Type DWord -Value 0
}

# Enable Recall
Function TweakEnableRecall { # RESINFO
	Write-Output "Enabling Recall..."
	Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall" -Force -ErrorAction SilentlyContinue | Out-Null
}

# View
Function TweakViewRecall { # RESINFO
	Write-Output "Viewing Recall (0: Disable, 1 or not exist: Enable)..."
	If (!(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall')) {
		Write-Output ' Recall is enabled'
		Return
		}

	Try {
		Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall' -Name 'AllowRecall' | Out-Null
	} Catch {
		Write-Output ' Recall not exists: enable'
		Return
	}
	ForEach ($Field in 'AllowRecall') {
		Write-Output " ${Field}: $((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Recall').${Field})"
	}
}

################################################################

# Disable Wi-Fi Sense
Function TweakDisableWiFiSense {
	Write-Output "Disabling Wi-Fi Sense..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type DWord -Value 0
}

# Enable Wi-Fi Sense
Function TweakEnableWiFiSense {
	Write-Output "Enabling Wi-Fi Sense..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -ErrorAction SilentlyContinue
}

################################################################

# Disable SmartScreen Filter
Function TweakDisableSmartScreen {
	Write-Output "Disabling SmartScreen Filter..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
}

# Enable SmartScreen Filter
Function TweakEnableSmartScreen {
	Write-Output "Enabling SmartScreen Filter..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -ErrorAction SilentlyContinue
}

################################################################

# https://admx.help/?Category=Windows_11_2022&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::DisableWebSearch
# Disable Web Search in Start Menu
Function TweakDisableWebSearch {
	Write-Output "Disabling Bing Search in Start Menu. See DisableWebSearch_CU..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
}

# Enable Web Search in Start Menu
Function TweakEnableWebSearch {
	Write-Output "Enabling Bing Search in Start Menu. See EnableWebSearch_CU..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -ErrorAction SilentlyContinue
}

################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::AllowSearchHighlights
# Disable search highlights
Function TweakDisableHighlightsSearch { # RESINFO
	Write-Output "Disabling search highlights..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -Type DWord -Value 0
}

# Enable search highlights
Function TweakEnableHighlightsSearch { # RESINFO
	Write-Output "Enabling (Allow) search highlights..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -ErrorAction SilentlyContinue
}

# View
Function TweakViewHighlightsSearch { # RESINFO
	Write-Output "Viewing Highlights Search (1: Disable, Error: Not configured = Enable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB"
}

################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::AllowCloudSearch
# Disable Cloud Search
Function TweakDisableCloudSearch { # RESINFO
	Write-Output "Disabling Cloud Search..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -Type DWord -Value 0
}

# Enable Cloud Search
Function TweakEnableCloudSearch { # RESINFO
	Write-Output "Enabling (Allow) Cloud Search..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -ErrorAction SilentlyContinue
}

# View
Function TweakViewCloudSearch { # RESINFO
	Write-Output "Viewing Cloud Search (0: Disable, Error: Not configured = Enable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch"
}


################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::AllowSearchToUseLocation
# Don't allow search and Cortana to use location
Function TweakDisableSearchUseLocation { # RESINFO
	Write-Output "Disabling Search and Cortana are disallowed to use location..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0
}

# Enable search and Cortana to use location
Function TweakEnableSearchUseLocation { # RESINFO
	Write-Output "Enabling (Allow) Search and Cortana to use location..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -ErrorAction SilentlyContinue
}

# View
Function TweakViewSearchUseLocation { # RESINFO
	Write-Output "Viewing search and Cortana to use location (0: Disable, Error: Not configured = Enable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation"
}


################################################################

## WARNING NOT RECOMMANDED - disable search start menu
## Search on Taskbar and Start Menu for All Users
# Disable
Function TweakDisableSearchOnTaskbar { # RESINFO
	Write-Output "Disabling Search on Taskbar and Start Menu for All Users..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch" -Name "value" -Type DWord -Value 1

	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableSearch" -Type DWord -Value 1
}

# Enable
Function TweakEnableSearchOnTaskbar { # RESINFO
	Write-Output "Enabling Search on Taskbar and Start Menu for All Users..."
	If (Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch") {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch" -Name "value" -Type DWord -Value 0
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableSearch" -ErrorAction SilentlyContinue
	}
}

# View
Function TweakViewSearchOnTaskbar { # RESINFO
	Write-Output "Viewing search on taskbar (0: Disable, Error: Not configured = Enable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableSearch"
}

################################################################

# Disable Application suggestions and automatic installation
Function TweakDisableAppSuggestions {
	Write-Output "Disabling Application suggestions. See DisableAppSuggestions_CU..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -Type DWord -Value 0
}

# Enable Application suggestions and automatic installation
Function TweakEnableAppSuggestions {
	Write-Output "Enabling Application suggestions. See EnableAppSuggestions_CU..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -ErrorAction SilentlyContinue
}

################################################################

# Disable Activity History feed in Task View
# Note: The checkbox "Let Windows collect my activities from this PC" remains checked even when the function is disabled
Function TweakDisableActivityHistory {
	Write-Output "Disabling Activity History..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
}

# Enable Activity History feed in Task View
Function TweakEnableActivityHistory {
	Write-Output "Enabling Activity History..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -ErrorAction SilentlyContinue
}

# View
Function TweakViewActivityHistory {
	Write-Output "Viewing Activity History (0: Disable, Error: Enable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed"    | Select-Object -Property Enable*  | Format-List
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" | Select-Object -Property Publish* | Format-List
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities"  | Select-Object -Property Upload*  | Format-List
}

################################################################

# Disable sensor features, such as screen auto rotation
Function TweakDisableSensors {
	Write-Output "Disabling sensors..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -Type DWord -Value 1
}

# Enable sensor features
Function TweakEnableSensors {
	Write-Output "Enabling sensors..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -ErrorAction SilentlyContinue
}

################################################################

# Disable location feature and scripting for the location feature
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Sensors::DisableLocationScripting_2
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Sensors::DisableLocation_2
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Sensors.WindowsLocationProvider::DisableWindowsLocationProvider_1
Function TweakDisableLocation { # RESINFO
	Write-Output "Disabling location services..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -Type DWord -Value 1
}

# Enable location feature and scripting for the location feature
Function TweakEnableLocation { # RESINFO
	Write-Output "Enabling location services..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -ErrorAction SilentlyContinue

}

################################################################

# Disable automatic Maps updates
Function TweakDisableMapUpdates {
	Write-Output "Disabling automatic Maps updates..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
}

# Enable automatic Maps updates
Function TweakEnableMapUpdates {
	Write-Output "Enabling automatic Maps updates..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -ErrorAction SilentlyContinue
}

################################################################

# Begin KeyFeedback
# Disable Windows Feedback notifications through the Windows Feedback app
# ANSSI Annexe A1
# Configuration ordinateur / Modèles d'administration / Composants Windows / Collecte des données et versions d'évaluation Preview / Ne plus afficher les notifications de commentaires
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.FeedbackNotifications::DoNotShowFeedbackNotifications&Language=fr-fr#
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.FeedbackNotifications::DoNotShowFeedbackNotifications
# End

# Disable Feedback
Function TweakDisableFeedback {
	Write-Output "Disabling Windows Feedback. See DisableFeedback_CU..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
	# HKCU or HKLM ?
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

# Enable Feedback
Function TweakEnableFeedback {
	Write-Output "Enabling Windows Feedback. See EnableFeedback_CU..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

################################################################

# Limit Diagnostic Log Collection
# https://admx.help/?Category=Windows_11_2022&Policy=Microsoft.Policies.DataCollection::LimitDiagnosticLogCollection
# Disable DiagnosticLogs
Function TweakDisableDiagnosticLogs { # RESINFO
	Write-Output "Disabling Diagnostic Logs: Diagnostic logs will not be collected..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "LimitDiagnosticLogCollection" -Type DWord -Value 1
}

# Enable DiagnosticLogs
Function TweakEnableDiagnosticLogs { # RESINFO
	Write-Output "Enabling Diagnostic Logs: Collect diagnostic log not configured..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "LimitDiagnosticLogCollection" -ErrorAction SilentlyContinue
}

# View DiagnosticLogs
Function TweakViewDiagnosticLogs { # RESINFO
	Write-Output "Viewing Collect diagnostic log (error => not configured, 1 => Diagnostic logs not be collected)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "LimitDiagnosticLogCollection"  | Format-List
}

################################################################

# Disable OneSettings Downloads
# https://admx.help/?Category=Windows_11_2022&Policy=Microsoft.Policies.DataCollection::DisableOneSettingsDownloads
Function TweakDisableOneSettingsDownloads { # RESINFO
	Write-Output "Disabling download configuration settings from the OneSettings service..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DisableOneSettingsDownloads" -Type DWord -Value 1
}

# Enable OneSettings Downloads
Function TweakEnableOneSettingsDownloads { # RESINFO
	Write-Output "Enabling download configuration settings from the OneSettings service (not configured)..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DisableOneSettingsDownloads" -ErrorAction SilentlyContinue
}

# View OneSettings Downloads
Function TweakViewOneSettingsDownloads { # RESINFO
	Write-Output "Viewing Download configuration settings from the OneSettings service (error => not configured, 1 => Disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DisableOneSettingsDownloads"  | Format-List
}

################################################################


# Disable Advertising ID
Function TweakDisableAdvertisingID {
	Write-Output "Disabling Advertising ID..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
}

# Enable Advertising ID
Function TweakEnableAdvertisingID {
	Write-Output "Enabling Advertising ID..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -ErrorAction SilentlyContinue
}

################################################################

# Disable biometric features
# Note: If you log on using biometrics (fingerprint, Windows Hello etc.) it's recommended to create a password recovery disk before applying this tweak.
Function TweakDisableBiometrics {
	Write-Output "Disabling biometric services..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" -Name "Enabled" -Type DWord -Value 0
}

# Enable biometric features
Function TweakEnableBiometrics {
	Write-Output "Enabling biometric services..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" -Name "Enabled" -ErrorAction SilentlyContinue
}

################################################################

# Disable access to camera
# Note: This disables access using standard Windows API. Direct access to device will still be allowed.
Function TweakDisableCamera {
	Write-Output "Disabling access to camera..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCamera" -Type DWord -Value 2
}

# Enable access to camera
Function TweakEnableCamera {
	Write-Output "Enabling access to camera..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCamera" -ErrorAction SilentlyContinue
}

################################################################

# Disable access to microphone
# Note: This disables access using standard Windows API. Direct access to device will still be allowed.
Function TweakDisableMicrophone {
	Write-Output "Disabling access to microphone..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMicrophone" -Type DWord -Value 2
}

# Enable access to microphone
Function TweakEnableMicrophone {
	Write-Output "Enabling access to microphone..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMicrophone" -ErrorAction SilentlyContinue
}

################################################################

# Disable Error reporting
Function TweakDisableErrorReporting {
	Write-Output "Disabling Error reporting..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
}

# Enable Error reporting
Function TweakEnableErrorReporting {
	Write-Output "Enabling Error reporting..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
}

################################################################

# Restrict Windows Update P2P delivery optimization to computers in local network - Default since 1703
Function TweakSetP2PUpdateLocal {
	Write-Output "Setting P2P: Restricting Windows Update P2P optimization to local network..."
	If ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
	} ElseIf ([System.Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 1
	} Else {
		# Method used since 1703
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
	}
}

# Unrestrict Windows Update P2P delivery optimization to both local networks and internet - Default in 1507 - 1607
Function TweakSetP2PUpdateInternet {
	Write-Output "Setting P2P: Unrestricting Windows Update P2P optimization to internet..."
	If ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 3
	} ElseIf ([System.Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
	} Else {
		# Method used since 1703
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 3
	}
}

# Disable Windows Update P2P delivery optimization completely
# Warning: Completely disabling delivery optimization can break Windows Store downloads - see https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/281
Function TweakSetP2PUpdateDisable {
	Write-Output "Setting P2P: Disabling Windows Update P2P optimization..."
	If ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0
	} Else {
		# Method used since 1511
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 100
	}
}

################################################################

# Begin KeyDiagTrack
# ANSSI Annexe A2
# Service Expérience des utilisateurs connectés et télémetrie / Connected User Experiences and Telemetry - Diagtrack
# Stop and disable (or Enable and start) Connected User Experiences and Telemetry (previously named Diagnostics Tracking Service)
# End

# Stop and disable Connected User Experiences and Telemetry (previously named Diagnostics Tracking Service)
Function TweakDisableDiagTrack {
	Write-Output "Disabling and Stopping Connected User Experiences and Telemetry Service..."
	Stop-Service "DiagTrack" -WarningAction SilentlyContinue
	Set-Service "DiagTrack" -StartupType Disabled
}

# Enable and start Connected User Experiences and Telemetry (previously named Diagnostics Tracking Service)
Function TweakEnableDiagTrack {
	Write-Output "Enabling and starting Connected User Experiences and Telemetry Service ..."
	Set-Service "DiagTrack" -StartupType Automatic
	Start-Service "DiagTrack" -WarningAction SilentlyContinue
}

# View
Function TweakViewDiagTrack {
	Write-Output "Viewing Connected User Experiences and Telemetry (2 activated, 4 no)..."
	Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack" -Name "Start" | Select-Object -Property Start*  | Format-List
}

################################################################

# Stop and disable Device Management Wireless Application Protocol (WAP) Push Service
# Note: This service is needed for Microsoft Intune interoperability
Function TweakDisableWAPPush {
	Write-Output "Disabling and Stopping Device Management WAP Push Service..."
	Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
	Set-Service "dmwappushservice" -StartupType Disabled
}

# Enable and start Device Management Wireless Application Protocol (WAP) Push Service
Function TweakEnableWAPPush {
	Write-Output "Enabling and Starting Device Management WAP Push Service..."
	Set-Service "dmwappushservice" -StartupType Automatic
	Start-Service "dmwappushservice" -WarningAction SilentlyContinue
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1
}

################################################################

# Enable clearing of recent files on exit
# Empties most recently used (MRU) items lists such as 'Recent Items' menu on the Start menu, jump lists, and shortcuts at the bottom of the 'File' menu in applications during every logout.
Function TweakEnableClearRecentFiles {
	Write-Output "Enabling clearing of recent files on exit..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ClearRecentDocsOnExit" -Type DWord -Value 1
}

# Disable clearing of recent files on exit
Function TweakDisableClearRecentFiles {
	Write-Output "Disabling clearing of recent files on exit..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ClearRecentDocsOnExit" -ErrorAction SilentlyContinue
}

################################################################

# Disable recent files lists
# Stops creating most recently used (MRU) items lists such as 'Recent Items' menu on the Start menu, jump lists, and shortcuts at the bottom of the 'File' menu in applications.
Function TweakDisableRecentFiles {
	Write-Output "Disabling recent files lists..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Type DWord -Value 1
}

# Enable recent files lists
Function TweakEnableRecentFiles {
	Write-Output "Enabling recent files lists..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -ErrorAction SilentlyContinue
}

###############################################################

# From BSI document
# La session "Autologger-DiagTrack-Listener" doit être désactivée en mettant sa clé de registre à zéro
# Par défaut cette clé ne semble pas exister, on l'efface donc en fonction Disable, comme avant

# Disable
Function TweakDisableAutologgerDiagTrack { # RESINFO
	Write-Output "Disabling Autologger-DiagTrack-Listener..."
	If (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener") {
		Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" -Force -ErrorAction SilentlyContinue | Out-Null
	}
}

# Enable
Function TweakEnableAutologgerDiagTrack { # RESINFO
	Write-Output "Enabling Autologger-DiagTrack-Listener..."
	If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener")) {
		New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 2
}

# View
Function TweakViewAutologgerDiagTrack { # RESINFO
	Write-Output "Viewing Autologger-DiagTrack-Listener (0 no or not exist, 2 activated)..."
	Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" -Name "Start"
}

################################################################

# Cortana and search
# Configuration ordinateur / Modèles d'administration / Composants Windows / Rechercher / Autoriser Cortona au-dessus de l'écran de verouillage / desactivé
# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::AllowCortanaAboveLock&Language=fr-fr
# ANSSI Annexe B1
Function TweakDisableCortanaAboveLock { # RESINFO
	Write-Output "Disabling Cortana AboveLock..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Type DWord -Value 0
}

# Enable
Function TweakEnableCortanaAboveLock { # RESINFO
	Write-Output "Enabling Cortana AboveLock..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Type DWord -Value 1
}

################################################################

# Cortana and search
# Configuration ordinateur / Modèles d'administration / Composants Windows / Rechercher / Autoriser l'indexation des fichiers chiffrés / desactivé
# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::AllowIndexingEncryptedStoresOrItems
# ANSSI Annexe B1
Function TweakDisableIndexingEncryptedStores { # RESINFO
	Write-Output "Disabling IndexingEncryptedStores..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowIndexingEncryptedStoresOrItems" -Type DWord -Value 0
}

# Enable
Function TweakEnableIndexingEncryptedStores { # RESINFO
	Write-Output "Enabling IndexingEncryptedStores..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowIndexingEncryptedStoresOrItems" -Type DWord -Value 1
}

################################################################

# Cortana and search
# Configuration ordinateur / Modèles d'administration / Composants Windows / Rechercher / Définir quelles informations sont partagées dans search / activé type => informations anonymes
# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::SearchPrivacy
# ANSSI Annexe B1
Function TweakDisableSharedInformationSearch { # RESINFO
	Write-Output "Disabling Shared Information: Anonymous information is shared in Search..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchPrivacy" -Type DWord -Value 3
}

# Enable
Function TweakEnableSharedInformationSearch { # RESINFO
	Write-Output "Enabling Shared Information: User info and location is shared in Search..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchPrivacy" -Type DWord -Value 1
}

################################################################

# Cortana and search
# Configuration ordinateur / Modèles d'administration / Composants Windows / Rechercher / Ne pas effectuer des rechechers sur le web ou afficher dse résultats Web dans search / activé
# https://admx.help/?Category=Windows_10_2016&Policy=FullArmor.Policies.3B9EA2B5_A1D1_4CD5_9EDE_75B22990BC21::DoNotUseWebResults
# ANSSI Annexe B1
Function TweakDisableDisplayWebResults { # RESINFO
	Write-Output "Disabling search the web or display web results in Search..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
}

# Enable
Function TweakEnableDisplayWebResults { # RESINFO
	Write-Output "Enabling Web results will be displayed ..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 1
}
################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / Rapport d'erreurs Windows / Envoyer automatiquement des images mémoires pour les rapports
# key AutoApproveOSDumps
# https://admx.help/?Category=Windows_8.1_2012R2&Policy=Microsoft.Policies.WindowsErrorReporting::WerAutoApproveOSDumps_2
# GPO Desactivé par défaut
# Disable
Function TweakDisableOsGeneratedReport { # RESINFO
	Write-Output "Disabling (Turn Off) OS-generated error reports..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "AutoApproveOSDumps" -Type DWord -Value 0
}

# Enable
Function TweakEnableOsGeneratedReport { # RESINFO
	Write-Output "Enabling (Turn On) OS-generated error reports..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "AutoApproveOSDumps" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / Rapport d'erreurs Windows / Ne pas envoyer des données complémentaires
# key DontSendAdditionalData
# https://admx.help/?Category=Windows_8.1_2012R2&Policy=Microsoft.Policies.WindowsErrorReporting::WerNoSecondLevelData_2
# GPO activé par défaut
# Disable
Function TweakDisableSendAdditionalData { # RESINFO
	Write-Output "Disabling Error reporting Send Additional Data..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "DontSendAdditionalData" -Type DWord -Value 1
}

# Enable
Function TweakEnableSendAdditionalData { # RESINFO
	Write-Output "Enabling Error reporting Send Additional Data..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "DontSendAdditionalData" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Panneau de Configuration / Options Regionales et Linguistiques / Personnalisation de l'écriture manuscrite / Désactiver l’apprentissage automatique / Activé
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.Globalization::ImplicitDataCollectionOff_2
# Disable
Function TweakDisableAutomaticLearning { # RESINFO
	Write-Output "Disabling (Turn Off) automatic learning..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
}

# Enable
Function TweakEnableAutomaticLearning { # RESINFO
	Write-Output "Enabling (Turn On) automatic learning..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
}

################################################################

# User Experience
# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4727
# Disable
Function TweakDisableWindowsErrorReporting { # RESINFO
	Write-Output "Disabling (Turn Off) Windows error reporting..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting\")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "DoReport" -Type DWord -Value 0
}

# Enable
Function TweakEnableWindowsErrorReporting { # RESINFO
	Write-Output "Enabling (Turn On) Windows error reporting..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting" -Name "DoReport" -ErrorAction SilentlyContinue
}
################################################################

# User Experience
### Désactiver les questions pour chaque nouvel utilisateur
# Computer Configuration\Administrative Templates\Windows Components\OOBE
# https://docs.microsoft.com/fr-fr/windows/client-management/mdm/policy-csp-privacy#privacy-disableprivacyexperience
# Disable
Function TweakDisablePrivacyExperience { # RESINFO
	Write-Output "Disabling privacy experience from launching during user logon for new and upgraded users..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Type DWord -Value 1
}

# Enable
Function TweakEnablePrivacyExperience { # RESINFO
	Write-Output "Enabling privacy experience from launching during user logon for new and upgraded users..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

# User Experience
### Enregistreur d'actions utilisateur
# https://support.microsoft.com/en-us/help/22878/windows-10-record-steps
# Disable
Function TweakDisableStepsRecorder { # RESINFO
	Write-Output "Disabling Windows steps recorder..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
}

# Enable
Function TweakEnableStepsRecorder { # RESINFO
	Write-Output "Enabling Windows steps recorder..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -ErrorAction SilentlyContinue
}

################################################################

# User Experience
# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4723
# Disable
Function TweakDisableDidYouKnow { # RESINFO
	Write-Output "Disabling (Turn Off) Help and Support Center Did you know? content..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 1
}

# Enable
Function TweakEnableDidYouKnow { # RESINFO
	Write-Output "Enabling (Turn On) Help and Support Center Did you know? content..."
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

# User Experience
# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4754
# Disable
Function TweakDisableHandwritingDataSharing { # RESINFO
	Write-Output "Disabling (Turn Off) handwriting personalization data sharing..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1
}

# Enable
Function TweakEnableHandwritingDataSharing { # RESINFO
	Write-Output "Enabling (Turn On) handwriting personalization data sharing..."
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

# User Experience
# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4743
# Disable
Function TweakDisableHandwritingRecognitionErrorReporting { # RESINFO
	Write-Output "Disabling (Turn Off) handwriting recognition error reporting..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "PreventHandwritingErrorReports" -Type DWord -Value 1
}

# Enable
Function TweakEnableHandwritingRecognitionErrorReporting { # RESINFO
	Write-Output "Enabling (Turn On) handwriting recognition error reporting..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "PreventHandwritingErrorReports" -ErrorAction SilentlyContinue
}

################################################################

# Telemetry
# Configuration ordinateur / Modèles d'administration / Composants Windows /Antivirus Windows Defender / MAPS / Configurer une valeur de remplacement de paramètre locale pour l'envoi de rapports à Microsoft MAPS / Desactivé
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsDefender::Spynet_LocalSettingOverrideSpynetReporting&Language=fr-fr
# Disable
Function TweakDisableOverrideReportingMAPS { # RESINFO
	Write-Output "Disabling override for reporting to Microsoft MAPS..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "LocalSettingOverrideSpynetReporting" -Type DWord -Value 0
}

# Enable
Function TweakEnableOverrideReportingMAPS { # RESINFO
	Write-Output "Enabling override for reporting to Microsoft MAPS..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "LocalSettingOverrideSpynetReporting" -Type DWord -Value 1 -ErrorAction SilentlyContinue
}

################################################################

# Telemetry
# ANSSI Annexe A3
# https://admx.help/?Category=Windows10_Telemetry&Policy=Microsoft.Policies.Win10Privacy::DontReportInfection
# Disable
Function TweakDisableMRTReportInfectionInformation { # RESINFO
	Write-Output "Disabling Malicious Software Reporting tool diagnostic data..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontReportInfectionInformation" -Type DWord -Value 1
}

# Enable
Function TweakEnableMRTReportInfectionInformation { # RESINFO
	Write-Output "Enabling Malicious Software Reporting tool diagnostic data..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontReportInfectionInformation" -ErrorAction SilentlyContinue
}

################################################################

# Bluetooth advertising
# https://en.wikipedia.org/wiki/Bluetooth_advertising
# Disable
Function TweakDisableBluetoothAdvertising { # RESINFO
	Write-Output "Disabling Bluetooth advertising..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth\")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth\" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth\" -Name "AllowAdvertising" -Type DWord -Value 0
}

# Enable
Function TweakEnableBluetoothAdvertising { # RESINFO
	Write-Output "Enabling Bluetooth advertising..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth\" -Name "AllowAdvertising" -ErrorAction SilentlyContinue
}

# View
Function TweakViewBluetoothAdvertising { # RESINFO
	Write-Output "Viewing Bluetooth advertising (not exist: Enable, 0 Disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth\" -Name "AllowAdvertising" -ErrorAction SilentlyContinue
}

################################################################

# This policy setting allows backup and restore of cellular text messages to Microsoft's cloud services.
# https://admx.help/?Category=Windows_11_2022&Policy=Microsoft.Policies.Messaging::AllowMessageSync
# Disable
Function TweakDisableBackupMessages { # RESINFO
	Write-Output "Disabling backup of text messages into the cloud..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging\")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging\" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging\" -Name "AllowMessageSync" -Type DWord -Value 0
}

# Enable
Function TweakEnableBackupMessages { # RESINFO
	Write-Output "Enabling backup of text messages into the cloud..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging\" -Name "AllowMessageSync" -ErrorAction SilentlyContinue
}

# View
Function TweakViewBackupMessages { # RESINFO
	Write-Output "Viewing backup of text messages into the cloud (not exist: Enable, 0 Disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging\" -Name "AllowMessageSync" -ErrorAction SilentlyContinue
}

################################################################

# This policy setting lets you turn off cloud optimized content in all Windows experiences.
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.CloudContent::DisableCloudOptimizedContent
# Disable
Function TweakDisableCloudOptimizedContent { # RESINFO
	Write-Output "Disabling (Turn Off) cloud optimized content..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Type DWord -Value 1
}

# Enable
Function TweakEnableCloudOptimizedContent { # RESINFO
	Write-Output "Enabling (Turn On) cloud optimized content..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -ErrorAction SilentlyContinue
}

# View
Function TweakViewCloudOptimizedContent { # RESINFO
	Write-Output "Viewing cloud optimized content (not exist: Enable, 1 Disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -ErrorAction SilentlyContinue
}

################################################################

# This policy setting prevents Windows tips from being shown to users.
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.CloudContent::DisableSoftLanding
# only on  Enterprise and Education versions
# See also DisableTelemetry
# Disable
Function TweakDisableWindowsTips { # RESINFO
	Write-Output "Disabling Windows Tips, users will no longer see Windows tips..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Type DWord -Value 1
}

# Enable
Function TweakEnableWindowsTips { # RESINFO
	Write-Output "Enabling Windows Tips..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -ErrorAction SilentlyContinue
}

# View
Function TweakViewWindowsTips { # RESINFO
	Write-Output "Viewing Windows Tips (not exist: Enable, 1 Disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -ErrorAction SilentlyContinue
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
