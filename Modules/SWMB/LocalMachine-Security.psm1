##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Security Tweaks
##########

################################################################

# Lower UAC level (disabling it completely would break apps)
Function TweakSetUACLow {
	Write-Output "Lowering UAC level..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
}

# Raise UAC level
Function TweakSetUACHigh {
	Write-Output "Raising UAC level..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
}

################################################################

# Enable sharing mapped drives between users
Function TweakEnableSharingMappedDrives {
	Write-Output "Enabling sharing mapped drives between users..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
}

# Disable sharing mapped drives between users
Function TweakDisableSharingMappedDrives {
	Write-Output "Disabling sharing mapped drives between users..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
}

################################################################

# Disable implicit administrative shares
Function TweakDisableAdminShares {
	Write-Output "Disabling implicit administrative shares..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Type DWord -Value 0
}

# Enable implicit administrative shares
Function TweakEnableAdminShares {
	Write-Output "Enabling implicit administrative shares..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -ErrorAction SilentlyContinue
}

################################################################

# Disable Firewall
Function TweakDisableFirewall {
	Write-Output "Disabling Firewall..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Force | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "EnableFirewall" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

# Enable Firewall
Function TweakEnableFirewall {
	Write-Output "Enabling Firewall..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
}

################################################################

# Hide Windows Defender SysTray icon
Function TweakHideDefenderTrayIcon {
	Write-Output "Hiding Windows Defender SysTray icon..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -Type DWord -Value 1
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
	}
}

# Show Windows Defender SysTray icon
Function TweakShowDefenderTrayIcon {
	Write-Output "Showing Windows Defender SysTray icon..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -ErrorAction SilentlyContinue
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 17134) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%ProgramFiles%\Windows Defender\MSASCuiL.exe"
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 17763) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%windir%\system32\SecurityHealthSystray.exe"
	}
}

################################################################

# Disable Windows Defender
Function TweakDisableDefender {
	Write-Output "Disabling Windows Defender..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
	}
}

# Enable Windows Defender
Function TweakEnableDefender {
	Write-Output "Enabling Windows Defender..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 17134) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%ProgramFiles%\Windows Defender\MSASCuiL.exe"
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 17763) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%windir%\system32\SecurityHealthSystray.exe"
	}
}

################################################################

# Disable Windows Defender Cloud
Function TweakDisableDefenderCloud {
	Write-Output "Disabling Windows Defender Cloud..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2
}

# Enable Windows Defender Cloud
Function TweakEnableDefenderCloud {
	Write-Output "Enabling Windows Defender Cloud..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -ErrorAction SilentlyContinue
}

################################################################

# Enable Controlled Folder Access (Defender Exploit Guard feature) - Applicable since 1709, requires Windows Defender to be enabled
Function TweakEnableCtrldFolderAccess {
	Write-Output "Enabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
}

# Disable Controlled Folder Access (Defender Exploit Guard feature) - Applicable since 1709, requires Windows Defender to be enabled
Function TweakDisableCtrldFolderAccess {
	Write-Output "Disabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue
}

################################################################

# Enable Core Isolation Memory Integrity - Part of Windows Defender System Guard virtualization-based security - Applicable since 1803
# Warning: This may cause old applications and drivers to crash or even cause BSOD
# Problems were confirmed with old video drivers (Intel HD Graphics for 2nd gen., Radeon HD 6850), and old antivirus software (Kaspersky Endpoint Security 10.2, 11.2)
Function TweakEnableCIMemoryIntegrity {
	Write-Output "Enabling Core Isolation Memory Integrity..."
	If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity")) {
		New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1
}

# Disable Core Isolation Memory Integrity - Applicable since 1803
Function TweakDisableCIMemoryIntegrity {
	Write-Output "Disabling Core Isolation Memory Integrity..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
}

################################################################

