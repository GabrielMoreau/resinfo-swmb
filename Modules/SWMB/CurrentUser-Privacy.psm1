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

# Disable Cortana
Function TweakDisableCortana_CU {
	Write-Output "Disabling Cortana for CU. See DisableCortana..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0
}

# Enable Cortana
Function TweakEnableCortana_CU {
	Write-Output "Enabling Cortana for CU. See EnableCortana..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 1
}

################################################################

# Disable Web Search (Bing, Cortana) in Start Menu
Function TweakDisableWebSearch_CU {
	Write-Output "Disabling Bing Search in Start Menu for CU. See DisableWebSearch..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
}

# Enable
Function TweakEnableWebSearch_CU {
	Write-Output "Enabling Bing Search in Start Menu for CU. See EnableWebSearch..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 1
}

# View
Function TweakViewWebSearch_CU { # RESINFO
	Write-Output "Viewing Bing Search in Start Menu for CU (0: Disable, 1 or not exist: Enable, other: unknown)..."
	If (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search") {
		Write-Output " BingSearchEnabled: $((Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search').BingSearchEnabled)"
	} Else {
		Write-Output " BingSearchEnabled: not exist"
	}
	If (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search") {
		Write-Output " CortanaConsent: $((Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search').CortanaConsent)"
	} Else {
		Write-Output " CortanaConsent: not exist"
	}
}

################################################################

# Disable Application suggestions and automatic installation
Function TweakDisableAppSuggestions_CU {
	Write-Output "Disabling Application suggestions for CU. See DisableAppSuggestions..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
	# Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
	If ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
		Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
	}
}

# Enable Application suggestions and automatic installation
Function TweakEnableAppSuggestions_CU {
	Write-Output "Enabling Application suggestions for CU. See EnableAppSuggestions..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -ErrorAction SilentlyContinue
}

################################################################

# Disable Windows Feedback notifications through the Windows Feedback app
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.FeedbackNotifications::DoNotShowFeedbackNotifications

