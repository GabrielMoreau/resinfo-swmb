################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
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
	Write-Output "Uninstalling software Kaspersky Endpoint protection..."

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

	# Remove Kaspersky Endpoint
	$KesEndpoint = Get-WmiObject win32_product | Where { $_.Name -like "*Kaspersky Endpoint Security*" }
	If ($KesEndpoint.IdentifyingNumber) {
		Write-Output " Uninstalling Kaspersky version $($KesEndpoint.Version) with GUID => $($KesEndpoint.IdentifyingNumber)"
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
		Start-Process "MsiExec.exe" -ArgumentList $MSIEndpointArguments -Wait -NoNewWindow
		Write-Output " Uninstall finish"
	} Else {
		Write-Output " Kaspersky Endpoint is not installed on this computer"
	}

	# Remove Kaspersky Agent, French GUID = {2924BEDA-E0D7-4DAF-A224-50D2E0B12F5B}
	$KesAgent = Get-WmiObject win32_product | Where { $_.Name -like "*Agent*Kaspersky Security Center*" }
	If ($KesAgent.IdentifyingNumber) {
		Write-Output " Uninstalling Agent Kaspersky Security Center $($KesAgent.Version) with GUID => $($KesAgent.IdentifyingNumber)"
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
		Start-Process "MsiExec.exe" -ArgumentList $MSIAgentArguments -Wait -NoNewWindow
		}
	Else {
		Write-Output " Kaspersky Agent Security Center is not installed on this computer "
	}
}

################################################################

# Suppress Kaspersky Console software
# Uninstall
Function TweakUninstallKasperskyConsole { # RESINFO
	Write-Output "Uninstalling software Kaspersky Console..."

	# Remove Kaspersky Console, French GUID = {5D35D57A-30B9-493B-819F-C6C2181A0A1A}
	$KesConsole = Get-WmiObject win32_product | Where { $_.Name -like "*Console*Kaspersky Security Center*" }
	If ($KesConsole.IdentifyingNumber) {
		Write-Output " Uninstalling Console Kaspersky Security Center..."
		Start-Process "MsiExec.exe" -ArgumentList "/X $($KesConsole.IdentifyingNumber) /qn" -Wait -NoNewWindow
		Write-Output " Uninstall finish"
	} Else {
		Write-Output " Kaspersky Console is not installed on this computer"
	}
}

################################################################

# View all Kaspersky Product
# View
Function TweakViewKasperskyProduct { # RESINFO
	Write-Output "Viewing all Kaspersky products..."
	# Warning if another Kaspersky is still installed on the computer
	Get-WmiObject win32_product | Where { $_.Name -like "*Kaspersky*" } | ForEach-Object {
		Write-Output " Note: Product $($_.IdentifyingNumber) is installed: $($_.Name)"
	}
}
################################################################