# Enable Windows Defender Application Guard - Applicable since 1709 Enterprise and 1803 Pro. Not applicable to Server
# Not supported on VMs and VDI environment. Check requirements on https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-guard/reqs-wd-app-guard
Function TweakEnableDefenderAppGuard {
	Write-Output "Enabling Windows Defender Application Guard..."
	Enable-WindowsOptionalFeature -online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Disable Windows Defender Application Guard - Applicable since 1709 Enterprise and 1803 Pro. Not applicable to Server
Function TweakDisableDefenderAppGuard {
	Write-Output "Disabling Windows Defender Application Guard..."
	Disable-WindowsOptionalFeature -online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

################################################################

# Disable Windows Script Host (execution of *.vbs scripts and alike)
Function TweakDisableScriptHost {
	Write-Output "Disabling Windows Script Host..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
}

# Enable Windows Script Host
Function TweakEnableScriptHost {
	Write-Output "Enabling Windows Script Host..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -ErrorAction SilentlyContinue
}

################################################################

# Enable strong cryptography for old versions of .NET Framework (4.6 and newer have strong crypto enabled by default)
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/tls#schusestrongcrypto
Function TweakEnableDotNetStrongCrypto {
	Write-Output "Enabling .NET strong cryptography..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
}

# Disable strong cryptography for old versions of .NET Framework
Function TweakDisableDotNetStrongCrypto {
	Write-Output "Disabling .NET strong cryptography..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
}

################################################################

# Enable Meltdown (CVE-2017-5754) compatibility flag - Required for January and February 2018 Windows updates
# This flag is normally automatically enabled by compatible antivirus software (such as Windows Defender).
# Use the tweak only if you have confirmed that your AV is compatible but unable to set the flag automatically or if you don't use any AV at all.
# As of March 2018, the compatibility check has been lifted for security updates.
# See https://support.microsoft.com/en-us/help/4072699/windows-security-updates-and-antivirus-software for details
Function TweakEnableMeltdownCompatFlag {
	Write-Output "Enabling Meltdown (CVE-2017-5754) compatibility flag..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
}

# Disable Meltdown (CVE-2017-5754) compatibility flag
Function TweakDisableMeltdownCompatFlag {
	Write-Output "Disabling Meltdown (CVE-2017-5754) compatibility flag..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -ErrorAction SilentlyContinue
}

################################################################

# Enable F8 boot menu options
Function TweakEnableF8BootMenu {
	Write-Output "Enabling F8 boot menu options..."
	bcdedit /set `{current`} BootMenuPolicy Legacy | Out-Null
}

# Disable F8 boot menu options
Function TweakDisableF8BootMenu {
	Write-Output "Disabling F8 boot menu options..."
	bcdedit /set `{current`} BootMenuPolicy Standard | Out-Null
}

################################################################

# Disable automatic recovery mode during boot
# This causes boot process to always ignore startup errors and attempt to boot normally
# It is still possible to interrupt the boot and enter recovery mode manually. In order to disable even that, apply also DisableRecoveryAndReset tweak
Function TweakDisableBootRecovery {
	Write-Output "Disabling automatic recovery mode during boot..."
	bcdedit /set `{current`} BootStatusPolicy IgnoreAllFailures | Out-Null
}

# Enable automatic entering recovery mode during boot
# This allows the boot process to automatically enter recovery mode when it detects startup errors (default behavior)
Function TweakEnableBootRecovery {
	Write-Output "Enabling automatic recovery mode during boot..."
	bcdedit /deletevalue `{current`} BootStatusPolicy | Out-Null
}

################################################################

# Disable System Recovery and Factory reset
# Warning: This tweak completely removes the option to enter the system recovery during boot and the possibility to perform a factory reset
Function TweakDisableRecoveryAndReset {
	Write-Output "Disabling System Recovery and Factory reset..."
	reagentc /disable 2>&1 | Out-Null
}

# Enable System Recovery and Factory reset
Function TweakEnableRecoveryAndReset {
	Write-Output "Enabling System Recovery and Factory reset..."
	reagentc /enable 2>&1 | Out-Null
}

################################################################

# Set Data Execution Prevention (DEP) policy to OptOut - Turn on DEP for all 32-bit applications except manually excluded. 64-bit applications have DEP always on.
Function TweakSetDEPOptOut {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptOut..."
	bcdedit /set `{current`} nx OptOut | Out-Null
}

# Set Data Execution Prevention (DEP) policy to OptIn - Turn on DEP only for essential 32-bit Windows executables and manually included applications. 64-bit applications have DEP always on.
Function TweakSetDEPOptIn {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptIn..."
	bcdedit /set `{current`} nx OptIn | Out-Null
}

################################################################
# 2022/02/02 - Enable is better
# ASLR (Address Space Layout Randomisation)
# Disable ASLR for Easier Malware Debugging
# Disable : HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\MoveImages and set its value to 0x00000000.
# https://oalabs.openanalysis.net/2019/06/12/disable-aslr-for-easier-malware-debugging/
# Disable
Function TweakDisableASLR { # RESINFO
	Write-Output "Disabling (Turn Off) ASLR (Address Space Layout Randomisation)..."
	If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management")) {
		New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "MoveImages" -Type DWord -Value 0
}