Function TweakDisableFeedback_CU {
	Write-Output "Disabling Windows Feedback for CU. See DisableFeedback..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
		New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

# Enable Feedback
Function TweakEnableFeedback_CU {
	Write-Output "Enabling Windows Feedback for CU. See EnableFeedback..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

################################################################

# User configuration / Administration templates / Windows components / Cloud content / Do not use diagnostic data to customize user experience
# [fr] Configuration utilisateur / Modèles d'administration / Composants Windows / Contenu Cloud / Ne pas utiliser les données de diagnostic pour personnaliser l'expérience utilisateur
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.CloudContent::DisableTailoredExperiencesWithDiagnosticData

# Disable Tailored Experiences
Function TweakDisableTailoredExperiences_CU {
	Write-Output "Disabling Tailored Experiences for CU..."
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
}

# Enable Tailored Experiences
Function TweakEnableTailoredExperiences_CU {
	Write-Output "Enabling Tailored Experiences for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -ErrorAction SilentlyContinue
}

################################################################

# Disable setting 'Let websites provide locally relevant content by accessing my language list'
Function TweakDisableWebLangList_CU {
	Write-Output "Disabling Website Access to Language List for CU..."
	Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
}

# Enable setting 'Let websites provide locally relevant content by accessing my language list'
Function TweakEnableWebLangList_CU {
	Write-Output "Enabling Website Access to Language List for CU..."
	Remove-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -ErrorAction SilentlyContinue
}

################################################################

# Disable "Send Microsoft info about how I write to help us improve typing and writing in the future"
# https://admx.help/?Category=Windows10_Telemetry&Policy=Microsoft.Policies.Win10Privacy::ImproveTyping

Function TweakDisableTypingRecognition_CU { # RESINFO
	Write-Output "Disabling sending of ink and character data to Microsoft to improve language recognition for CU..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -Type DWord -Value 0
}

# Enable
Function TweakEnableTypingRecognition_CU { # RESINFO
	Write-Output "Enabling sending of ink and character data to Microsoft to improve language recognition for CU..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -ErrorAction SilentlyContinue
}

# View
Function TweakViewTypingRecognition_CU { # RESINFO
	Write-Output "Viewing sending of ink and character data to Microsoft to improve language recognition for CU (0: Disabled)..."
	Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled"
}

################################################################

# Disable Connected Experiences in MS Office
# https://admx.help/?Category=Office2016&Policy=office16.Office.Microsoft.Policies.Windows::L_ConnectedOfficeExperiences

# Disable
Function TweakDisableMSOfficeConnectedExperiences_CU { # RESINFO
	Write-Output "Disabling MS Office ConnectedExperience for CU..."
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy" -Force | Out-Null
	}
	ForEach ($Field in 'controllerconnectedservicesenabled', 'disconnectedstate', 'usercontentdisabled', 'downloadcontentdisabled') {
		Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy" -Name "$Field" -Type DWord -Value 2
	}
}

# Enable
Function TweakEnableMSOfficeConnectedExperiences_CU { # RESINFO
	Write-Output "Enabling MS Office ConnectedExperience for CU..."
	If (Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy") {
		ForEach ($Field in 'controllerconnectedservicesenabled', 'disconnectedstate', 'usercontentdisabled', 'downloadcontentdisabled') {
			Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy" -Name "$Field" -Type DWord -Value 1
		}
	}
}

# View
Function TweakViewMSOfficeConnectedExperiences_CU { # RESINFO
	Write-Output "Viewing MS Office ConnectedExperience for CU (1 or not exist: Enable, 2: Disable)..."
	If (Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy") {
		ForEach ($Field in 'controllerconnectedservicesenabled', 'disconnectedstate', 'usercontentdisabled', 'downloadcontentdisabled') {
			Write-Output " ${Field}: $((Get-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Privacy').${Field})"
		}
	} Else {
		Write-Output " Not configure: Enable"
	}
}

################################################################

# Disable Feedback in MS Office
# https://admx.help/?Category=Office2016&Policy=office16.Office.Microsoft.Policies.Windows::L_EmailCollection

# Disable
Function TweakDisableMSOfficeFeedback_CU { # RESINFO
	Write-Output "Disabling MS Office Feedback for CU..."
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common" -Force | Out-Null
	}
	ForEach ($Field in 'qmenable', 'sendcustomerdata') {
		Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common' -Name "$Field" -Type DWord -Value 1
	}
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback" -Force | Out-Null
	}
	ForEach ($Field in 'includeemail', 'feedbackincludelog', 'includescreenshot', 'surveyenabled', 'enabled') {
		Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback' -Name "$Field" -Type DWord -Value 1
	}
	If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry" -Force | Out-Null
	}
	Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry' -Name "sendtelemetry" -Type DWord -Value 2
}

# Enable
Function TweakEnableMSOfficeFeedback_CU { # RESINFO
	Write-Output "Enabling MS Office Feedback for CU..."
	ForEach ($Field in 'qmenable', 'sendcustomerdata') {
		Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common' -Name "$Field" -ErrorAction SilentlyContinue
	}
	ForEach ($Field in 'includeemail', 'feedbackincludelog', 'includescreenshot', 'surveyenabled', 'enabled') {
		Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback' -Name "$Field" -ErrorAction SilentlyContinue
	}
	Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry' -Name "sendtelemetry" -ErrorAction SilentlyContinue
}

# View
Function TweakViewMSOfficeFeedback_CU { # RESINFO
	Write-Output "Viewing MS Office Feedback for CU (0 or not exist: Enable, 1: Disable)..."
	If (Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common") {
		ForEach ($Field in 'qmenable', 'sendcustomerdata') {
			Write-Output " ${Field}: $((Get-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common').${Field})"
		}
	} Else {
		Write-Output " PersonnalData not configure: Enable"
	}
	If (Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback") {
		ForEach ($Field in 'includeemail', 'feedbackincludelog', 'includescreenshot', 'surveyenabled', 'enabled') {
			Write-Output " ${Field}: $((Get-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\16.0\Common\Feedback').${Field})"
		}
	} Else {
		Write-Output " Feedback not configure: Enable"
	}
	If (Test-Path "HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry") {
		ForEach ($Field in 'sendtelemetry') {
			Write-Output " ${Field}: $((Get-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Office\Common\ClientTelemetry').${Field}) (1: Required, 2 or not exist: Optional, 3: Neither)"
		}
	} Else {
		Write-Output " ClientTelemetry not configure: Optional (1: Required, 2 or not exist: Optional, 3: Neither)"
	}
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
