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

# Disable password complexity and maximum age requirements
# MaximumPasswordAge = Number of week (52 = 1 year)
# PasswordComplexity (0: Simple, 1: Complexe)

# Disable
Function TweakDisablePasswordPolicy {
	Write-Output "Disabling password complexity and maximum age requirements..."
	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet
	(Get-Content $TmpFile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $TmpFile
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# Enable password complexity and maximum age requirements
Function TweakEnablePasswordPolicy {
	Write-Output "Enabling password complexity and maximum age requirements..."
	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet
	(Get-Content $TmpFile).Replace("PasswordComplexity = 0", "PasswordComplexity = 1").Replace("MaximumPasswordAge = -1", "MaximumPasswordAge = 42") | Out-File $TmpFile
	secedit /configure /db "${Env:SystemRoot}\security\database\local.sdb" /cfg $TmpFile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $TmpFile
}

# View
Function TweakViewPasswordPolicy { # RESINFO
	Write-Output "Viewing Password Policy (Recommanded - PasswordComplexity: 1 (Complex), MaximumPasswordAge: X weeks, MinimumPasswordLength: >12, PasswordHistorySize: ?, ClearTextPassword: 0 (Not reversible))..."

	$TmpFile = New-TemporaryFile
	secedit /export /cfg $TmpFile /quiet | Out-Null
	$SecurityConf = SWMB_LoadIniFile -Path $TmpFile
	Remove-Item -Path $TmpFile

	$Rules = [ordered]@{
		PasswordComplexity = @{
			OkValues = @(1)
			Description = "Password Complexity"
			Remediation = "EnablePasswordPolicy / PasswordComplexity=1"
		}
		MaximumPasswordAge = @{
			#OkValues = $Null
			Description = "Maximum Password Age in weeks"
		}
		MinimumPasswordLength = @{
			OkValues = @('>12')
			Description = "Minimum Password Length"
			Remediation = "EnablePasswordPolicy / MinimumPasswordLength=13"
		}
		PasswordHistorySize = @{
			#OkValues = $Null
			Description = "Password History Size "
		}
		ClearTextPassword = @{
			OkValues = @(0, $Null)
			Description = "Disable Reversible Text Password"
			Remediation = "DisablePasswordClearText (W11 STIG V-253305)"
		}
	}
	SWMB_GetIniSettings -IniData $SecurityConf -Section 'System Access' -Rules $Rules | SWMB_WriteSettings
}

################################################################

# Reversible password encryption must be disabled
# W11 STIG V-253305

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
