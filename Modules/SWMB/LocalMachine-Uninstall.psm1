################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2024, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - Clement Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################
###### Software Uninstall Only
################################################################

################################################################

# Suppress Kaspersky Endpoint software
# Uninstall
Function TweakUninstallKasperskyEndpoint { # RESINFO

	Function _String2Hex00 {
		Param (
			[string]$Text
		)

		$CharArray=$Text.ToCharArray()
		ForEach ($Char in $CharArray) {
			$TextHex = $TextHex + [System.String]::Format("{0:x2}", [System.Convert]::ToUInt32($Char)) + '00'
		}
		Return $TextHex
	}

	Write-Output "Suppress software Kaspersky Endpoint protection..."

	# Remove Kaspersky Endpoint
	$KesEndpoint = Get-WmiObject win32_product | Where { $_.Name -like "*Kaspersky Endpoint Security*" }
	If ($KesEndpoint.IdentifyingNumber) {
		Write-Host "Uninstalling Kaspersky version $($KesEndpoint.Version) with GUID => $($KesEndpoint.IdentifyingNumber)"
		$EndpointPlainPassword=''
		If ($($Global:SWMB_Custom.KesPassword)) {
			If (($($Global:SWMB_Custom.KesKeyFile)) -And (Test-Path -LiteralPath "$($Global:SWMB_Custom.KesKeyFile)")) {
				# Batch - encrypted (blurred) password
				$EndpointCryptPassword = $($Global:SWMB_Custom.KesPassword) | ConvertTo-SecureString -Key (Get-Content $($Global:SWMB_Custom.KesKeyFile))
				$EndpointCredential = New-Object System.Management.Automation.PsCredential($($Global:SWMB_Custom.KesLogin),$EndpointCryptPassword)
				$EndpointPlainPassword = $EndpointCredential.GetNetworkCredential().Password
			} Else {
				# Batch - password defined in clear text
				$EndpointPlainPassword = $($Global:SWMB_Custom.KesPassword)
			}
		}

		# Uninstall
		$MSIEndpointArguments = @(
			"/x"
			$KesEndpoint.IdentifyingNumber
			"KLLOGIN=$($($Global:SWMB_Custom.KesLogin))"
			"KLPASSWD=$EndpointPlainPassword"
			"/norestart"
			"/qn"
		)
		If ($($Global:SWMB_Custom.KesLogFile)) {
			$MSIEndpointArguments += "/l*vx `"$($Global:SWMB_Custom.KesLogFile)`""
		}
		Start-Process "msiexec.exe" -ArgumentList $MSIEndpointArguments -Wait -NoNewWindow
		Write-Host "Uninstall finish"
	} Else {
		Write-Host "Kaspersky Endpoint is not installed on this computer"
	}

	# Remove Kaspersky Agent, French GUID = {2924BEDA-E0D7-4DAF-A224-50D2E0B12F5B}
	$KesAgent = Get-WmiObject win32_product | Where { $_.Name -like "*Agent*Kaspersky Security Center*" }
	If ($KesAgent.IdentifyingNumber) {
		Write-Output "Suppress Agent Kaspersky Security Center $($KesAgent.Version) with GUID => $($KesAgent.IdentifyingNumber)"
		$AgentPlainPassword=''
		If ($($Global:SWMB_Custom.KesAgentPass)) {
			If (($($Global:SWMB_Custom.KesKeyFile)) -And (Test-Path -LiteralPath "$($Global:SWMB_Custom.KesKeyFile)")) {
				# Batch - encrypted (blurred) password
				$AgentCryptPassword = $($Global:SWMB_Custom.KesAgentPass) | ConvertTo-SecureString -Key (Get-Content $($Global:SWMB_Custom.KesKeyFile))
				$AgentCredential = New-Object System.Management.Automation.PsCredential($($Global:SWMB_Custom.KesLogin),$AgentCryptPassword)
				$AgentPlainPassword = $AgentCredential.GetNetworkCredential().Password
			} Else {
				# Batch - password defined in clear text
				$AgentPlainPassword = $($Global:SWMB_Custom.KesAgentPass)
			}
		}
		$AgentHexPassword = (_String2Hex00 -Text $AgentPlainPassword)

		# Uninstall
		$MSIAgentArguments = @(
			"/x"
			$KesAgent.IdentifyingNumber
			"KLUNINSTPASSWD=$AgentHexPassword"
			"/qn"
		)
		If ($($Global:SWMB_Custom.KesLogFile)) {
			$MSIAgentArguments += "/l*vx+ `"$($Global:SWMB_Custom.KesLogFile)`""
		}
		Start-Process "msiexec.exe" -ArgumentList $MSIAgentArguments -Wait -NoNewWindow
		}
	Else {
		Write-Host "Kaspersky Agent Security Center is not installed on this computer "
	}
}

