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

# Disable Shared Experiences - Applicable since 1703. Not applicable to Server
# This setting can be set also via GPO, however doing so causes reset of Start Menu cache. See https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/145 for details
Function TweakDisableSharedExperiences_CU {
	Write-Output "Disabling Shared Experiences for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 0
}

# Enable Shared Experiences - Applicable since 1703. Not applicable to Server
Function TweakEnableSharedExperiences_CU {
	Write-Output "Enabling Shared Experiences for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 1
}

################################################################

# Enable Clipboard History - Applicable since 1809. Not applicable to Server
Function TweakEnableClipboardHistory_CU {
	Write-Output "Enabling Clipboard History for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 1
}

# Disable Clipboard History - Applicable since 1809. Not applicable to Server
Function TweakDisableClipboardHistory_CU {
	Write-Output "Disabling Clipboard History for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -ErrorAction SilentlyContinue
}

################################################################

# See also AutoRun / NoDriveTypeAutoRun
# Disable Autoplay
Function TweakDisableAutoplay_CU {
	Write-Output "Disabling Autoplay for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
}

# Enable Autoplay
Function TweakEnableAutoplay_CU {
	Write-Output "Enabling Autoplay for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 0
}

# View
Function TweakViewAutoplay_CU { # RESINFO
	Write-Output "Viewing Autoplay for CU (0 or not exist: Enable, 1: Disable)..."
	$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers'
	$RegFields = @("DisableAutoplay")

	$Props = Get-ItemProperty -Path $RegPath
	ForEach ($Field in $RegFields) {
		If ($Props.PSObject.Properties.Name -notcontains $Field) {
			Write-Output " ${Field}: not exist"
			Continue
		}
		Write-Output " ${Field}: $($Props.$Field)"
	}
}

################################################################

# Disable Autorun on all kinds of drives (NoDriveTypeAutorun)
# https://system32.eventsentry.com/stig/search?query=NoDriveTypeAutoRun
# https://learn.microsoft.com/en-us/windows/win32/shell/autoplay-reg
# https://superuser.com/questions/37569/disable-autoplay-of-audio-cds-and-usb-drives-with-registry#37575

# Disable
Function TweakDisableAutorun_CU {
	Write-Output "Disabling Autorun for CU..."
	$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
	Set-ItemProperty -Path $RegPath -Name "NoDriveTypeAutorun" -Type DWord -Value 0xFF
}

# Enable
Function TweakEnableAutorun_CU {
	Write-Output "Enabling Autorun for CU..."
	$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
	Remove-ItemProperty -Path $RegPath -Name "NoDriveTypeAutorun" -ErrorAction SilentlyContinue
}

# View
Function TweakViewAutorun_CU { # RESINFO
	Write-Output "Viewing Autorun for CU (0 or not exist: Enable, 22: Disable (All drive))..."
	$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
	$RegFields = @("NoDriveTypeAutorun")

	$Props = Get-ItemProperty -Path $RegPath
	ForEach ($Field in $RegFields) {
		If ($Props.PSObject.Properties.Name -notcontains $Field) {
			Write-Output " ${Field}: not exist"
			Continue
		}
		Write-Output " ${Field}: $($Props.$Field)"
	}
}

################################################################

# Enable Storage Sense - automatic disk cleanup - Applicable since 1703
Function TweakEnableStorageSense_CU {
	Write-Output "Enabling Storage Sense for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "StoragePoliciesNotified" -Type DWord -Value 1
}

# Disable Storage Sense - Applicable since 1703
Function TweakDisableStorageSense_CU {
	Write-Output "Disabling Storage Sense for CU..."
	Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
}

################################################################

# Disable Recycle Bin - Files will be permanently deleted without placing into Recycle Bin
Function TweakDisableRecycleBin_CU {
	Write-Output "Disabling Recycle Bin for CU..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecycleFiles" -Type DWord -Value 1
}

# Enable Recycle Bin
Function TweakEnableRecycleBin_CU {
	Write-Output "Enabling Recycle Bin for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecycleFiles" -ErrorAction SilentlyContinue
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