# Suppress RealPlayer software
# With the help of https://silentinstallhq.com/realplayer-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallRealPlayer { # RESINFO
	Write-Output "Uninstalling software RealPlayer..."
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
				Write-Output " Uninstalling RealPlayer version $VersionMajor.$VersionMinor"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "RealPlayer" -Timeout 300
			}
			Start-Sleep -Seconds 2
		}

	## Uninstall RealTimes Desktop Service
	If (Test-Path -Path "${Env:ProgramFiles}\Real\RealPlayer\RPDS\uninst.exe") {
		Write-Output " Uninstalling RealTimes Desktop Service."
		SWMB_RunExec -FilePath "${Env:ProgramFiles}\Real\RealPlayer\RPDS\uninst.exe" -ArgumentList "-s" -Name "RealPlayer" -Timeout 300
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\RealPlayer\RPDS\uninst.exe") {
		Write-Output " Uninstalling RealTimes Desktop Service."
		SWMB_RunExec -FilePath "${Env:ProgramFiles(x86)}\Real\RealPlayer\RPDS\uninst.exe" -ArgumentList "-s" -Name "RealPlayer" -Timeout 300
		Start-Sleep -Seconds 2
	}
	## Uninstall RealUpgrade
	If (Test-Path -Path "${Env:ProgramFiles}\Real\RealUpgrade\uninst.exe") {
		Write-Output " Uninstalling Any Existing Versions of RealUpgrade."
		SWMB_RunExec -FilePath "${Env:ProgramFiles}\Real\RealUpgrade\uninst.exe" -ArgumentList "-s" -Name "RealPlayer" -Timeout 300
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\RealUpgrade\uninst.exe") {
		Write-Output " Uninstalling Any Existing Versions of RealUpgrade."
		SWMB_RunExec -FilePath "${Env:ProgramFiles(x86)}\Real\RealUpgrade\uninst.exe" -ArgumentList "-s" -Name "RealPlayer" -Timeout 300
		Start-Sleep -Seconds 2
	}
	## Cleanup Start Menu Directory
	If (Test-Path -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\Real\") {
		Write-Output " Removing RealPlayer Start Menu Entry."
		Remove-Item -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 2
	}
	## Cleanup ProgramData Directory
	If (Test-Path -Path "${Env:AllUsersProfile}\Real\") {
		Write-Output " Removing Existing Real ProgramData Directory."
		Remove-Item -Path "${Env:AllUsersProfile}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	## Cleanup RealPlayer Directories
	If (Test-Path -Path "${Env:ProgramFiles}\Real\") {
		Write-Output " Cleanup ${Env:ProgramFiles}\Real\ Directory."
		Remove-Item -Path "${Env:ProgramFiles}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\Real\") {
		Write-Output " Cleanup ${Env:ProgramFiles(x86)}\Real\ Directory."
		Remove-Item -Path "${Env:ProgramFiles(x86)}\Real\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 1
	}
	## Cleanup Local & Roaming RealPlayer Directories
	Get-WmiObject -ClassName Win32_UserProfile | Where {!$_.Special} | Select LocalPath | ForEach {
		$UserHomePath = $_
		ForEach ($UserCleanItem in "$UserHomePath\AppData\Local\Real", "$UserHomePath\AppData\Roaming\Real") {
			If (Test-Path -Path "$UserCleanItem") {
				Write-Output " Cleanup ($UserCleanItem) Directory."
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
	Write-Output "Uninstalling software WinRAR..."
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
				Write-Output " Uninstalling WinRAR version $VersionMajor.$VersionMinor"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "WinRAR" -Timeout 300
			}
			Start-Sleep -Seconds 2
		}

	## Cleanup Start Menu Directory
	If (Test-Path -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\WinRAR\") {
		Write-Output " Removing WinRAR Start Menu Entry."
		Remove-Item -Path "${Env:ProgramData}\Microsoft\Windows\Start Menu\Programs\WinRAR\" -Force -Recurse -ErrorAction SilentlyContinue
		Start-Sleep -Seconds 2
	}

	## Cleanup User Profile (If Present)
	Get-WmiObject -ClassName Win32_UserProfile | Where {!$_.Special} | Select LocalPath | ForEach {
		$UserHomePath = $_
		ForEach ($UserCleanItem in "$UserHomePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\WinRAR") {
			If (Test-Path -Path "$UserCleanItem") {
				Write-Output " Cleanup ($UserCleanItem) Directory."
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
	Write-Output "Uninstalling software TotalCommander..."
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
					Write-Output " Uninstalling Total Commander version $DisplayVersion / $Exe $Args"
					SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "TotalCommander" -Timeout 300
				}
				Start-Sleep -Seconds 1
			}
		}
}

# View
Function TweakViewTotalCommander { # RESINFO
	Write-Output "Viewing software TotalCommander ..."
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
				Write-Output " $DisplayName / $DisplayVersion / $Exe"
			}
		}
}

################################################################

# Suppress Avast Free Antivirus software (not working)
# https://silentinstallhq.com/avast-free-antivirus-silent-install-how-to-guide/
# Does not work - impossible to change the Stats.ini file
# Uninstall
Function TweakUninstallAvast { # RESINFO
	Write-Output "Uninstalling software Avast..."
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

				Write-Output " Uninstalling Avast Antivirus version $VersionMajor.$VersionMinor"
				# Ok but UI (without UI if SYSTEM account)
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "Avast Antivirus" -Timeout 300
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
	Write-Output "Uninstalling software OpenOffice..."
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

				Write-Output " Uninstalling OpenOffice version $VersionMajor.$VersionMinor"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "OpenOffice" -Timeout 300
			}
		}
}

################################################################

# Suppress GlassWire software
# With the help of https://silentinstallhq.com/glasswire-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallGlassWire { # RESINFO
	Write-Output "Uninstalling software GlassWire..."
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
				Write-Output " Uninstalling GlassWire version $Version"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "GlassWire" -Timeout 300
			}
			Start-Sleep -Seconds 1
		}
}

################################################################