################################################################

# Suppress Kaspersky Console software
# Uninstall
Function TweakUninstallKasperskyConsole { # RESINFO
	Write-Output "Uninstall software Kaspersky Console..."

	# Remove Kaspersky Console, French GUID = {5D35D57A-30B9-493B-819F-C6C2181A0A1A}
	$KesConsole = Get-WmiObject win32_product | Where { $_.Name -like "*Console*Kaspersky Security Center*" }
	If ($KesConsole.IdentifyingNumber) {
		Write-Output "Suppress Console Kaspersky Security Center..."
		Start-Process "msiexec.exe" -ArgumentList "/X $($KesConsole.IdentifyingNumber) /qn" -Wait -NoNewWindow
		Write-Host "Uninstall finish"
	} Else {
		Write-Host "Kaspersky Console is not installed on this computer"
	}
}

################################################################

# View all Kaspersky Product
# View
Function TweakViewKasperskyProduct { # RESINFO
	Write-Output "View all Kaspersky products..."
	# Warning if another Kaspersky is still installed on the computer
	Get-WmiObject win32_product | Where { $_.Name -like "*Kaspersky*" } | ForEach-Object {
		Write-Host "Note: Product $($_.IdentifyingNumber) is installed: $($_.Name)"
	}
}
################################################################