# Enable
Function TweakEnableASLR { # RESINFO
	Write-Output "Disabling (Turn On) ASLR (Address Space Layout Randomisation)..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "MoveImages" -ErrorAction SilentlyContinue
}

# View
Function TweakViewASLR { # RESINFO
	Write-Output "ASLR (Address Space Layout Randomisation) (not exist - enable, 0 disable)..."
	$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
		If ((Get-ItemProperty $Path -Name "MoveImages" -ea 0)."MoveImages" -ne $null) {
			Get-ItemProperty -Path $Path -Name "MoveImages"
		} Else {
			Write-Output "$Path name MoveImages not exist"
		}
}

################################################################

# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.LanmanWorkstation::Pol_EnableInsecureGuestLogons
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-workstationservice-allowinsecureguestauth
# Enable
Function TweakEnableInsecureGuestLogons { # RESINFO
	Write-Output "SMB client will allow insecure guest logons to an SMB server..."
	If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -Value 1
}

# Disable (default)
Function TweakDisableInsecureGuestLogons { # RESINFO
	Write-Output "SMB client rejects insecure guest logons to an SMB server (default)..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation" -Name "AllowInsecureGuestAuth" -ErrorAction SilentlyContinue
}

################################################################

# Disable offering of drivers through network
# Is part of DisableUpdateDriver
Function TweakDisableAutoloadDriver { # RESINFO
	Write-Output "Disabling autoload driver from network..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
}

# Enable offering of drivers through network
Function TweakEnableAutoloadDriver { # RESINFO
	Write-Output "Enabling autoload driver from network..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
}

# View
Function TweakViewAutoloadDriver { # RESINFO
	Write-Output "Autoload driver from network (0 no or not exist - enable, 1 disable)..."
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork"
}

################################################################

# From BSI document
# Désactivation des anciennes versions de PowerShell (2.0) qui ne proposent pas les fonctionnalités de sécurité avancées

# Disable
Function TweakDisablePowershell2 { # RESINFO
	Write-Output "Désactivation des anciennes versions de Powershell(2)..."
	Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
}

# Enable
Function TweakEnablePowershell2 { # RESINFO
	Write-Output "Activation des anciennes versions de Powershell(2)..."
	Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
}

################################################################

# From BSI document
# Désactivation de l'utilisation de PowerShell à distance
# TODO

# Disable
# Function TweakDisableRemotePowershell { # RESINFO
# 	Write-Output "Désactivation de l'utilisation de PowerShell à distance"
# 	Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
# }

# Enable
# Function TweakEnableRemotePowershell { # RESINFO
# 	Write-Output "Activation de l'utilisation de PowerShell à distance"
# 	Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
# }

################################################################

# Turn off hybrid sleep
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.PowerManagement::DCStandbyWithHiberfileEnable_2
# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.PowerManagement::ACStandbyWithHiberfileEnable_2
# Disable
Function TweakDisableHybridSleep { # RESINFO
	Write-Output "Disabling (Turn Off) hybrid sleep (plugged in and battery)..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Name "ACSettingIndex" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Name "DCSettingIndex" -Type DWord -Value 0
}

# Enable
Function TweakEnableHybridSleep { # RESINFO
	Write-Output "Disabling (Turn On) hybrid sleep (plugged in and battery)..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Name "ACSettingIndex" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e" -Name "DCSettingIndex" -Type DWord -Value 1
}

################################################################

# Windows_FW_Rules_DR11
# GPO Configuration Ordinateur / Paramètres Windows / Paramètres de sécurité / Pare-feu Windows avec sécurité avancée
# Paramètres du profil de domaine | Paramètres du profil privé | Paramètres du profil public

