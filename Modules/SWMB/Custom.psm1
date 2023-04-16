################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2023, CNRS, France
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
		[Parameter(Mandatory = $True)] [string]$ModuleScriptName
	)

	Function _ModuleAutoLoad() {
		Param (
			[Parameter(Mandatory = $True)] [string]$PathBase
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
			Return $True
		}
		Return $False
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
	ForEach ($ItemPath in (Get-Location).Path, (Join-Path -Path $Env:ProgramData -ChildPath "SWMB"), $ModuleScriptPath) {
		While (Test-Path -LiteralPath $ItemPath) {
			# Module VarOverload directly in the current folder
			If (_ModuleAutoLoad -PathBase (Join-Path -Path $ItemPath -ChildPath $ModuleScriptBasename)) {
				Return $True
			}

			# Or module VarOverload directly in the subfolder Modules
			If (_ModuleAutoLoad -PathBase (Join-Path -Path $ItemPath -ChildPath (Join-Path -Path "Modules" -ChildPath $ModuleScriptBasename))) {
				Return $True
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
		Return $True
	}
	If (_ModuleAutoLoad -PathBase (Join-Path -Path $DataModule -ChildPath $ModuleScriptBasename)) {
		Return $True
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
	$ComputerSID = ((Get-LocalUser | Select-Object -First 1).SID).AccountDomainSID.ToString()
	$LocalAdminAccount = Get-LocalUser -SID "$ComputerSID-500" -ErrorAction SilentlyContinue
	If ($LocalAdminAccount -And ($LocalAdminAccount.Name -ne $Global:SWMB_Custom.LocalAdminNameEffective)) {
		Rename-LocalUser -Name $LocalAdminAccount.Name -NewName $Global:SWMB_Custom.LocalAdminNameEffective -ErrorAction SilentlyContinue
	}
}

# Unset
Function TweakUnsetAdminAccountLogin { # RESINFO
	$ComputerSID = ((Get-LocalUser | Select-Object -First 1).SID).AccountDomainSID.ToString()
	$LocalAdminAccount = Get-LocalUser -SID "$ComputerSID-500" -ErrorAction SilentlyContinue
	If ($LocalAdminAccount -And ($LocalAdminAccount.Name -ne $Global:SWMB_Custom.LocalAdminNameOriginal)) {
		Rename-LocalUser -Name $LocalAdminAccount.Name -NewName $Global:SWMB_Custom.LocalAdminNameOriginal -ErrorAction SilentlyContinue
	}
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
#      https://resources.infosecinstitute.com/topic/how-to-configure-password-policies-in-windows-10/
# Configuration ordinateur / Paramètres Windows / Paramètres de sécurité / Stratégie de comptes / Stratégie de mots de passe
# Set
Function TweakSetSecurityParamAccountPolicy { # RESINFO
	$TempFile = New-TemporaryFile
	$TempInfFile = "$TempFile.inf"

	Rename-Item -Path $TempFile.FullName -NewName $TempInfFile

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

	$securityString | Out-File -FilePath $TempInfFile
	secedit /configure  /db hisecws.sdb /cfg $TempInfFile /areas SECURITYPOLICY
	Remove-Item -Path $TempInfFile
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
	Write-Output "Setting NTP client configuration..."
	w32tm /register
	net start w32time
	w32tm /config /manualpeerlist:"$($Global:SWMB_Custom.NTP_ManualPeerList)" /syncfromflags:manual
	w32tm /config /update
	w32tm /resync
}

# Unset
Function TweakUnsetNTPConfig { # RESINFO
	Write-Output "Unset NTP client (stop)..."
	w32tm /unregister
	net stop w32time
}

# View
Function TweakViewNTPConfig { # RESINFO
	w32tm /query /configuration
	w32tm /query /status
	w32tm /tz
}

################################################################

# Workgroup Name
# Set
Function TweakSetWorkgroupName { # RESINFO
	Write-Output "Setting Workgroup Name..."
	If (!(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
		If (![string]::IsNullOrEmpty($($Global:SWMB_Custom.WorkgroupName))) {
			If ((Get-WmiObject -Class Win32_ComputerSystem).Workgroup -ne "$($Global:SWMB_Custom.WorkgroupName)") {
				Add-Computer -WorkgroupName "$($Global:SWMB_Custom.WorkgroupName)"
			}
		}
	}
}

# Unset
Function TweakUnsetWorkgroupName { # RESINFO
	Write-Output "Setting Workgroup Name to the default (WORKGROUP)..."
	If (!(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
		If ((Get-WmiObject -Class Win32_ComputerSystem).Workgroup -ne "WORKGROUP") {
			Add-Computer -WorkgroupName "WORKGROUP"
		}
	}
}

# View
Function TweakViewWorkgroupName { # RESINFO
	If ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
		Write-Output "This computer is part of domain"
	} Else {
		Write-Output "The Workgroup name is: $((Get-WmiObject -Class Win32_ComputerSystem).Workgroup)" 
	}
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function *
