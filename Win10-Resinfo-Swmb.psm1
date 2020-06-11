################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################
###### Exemples https://github.com/Disassembler0/Win10-Initial-Setup-Script#examples
################################################################


################################################################
###### User Experience
################################################################

### Désactiver les questions pour chaque nouvel utilisateur
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

################################################################

### Enregistreur d'actions utilisateur
# https://support.microsoft.com/en-us/help/22878/windows-10-record-steps
# Disable
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

################################################################

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4723
# Disable
Function DisableDidYouKnow {
	Write-Output "Turn off Help and Support Center Did you know? content..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 1
}

# Enable
Function EnableDidYouKnow {
	Write-Output "Turn on Help and Support Center Did you know? content..."
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\HelpSvc" -Name "Headlines" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4754
# Disable
Function DisableHandwritingDataSharing {
	Write-Output "Turn off handwriting personalization data sharing..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1
}

# Enable
Function EnableHandwritingDataSharing {
	Write-Output "Turn on handwriting personalization data sharing..."
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4743
# Disable
Function DisableHandwritingRecognitionErrorReporting {
	Write-Output "Turn off handwriting recognition error reporting..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "PreventHandwritingErrorReports" -Type DWord -Value 1
}

# Enable
Function EnableHandwritingRecognitionErrorReporting {
	Write-Output "Turn on handwriting recognition error reporting..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "PreventHandwritingErrorReports" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Système / Gestion de la communication Internet / Paramètres de communication Internet
# ANSSI Annexe C1
# https://gpsearch.azurewebsites.net/#4727
# Disable
Function DisableWindowsErrorReporting {
	Write-Output "Turn off Windows error reporting..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting\")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting\" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HandwritingErrorReports\" -Name "DoReport" -Type DWord -Value 0
}

# Enable
Function EnableWindowsErrorReporting {
	Write-Output "Turn on Windows error reporting..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\PCHealth\ErrorReporting" -Name "DoReport" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / Rapport d'erreurs Windows / Envoyer automatiquement des images mémoires pour les rapports
# key AutoApproveOSDumps
# https://getadmx.com/?Category=Windows_8.1_2012R2&Policy=Microsoft.Policies.WindowsErrorReporting::WerAutoApproveOSDumps_2
# GPO Desactivé par défaut
# Disable
Function DisableOsGeneratedReport {
	Write-Output "Turn off OS-generated error reports"
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "AutoApproveOSDumps" -Type DWord -Value 0
}

# Enable
Function EnableOsGeneratedReport {
	Write-Output "Turn on OS-generated error reports"
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "AutoApproveOSDumps" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Composants Windows / Rapport d'erreurs Windows / Ne pas envoyer des données complémentaires
# key DontSendAdditionalData
# https://getadmx.com/?Category=Windows_8.1_2012R2&Policy=Microsoft.Policies.WindowsErrorReporting::WerNoSecondLevelData_2
# GPO activé par défaut
# Disable
Function DisableSendAdditionalData {
	Write-Output "Disable Error reporting Send Additional Data"
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "DontSendAdditionalData" -Type DWord -Value 1
}

# Enable
Function EnableSendAdditionalData {
	Write-Output "Enable Error reporting Send Additional Data"
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "DontSendAdditionalData" -ErrorAction SilentlyContinue
}

################################################################

# Configuration ordinateur / Modèles d'administration / Panneau de Configuration / Options Regionales et Linguistiques / Personnalisation de l'écriture manuscrite / Désactiver l’apprentissage automatique / Activé
# https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.Globalization::ImplicitDataCollectionOff_2
# Disable
Function DisableAutomaticLearning {
	Write-Output "Turn off automatic learning..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
}

# Enable
Function EnableAutomaticLearning {
	Write-Output "Turn on automatic learning..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
}


################################################################
###### Universal Apps
################################################################

### Déactiver le Windows Store
# https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsStore::RemoveWindowsStore_2
# Configuration ordinateur / Modèles d'administration / Composants Windows / WindowsStore / Desactiver l'application / active
# Disable
Function DisableWindowsStore {
	Write-Output "Disable Windows Store..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Type DWord -Value 1
}

# Enable
Function EnableWindowsStore {
	Write-Output "Enable Windows Store..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsStore")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Type DWord -Value 0
}





# Export functions
Export-ModuleMember -Function *