# Suppress Microsoft Edge WebView2 Runtime
# https://silentinstallhq.com/microsoft-edge-webview2-runtime-silent-install-how-to-guide/
# Does not work
# Uninstall
Function TweakUninstallEdgeWebView2 { # RESINFO
	Write-Output "Uninstalling software EdgeWebView2..."
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

				Write-Output " Uninstalling Microsoft Edge WebView2 Runtime version $DisplayVersion"
				# Write-Output " $Exe $Args"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "Edge WebView2" -Timeout 300
			}
		}
}

# View
Function TweakViewEdgeWebView2 { # RESINFO
	Write-Output "Viewing software EdgeWebView2..."
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match 'Microsoft Edge WebView2 Runtime') {
				$DisplayVersion = $App.DisplayVersion
				$UninstallString = $App.UninstallString
				Write-Output " Microsoft Edge WebView2 Runtime: $DisplayVersion / $UninstallString"
			}
		}
}

################################################################

# Suppress Google Toolbar for Internet Explorer
# https://community.spiceworks.com/topic/263040-how-do-i-uninstall-google-toolbar-using-pdq
# "C:\Program Files (x86)\Google\Google Toolbar\Component\GoogleToolbarManager_E6C807F38EB64284.exe" /uninstall
# Uninstall
Function TweakUninstallGoogleToolbar { # RESINFO
	Write-Output "Uninstalling software GoogleToolbar..."
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

				Write-Output " Uninstalling $RefName version $DisplayVersion"
				# Write-Output " $Exe $Args"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
			}
		}
}

# View
Function TweakViewGoogleToolbar { # RESINFO
	Write-Output "Viewing software GoogleToolbar..."
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
				Write-Output " ${RefName}: $DisplayVersion / $UninstallString"
			}
		}
}

################################################################

# Suppress novaPDF
# https://www.novapdf.com/how-to-install-or-uninstall-novapdf-silently-kb.html
# https://silentinstallhq.com/dopdf-silent-install-how-to-guide/
# Uninstall
Function TweakUninstallNovaPDF { # RESINFO
	Write-Output "Uninstalling software Nova PDF..."
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
			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewNovaPDF { # RESINFO
	Write-Output "Viewing software Nova PDF..."
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
				Write-Output " $DisplayName / $DisplayVersion / $UninstallString"
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
	Write-Output "Uninstalling software HP Wolf Security..."
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
				$Exe = 'MsiExec.exe'
				Write-Output " Uninstalling $DisplayName version $DisplayVersion"
				SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$DisplayName" -Timeout 300
			}
		}
}

# View
Function TweakViewHPWolfSecurity { # RESINFO
	Write-Output "Viewing software HP Wolf Security..."
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
	Write-Output "Uninstalling software HP BuiltIn Apps..."
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
		Write-Output " Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
		Try {
			$Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
			Write-Output " Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
		} Catch {
			Write-Output " Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
		}
	}

	# Remove appx packages - AppxPackage
	ForEach ($AppxPackage in $InstalledPackages) {
		Write-Output " Attempting to remove Appx package: [$($AppxPackage.Name)]..."

		Try {
			$Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
			Write-Output " Successfully removed Appx package: [$($AppxPackage.Name)]"
		} Catch {
			Write-Output " Failed to remove Appx package: [$($AppxPackage.Name)]"
		}
	}
}


################################################################