# Disable Firewall
Function TweakDisableDomainProfile { # RESINFO
	Write-Output "Disabling Domain Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

# Enable Firewall
Function TweakEnableDomainProfile { # RESINFO
	Write-Output "Enabling Domain Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "EnableFirewall" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultOutboundAction" -Type DWord -Value 0
}

################################################################

Function TweakDisablePrivateProfile { # RESINFO
	Write-Output "Disabling Private Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

Function TweakEnablePrivateProfile { # RESINFO
	Write-Output "Enabling Private Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "EnableFirewall" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultInboundAction" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultOutboundAction" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DoNotAllowExceptions" -Type DWord -Value 1
}

################################################################

Function TweakDisablePublicProfile { # RESINFO
	Write-Output "Disabling Public Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

Function TweakEnablePublicProfile { # RESINFO
	Write-Output "Enabling Public Profile..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultInboundAction" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultOutboundAction" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalPolicyMerge" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalIPsecPolicyMerge" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DisableNotifications" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DoNotAllowExceptions" -Type DWord -Value 1
}

################################################################

# Cloud
# Computer configuration / Windows settings / Security settings / Local policies / Security options / Accounts : Block Microsoft accounts / Users cannot add or log in to Microsoft accounts
# [fr] Configuration Ordinateur / Paramètres Windows / Paramètres de Sécurité / Stratégies Locales / Options de sécurité / Comptes : Bloquer les comptes Microsoft /  Les utilisateurs ne peuvent pas ajouter de comptes Microsoft ni se connecter avec ces derniers

# Disable
Function TweakDisableMicrosoftAccount { # RESINFO
	Write-Output "Disabling (Block) Microsoft Account..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser" -Type DWord -Value 3
}

# Enable
Function TweakEnableMicrosoftAccount { # RESINFO
	Write-Output "Enabling Microsoft Account..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser" -Type DWord -Value 0
}

################################################################

# See https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/winsoft-main/-/blob/main/windows11update/pre-install.ps1
# Force a registry key so that hardware not supported for accepting Windows 11 upgrades can continue to benefit from updates (use at your own risk).
# This only applies to machines already running Windows 11.
# This tweak does nothing for computers running Windows 10 (build < 22000).

# Disable
Function TweakDisableUpgradesOnUnsupportedHard { # RESINFO
	Write-Output "Disabling Windows 11 upgrades with unsupported hardware..."
	If ([System.Environment]::OSVersion.Version.Build -ge 22000) {
		Remove-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -ErrorAction SilentlyContinue
	}
}

# Enable
Function TweakEnableUpgradesOnUnsupportedHard { # RESINFO
	Write-Output "Enabling Windows 11 upgrades with unsupported hardware..."
	If ([System.Environment]::OSVersion.Version.Build -ge 22000) {
		[cultureinfo]::CurrentUICulture='en-US'
		$CheckTPM_Version = (Get-Tpm).ManufacturerVersionFull20
		If (($CheckTPM_Version -like '*not supported*') -Or ($CheckTPM_Version -like '*non pris*')) {
			Write-Output ' TPM not 2.0 - registry bypass force'
			If (!(Test-Path 'HKLM:\SYSTEM\Setup\MoSetup')) {
				New-Item -Path 'HKLM:\SYSTEM\Setup\MoSetup' -Force | Out-Null
			}
			Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\MoSetup' -Name 'AllowUpgradesWithUnsupportedTPMOrCPU' -Type DWord -Value 1
		}
	}
}

# View
Function TweakViewUpgradesOnUnsupportedHard { # RESINFO
	Write-Output "Windows 11 upgrades with unsupported hardware (0 no or not exist - disable, 1 enable)..."
	If ([System.Environment]::OSVersion.Version.Build -ge 22000) {
		Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup\MoSetup' -Name 'AllowUpgradesWithUnsupportedTPMOrCPU'
	} Else {
		Write-Output " Operating system not running Windows 11 or higher"
	}
}

################################################################

# Disable or enable AutoLogon with a DefaultUserName
# See https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
# Via netplwiz https://lecrabeinfo.net/netplwiz-creer-modifier-et-supprimer-les-utilisateurs-sur-windows.html
# We see only that the register value DefaultUserName exist but is empty
# Need better work to take netplwiz config properly

# Disable
Function TweakDisableAutoLogon { # RESINFO
	Write-Output "Disabling Windows AutoLogon..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
}

# Enable
Function TweakEnableAutoLogon { # RESINFO
	Write-Output "Enabling Windows AutoLogon..."
	If ([string]::IsNullOrEmpty($Global:SWMB_Custom.AutoLogon_UserName)) { Return }
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -Type DWord -Value 1 -Force
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name "DefaultUserName" -Type String -Value $Global:SWMB_Custom.AutoLogon_UserName -Force
}

# View
Function TweakViewAutoLogon { # RESINFO
	Write-Output "Viewing Windows AutoLogon..."
	Try {
		Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUserName' | Out-Null
	} Catch {
		Write-Output ' Windows AutoLogon not configured'
		Return
	}
	Write-Output ' Windows AutoLogon is enabled'
	Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUserName'
	Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue
}

################################################################
###### Crypt Bitlocker
################################################################

# Enable
Function TweakEnableBitlocker { # RESINFO
	## PowerShell bitlocker commands
	# https://docs.microsoft.com/en-us/powershell/module/bitlocker/?view=win10-ps

	Function _NetworkKeyBackup() {
		Param (
			[Parameter(Mandatory = $True)] [string]$WantToSave
		)

		If ($WantToSave -eq $False) {
			$IsNetWorkBackup = Read-Host -Prompt "Do you want to save recovery keys on a network drive? [y/N]"
			If ($IsNetWorkBackup.ToLower() -ne "y") {
				Return $null
			}
		}

		Do {
			$NetworkKeyBackup = Read-Host -Prompt "Provide a CIFS/SMB writable network path with UNC syntax \\serverName\SharedFolder"
		} Until (($NetworkKeyBackup.Length -gt 2) -and ("\\" -ccontains $NetworkKeyBackup.Substring(0, 2)))

		If ($NetworkKeyBackup.Substring($NetworkKeyBackup.Length - 1) -ne "\") {
			$NetworkKeyBackup += "\"
		}

		Try {
			New-Item -Name isWriteAllowed.txt -ItemType File -Path $NetworkKeyBackup -Force -ErrorAction stop | Out-Null
			Return $NetworkKeyBackup
			# Todo question : do I delete the file afterwards?
		} Catch {
			Write-Output ("$NetworkKeyBackup is not writable! Choose another location!") -ForegroundColor Red
			_NetworkKeyBackup -wantToSave $True
		}
	}

	Function _DecryptAndWait () {
		Param (
			[string]$Letter
		)

		Disable-BitLocker -MountPoint $Letter
		Write-Output "decryption in progress for $Letter"
		While ((Get-BitLockerVolume -MountPoint $Letter).EncryptionPercentage -gt 0 ) {
			Start-Sleep -Seconds 20
		}
		Write-Output "$Letter is fully decrypted"
	}

	Function _EncryptSytemDrive() {
		Param (
			[string]$NetworkKeyBackupFolder
		)

		#$title = 'Activation bitlocker'
		#$query = 'Do you want to use PIN?'
		#$choices = '&Yes', '&No'
		#$decision = $Host.UI.PromptForChoice($title, $query, $choices, 1)
		$UseCodePin = Read-Host -Prompt "Activation bitlocker - Do you want to use PIN code? [Y/n]"
		If ($UseCodePin.ToLower() -ne "n") {
			$Secure = Read-Host -AsSecureString -Prompt "Code PIN (6 digits)"
			Write-Output "Enabling bitlocker on system drive $SystemDrive with PIN code"
			Enable-BitLocker -MountPoint "$SystemDrive" -TpmAndPinProtector -Pin $Secure -EncryptionMethod "XtsAes256" 3> $null
			Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 2 `
				-Message "SWMB: Enable bitlocker on system drive $SystemDrive with PIN code"
		} Else {
			Write-Output "Enabling bitlocker on system drive $SystemDrive without PIN code"
			Enable-BitLocker -MountPoint "$SystemDrive" -TpmProtector -EncryptionMethod "XtsAes256"
			Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 3 `
				-Message "SWMB: Enable bitlocker on system drive $SystemDrive without PIN code"
		}

		Write-Output "Add system drive key"
		Add-BitLockerKeyProtector -MountPoint "$SystemDrive" -RecoveryPasswordProtector
		Write-Output "Copy system drive key on $SystemDrive"
		$PathKey = $SystemDrive + "\" + ${Env:ComputerName} + "-bitlockerRecoveryKey-" + $DateNow + "-" + $SystemDriveLetter + ".txt"
		If (Test-Path -Path $PathKey -PathType leaf) {
			$oldKey = $SystemDrive + "\" + ${Env:ComputerName} + "-bitlockerRecoveryKey-" + $DateNow + "-" + $SystemDriveLetter + ".txt.old"
			Write-Output "Warning: $PathKey already exist => rename with .old extension"
			If (Test-Path -Path $oldKey -PathType leaf) {
				Write-Output "Warning: delete before old key $oldKey"
				Remove-Item -Path $oldKey -Force
			}
			Rename-Item -Path $PathKey -NewName $oldKey
		}
		(Get-BitLockerVolume -MountPoint $SystemDriveLetter).KeyProtector > $PathKey
		# acl on key see https://stackoverflow.com/a/43317244
		icacls.exe $PathKey /Reset
		icacls.exe $PathKey /Grant:r "$((Get-Acl -Path $PathKey).Owner):(R)"
		icacls.exe $PathKey /InheritanceLevel:r

		# copy key if $NetworkKeyBackup
		If (!([string]::IsNullOrEmpty($NetworkKeyBackupFolder))) {
			Try {
				Copy-Item $PathKey -Destination $NetworkKeyBackupFolder -ErrorAction Continue
			} Catch {
				$Message = "Error backuping $PathKey on network folder $NetworkKeyBackupFolder"
				Write-Output $Message
				Write-EventLog -LogName Application -Source "SWMB" -EntryType Warning -EventID 4 -Message $Message
			}
		}
	}

	# We treat all partitions that have an associated letter and that are of type fixed
	# ie we don't take into account the usb keys
	Function _EncryptNonSytemDrives() {
		Param (
			[string]$NetworkKeyBackupFolder
		)

		# Other drives encryption
		$ListVolume = Get-volume | Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter -ne $SystemDriveLetter }
		ForEach ($Volume in $ListVolume) {
			If (!($Volume.DriveLetter)) { continue }

			$Letter = $Volume.DriveLetter
			$LetterColon = $Letter + ":"
			#If (Test-Path $Letter){
			$cryptDrive = Read-Host -Prompt "The $Letter drive is not removable and hosts a file system. Do you want to enable encryption on this drive? [Y/n]"
			If ($cryptDrive.ToLower() -eq "n") { continue }

			# Test if partition is already encrypted (like for C:)
			If ((Get-BitLockerVolume $Letter).ProtectionStatus -eq "On") {
				Write-Output "Bitlocker on drive $Letter is already ON!"
				continue
			}

			Write-Output "Bitlocker activation on drive $Letter is going to start"

			Enable-BitLocker -MountPoint $Letter -RecoveryPasswordProtector -UsedSpaceOnly -EncryptionMethod "XtsAes256" 3> $null
			Resume-BitLocker -MountPoint $Letter
			Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 1 -Message "SWMB: Bitlocker enable drive $Letter"

			Write-Output "Copy drive $Letter key"
			$BackupFile = $SystemDrive + "\" + ${Env:ComputerName} + "-bitlockerRecoveryKey-" + $DateNow + "-" + $Letter + ".txt"
			Write-Output $BackupFile
			(Get-BitLockerVolume -MountPoint $LetterColon).KeyProtector > $BackupFile

			icacls.exe $BackupFile /Reset
			icacls.exe $BackupFile /Grant:r "$((Get-Acl -Path $BackupFile).Owner):(R)"
			icacls.exe $BackupFile /InheritanceLevel:r
			Write-Output "Bitlocker activation on drive $Letter ended with success"

			# copy key if $NetworkKeyBackup
			If (!([string]::IsNullOrEmpty($NetworkKeyBackupFolder))) {
				Try {
					Copy-Item $BackupFile -Destination $NetworkKeyBackupFolder -ErrorAction Continue
				} Catch {
					$Message = "Error backuping $BackupFile on network folder $NetworkKeyBackupFolder"
					Write-Output $Message
					Write-EventLog -LogName Application -Source "SWMB" -EntryType Warning -EventID 4 -Message $Message
				}
			}

			# AutoUnlock
			If ((Get-BitLockerVolume ${Env:SystemDrive}).ProtectionStatus -eq "On") {
				Enable-BitLockerAutoUnlock -MountPoint $Letter
			} Else {
				$TaskTrigger  = New-ScheduledTaskTrigger -AtStartup
				$TaskUser     = "NT AUTHORITY\SYSTEM"
				$KeyProtector = (Get-BitLockerVolume -MountPoint $Letter).KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'} | Select-Object -Property RecoveryPassword
				$Password     = $KeyProtector.RecoveryPassword
				$TaskName     = 'swmb-bitlocker-' + $Letter + '-' + (Get-Random -Minimum 1000 -Maximum 9999)
				$TaskAction   = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command &{Unlock-BitLocker -MountPoint $Letter -RecoveryPassword $Password ; Enable-BitLockerAutoUnlock -MountPoint $Letter ; Write-EventLog -LogName Application -Source 'SWMB' -EntryType Information -EventID 5 -Message 'SWMB: Bitlocker finish ScheduledTask $TaskName' ; Unregister-ScheduledTask $TaskName -confirm:`$False}"
				Register-ScheduledTask -Force -TaskName $TaskName -Trigger $TaskTrigger -User $TaskUser -Action $TaskAction -RunLevel Highest
				Write-EventLog -LogName Application -Source "SWMB" -EntryType Information -EventID 4 -Message "SWMB: Bitlocker add ScheduledTask $TaskName"
				#$cmd     = "&{Unlock-BitLocker -MountPoint $Letter -RecoveryPassword $Password ; Enable-BitLockerAutoUnlock -MountPoint $Letter}"
				#Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "Enable-BitLockerAutoUnlock-$Letter" -Value "powershell.exe -noexit -command '$cmd'"
			}
		}
	}

	Function _EnforceCryptGPO() {
		# All registry keys :
		# https://admx.help/HKLM/Software/Policies/Microsoft/FVE
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\" -Name "FVE"
		}

		# 256 bits# XTS-AES 256-bit
		# https://admx.help/?Category=MDOP&Policy=Microsoft.Policies.BitLockerManagement::BLEncryptionMethodWithXts_Name

		# Encryption method for operating system drives
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsOs" -Value 7
		# Encryption method for fixed data drives
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsFdv" -Value 7
		# Encryption method for removable data drives
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsRdv" -Value 7

		# Additional authentication at startup
		# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.VolumeEncryption::ConfigureAdvancedStartup_Name
		# If you enable this policy setting, users can configure advanced startup options in the BitLocker setup wizard.
		# If you disable or do not configure this policy setting, users can configure only basic options on computers with a TPM.
		# Active this GPO
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "UseAdvancedStartup" -Value 1
		# Don't allow bitlocker without TPM
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EnableBDEWithNoTPM" -Value 0
		# Dont allow =>0, allow =>2, require=>1
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "UseTPM" -Value 2
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "UseTPMPIN" -Value 2
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "UseTPMKey" -Value 2
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "UseTPMKeyPIN" -Value 2
		# Disable PIN change by a standard user
		# https://admx.help/?Category=Windows_8.1_2012R2&Policy=Microsoft.Policies.VolumeEncryption::DisallowStandardUsersCanChangePIN_Name
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "DisallowStandardUserPINReset" -Value 1

		# Allowed recovery method
		# https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.VolumeEncryption::OSRecoveryUsage_Name
		# Active this GPO
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSRecovery" -Value 1
		# Allow data recovery agent
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSManageDRA" -Value 1
		# Allow 48-digit recovery password
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSRecoveryPassword" -Value 2
		# Allow 256-bit recovery key
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSRecoveryKey" -Value 2
		# Omit recovery options from the BitLocker setup wizard
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSHideRecoveryPage" -Value 0
		# Don't Save BitLocker recovery information to AD DS for operating system drives
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSActiveDirectoryBackup" -Value 0
		# Store recovery passwords and key packages
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSActiveDirectoryInfoToStore" -Value 1
		# Do not enable BitLocker until recovery information is stored to AD DS for operating system drives
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "OSRequireActiveDirectoryBackup" -Value 0

		# Update GPO
		gpupdate
		# Invoke-GPUpdate -Force # don't work on all powershell versions
	}

	Function _EncryptAllDrives() {
		# Preliminary Test on SecureBoot and TPM
		Try {
			If (!(Confirm-SecureBootUEFI)) {
				Write-Error "SecureBoot is OFF!"
				Return
			}
		}
		Catch {
			Write-Error "Error SecureBoot: Verify if your BIOS support SecureBoot"
			Write-Warning "exit"
			Return
		}
		If (!(Get-Tpm).TpmReady) {
			Write-Output "Get-TPM informations"
			Get-Tpm
			Write-Error "TPM not ready!"
			Return
		}

		$DateNow           = (Get-Date).ToString("yyyyMMddhhmm")
		$SystemDrive       = ${Env:SystemDrive}
		$SystemDriveLetter = $SystemDrive.Substring(0, 1)

		$DrivePStatus = (Get-BitLockerVolume $SystemDrive).ProtectionStatus
		$DriveVStatus = (Get-BitLockerVolume $SystemDrive).VolumeStatus
		$DriveEMethod = (Get-BitLockerVolume $SystemDrive).EncryptionMethod

		If (($DriveVStatus -eq "FullyDecrypted") -and ((Get-BitLockerVolume $SystemDrive).KeyProtector)) {
			Write-Warning "Your are FullyDecrypted with a Key protector. Your computer need reboot"
			Return
		}

		If ($DriveEMethod -eq "None") {
			# use network to save key ?
			$NetworkBackup = _NetworkKeyBackup -wantToSave $False

			# Disk ready for encryption
			$applyGPO = Read-Host -Prompt "Your disk is ready for encryption. Are you agree to apply Resinfo GPO and start encryption [Y/n]"
			If ($applyGPO.ToLower() -eq "n") {
				Write-Warning "Stop script. Your drive is not encrypted"
				Return
			}
			_EnforceCryptGPO
			_EncryptSytemDrive -networkKeyBackupFolder $NetworkBackup
			_EncryptNonSytemDrives -networkKeyBackupFolder $NetworkBackup

			$reboot = Read-Host -Prompt "The computer must be restarted to finish the system disk encryption. Reboot now? [Y/n]"
			If ($reboot.ToLower() -ne "n") {
				Restart-Computer -Force
			}
		} ElseIf ($DriveEMethod -eq "XtsAes256") {
			# Disk crypt but...
			If (($DriveVStatus -eq "DecryptionInProgress") -or ($DriveVStatus -eq "EncryptionInProgress")) {
				Write-Warning "Operation in progress on your ${Env:SystemDrive} => $DriveVStatus"
				Write-Output ("Stop and try later - Encryption percentage = " + (Get-BitLockerVolume $SystemDrive).EncryptionPercentage)
				Return
			} Else {
				If ($DrivePStatus -eq "On") {
					Write-Warning "Your ${Env:SystemDrive} is already encrypt (XtsAes256) and activated"
					Write-Output "Nothing to do on System drive !"

					# use network to save key ?
					$NetworkBackup = _NetworkKeyBackup -wantToSave $False
					_EncryptNonSytemDrives -networkKeyBackupFolder $NetworkBackup
					Return
				} Else {
					Write-Output "Bitlocker is suspend, resume with :"
					Write-Output "Resume-BitLocker $SystemDrive ... and save your key"
					Return
				}
			}
		} ElseIf ($DriveEMethod -ne "XtsAes256") {
			# Disk crypt but not with XtsAes256
			Write-Warning "Your ${Env:SystemDrive} is not encrypt in XtsAes256, the encryption is $DriveEMethod"
			$decrypt = Read-Host -Prompt "Do you want to decrypt all fixed drive [Y/n]"
			If ($decrypt.ToLower() -ne "n") {
				TweakDisableBitlocker
				Write-Output "Wait for the end of decryption and launch this script again"
			}
			Else {Write-Output "You can decrypt with command : .\swmb.ps1 DisableBitlocker"}
			Return
		}
	}

	$AskCrypt = Read-Host -Prompt "Activation bitlocker - Do you really want to crypt your system? [Y/n]"
	If ($AskCrypt.ToLower() -eq "n") {
		Return
	}

	If (!(Get-Eventlog -LogName Application -Source "SWMB")){
		New-EventLog -LogName Application -Source "SWMB"
	}

	_EncryptAllDrives

	Write-Output "`nActivation bitlocker - Press any key to finish..."
	[Console]::ReadKey($True) | Out-Null
}

# Disable
Function TweakDisableBitlocker { # RESINFO
	$ListVolume = Get-volume | Where-Object { $_.DriveType -eq "Fixed" }
	ForEach ($Volume in $ListVolume) {
		If (!($Volume.DriveLetter)) { continue }
		$Letter = $Volume.DriveLetter
		Disable-BitLocker $Letter
	}
}

################################################################

# Suspend or Resume Bitlocker
# Set
Function TweakSetBitlockerActive { # RESINFO
	Write-Output "Setting bitlocker on all crypt drive (Resume)..."
	Get-BitLockerVolume | Resume-BitLocker
}

# Unset
Function TweakUnsetBitlockerActive { # RESINFO
	Write-Output "Unsetting bitlocker on all crypt drive (Suspend)..."
	Get-BitLockerVolume | Suspend-BitLocker -RebootCount 0
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