# Suppress RealPlayer software
# With the help of https://silentinstallhq.com/realplayer-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallRealPlayer { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		Where { $_.Name -match 'RealPlayer \d' } |
		ForEach {
			$App = (Get-ItemProperty -Path $_.PSPath)
			$VersionMajor = $App.VersionMajor
			$VersionMinor = $App.VersionMinor
			$UninstallString = $App.UninstallString

			# Kill process
			ForEach ($Task in 'RealPlayerUpdateSvc.exe', 'realsched.exe', 'rpbgdownloader.exe', 'rpsystray.exe', 'rpdsvc.exe') {
				Get-Process -Name "$Task" -ErrorAction 'SilentlyContinue' | Stop-Process -Force -ErrorAction 'SilentlyContinue'
			}

			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe'
			$Args = '"' + $UninstallSplit[1].Trim() + '"' + ' -s'
			If (Test-Path -Path "$Exe") {
				Write-Output "Uninstalling RealPlayer version $VersionMajor.$VersionMinor"
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill RealPlayer uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: RealPlayer uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
			Start-Sleep -Seconds 2
		}

	## Uninstall RealTimes Desktop Service
	If (Test-Path -Path "${Env:ProgramFiles}\Real\RealPlayer\RPDS\uninst.exe") {
		Write-Output "Uninstalling RealTimes Desktop Service."
		Start-Process -FilePath "${Env:ProgramFiles}\Real\RealPlayer\RPDS\uninst.exe" -ArgumentList "-s" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -Wait
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\RealPlayer\RPDS\uninst.exe") {
		Write-Output "Uninstalling RealTimes Desktop Service."
		Start-Process -FilePath "${Env:ProgramFiles(x86)}\Real\RealPlayer\RPDS\uninst.exe" -ArgumentList "-s" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -Wait
		Start-Sleep -Seconds 2
	}
	## Uninstall RealUpgrade
	If (Test-Path -Path "${Env:ProgramFiles}\Real\RealUpgrade\uninst.exe") {
		Write-Output "Uninstalling Any Existing Versions of RealUpgrade."
		Start-Process -FilePath "${Env:ProgramFiles}\Real\RealUpgrade\uninst.exe" -ArgumentList "-s" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -Wait
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\RealUpgrade\uninst.exe") {
		Write-Output "Uninstalling Any Existing Versions of RealUpgrade."
		Start-Process -FilePath "${Env:ProgramFiles(x86)}\Real\RealUpgrade\uninst.exe" -ArgumentList "-s" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -Wait
		Start-Sleep -Seconds 2
	}
	## Cleanup Start Menu Directory
	If (Test-Path -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\Real\") {
		Write-Output "Removing RealPlayer Start Menu Entry."
		Remove-Item -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 2
	}
	## Cleanup ProgramData Directory
	If (Test-Path -Path "${Env:AllUsersProfile}\Real\") {
		Write-Output "Removing Existing Real ProgramData Directory."
		Remove-Item -Path "${Env:AllUsersProfile}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	## Cleanup RealPlayer Directories
	If (Test-Path -Path "${Env:ProgramFiles}\Real\") {
		Write-Output "Cleanup ${Env:ProgramFiles}\Real\ Directory."
		Remove-Item -Path "${Env:ProgramFiles}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\") {
		Write-Output "Cleanup ${Env:ProgramFiles(x86)}\Real\ Directory."
		Remove-Item -Path "${Env:ProgramFiles(x86)}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	## Cleanup Local & Roaming RealPlayer Directories
	Get-WmiObject -ClassName Win32_UserProfile | Where {!$_.Special} | Select LocalPath | ForEach {
		$UserHomePath = $_
		ForEach ($UserCleanItem in "$UserHomePath\AppData\Local\Real", "$UserHomePath\AppData\Roaming\Real") {
			If (Test-Path -Path "$UserCleanItem") {
				Write-Output "Cleanup ($UserCleanItem) Directory."
				Remove-Item -Path "$UserCleanItem" -Force -Recurse -ErrorAction SilentlyContinue
			}
		}
	}
}

################################################################

# Suppress WinRAR software
# With the help of https://silentinstallhq.com/winrar-silent-uninstall-powershell/
# Uninstall
Function TweakUninstallWinRAR { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		Where { $_.Name -match 'WinRAR archiver' } |
		ForEach {
			$App = (Get-ItemProperty -Path $_.PSPath)
			$VersionMajor = $App.VersionMajor
			$VersionMinor = $App.VersionMinor
			$Exe = $App.UninstallString
			$Args = '/S'
			If (Test-Path -Path "$Exe") {
				Write-Output "Uninstalling WinRAR version $VersionMajor.$VersionMinor"
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill WinRAR uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: WinRAR uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
			Start-Sleep -Seconds 2
		}

	## Cleanup Start Menu Directory
	If (Test-Path -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\WinRAR\") {
		Write-Output "Removing WinRAR Start Menu Entry."
		Remove-Item -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\WinRAR\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 2
	}

	## Cleanup User Profile (If Present)
	Get-WmiObject -ClassName Win32_UserProfile | Where {!$_.Special} | Select LocalPath | ForEach {
		$UserHomePath = $_
		ForEach ($UserCleanItem in "$UserHomePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\WinRAR") {
			If (Test-Path -Path "$UserCleanItem") {
				Write-Output "Cleanup ($UserCleanItem) Directory."
				Remove-Item -Path "$UserCleanItem" -Force -Recurse -ErrorAction SilentlyContinue
			}
		}
	}
}

################################################################

# Suppress Total Commander software
# With the help of https://silentinstallhq.com/total-commander-silent-install-how-to-guide/
# Total Commander 10.x
# "%ProgramFiles%\totalcmd\tcuninst.exe" /7
# "%ProgramFiles%\totalcmd\tcunin64.exe" /7
# Total Commander 9.x
# "%SystemDrive%\totalcmd\tcuninst.exe" /7
# "%SystemDrive%\totalcmd\tcunin64.exe" /7
# Uninstall
Function TweakUninstallTotalCommander { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'Total Commander') {
				$DisplayVersion = $App.DisplayVersion
				$UninstallSplit = $App.UninstallString -Split '"'
				$Exe = $UninstallSplit[1].Trim()
				$Args = '/7'
				If (Test-Path -Path "$Exe") {
					Write-Output "Uninstalling Total Commander version $DisplayVersion / $Exe $Args"
					$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

					$Timeouted = $Null # Reset any previously set timeout
					# Wait up to 180 seconds for normal termination
					$Proc | Wait-Process -Timeout 180 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
					If ($Timeouted) {
						# Terminate the process
						$Proc | Kill
						Write-Output "Error: kill Total Commander uninstall exe"
						# Next tweak now
						Return
					} ElseIf ($Proc.ExitCode -ne 0) {
						Write-Output "Error: Total Commander uninstall return code $($Proc.ExitCode)"
						# Next tweak now
						Return
					}
				}
				Start-Sleep -Seconds 1
			}
		}
}

# View
Function TweakViewTotalCommander { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'Total Commander') {
				$DisplayVersion = $App.DisplayVersion
				$UninstallSplit = $App.UninstallString -Split '"'
				$Exe = $UninstallSplit[1].Trim()
				Write-Output "$DisplayName / $DisplayVersion / $Exe"
			}
		}
}

