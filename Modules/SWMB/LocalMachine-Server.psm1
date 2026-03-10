##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Server specific Tweaks
##########

################################################################

# Hide Server Manager after login
Function TweakHideServerManagerOnLogin {
	Write-Output "Hiding Server Manager after login..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -Type DWord -Value 1
}

# Show Server Manager after login
Function TweakShowServerManagerOnLogin {
	Write-Output "Showing Server Manager after login..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -ErrorAction SilentlyContinue
}

################################################################

# Disable Shutdown Event Tracker
Function TweakDisableShutdownTracker {
	Write-Output "Disabling Shutdown Event Tracker..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Type DWord -Value 0
}

# Enable Shutdown Event Tracker
Function TweakEnableShutdownTracker {
	Write-Output "Enabling Shutdown Event Tracker..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -ErrorAction SilentlyContinue
}

################################################################

# The "Act as part of the operating system" (Trusted Computing Base Privilege) user right must not be assigned to any groups or accounts.
# W11 STIG V-253481 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253481
#
# SeTcbPrivilege = $($Global:SWMB_Custom.ActAsPartOfOS)

# Disable
Function TweakDisableTCBPrivilege { # RESINFO
	Write-Output "Disabling Trusted Computing Base Privilege (Act as part of the operating system)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
		}
	$IniData['Privilege Rights']['SeTcbPrivilege'] = ''

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# Enable
Function TweakEnableTCBPrivilege { # RESINFO
	Write-Output "Enabling Trusted Computing Base Privilege (Act as part of the operating system)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
		}
	$IniData['Privilege Rights']['SeTcbPrivilege'] = $($Global:SWMB_Custom.TCBPrivilege)

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewTCBPrivilege { # RESINFO
	Write-Output "Viewing Trusted Computing Base Privilege (Act as part of the operating system) (empty or not exist: Disable (Default, Recommended))..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = @{
		SeTcbPrivilege = @{
			OkValues = @('', $Null)
			Description = "Disable Trusted Computing Base Privilege (Act as part of the operating system)"
			Remediation = "DisableTCBPrivilege (W11 STIG V-253481)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'Privilege Rights' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# The "Create a token object" user right must not be assigned to any groups or accounts
# W11 STIG V-253486 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253486
#
# SeCreateTokenPrivilege = $($Global:SWMB_Custom.CreateTokenObject)

# Disable
Function TweakDisableCreateTokenObject { # RESINFO
	Write-Output "Disabling Create Token Object..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
		}
	$IniData['Privilege Rights']['SeCreateTokenPrivilege'] = ''

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# Enable
Function TweakEnableCreateTokenObject { # RESINFO
	Write-Output "Enabling Create Token Object..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
		}
	$IniData['Privilege Rights']['SeCreateTokenPrivilege'] = $($Global:SWMB_Custom.CreateTokenObject)

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewCreateTokenObject { # RESINFO
	Write-Output "Viewing Create Token Object (empty or not exist: Disable (Default, Recommended))..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = @{
		SeCreateTokenPrivilege = @{
			OkValues = @('', $Null)
			Description = "Disable Create Token Object"
			Remediation = "DisableCreateTokenObject (W11 STIG V-253486)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'Privilege Rights' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# The "Debug programs" user right must only be assigned to the Administrators group
# W11 STIG V-253490 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253490
#
# SeDebugPrivilege = $($Global:SWMB_Custom.DebugPrograms)

# Unset
Function TweakUnsetDebugPrograms { # RESINFO
	Write-Output "Unsetting Debug Programs user right (keeping only Administrators)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
	}
	$IniData['Privilege Rights']['SeDebugPrivilege'] = '*S-1-5-32-544'  # Administrators SID

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# Set
Function TweakSetDebugPrograms { # RESINFO
	Write-Output "Setting Debug Programs user right with custom setting..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$IniData = [ordered]@{
		'Privilege Rights' = $SecurityConf['Privilege Rights']
	}
	$IniData['Privilege Rights']['SeDebugPrivilege'] = $($Global:SWMB_Custom.DebugPrograms)

	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas USER_RIGHTS | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewDebugPrograms { # RESINFO
	Write-Output "Viewing Debug Programs user right (must be only Administrators - *S-1-5-32-544)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = @{
		SeDebugPrivilege = @{
			OkValues = @('*S-1-5-32-544')   # Administrators SID only
			Description = "Debug Programs privilege"
			Remediation = "UnsetDebugPrograms (W11 STIG V-253490)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'Privilege Rights' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# Password Policy
# MaximumPasswordAge = Number of week (52 = 1 year)
#
# PasswordHistorySize = $($Global:SWMB_Custom.PasswordHistorySize) (>23: Recommanded) - W11 STIG V-253300 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253300
# MinimumPasswordAge = $($Global:SWMB_Custom.MinimumPasswordAge) - W11 STIG V-253301 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253301
# MaximumPasswordAge = $($Global:SWMB_Custom.MaximumPasswordAge) - W11 STIG V-253302 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253302
# MinimumPasswordLength = $($Global:SWMB_Custom.MinimumPasswordLength) (>13: Recommanded) - W11 STIG V-253303 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253303
# LockoutBadCount = $($Global:SWMB_Custom.LockoutBadCount)
# ResetLockoutCount = $($Global:SWMB_Custom.ResetLockoutCount)
# LockoutDuration = $($Global:SWMB_Custom.LockoutDuration)
# EnableGuestAccount = $($Global:SWMB_Custom.EnableGuestAccount)

# Enable password complexity and maximum age requirements
Function TweakEnablePasswordPolicy { # RESINFO
	Write-Output "Enabling Password Policy (PasswordHistorySize, MinimumPasswordAge, MaximumPasswordAge, MinimumPasswordLength)..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"PasswordHistorySize"   = $($Global:SWMB_Custom.PasswordHistorySize)
			"MinimumPasswordAge"    = $($Global:SWMB_Custom.MinimumPasswordAge)
			"MaximumPasswordAge"    = $($Global:SWMB_Custom.MaximumPasswordAge)
			"MinimumPasswordLength" = $($Global:SWMB_Custom.MinimumPasswordLength)
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# Disable
Function TweakDisablePasswordPolicy { # RESINFO
	Write-Output "Disabling (Reset to défault) (PasswordHistorySize, MinimumPasswordAge, MaximumPasswordAge, MinimumPasswordLength)..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"PasswordHistorySize"   = 0
			"MinimumPasswordAge"    = 0
			"MaximumPasswordAge"    = -1
			"MinimumPasswordLength" = 0
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewPasswordPolicy { # RESINFO
	Write-Output "Viewing Password Policy (Recommanded - PasswordHistorySize: >23, MinimumPasswordAge: >0, MaximumPasswordAge: X days, MinimumPasswordLength: >13)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = [ordered]@{
		PasswordHistorySize = @{
			OkValues = @('>23')
			Description = "Password History Size"
			Remediation = "EnablePasswordPolicy / PasswordHistorySize>23 (W11 STIG V-253300)"
		}
		MinimumPasswordAge = @{
			OkValues = @('>0')
			Description = "Minimum Password Age in days"
			Remediation = "EnablePasswordPolicy / MinimumPasswordAge=1 (W11 STIG V-253301)"
		}
		MaximumPasswordAge = @{
			OkValues = @('0..60')
			Description = "Maximum Password Age in days"
			Remediation = "EnablePasswordPolicy / MaximumPasswordAge=60 (W11 STIG V-253302)"
		}
		MinimumPasswordLength = @{
			OkValues = @('>13')
			Description = "Minimum Password Length"
			Remediation = "EnablePasswordPolicy / MinimumPasswordLength>13 (W11 STIG V-253303)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'System Access' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# Enable Password complexity filter
# PasswordComplexity (0: Simple, 1: Complex) - W11 STIG V-253304 https://system32.eventsentry.com/stig/viewer/V-253304

# Enable
Function TweakEnablePasswordComplexity { # RESINFO
	Write-Output "Enabling Password Complexity..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"PasswordComplexity" = "1"
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# Disable
Function TweakDisablePasswordComplexity { # RESINFO
	Write-Output "Disabling Password Complexity..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"PasswordComplexity" = "0"
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewPasswordComplexity { # RESINFO
	Write-Output "Viewing Password Complexity (0 or not exist: Disable (Default), 1: Enable (Recommanded))..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = @{
		PasswordComplexity = @{
			OkValues = @(1)
			Description = "Password Complexity"
			Remediation = "EnablePasswordComplexity (W11 STIG V-253304)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'System Access' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# Disable Reversible password encryption
# ClearTextPassword (0 or not exist: Recommanded) - W11 STIG V-253305 https://system32.eventsentry.com/stig/viewer/V-253305

# Disable
Function TweakDisablePasswordClearText { # RESINFO
	Write-Output "Disabling Reversible Text Password..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"ClearTextPassword" = "0"
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# Disable
Function TweakEnablePasswordClearText { # RESINFO
	Write-Output "Enabling Reversible Text Password..."
	$IniData = [ordered]@{
		'System Access' = [ordered]@{
			"ClearTextPassword" = "1"
		}
	}
	$TmpFile = New-TemporaryFile
	SWMB_SaveIniFile -Path $TmpFile -IniData $IniData -SeceditFormat
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewPasswordClearText { # RESINFO
	Write-Output "Viewing Reversible Text Password (0 or not exist: Disable (Default, Recommanded), 1: Enable)..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = @{
		ClearTextPassword = @{
			OkValues = @(0, $Null)
			Description = "Disable Reversible Text Password"
			Remediation = "DisablePasswordClearText (W11 STIG V-253305)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'System Access' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# The system must be configured to prevent the storage of the LAN Manager hash of passwords
# Disable Password LM Hash Storage
# W11 STIG V-253305 https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253461

# Disable
Function TweakDisablePasswordLMHash { # RESINFO
	Write-Output "Disabling LM Password Hash Storage..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
	Set-ItemProperty -Path $RegPath -Name 'NoLMHash' -Type DWord -Value 1
}

# Enable
Function TweakEnablePasswordLMHash { # RESINFO
	Write-Output "Enabling LM Password Hash Storage..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
	Remove-ItemProperty -Path $RegPath -Name 'NoLMHash' -ErrorAction SilentlyContinue
}

# View
Function TweakViewPasswordLMHash { # RESINFO
	Write-Output "Viewing LM Password Hash Storage (0 or not exist: Enable (Default), 1: Disable (Recommanded))..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
	$RegFields = @{
		NoLMHash = @{
			OkValues = @(1)
			Description = "LM Password Hash Storage"
			Remediation = "DisablePasswordLMHash (W11 STIG V-253305)"
		}
	}
	SWMB_GetRegistrySettings -Path $RegPath -Rules $RegFields | SWMB_WriteSettings
}

################################################################

# Disable Ctrl+Alt+Del requirement before login
Function TweakDisableCtrlAltDelLogin {
	Write-Output "Disabling Ctrl+Alt+Del requirement before login..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 1
}

# Enable Ctrl+Alt+Del requirement before login
Function TweakEnableCtrlAltDelLogin {
	Write-Output "Enabling Ctrl+Alt+Del requirement before login..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 0
}

################################################################

# Disable Internet Explorer Enhanced Security Configuration (IE ESC)
Function TweakDisableIEEnhancedSecurity {
	Write-Output "Disabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
}

# Enable Internet Explorer Enhanced Security Configuration (IE ESC)
Function TweakEnableIEEnhancedSecurity {
	Write-Output "Enabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
}

################################################################

# Enable Audio
Function TweakEnableAudio {
	Write-Output "Enabling Audio..."
	Set-Service "Audiosrv" -StartupType Automatic
	Start-Service "Audiosrv" -WarningAction SilentlyContinue
}

# Disable Audio
Function TweakDisableAudio {
	Write-Output "Disabling Audio..."
	Stop-Service "Audiosrv" -WarningAction SilentlyContinue
	Set-Service "Audiosrv" -StartupType Manual
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
