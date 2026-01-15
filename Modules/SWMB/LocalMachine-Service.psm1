##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Service Tweaks
##########

################################################################

# Disable offering of Malicious Software Removal Tool through Windows Update
Function TweakDisableUpdateMSRT {
	Write-Output "Disabling Malicious Software Removal Tool offering..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
}

# Enable offering of Malicious Software Removal Tool through Windows Update
Function TweakEnableUpdateMSRT {
	Write-Output "Enabling Malicious Software Removal Tool offering..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -ErrorAction SilentlyContinue
}

################################################################

# Disable offering of drivers through Windows Update
# Note: This doesn't work properly if you use a driver intended for another hardware model. E.g. Intel I219-V on WinServer works only with I219-LM driver.
# Therefore Windows update will repeatedly try and fail to install I219-V driver indefinitely even if you use the tweak.
Function TweakDisableUpdateDriver {
	Write-Output "Disabling driver offering through Windows Update..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1
}

# Enable offering of drivers through Windows Update
Function TweakEnableUpdateDriver {
	Write-Output "Enabling driver offering through Windows Update..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "SearchOrderConfig" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
}

################################################################

# Enable receiving updates for other Microsoft products via Windows Update
Function TweakEnableUpdateMSProducts {
	Write-Output "Enabling updates for other Microsoft products..."
	(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") | Out-Null
}

# Disable receiving updates for other Microsoft products via Windows Update
Function TweakDisableUpdateMSProducts {
	Write-Output "Disabling updates for other Microsoft products..."
	If ((New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object { $_.ServiceID -eq "7971f918-a847-4430-9279-4a52d1efe18d"}) {
		(New-Object -ComObject Microsoft.Update.ServiceManager).RemoveService("7971f918-a847-4430-9279-4a52d1efe18d") | Out-Null
	}
}

################################################################

# Disable Windows Update automatic downloads
Function TweakDisableUpdateAutoDownload {
	Write-Output "Disabling Windows Update automatic downloads..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 2
}

# Enable Windows Update automatic downloads
Function TweakEnableUpdateAutoDownload {
	Write-Output "Enabling Windows Update automatic downloads..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -ErrorAction SilentlyContinue
}

################################################################

# Disable automatic restart after Windows Update installation
# The tweak is slightly experimental, as it registers a dummy debugger for MusNotification.exe
# which blocks the restart prompt executable from running, thus never schedulling the restart
Function TweakDisableUpdateRestart {
	Write-Output "Disabling Windows Update automatic restart..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Name "Debugger" -Type String -Value "cmd.exe"
}

# Enable automatic restart after Windows Update installation
Function TweakEnableUpdateRestart {
	Write-Output "Enabling Windows Update automatic restart..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Name "Debugger" -ErrorAction SilentlyContinue
}

################################################################

# Disable nightly wake-up for Automatic Maintenance and Windows Updates
Function TweakDisableMaintenanceWakeUp {
	Write-Output "Disabling nightly wake-up for Automatic Maintenance..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -Type DWord -Value 0
}

# Enable nightly wake-up for Automatic Maintenance and Windows Updates
Function TweakEnableMaintenanceWakeUp {
	Write-Output "Enabling nightly wake-up for Automatic Maintenance..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -ErrorAction SilentlyContinue
}

################################################################

# Disable Automatic Restart Sign-on - Applicable since 1903
# See https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/winlogon-automatic-restart-sign-on--arso-
Function TweakDisableAutoRestartSignOn {
	Write-Output "Disabling Automatic Restart Sign-on..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -Type DWord -Value 1
}

# Enable Automatic Restart Sign-on - Applicable since 1903
Function TweakEnableAutoRestartSignOn {
	Write-Output "Enabling Automatic Restart Sign-on..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -ErrorAction SilentlyContinue
}

################################################################

# Disable Autorun for all drives
Function TweakDisableAutorun {
	Write-Output "Disabling Autorun for all drives..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
}

# Enable Autorun for removable drives
Function TweakEnableAutorun {
	Write-Output "Enabling Autorun for all drives..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
}

################################################################

# Disable System Restore for system drive - Not applicable to Server
# Note: This does not delete already existing restore points as the deletion of restore points is irreversible. In order to do that, run also following command.
# vssadmin Delete Shadows /For=${Env:SystemDrive} /Quiet
Function TweakDisableRestorePoints {
	Write-Output "Disabling System Restore for system drive..."
	Disable-ComputerRestore -Drive "${Env:SystemDrive}"
}

# Enable System Restore for system drive - Not applicable to Server
# Note: Some systems (notably VMs) have maximum size allowed to be used for shadow copies set to zero. In order to increase the size, run following command.
# vssadmin Resize ShadowStorage /On=${Env:SystemDrive} /For=${Env:SystemDrive} /MaxSize=10GB
Function TweakEnableRestorePoints {
	Write-Output "Enabling System Restore for system drive..."
	Enable-ComputerRestore -Drive "${Env:SystemDrive}"
}

################################################################

# Disable scheduled defragmentation task
Function TweakDisableDefragmentation {
	Write-Output "Disabling scheduled defragmentation..."
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
}

# Enable scheduled defragmentation task
Function TweakEnableDefragmentation {
	Write-Output "Enabling scheduled defragmentation..."
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
}

################################################################

# Stop and disable Superfetch service
Function TweakDisableSuperfetch {
	Write-Output "Disabling and stopping Superfetch service..."
	Stop-Service "SysMain" -WarningAction SilentlyContinue
	Set-Service "SysMain" -StartupType Disabled
}

# Start and enable Superfetch service
Function TweakEnableSuperfetch {
	Write-Output "Enabling and starting Superfetch service..."
	Set-Service "SysMain" -StartupType Automatic
	Start-Service "SysMain" -WarningAction SilentlyContinue
}

################################################################

# Stop and disable Windows Search indexing service
Function TweakDisableIndexing {
	Write-Output "Disabling and stopping Windows Search indexing service..."
	Stop-Service "WSearch" -WarningAction SilentlyContinue
	Set-Service "WSearch" -StartupType Disabled
}

# Start and enable Windows Search indexing service
Function TweakEnableIndexing {
	Write-Output "Enabling and starting Windows Search indexing service..."
	Set-Service "WSearch" -StartupType Automatic
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "DelayedAutoStart" -Type DWord -Value 1
	Start-Service "WSearch" -WarningAction SilentlyContinue
}

################################################################

# Enable NTFS paths with length over 260 characters
Function TweakEnableNTFSLongPaths {
	Write-Output "Enabling NTFS paths with length over 260 characters..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1
}

# Disable NTFS paths with length over 260 characters
Function TweakDisableNTFSLongPaths {
	Write-Output "Disabling NTFS paths with length over 260 characters..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 0
}

################################################################

# Disable updating of NTFS last access timestamps
Function TweakDisableNTFSLastAccess {
	Write-Output "Disabling updating of NTFS last access timestamps..."
	# User Managed, Last Access Updates Disabled
	fsutil behavior set DisableLastAccess 1 | Out-Null
}

# Enable updating of NTFS last access timestamps
Function TweakEnableNTFSLastAccess {
	Write-Output "Enabling updating of NTFS last access timestamps..."
	If ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		# System Managed, Last Access Updates Enabled
		fsutil behavior set DisableLastAccess 2 | Out-Null
	} Else {
		# Last Access Updates Enabled
		fsutil behavior set DisableLastAccess 0 | Out-Null
	}
}

################################################################

# Set BIOS time to UTC
Function TweakSetBIOSTimeUTC {
	Write-Output "Setting BIOS time to UTC..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
}

# Set BIOS time to local time
Function TweakSetBIOSTimeLocal {
	Write-Output "Setting BIOS time to Local time..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -ErrorAction SilentlyContinue
}

################################################################

# Enables/disables Hibernation functionality
# Do not use on Server with automatically started Hyper-V hvboot service as it may lead to BSODs (Win10 with Hyper-V is fine)
# Hibernate https://uwyo.teamdynamix.com/TDClient/1940/Portal/KB/ArticleDet?ID=144174

# Enable Hibernation
Function TweakEnableHibernation {
	Write-Output "Enabling Hibernation..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type DWord -Value 1
	powercfg /HIBERNATE ON 2>&1 | Out-Null
}

# Disable Hibernation
Function TweakDisableHibernation {
	Write-Output "Disabling Hibernation..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type DWord -Value 0
	powercfg /HIBERNATE OFF 2>&1 | Out-Null
}

# View Hibernation
Function TweakViewHibernation { # RESINFO
	Write-Output "Viewing Hibernate..."
	$HiberActive = $True
	$PowercfgOutput = powercfg.exe /A

	# On cherche une ligne qui mentionne que la veille prolongée est DISPONIBLE
	ForEach ($Line in $PowercfgOutput) {
		# Write-Output "    :: $Line"
		If ($Line -match "Hibernation has not been enabled|veille prolongée.*pas été activée") {
			$HiberActive = $False
			Break
		}
	}

	If ($HiberActive) {
		Write-Output " Hibernate is activated"
	} Else {
		Write-Output " Hibernate is deactivated"
	}
}

################################################################

# Disable Sleep start menu and keyboard button
Function TweakDisableSleepButton {
	Write-Output "Disabling Sleep start menu and keyboard button..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type DWord -Value 0
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
}

# Enable Sleep start menu and keyboard button
Function TweakEnableSleepButton {
	Write-Output "Enabling Sleep start menu and keyboard button..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type DWord -Value 1
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
}

################################################################

# Disable display and sleep mode timeouts
Function TweakDisableSleepTimeout {
	Write-Output "Disabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 0
	powercfg /X monitor-timeout-dc 0
	powercfg /X standby-timeout-ac 0
	powercfg /X standby-timeout-dc 0
}

# Enable display and sleep mode timeouts
Function TweakEnableSleepTimeout {
	Write-Output "Enabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 10
	powercfg /X monitor-timeout-dc 5
	powercfg /X standby-timeout-ac 30
	powercfg /X standby-timeout-dc 15
}

################################################################

# Disable Fast Startup
Function TweakDisableFastStartup {
	Write-Output "Disabling Fast Startup..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
}

# Enable Fast Startup
Function TweakEnableFastStartup {
	Write-Output "Enabling Fast Startup..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 1
}

################################################################

# Disable automatic reboot on crash (BSOD)
Function TweakDisableAutoRebootOnCrash {
	Write-Output "Disabling automatic reboot on crash (BSOD)..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type DWord -Value 0
}

# Enable automatic reboot on crash (BSOD)
Function TweakEnableAutoRebootOnCrash {
	Write-Output "Enabling automatic reboot on crash (BSOD)..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type DWord -Value 1
}

################################################################

# Set a target version
# https://docs.microsoft.com/en-us/windows/release-health/release-information
# If you don't update this policy before the device reaches end of service, the device will automatically be updated once it is 60 days past end of service for its version.
# If you specify a TargetReleaseVersion the same as the current version, Windows 10 will stay on this version until it reaches end of service.
# If you specify a TargetReleaseVersion higher than the current version, Windows 10 will directly update only to the specified version even if a higher version is available.
# Enable
Function TweakSetTargetRelease { # RESINFO
	Write-Output "Setting Target Release to $($Global:SWMB_Custom.$OSShortName.TargetReleaseVersionInfo)..."
	$OSShortName = SWMB_GetOSShortName
	Write-Output " OS $OSShortName, Product and Target Release to $($Global:SWMB_Custom.$OSShortName.ProductVersion) / $($Global:SWMB_Custom.$OSShortName.TargetReleaseVersionInfo)"
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "ProductVersion" -value  $Global:SWMB_Custom.$OSShortName.ProductVersion -Type String -Force
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "TargetReleaseVersion" -value '00000001' -Type DWord -Force
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "TargetReleaseVersionInfo" -value $Global:SWMB_Custom.$OSShortName.TargetReleaseVersionInfo -Type String -Force
}

# Disable
Function TweakUnsetTargetRelease { # RESINFO
	Write-Output "Unsetting Target Release (No Target Release)..."
	Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "ProductVersion" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "TargetReleaseVersion" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue
}

# View
Function TweakViewTargetRelease { # RESINFO
	Write-Output "Viewing Target Release (nothing = no target release)..."
	Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue
}

################################################################

# Create a unique Host Id if it doesn't already exist,
# which will be used in webhooks, for example, to uniquely identify each host
# We could also use the GUID at HKLM:\SYSTEM\HardwareConfig that seems to be unique
#  HKLM:\SYSTEM\HardwareConfig\{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
#  HKLM:\SYSTEM\HardwareConfig LastConfig {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
#  (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID

# Enable
Function TweakEnableSWMBUniqueId { # RESINFO
	Write-Output "Enabling SWMB Unique HostId..."
	$KeyId = Get-Item -LiteralPath 'HKLM:\Software\WOW6432Node\SWMB' -ErrorAction SilentlyContinue
	If (!(($KeyId) -And ($KeyId.GetValue('HostId', $Null) -ne $Null))) {
		$HostId = (New-Guid).ToString()
		# Write-Output " Warning: create a registry key HostId set to = $HostId"
		If (!(Test-Path 'HKLM:\Software\WOW6432Node\SWMB')) {
			New-Item -Path 'HKLM:\Software\WOW6432Node\SWMB' | Out-Null
		}
		Set-ItemProperty -Path 'HKLM:\Software\WOW6432Node\SWMB' -Name 'HostId' -Type String -Value "$HostId"
	#} Else {
	#	$HostId = (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\SWMB' -Name 'HostId').HostId
	#	Write-Output " Info: the registry key for this HostId is = $HostId"
	}
}

# Disable
Function TweakDisableSWMBUniqueId { # RESINFO
	Write-Output "Disabling SWMB Unique HostId..."
	Remove-ItemProperty -Path 'HKLM:\Software\WOW6432Node\SWMB' -Name 'HostId' -ErrorAction SilentlyContinue
}

# View
Function TweakViewSWMBUniqueId { # RESINFO
	Write-Output "Viewing SWMB Unique HostId..."
	$KeyId = Get-Item -LiteralPath 'HKLM:\Software\WOW6432Node\SWMB' -ErrorAction SilentlyContinue
	If (!(($KeyId) -And ($KeyId.GetValue('HostId', $Null) -ne $Null))) {
		Write-Output " Warning: no HostId"
	} Else {
		$HostId = (Get-ItemProperty -Path 'HKLM:\Software\WOW6432Node\SWMB' -Name 'HostId').HostId
		Write-Output " Info: the HostId is $HostId"
	}
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