################################################################

# Suppress Avast Free Antivirus software (not working)
# https://silentinstallhq.com/avast-free-antivirus-silent-install-how-to-guide/
# Does not work - impossible to change the Stats.ini file
# Uninstall
Function TweakUninstallAvast { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		Where { $_.Name -match 'Avast Antivirus' } |
		ForEach {
			$App = (Get-ItemProperty -Path $_.PSPath)
			$VersionMajor = $App.VersionMajor
			$VersionMinor = $App.VersionMinor
			$UninstallString = $App.UninstallString
			$InstallLocation = $App.InstallLocation

			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe'
			$Args = '"' + $UninstallSplit[1].Trim() + '"' + ' /instop:uninstall /silent /wait'
			If (Test-Path -Path "$Exe") {
				# Need to be changed for silent uninstall
				$StatsIni = "$InstallLocation\setup\Stats.ini"
				If (Test-Path -Path "$StatsIni") {
					(Get-Content $StatsIni) | ForEach-Object { $_ -replace "\[Common\]", "[Common]`nSilentUninstallEnabled=1" } | Set-Content $StatsIni
				}

				Write-Output "Uninstalling Avast Antivirus version $VersionMajor.$VersionMinor"
				# Ok but UI (without UI if SYSTEM account)
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill Avast uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: Avast uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
				Start-Sleep -Seconds 2
			}
		}
}

################################################################

# Suppress OpenOffice software
# https://silentinstallhq.com/apache-openoffice-silent-install-how-to-guide/
# https://www.pdq.com/blog/silently-install-openoffice/
# https://wiki.openoffice.org/wiki/Documentation/How_Tos/Automatic_Installation_on_Windows
# Uninstall
Function TweakUninstallOpenOffice { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'OpenOffice') {
				$VersionMajor = $App.VersionMajor
				$VersionMinor = $App.VersionMinor
				$KeyProduct = $Key | Split-Path -Leaf
				$Args = '/quiet /qn /norestart /x ' + '"' + "$KeyProduct" + '"'

				Write-Output "Uninstalling OpenOffice version $VersionMajor.$VersionMinor"
				$Proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill OpenOffice uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: OpenOffice uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
		}
}

################################################################

# Suppress GlassWire software
# With the help of https://silentinstallhq.com/glasswire-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallGlassWire { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		Where { $_.Name -match 'GlassWire' } |
		ForEach {
			$App = (Get-ItemProperty -Path $_.PSPath)
			$Version = $App.DisplayVersion
			$Exe = $App.UninstallString
			If ($Exe -eq $null) {
				Return
			}
			$Exe = $Exe.Trim('"')
			$Args = '/S'
			If (Test-Path -Path "$Exe") {
				Write-Output "Uninstalling GlassWire version $Version"
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill GlassWire uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: GlassWire uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
			Start-Sleep -Seconds 1
		}
}

################################################################

# Suppress Microsoft Edge WebView2 Runtime
# https://silentinstallhq.com/microsoft-edge-webview2-runtime-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallEdgeWebView2 { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'Microsoft Edge WebView2 Runtime') {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				$UninstallSplit = $UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '--uninstall --msedgewebview --system-level --force-uninstall'

				Write-Output "Uninstalling Microsoft Edge WebView2 Runtime version $DisplayVersion"
				# Write-Output " $Exe $Args"
				$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill Edge WebView2 uninstall exe"
					# Next tweak now
					Return
				} ElseIf (($Proc.ExitCode -ne 0) -And ($Proc.ExitCode -ne 19)) {
					Write-Output "Error: Edge WebView2 uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
		}
}

# View
Function TweakViewEdgeWebView2 { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'Microsoft Edge WebView2 Runtime') {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				Write-Output "Microsoft Edge WebView2 Runtime: $DisplayVersion / $UninstallString"
			}
		}
}

