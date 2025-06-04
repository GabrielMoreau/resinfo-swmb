##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Application Tweaks
##########

################################################################

# Disable Xbox features - Not applicable to Server
Function TweakDisableXboxFeatures_CU {
	Write-Output "Disabling Xbox features for CU. See DisableXboxFeatures..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
}

# Enable Xbox features - Not applicable to Server
Function TweakEnableXboxFeatures_CU {
	Write-Output "Enabling Xbox features for CU. See EnableXboxFeatures..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 1
}

################################################################

# Disable Fullscreen optimizations
Function TweakDisableFullscreenOptims_CU {
	Write-Output "Disabling Fullscreen optimizations for CU..."
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWord -Value 2
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 2
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 1
}

# Enable Fullscreen optimizations
Function TweakEnableFullscreenOptims_CU {
	Write-Output "Enabling Fullscreen optimizations for CU..."
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 0
	Remove-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 0
}

################################################################

# Disable Windows Media Player online access - audio file metadata download, radio presets, DRM.
Function TweakDisableMediaOnlineAccess_CU {
	Write-Output "Disabling Windows Media Player online access for CU. See DisableMediaOnlineAccess..."
	If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer")) {
		New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventMusicFileMetadataRetrieval" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventRadioPresetsRetrieval" -Type DWord -Value 1
}

# Enable Windows Media Player online access
Function TweakEnableMediaOnlineAccess_CU {
	Write-Output "Enabling Windows Media Player online access for CU. See EnableMediaOnlineAccess..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventMusicFileMetadataRetrieval" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventRadioPresetsRetrieval" -ErrorAction SilentlyContinue
}

################################################################

# Uninstall OneDrive - Not applicable to Server
Function TweakUninstallOneDrive_CU { # RESINFO
	Write-Output "Uninstalling OneDrive for CU..."
	@(Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall') |
		Get-ItemProperty |
		Where-Object { $_.DisplayName -like 'Microsoft OneDrive*' } |
		ForEach {
			$UninstallString = ($_.UninstallString).Replace('"',"")
			$Version = $_.DisplayVersion
			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe'
			$Args = $UninstallSplit[1].Trim()
			If (Test-Path -Path "$Exe") {
				Write-Output "Uninstalling OneDrive version $Version"
				Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
				Start-Sleep -Seconds 1
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru
				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill OneDrive uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: OneDrive uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
			Start-Sleep -Seconds 1
		}
}

# Install OneDrive - Not applicable to Server
Function TweakInstallOneDrive_CU { # RESINFO
	Write-Output "Installing OneDrive for CU..."
	$Exe = "${Env:SystemRoot}\SysWOW64\OneDriveSetup.exe"
	$Args = '/silent'
	If (!(Test-Path $Exe)) {
		$Exe = "${Env:SystemRoot}\System32\OneDriveSetup.exe"
	}
	Start-Process -FilePath "$Exe" -ArgumentList "$Args" -NoNewWindow -ErrorAction 'SilentlyContinue'
}

# View
Function TweakViewOneDrive_CU { # RESINFO
	Write-Output "Viewing OneDrive product for CU..."
	Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall' |
		Get-ItemProperty |
		Where-Object {$_.DisplayName -like 'Microsoft OneDrive*' } |
		Select-Object -Property DisplayName, DisplayVersion, PSChildName
}

################################################################

# Disable
Function TweakDisableWindowsCopilot_CU { # RESINFO
	Write-Output "Disabling (Turn Off) Windows Copilot for CU..."
	If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot")) {
		New-Item -Path  "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
	}
	Set-ItemProperty -Path  "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
}

# Enable Copilot
Function TweakEnableWindowsCopilot_CU { # RESINFO
	Write-Output "Enabling (Turn On) for Windows Copilot (Default) for CU..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
}

# View Copilot
Function TweakViewWindowsCopilot_CU { # RESINFO
	Write-Output "Viewing Windows Copilot for CU  (not exist: Enable, 0: Disable)..."
	Get-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
