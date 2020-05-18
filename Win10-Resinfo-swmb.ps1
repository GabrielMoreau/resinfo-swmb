###############
######### https://github.com/Disassembler0/Win10-Initial-Setup-Script#examples
###############

### Desactiver les questions pour chaque nouvel utilisateur
# Computer Configuration\Administrative Templates\Windows Components\OOBE
# https://docs.microsoft.com/fr-fr/windows/client-management/mdm/policy-csp-privacy#privacy-disableprivacyexperience
# Disable
Function DisablePrivacyExperience {
	Write-Output "Disabling privacy experience from launching during user logon for new and upgraded users..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Type DWord -Value 1
}

# Enable
Function EnablePrivacyExperience {
	Write-Output "Enabling privacy experience from launching during user logon for new and upgraded users..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}


### Enregistreur d'actions utilisateur
# https://support.microsoft.com/en-us/help/22878/windows-10-record-steps
Function DisableStepsRecorder {
	Write-Output "Disabling Windows steps recorder..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
}

# Enable
Function EnableStepsRecorder {
	Write-Output "Enable Windows steps recorder..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -ErrorAction SilentlyContinue
}

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4723
Function DisableDidYouKnow {
	Write-Output "Turn off Help and Support Center Did you know? content..."
	If (!(Test-Path "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc")) {
		New-Item -Path "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 1
}

# Enable
Function EnableDidYouKnow {
	Write-Output "Enable Windows steps recorder..."
	Set-ItemProperty -Path "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4754
# https://gpsearch.azurewebsites.net/#4740 (already in DisableTelemetry)
# https://gpsearch.azurewebsites.net/#4743
# https://gpsearch.azurewebsites.net/#4727


# Export functions
Export-ModuleMember -Function *