################################################################

# Suppress Google Toolbar for Internet Explorer
# https://community.spiceworks.com/topic/263040-how-do-i-uninstall-google-toolbar-using-pdq
# "C:\Program Files (x86)\Google\Google Toolbar\Component\GoogleToolbarManager_E6C807F38EB64284.exe" /uninstall
# Uninstall
Function TweakUninstallGoogleToolbar { # RESINFO
	$RefName = 'Google Toolbar for Internet Explorer'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				$UninstallSplit = $UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '/uninstall /S'

				Write-Output "Uninstalling $RefName version $DisplayVersion"
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
}

# View
Function TweakViewGoogleToolbar { # RESINFO
	$RefName = 'Google Toolbar for Internet Explorer'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				Write-Output "${RefName}: $DisplayVersion / $UninstallString"
			}
		}
}

################################################################

# Suppress novaPDF
# https://www.novapdf.com/how-to-install-or-uninstall-novapdf-silently-kb.html
# https://silentinstallhq.com/dopdf-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallNovaPDF { # RESINFO
	$RefName = 'novaPDF'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }
			$UninstallString = $App.UninstallString
			If ($UninstallString -match 'MsiExec.exe') { Return }
			# Only novapdf.exe here
			$DisplayVersion = $App.DisplayVersion
			$UninstallSplit = $UninstallString -Split "exe"
			$Exe = $UninstallSplit[0] + 'exe"'
			$Args = '/uninstall /quiet'
			Write-Output "Uninstalling $DisplayName version $DisplayVersion"
			Write-Output "Exe: $Exe $Args"
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

# View
Function TweakViewNovaPDF { # RESINFO
	$RefName = 'novaPDF'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				Write-Output "$DisplayName / $DisplayVersion / $UninstallString"
			}
		}
}

# novaPDF 11 Printer Driver / 11.9.444 / MsiExec.exe /X{0381A4C3-3B90-436E-8E69-15E4CDBDEC2D}
# novaPDF 11 add-in for Microsoft Office (x64) / 11.9.444 / MsiExec.exe /X{3742ACB4-D095-4247-9A19-D1682A510ED2}
# novaPDF 11 / 11.9.444 / MsiExec.exe /X{526D78AB-571E-4FCF-B06E-31AA9C98C44F}
# novaPDF 11 SDK COM (x64) / 11.9.444 / MsiExec.exe /X{7CC4C9C8-2CD5-4EDF-94B8-7AFF868585C9}
# novaPDF 11 SDK COM (x86) / 11.9.444 / MsiExec.exe /X{24C3CAC4-4442-429B-A90C-A09AF48291DE}
# novaPDF 11 Tools / 11.9.444 / MsiExec.exe /X{259700EE-CE49-402B-8C0B-8767A9C92E4C}
# novaPDF 11 / 11.9.444 / "C:\ProgramData\Package Cache\{393239a6-f3a2-413b-a4c9-e5b762602c3e}\novapdf.exe"  /uninstall
# novaPDF 11 add-in for Microsoft Office (x86) / 11.9.444 / MsiExec.exe /X{673C8085-8235-42C6-B259-C2E1CF791C46}

################################################################

# Suppress HP Wolf Security
# https://support.hpwolf.com/s/article/How-to-uninstall-HP-Wolf-Pro-Security
# Uninstall
Function TweakUninstallHPWolfSecurity { # RESINFO
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			# 'HP Wolf Security' or 'HP Wolf Security - Console' or 'HP Security Update Service'
			If (($DisplayName -match 'HP Wolf Security') -Or ($DisplayName -match 'HP Security Update Service')) {
				$DisplayVersion = $App.DisplayVersion
				$VersionMajor = $App.VersionMajor
				$VersionMinor = $App.VersionMinor
				$KeyProduct = $Key | Split-Path -Leaf
				$Args = '/quiet /qn /norestart /x ' + '"' + "$KeyProduct" + '"'

				Write-Output "Uninstalling $DisplayName version $DisplayVersion"
				$Proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru

				$Timeouted = $Null # Reset any previously set timeout
				# Wait up to 180 seconds for normal termination
				$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
				If ($Timeouted) {
					# Terminate the process
					$Proc | Kill
					Write-Output "Error: kill $DisplayName uninstall exe"
					# Next tweak now
					Return
				} ElseIf ($Proc.ExitCode -ne 0) {
					Write-Output "Error: $DisplayName uninstall return code $($Proc.ExitCode)"
					# Next tweak now
					Return
				}
			}
		}
}