# HP built-in apps to remove
# https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388
# Uninstall
Function TweakUninstallHPBloatware { # RESINFO
	Write-Output "Uninstalling software HP Bloatware..."
	# List of programs to uninstall
	$UninstallPrograms = @(
		"HP Client Security Manager"
		"HP Connection Optimizer"
		"HP Documentation"
		"HP MAC Address Manager"
		"HP Notifications"
		#"HP Security Update Service"
		"HP System Default Settings"
		"HP One Agent"
		"HP Sure Click"
		"HP Sure Click Security Browser"
		"HP Sure Run"
		"HP Sure Run Module"
		"HP Sure Recover"
		"HP Sure Sense"
		"HP Sure Sense Installer"
		"HP Presence Video"
		#"HP Wolf Security"
		#"HP Wolf Security Application Support for Sure Sense"
		#"HP Wolf Security Application Support for Windows"
	)

	# MSI Soft
	$InstalledMsi = Get-Package -ProviderName msi | Where-Object {$UninstallPrograms -contains $_.Name}
	$InstalledMsi | ForEach-Object {
		Write-Output " Attempting to uninstall: [$($_.Name)]..."
		Try {
			$Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
			Write-Output " Successfully uninstalled: [$($_.Name)]"
		} Catch {
			Write-Output " Failed to uninstall: [$($_.Name)]"
		}
	}

	# Program soft
	$InstalledPrograms = Get-Package -ProviderName programs | Where-Object {$UninstallPrograms -contains $_.Name}
	$InstalledPrograms | ForEach-Object {
		If ($_.Name -match "HP Connection Optimizer") {
			Write-Output " Attempting to uninstall: [$($_.Name)]..."
			Try {
				# need a iss file for silent uninstall see https://www.reddit.com/r/PowerShell/comments/mwdrvb/hp_connection_optimizer_silent_uninstall/
				$OptimizerUninstallAnswer = @"
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-DlgOrder]
Dlg0={6468C4A5-E47E-405F-B675-A70A70983EA6}-SdWelcomeMaint-0
Count=3
Dlg1={6468C4A5-E47E-405F-B675-A70A70983EA6}-MessageBox-0
Dlg2={6468C4A5-E47E-405F-B675-A70A70983EA6}-SdFinishReboot-0
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-SdWelcomeMaint-0]
Result=303
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-MessageBox-0]
Result=6
[Application]
Name=HP Connection Optimizer
Version=2.0.18.0
Company=HP Inc.
Lang=0409
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-SdFinishReboot-0]
Result=1
BootOption=0
"@
				$OptimizerUninstallAnswer | Out-File ${Env:Temp}\Optimizer.iss

				$UninstallArray = $_.metadata['uninstallstring'] -Split '"'
				$Exe = $UninstallArray[1].Trim()
				$Arguments = "/s /f1`"${Env:Temp}\Optimizer.iss`""
				(Start-Process "$Exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru).ExitCode
				Write-Output " Successfully uninstalled: [$($_.Name)]"
			} Catch {
				Write-Output " Failed to uninstall: [$($_.Name)]"
			}
		} ElseIf ($_.Name -match "HP One Agent") {
			Write-Output " Attempting to uninstall: [$($_.Name)]..."
			$UninstallArray = $_.metadata['uninstallstring'] -Split '"'
			$Exe = $UninstallArray[1].Trim()
			$Arguments = "/uninstall /quiet /norestart"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList $Arguments -Name "$($_.Name)" -Timeout 150
		}
	}
}

################################################################

# Suppress AnyDesk
# Uninstall
Function TweakUninstallAnyDesk { # RESINFO
	Write-Output "Uninstalling software AnyDesk..."
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
				$Exe = 'MsiExec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn'
			} Else {
				$UninstallSplit = $App.UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '--silent --remove'
			}

			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewAnyDesk { # RESINFO
	Write-Output "Viewing software AnyDesk..."
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
				Write-Output " $DisplayName / $DisplayVersion / $UninstallString"
			}
		}
}

################################################################

# Suppress VMware Player
# Uninstall
Function TweakUninstallVMwarePlayer { # RESINFO
	Write-Output "Uninstalling software VMware Player..."
	$RefName = 'VMware Player'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If (!($DisplayName -match $RefName)) { Return }
			$DisplayVersion = $App.DisplayVersion
			$KeyProduct = $Key | Split-Path -Leaf

			$Exe = 'MsiExec.exe'
			$Args = '/x "' + $KeyProduct + '" /qn REBOOT=ReallySuppress REMOVE=ALL'
			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewVMwarePlayer { # RESINFO
	Write-Output "Viewing software VMware Player..."
	$RefName = 'VMware Player'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress RealVNC 4
# http://help.syamsupport.com/UninstallingRealVNCandUltraVNC.html
# Uninstall
Function TweakUninstallRealVNC4 { # RESINFO
	Write-Output "Uninstalling software RealVNC4..."
	$Args = '/VERYSILENT /NORESTART'
	If (Test-Path -Path "${Env:ProgramFiles}\RealVNC\VNC4\unins000.exe") {
		Write-Output " Uninstalling RealVNC 4"
		SWMB_RunExec -FilePath "${Env:ProgramFiles}\RealVNC\VNC4\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\RealVNC\VNC4\unins000.exe") {
		Write-Output " Uninstalling RealVNC 4"
		SWMB_RunExec -FilePath "${Env:ProgramFiles(x86)}\RealVNC\VNC4\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
}

################################################################

# Suppress RealVNC Server
# http://help.syamsupport.com/UninstallingRealVNCandUltraVNC.html
# Uninstall
Function TweakUninstallRealVNCServer { # RESINFO
	Write-Output "Uninstalling software RealVNC Server..."
	$Args = '/VERYSILENT /NORESTART'
	If (Test-Path -Path "${Env:ProgramFiles}\RealVNC\VNC Server\unins000.exe") {
		Write-Output " Uninstalling RealVNC 5"
		SWMB_RunExec -FilePath "${Env:ProgramFiles}\RealVNC\VNC Server\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\RealVNC\VNC Server\unins000.exe") {
		Write-Output " Uninstalling RealVNC 5"
		SWMB_RunExec -FilePath "${Env:ProgramFiles(x86)}\RealVNC\VNC Server\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
}

# View
Function TweakViewRealVNCServer { # RESINFO
	Write-Output "Viewing software RealVNC Server..."
	$RefName = 'RealVNC Server'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress RealVNC Viewer
# http://help.syamsupport.com/UninstallingRealVNCandUltraVNC.html
# Uninstall
Function TweakUninstallRealVNCViewer { # RESINFO
	Write-Output "Uninstalling software RealVNC Viewer..."
	$Args = '/VERYSILENT /NORESTART'
	If (Test-Path -Path "${Env:ProgramFiles}\RealVNC\VNC Viewer\unins000.exe") {
		Write-Output " Uninstalling RealVNC 5"
		SWMB_RunExec -FilePath "${Env:ProgramFiles}\RealVNC\VNC Viewer\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
	If (Test-Path -Path "${Env:ProgramFiles(x86)}\RealVNC\VNC Viewer\unins000.exe") {
		Write-Output " Uninstalling RealVNC 5"
		SWMB_RunExec -FilePath "${Env:ProgramFiles(x86)}\RealVNC\VNC Viewer\unins000.exe" -ArgumentList "$Args" -Name "RealVNC" -Timeout 300
		Start-Sleep -Seconds 2
	}
}

# View
Function TweakViewRealVNCViewer { # RESINFO
	Write-Output "Viewing software RealVNC Viewer 5..."
	$RefName = 'RealVNC Viewer'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress UltraVNC
# http://help.syamsupport.com/UninstallingRealVNCandUltraVNC.html
# | Hive | DisplayName | Publisher | DisplayVersion | KeyProduct | UninstallExe |
# |:---- |:----------- |:--------- |:-------------- |:---------- |:------------ |
# | HKLM | UltraVNC | uvnc bvba | 1.4.36 | {AD7A5D3C-0443-4F04-A066-ADFF7EB9328C} | MsiExec.exe /I{AD7A5D3C-0443-4F04-A066-ADFF7EB9328C} |
# | HKLM | UltraVNC | uvnc bvba | 1.4.3.6 | Ultravnc2_is1 | "C:\Program Files (x86)\uvnc bvba\UltraVNC\unins000.exe" |

# Suppress UltraVNC
# http://help.syamsupport.com/UninstallingRealVNCandUltraVNC.html
# Uninstall
Function TweakUninstallUltraVNC { # RESINFO
	Write-Output "Uninstalling software UltraVNC..."
	$RefName = 'UltraVNC'
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
				$Exe = 'MsiExec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn /norestart'
			} Else {
				$UninstallSplit = $App.UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '/VERYSILENT /NORESTART'
			}

			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewUltraVNC { # RESINFO
	Write-Output "Viewing software UltraVNC..."
	$RefName = 'UltraVNC'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress PDF-XChange Viewer
# https://downloads.pdf-xchange.com/PXCViewer_x64.msi
# | Hive | DisplayName | Publisher | DisplayVersion | KeyProduct | UninstallExe |
# |:---- |:----------- |:--------- |:-------------- |:---------- |:------------ |
# | HKLM | PDF-XChange Viewer | Tracker Software Products (Canada) Ltd. | 2.5.322.10 | {9ED333F8-3E6C-4A38-BAFA-728454121CDA}     | MsiExec.exe /I{9ED333F8-3E6C-4A38-BAFA-728454121CDA}        |
# | HKLM | PDF-Viewer         | Tracker Software Products Ltd           | 2.5.322.10 | {A278382D-4F1B-4D47-9885-8523F7261E8D}_is1 | "C:\Program Files\Tracker Software\PDF Viewer\unins000.exe" |

# Uninstall
Function TweakUninstallPDFXChange { # RESINFO
	Write-Output "Uninstalling software PDF-XChange..."
	$RefName = '(PDF-XChange|PDF-Viewer)'
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
				$Exe = 'MsiExec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn /norestart'
			} Else {
				$UninstallSplit = $App.UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '/VERYSILENT /NORESTART'
			}

			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewPDFXChange { # RESINFO
	Write-Output "Viewing software PDF-XChange..."
	$RefName = '(PDF-XChange|PDF-Viewer)'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress Skype
# https://en.wikipedia.org/wiki/Skype
# | Hive | DisplayName | Publisher | DisplayVersion | KeyProduct | UninstallExe |
# |:---- |:----------- |:--------- |:-------------- |:---------- |:------------ |
# | HKLM | Skype version 8.137 | Skype Technologies S.A. | 8.137 | Skype_is1 | "C:\Program Files (x86)\Microsoft\Skype for Desktop\unins000.exe" |
# | HKLM | Skype version 8.138 | Skype Technologies S.A. | 8.138 | Skype_is1 | "C:\Program Files (x86)\Microsoft\Skype for Desktop\unins000.exe" |

# Uninstall
Function TweakUninstallSkype { # RESINFO
	Write-Output "Uninstalling software Skype..."
	$RefName = 'Skype version'
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
				$Exe = 'MsiExec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn /norestart'
			} Else {
				$UninstallSplit = $App.UninstallString -Split "exe"
				$Exe = $UninstallSplit[0] + 'exe"'
				$Args = '/VERYSILENT /NORESTART'
			}

			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewSkype { # RESINFO
	Write-Output "Viewing software Skype..."
	$RefName = 'Skype version'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Suppress TeamViewer
# https://www.teamviewer.com
# | Hive | DisplayName | Publisher | DisplayVersion | KeyProduct | UninstallExe |
# |:---- |:----------- |:--------- |:-------------- |:---------- |:------------ |
# | HKLM | TeamViewer | TeamViewer | 15.52.4 | `TeamViewer` | `"C:\Program Files\TeamViewer\uninstall.exe"` |

# Uninstall
Function TweakUninstallTeamViewer { # RESINFO
	Write-Output "Uninstalling software TeamViewer..."
	$RefName = 'TeamViewer'
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
				$Exe = 'MsiExec.exe'
				$Args = '/x "' + $KeyProduct + '" /qn'
			} Else {
				$UninstallSplit = ($App.UninstallString -Split "exe")[0] -Replace '"', ''
				$Exe = $UninstallSplit + 'exe'
				$Args = '/S'
			}

			Write-Output " Uninstalling $DisplayName version $DisplayVersion"
			Write-Output " Exe: $Exe $Args"
			SWMB_RunExec -FilePath "$Exe" -ArgumentList "$Args" -Name "$RefName" -Timeout 300
		}
}

# View
Function TweakViewTeamViewer { # RESINFO
	Write-Output "Viewing software TeamViewer..."
	$RefName = 'TeamViewer'
	@(Get-ChildItem -Recurse 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
	  Get-ChildItem -Recurse "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
		ForEach {
			$Key = $_
			$App = (Get-ItemProperty -Path $Key.PSPath)
			$DisplayName  = $App.DisplayName
			If ($DisplayName -match $RefName) {
				$DisplayVersion = $App.DisplayVersion
				$KeyProduct = $Key | Split-Path -Leaf
				$UninstallString = $App.UninstallString
				Write-Output " $DisplayName / $DisplayVersion / $KeyProduct / $UninstallString"
			}
		}
}

################################################################

# Dell Appx
# Uninstall
Function TweakUninstallDellBuiltInApps { # RESINFO
	Write-Output "Uninstalling software Dell BuiltIn Apps..."

	$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {($Global:SWMB_Custom.DellAppx -contains $_.Name)}
	$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {($Global:SWMB_Custom.DellAppx -contains $_.DisplayName)}

	# Remove appx provisioned packages - AppxProvisionedPackage
	ForEach ($ProvPackage in $ProvisionedPackages) {
		Write-Output " Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
		Try {
			$Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
			Write-Output " Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
		} Catch {
			Write-Output " Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
		}
	}

	# Remove appx packages - AppxPackage
	ForEach ($AppxPackage in $InstalledPackages) {
		Write-Output " Attempting to remove Appx package: [$($AppxPackage.Name)]..."

		Try {
			$Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
			Write-Output " Successfully removed Appx package: [$($AppxPackage.Name)]"
		} Catch {
			Write-Output " Failed to remove Appx package: [$($AppxPackage.Name)]"
		}
	}
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
