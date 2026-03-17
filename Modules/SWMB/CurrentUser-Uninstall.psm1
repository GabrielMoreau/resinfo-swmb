################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2026, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2023 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################
###### Software Uninstall Only
################################################################

################################################################

# Suppress BalenaEtcher
# https://silentinstallhq.com/etcher-silent-install-how-to-guide
# Uninstall
Function TweakUninstallBalenaEtcher_CU { # RESINFO
	Write-Output "Uninstalling BalenaEtcher software for CU..."
	$RefName = 'BalenaEtcher'
	@(Get-ChildItem -Recurse "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }

			$DisplayVersion = $App.DisplayVersion
			$UninstallString = $App.UninstallString
			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe"'
			$Args = '/S /currentuser'

			Write-Output "Uninstalling $RefName version $DisplayVersion from CurrentUser"
			# Write-Output " $Exe $Args"
			$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

			$Timeouted = $Null # Reset any previously set timeout
			# Wait up to 180 seconds for normal termination
			$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
			If ($Timeouted) {
				# Terminate the process
				$Proc | Kill
				Write-Output "Error: kill $RefName uninstall exe"
				# Next tweak now
				Return
			} ElseIf (($Proc.ExitCode -ne 0) -And ($Proc.ExitCode -ne 19)) {
				Write-Output "Error: $RefName uninstall return code $($Proc.ExitCode)"
				# Next tweak now
				Return
			}
		}
}

# balenaEtcher 1.18.8  / 1.18.8         / d2f3b6c7-6f49-59e2-b8a5-f72e33900c2b / "C:\Users\xxxxxxxxx\AppData\Local\Programs\balena-etcher\Uninstall balenaEtcher.exe" /currentuser (C) Balena Ltd.
# View
Function TweakViewBalenaEtcher_CU { # RESINFO
	Write-Output "Viewing BalenaEtcher software for CU..."
	$RefName = 'BalenaEtcher'
	@(Get-ChildItem -Recurse "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }

			$DisplayVersion = $App.DisplayVersion
			$Publisher = $App.Publisher
			$KeyProduct = $Key | Split-Path -Leaf
			$Exe = $App.UninstallString
			"# {0,-20} / {1,-14} / {2} / {3} (C) {4}" -F $DisplayName, $DisplayVersion, $KeyProduct, $Exe, $Publisher
		} | Sort-Object
}

################################################################

# Suppress Telegram
# https://silentinstallhq.com/telegram-desktop-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallTelegram_CU { # RESINFO
	Write-Output "Uninstalling Telegram software for CU..."
	$RefName = 'Telegram'
	@(Get-ChildItem -Recurse "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }

			$DisplayVersion = $App.DisplayVersion
			$UninstallString = $App.UninstallString
			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe"'
			$Args = '/VERYSILENT /NORESTART'

			Write-Output "Uninstalling $RefName version $DisplayVersion from CurrentUser"
			# Write-Output " $Exe $Args"
			$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

			$Timeouted = $Null # Reset any previously set timeout
			# Wait up to 180 seconds for normal termination
			$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
			If ($Timeouted) {
				# Terminate the process
				$Proc | Kill
				Write-Output "Error: kill $RefName uninstall exe"
				# Next tweak now
				Return
			} ElseIf (($Proc.ExitCode -ne 0) -And ($Proc.ExitCode -ne 19)) {
				Write-Output "Error: $RefName uninstall return code $($Proc.ExitCode)"
				# Next tweak now
				Return
			}
		}
}

# Telegram Desktop     / 4.9.9          / {53F49750-6209-4FBF-9CA8-7A333C87D1ED}_is1 / "C:\Users\xxxxxxxxx\AppData\Roaming\Telegram Desktop\unins000.exe" (C) Telegram FZ-LLC
# View
Function TweakViewTelegram_CU { # RESINFO
	Write-Output "Viewing Telegram software for CU..."
	$RefName = 'Telegram'
	@(Get-ChildItem -Recurse "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }

			$DisplayVersion = $App.DisplayVersion
			$Publisher = $App.Publisher
			$KeyProduct = $Key | Split-Path -Leaf
			$Exe = $App.UninstallString
			"# {0,-20} / {1,-14} / {2} / {3} (C) {4}" -F $DisplayName, $DisplayVersion, $KeyProduct, $Exe, $Publisher
		} | Sort-Object
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