# View
Function TweakViewHPWolfSecurity { # RESINFO
	Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
		Get-ItemProperty |
		Where-Object {$_.DisplayName -like "*HP*Security*" } |
		Select-Object -Property DisplayName, DisplayVersion, UninstallString
}

################################################################

# HP built-in apps to remove
# https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388
# Uninstall
Function TweakUninstallHPBuiltInApps { # RESINFO
	$UninstallPackages = @(
		"AD2F1837.HPJumpStarts"
		"AD2F1837.HPPCHardwareDiagnosticsWindows"
		"AD2F1837.HPPowerManager"
		"AD2F1837.HPPrivacySettings"
		#"AD2F1837.HPSupportAssistant"
		"AD2F1837.HPSureShieldAI"
		"AD2F1837.HPSystemInformation"
		"AD2F1837.HPQuickDrop"
		"AD2F1837.HPWorkWell"
		"AD2F1837.myHP"
		"AD2F1837.HPDesktopSupportUtilities"
		"AD2F1837.HPQuickTouch"
		"AD2F1837.HPEasyClean"
		"AD2F1837.HPSystemInformation"
	)

	$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {($UninstallPackages -contains $_.Name)}
	$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {($UninstallPackages -contains $_.DisplayName)}

	# Remove appx provisioned packages - AppxProvisionedPackage
	ForEach ($ProvPackage in $ProvisionedPackages) {

	Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

	Try {
		$Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
		Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
	} Catch {
		Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
	}

	# Remove appx packages - AppxPackage
	ForEach ($AppxPackage in $InstalledPackages) {

	Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

	Try {
		$Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
		Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
	} Catch {
		Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
	}
}


################################################################

# HP built-in apps to remove
# https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388
# Uninstall
Function TweakUninstallHPBloatware { # RESINFO
# List of programs to uninstall
	$UninstallPrograms = @(
		"HP Client Security Manager"
		"HP Connection Optimizer"
		"HP Documentation"
		"HP MAC Address Manager"
		"HP Notifications"
		#"HP Security Update Service"
		"HP System Default Settings"
		"HP Sure Click"
		"HP Sure Click Security Browser"
		"HP Sure Run"
		"HP Sure Recover"
		"HP Sure Sense"
		"HP Sure Sense Installer"
		#"HP Wolf Security"
		#"HP Wolf Security Application Support for Sure Sense"
		#"HP Wolf Security Application Support for Windows"
	)

	$InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}
	$InstalledPrograms | ForEach-Object {

	Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."
	Try {
		$Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
		Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
	} Catch {
		Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
	}
}
################################################################

# Suppress AnyDesk
# Uninstall
Function TweakUninstallAnyDesk { # RESINFO
	$RefName = 'AnyDesk'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }
			$DisplayVersion = $App.DisplayVersion
			$KeyProduct = $Key | Split-Path -Leaf

			If ($($App.UninstallString) -match 'MsiExec.exe') {
				$Exe = 'msiexec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn'
			} Else {
				$UninstallSplit = $App.UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '--silent --remove'
			}

			Write-Output "Uninstalling $DisplayName version $DisplayVersion"
			Write-Output "Exe: $Exe $Args"
			$Proc = Start-Process -FilePath "$Exe" -ArgumentList "$Args" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru
			$Timeouted = $Null # Reset any previously set timeout
			# Wait up to 180 seconds for normal termination
			$Proc | Wait-Process -Timeout 300 -ErrorAction SilentlyContinue -ErrorVariable Timeouted
			If ($Timeouted) {
				# Terminate the process
				$Proc | Kill
				Write-Output "Error: kill $RefName uninstall exe"
				Return
			} ElseIf ($Proc.ExitCode -ne 0) {
				Write-Output "Error: $RefName uninstall return code $($Proc.ExitCode)"
				Return
			}
		}
}

# View
Function TweakViewAnyDesk { # RESINFO
	$RefName = 'AnyDesk'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				Write-Output "$DisplayName / $DisplayVersion / $UninstallString"
			}
		}
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
