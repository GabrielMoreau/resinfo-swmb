################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2022, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################
### SWMB Import Parameter Extension
################################################################

Function SWMB_ImportModuleParameter() {
	Param (
		[Parameter(Mandatory = $true)] [string]$ModuleScriptName
	)

	Function _ModuleAutoLoad() {
		Param (
			[Parameter(Mandatory = $true)] [string]$PathBase
		)

		$VarOverload = $PathBase + '-VarOverload.psm1'
		$VarAutodel  = $PathBase + '-VarAutodel.psm1'

		If ((Test-Path -LiteralPath $VarOverload) -Or (Test-Path -LiteralPath $VarAutodel)) {
			If (Test-Path -LiteralPath $VarOverload) {
				Import-Module -Name $VarOverload -ErrorAction Stop
			}
			If (Test-Path -LiteralPath $VarAutodel) {
				Import-Module -Name $VarAutodel -ErrorAction Stop
				Remove-Item $VarAutodel -ErrorAction Stop
			}
			Return $true
		}
		Return $false
	}

	$ModuleScriptPath = (Get-Item $ModuleScriptName).DirectoryName
	$ModuleScriptBasename = (Get-Item $ModuleScriptName).Basename

	# Try to load default parameter module with extension -VarDefault
	$ModuleScriptVarDefault = (Join-Path -Path $ModuleScriptPath -ChildPath $ModuleScriptBasename) + '-VarDefault.psm1'
	If (Test-Path -LiteralPath $ModuleScriptVarDefault) {
		Import-Module -Name $ModuleScriptVarDefault -ErrorAction Stop
	}
	# Try to load the local overload parameter module with the extension
	# -VarOverload from the current folder to the root folder,
	# then from the SWMB ProgramData folder to the root folder,
	# and finally from the module folder to the root folder.
	Foreach ($ItemPath in (Get-Location).Path, (Join-Path -Path $Env:ProgramData -ChildPath "SWMB"), $ModuleScriptPath) {
		While (Test-Path -LiteralPath $ItemPath) {
			# Module VarOverload directly in the current folder
			If (_ModuleAutoLoad -PathBase (Join-Path -Path $ItemPath -ChildPath $ModuleScriptBasename)) {
				Return $true
			}

			# Or module VarOverload directly in the subfolder Modules
			If (_ModuleAutoLoad -PathBase (Join-Path -Path $ItemPath -ChildPath (Join-Path -Path "Modules" -ChildPath $ModuleScriptBasename))) {
				Return $true
			}

			# Search module in the parent folder .. and so on
			$NewPath = (Resolve-Path (Join-Path -Path $ItemPath -ChildPath "..") -ErrorAction SilentlyContinue) 
			If ("$NewPath" -eq "$ItemPath") {
				Break
			}
			$ItemPath = $NewPath
		}
	}

	# Search module in ProgramData folder
	$DataFolder = (Join-Path -Path $Env:ProgramData -ChildPath "SWMB")
	$DataModule = (Join-Path -Path $DataFolder      -ChildPath "Modules")
	If (_ModuleAutoLoad -PathBase (Join-Path -Path $DataFolder -ChildPath $ModuleScriptBasename)) {
		Return $true
	}
	If (_ModuleAutoLoad -PathBase (Join-Path -Path $DataModule -ChildPath $ModuleScriptBasename)) {
		Return $true
	}
}

################################################################
### Load module associated parameter
################################################################

SWMB_ImportModuleParameter (Get-PSCallStack)[0].ScriptName


################################################################
###### Les actions
################################################################

### Renommage du compte administrateur
# Configuration ordinateur / Paramètres Windows / Paramètres de sécurité / Stratégies locales / Options de sécurité
# Set
Function TweakSetAdminAccountLogin { # RESINFO
	$localAdminName = get-localuser | where-object {($_.SID -like "S-1-5-21*-500")}
	Rename-LocalUser -Name $localAdminName.name -NewName $Global:SWMB_Custom.LocalAdminNameToSet -ErrorAction SilentlyContinue
}

# Unset
Function TweakUnsetAdminAccountLogin { # RESINFO
	$localAdminName = get-localuser | where-object {($_.SID -like "S-1-5-21*-500")}
	Rename-LocalUser -Name $localAdminName.name -NewName $Global:SWMB_Custom.LocalAdminNameOriginal -ErrorAction SilentlyContinue
}

################################################################

### Ne pas afficher le nom du dernier utilisateur
# Enable
Function TweakEnableDontDisplayLastUsername { # RESINFO
	Write-Output "Ne pas afficher le dernier utilisateur..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Type DWord -Value 1 -ErrorAction SilentlyContinue
}

# Disable
Function TweakDisableDontDisplayLastUsername { # RESINFO
	Write-Output "Afficher le dernier utilisateur..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################

### Verrouillage de la session : timeout de session
# Enable
Function TweakEnableSessionLockTimeout { # RESINFO
	Write-Output "Définition du timeout de session..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name InactivityTimeoutSecs  -Type DWord -Value $Global:SWMB_Custom.InactivityTimeoutSecs -ErrorAction SilentlyContinue
}

# Disable
Function TweakDisableSessionLockTimeout { # RESINFO
	Write-Output "Suppression du timeout de session..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name InactivityTimeoutSecs  -Type DWord -Value 0 -ErrorAction SilentlyContinue
}

################################################################



################################################################

### Application de paramètres de sécurité
# cf : https://www.itninja.com/blog/view/using-secedit-to-apply-security-templates
# Configuration ordinateur / Paramètres Windows / Paramètres de sécurité / Stratégie de comptes / Stratégie de mots de passe
# Set
Function TweakSetSecurityParamAccountPolicy { # RESINFO
	$tempFile = New-TemporaryFile
	$tempInfFile = "$tempFile.inf"

	Rename-Item -Path $tempFile.FullName -NewName $tempInfFile

	$securityString = "[Unicode]
Unicode=yes
[Version]
signature=`"`$CHICAGO`$`"
Revision=10
[System Access]
MinimumPasswordAge = $($Global:SWMB_Custom.MinimumPasswordAge)
MaximumPasswordAge = $($Global:SWMB_Custom.MaximumPasswordAge)
MinimumPasswordLength = $($Global:SWMB_Custom.MinimumPasswordLength)
PasswordComplexity = $($Global:SWMB_Custom.PasswordComplexity)
PasswordHistorySize = $($Global:SWMB_Custom.PasswordHistorySize)
LockoutBadCount = $($Global:SWMB_Custom.LockoutBadCount)
ResetLockoutCount = $($Global:SWMB_Custom.ResetLockoutCount)
LockoutDuration = $($Global:SWMB_Custom.LockoutDuration)
EnableGuestAccount = $($Global:SWMB_Custom.EnableGuestAccount)
"

	$securityString | Out-File -FilePath $tempInfFile
	secedit /configure  /db hisecws.sdb /cfg $tempInfFile /areas SECURITYPOLICY
	Remove-Item -Path $tempInfFile
}

# Unset
Function TweakUnsetSecurityParamAccountPolicy { # RESINFO
	# Nécessite un reboot
	secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb
}

################################################################

# NTP time service
# https://docs.microsoft.com/fr-fr/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings
# Set
Function TweakSetNTPConfig { # RESINFO
	w32tm /register
	net start w32time
	w32tm /config /manualpeerlist: "$($Global:SWMB_Custom.NTP_ManualPeerList)"
	w32tm /config /update
	w32tm /resync
}

# Unset
Function TweakUnsetNTPConfig { # RESINFO
	w32tm /unregister
	net stop w32time
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function *
