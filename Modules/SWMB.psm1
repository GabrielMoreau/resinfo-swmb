################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################


################################################################
### Region Auxiliary Functions
################################################################

# Write message separator
$Script:SWMB_MsgCount = 0

Function TweakSysMessage {
	$Script:SWMB_MsgCount++
	Write-Output "SWMB: Message separator: $Script:SWMB_MsgCount"
}

################################################################

# Write event message
$Script:SWMB_EventCount = 0

Function TweakSysEvent {
	$Script:SWMB_EventCount++
	Write-EventLog -LogName "Application" -Source "SWMB" -EntryType "Information" -EventID $Script:SWMB_EventCount `
		-Message "SWMB: Event Message $Script:SWMB_EventCount"
}

################################################################

# Wait for box ok
Function TweakSysBox {
	[System.Windows.MessageBox]::Show('SWMB: Press OK to continue')
}

################################################################

# Wait for key press
Function TweakSysPause {
	Write-Output "`nSWMB: Press any key to continue..."
	[Console]::ReadKey($True) | Out-Null
}

################################################################

# Halt computer
Function TweakSysHalt {
	Write-Output "SWMB: Shutdown now..."
	Stop-Computer -ComputerName localhost -Force
}

################################################################

# Restart computer
Function TweakSysRestart {
	Write-Output "SWMB: Restarting..."
	Restart-Computer
}

################################################################

# Checkpoint computer
Function TweakSysCheckpoint {
	Write-Output "SWMB: Make a System Checkpoint..."
	$Date = (Get-Date -Format "yyyy/MM/dd HH:mm")
	Checkpoint-Computer -Description "SWMB Checkpoint performed at $Date"
}

################################################################

# Implementation used in powershell script
# The main implementation in swmb.ps1 is used otherwise in the CLI
Function TweakSysRequireAdmin {
	Write-Output "SWMB: Require administrator privileges..."
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Write-Output " You must run this script with administrator privileges"
		Exit
	}
}

################################################################

Function TweakSysAutoUpgrade {
	$ModuleScriptPath = (Get-Item (Get-PSCallStack)[0].ScriptName).DirectoryName
	$SwmbCorePath = (Resolve-Path (Join-Path -Path $ModuleScriptPath -ChildPath '..') -ErrorAction SilentlyContinue)

	$gitUrl = 'https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/-/archive/master/resinfo-swmb-master.zip'
	$tmpFolder = (Join-Path -Path ${Env:SystemDrive} -ChildPath "SWMB-$(New-Guid)")
	If (${Env:Temp} -ne '') {
		$tmpFolder = (Join-Path -Path ${Env:Temp} -ChildPath "SWMB-$(New-Guid)")
	}
	New-Item -Path $tmpFolder -ItemType Directory | Out-Null

	$outZipFile = (Join-Path -Path $tmpFolder -ChildPath swmb-bitlocker.zip)

	Invoke-WebRequest -Uri $gitUrl -OutFile $outZipFile -ErrorAction SilentlyContinue
	Expand-Archive -Path $outZipFile -DestinationPath $tmpFolder
	If (Test-Path "$tmpFolder\resinfo-swmb-master") {
		Write-Output "Upgrade of SWMB installation..."
		Copy-Item -Path "$tmpFolder\resinfo-swmb-master\*" -Destination "$SwmbCorePath" -Recurse -Force
		Get-ChildItem -Path "$SwmbCorePath" -Recurse | Unblock-File
	} Else {
		Write-Output "Error: Upgrade of SWMB impossible..."
	}

	If (Test-Path "$tmpFolder") {
		Remove-Item -Path "$tmpFolder" -Force -Recurse -ErrorAction SilentlyContinue
	}
}

################################################################
### Obsolete function
################################################################

# Since 2021/06
# Wait for key press
Function TweakWaitForKey { # Obsolete
	Write-Output "Warning: obsolete tweak WaitForKey, now use SysPause"
	TweakSysPause
}

################################################################

# Since 2021/06
# Restart computer
Function TweakRestart { # Obsolete
	Write-Output "Warning: obsolete tweak Restart, now use SysRestart"
	TweakSysRestart
}

################################################################

# Since 2021/07
# Require administrator privileges
Function TweakRequireAdmin { # Obsolete
	Write-Output "Warning: obsolete tweak RequireAdmin, now use SysRequireAdmin"
	TweakSysRequireAdmin
}

################################################################
### Region Internal Functions
################################################################

Function SWMB_Init {
	$Global:SWMB_Tweaks = @()
	$Global:SWMB_PSCommandArgs = @()
	# $Global:SWMB_ChkSumFile = (Join-Path -Path (Join-Path -Path (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB") -ChildPath "Caches") -ChildPath "last.chksum")
}

################################################################

Function SWMB_AddOrRemoveTweak() {
	Param (
		[string]$Tweak,
		[string]$Path = '.'
	)

	Function _MergePath {
		Param (
			[Parameter(Mandatory = $True)] [string]$Path,
			[Parameter(Mandatory = $True)] [string]$FilePath
		)

		If (($FilePath -cmatch '^[A-Z]:\\') -or ($FilePath -cmatch '^\\\\')) {
			# Absolute Path
			Return $FilePath
		} Else {
			# Relative Path
			Return (Join-Path -Path $Path -ChildPath $FilePath)
		}
	}

	If ($Tweak[0] -eq "!") {
		# If the name starts with exclamation mark (!), exclude the tweak from selection
		$Global:SWMB_Tweaks = $Global:SWMB_Tweaks | Where-Object { $_ -ne $Tweak.Substring(1) }
	} ElseIf ($Tweak -cmatch '^\$INCLUDE\s+"[^"]+"') {
		Write-Output "Warning: obsolete special tweak `$INCLUDE, now use `$PRESET"
		# Include preset file, wildcard possible
		$TweakFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$INCLUDE\s+"([^"]+)"', '$1'))
		SWMB_LoadTweakFile -TweakFile "$TweakFile" -CLI $False
	} ElseIf ($Tweak -cmatch '^\$INCLUDE\s+[^\s]') {
		Write-Output "Warning: obsolete special tweak `$INCLUDE, now use `$PRESET"
		# Include preset file, wildcard possible
		$TweakFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$INCLUDE\s+([^\s])', '$1'))
		SWMB_LoadTweakFile -TweakFile "$TweakFile" -CLI $False
	} ElseIf ($Tweak -cmatch '^\$PRESET\s+"[^"]+"') {
		# PRESET preset file, wildcard possible
		$TweakFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$PRESET\s+"([^"]+)"', '$1'))
		SWMB_LoadTweakFile -TweakFile "$TweakFile" -CLI $False
	} ElseIf ($Tweak -cmatch '^\$PRESET\s+[^\s]') {
		# PRESET preset file, wildcard possible
		$TweakFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$PRESET\s+([^\s])', '$1'))
		SWMB_LoadTweakFile -TweakFile "$TweakFile" -CLI $False
	} ElseIf ($Tweak -cmatch '^\$IMPORT\s+"[^"]+"') {
		# Import the file as a module, wildcard possible
		$ModuleFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$IMPORT\s+"([^"]+)"', '$1'))
		Resolve-Path $ModuleFile -ErrorAction Stop | ForEach-Object {
			Import-Module -Name "$_" -ErrorAction Stop
		}
	} ElseIf ($Tweak -cmatch '^\$IMPORT\s+[^\s]') {
		# Import the file as a module, wildcard possible
		$ModuleFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$IMPORT\s+([^\s])', '$1'))
		Resolve-Path $ModuleFile -ErrorAction Stop | ForEach-Object {
			Import-Module -Name "$_" -ErrorAction Stop
		}
	} ElseIf ($Tweak -ne "") {
		# Otherwise add the tweak
		$Global:SWMB_Tweaks += $Tweak
	}
}

################################################################

Function SWMB_LoadTweakFile() {
	Param (
		[string]$TweakFile,
		[bool]$CLI = $True
	)

	# Resolve full path to the preset file
	Resolve-Path $TweakFile -ErrorAction Stop | ForEach-Object {
		$preset = $_.Path
		$path = (Split-Path -Path $_)
		# Bluid CLI for RequireAdmin
		If ($CLI -eq $True) {
			$Global:SWMB_PSCommandArgs += "-preset `"$preset`""
		}
		# Load tweak names from the preset file
		Get-Content $preset -ErrorAction Stop | ForEach-Object {
			SWMB_AddOrRemoveTweak -Tweak $_.Split("#")[0].Trim() -Path $path
		}
	}
}

################################################################

Function SWMB_RunTweaks {
	$Global:SWMB_Tweaks | ForEach-Object {
		If (Get-Command -Name "Tweak$_" -ErrorAction SilentlyContinue) {
			Invoke-Expression "Tweak$_"
		} Else {
			Write-Output "Tweak $_ is not defined!"
		}
	}
}

################################################################

Function SWMB_CheckTweaks {
	$UniqueTweak = @{}

	ForEach ($CurrentTweak in $Global:SWMB_Tweaks) {
		# Test if tweak function really exists
		If (!(Get-Command -Name "Tweak$CurrentTweak" -ErrorAction SilentlyContinue)) {
			Write-Output "Tweak $CurrentTweak is not defined!"
		}

		# Push tweak in a hash table
		$Key = $CurrentTweak -Replace '^(Enable|Disable|Install|Uninstall|Show|Hide|Add|Remove|Set|Unset|Pin|Unpin)',''
		$UniqueTweak[$Key]++
	}

	ForEach ($CurrentTweak in $UniqueTweak.keys) {
		If ($UniqueTweak[$CurrentTweak] -eq 1) {
			Continue
		}
		$Message = "Tweak {0} is defined {1} times!" -f $CurrentTweak, $UniqueTweak[$CurrentTweak]
		Write-Output $Message
	}
}

################################################################

Function SWMB_PrintTweaks {
	ForEach ($CurrentTweak in $Global:SWMB_Tweaks) {
		# Test if tweak function really exists
		If (!(Get-Command -Name "Tweak$CurrentTweak" -ErrorAction SilentlyContinue)) {
			Write-Output "# $CurrentTweak"
		} Else {
			Write-Output "$CurrentTweak"
		}
	}
}

################################################################

Function SWMB_MakeCkeckpoint() {
	Param (
		[Parameter(Mandatory = $True)] [string]$Path
	)

	Function _String2Sha256 {
		Param (
			[Parameter(Mandatory = $True)] [string]$Text
		)

		$Hasher = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
		$Hash = $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Text))
		$HashString = [System.BitConverter]::ToString($Hash)
		Return $HashString.Replace('-', '')
	}

	TweakSysRequireAdmin
	$HashPrev = "UNKNOWN"
	If (Test-Path -LiteralPath $Path) {
		$HashPrev = Get-Content -Path $Path
	}

	# Windows build version
	$Build = [System.Environment]::OSVersion.Version.Build
	# Windows monthly subversion
	$UBR = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name UBR).UBR
	# String to Hash
	$Text = "BuildOSVersion-" + $Build + "-" + $UBR + "/" + ($Global:SWMB_Tweaks -Join '/')
	$HashNext = _String2Sha256 -Text $Text
	# Checkpoint when OS version change or tweak list change
	If ($HashNext -ne $HashPrev) {
		TweakSysCheckpoint
		Write-Output $HashNext > $Path
	}
}

################################################################

# Return OS version with build and UBR monthly version
Function SWMB_GetOSVersion {
	$Major = [System.Environment]::OSVersion.Version.Major
	$Minor = [System.Environment]::OSVersion.Version.Minor
	$Build = [System.Environment]::OSVersion.Version.Build
	$UBR = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name UBR).UBR
	Return [version]"$Major.$Minor.$Build.$UBR"
}

################################################################

# Return OS short name Windows10 or Windows11 without space (for use as key in hash table)
Function SWMB_GetOSShortName {
	$OSVersion = SWMB_GetOSVersion
	If ($OSVersion -ge [version]"10.0.22000.0") {
		$OSShortName = "Windows11"
	} ElseIf ($OSVersion -ge [version]"10.0.10240.0") {
		$OSShortName = "Windows10"
	} Else {
		Write-Output "Error: Windows OS not officially supported, version $OSVersion"
		$OSShortName = "WindowsXX"
	}
	Return $OSShortName
}

################################################################

# Transform string to a version object
Function SWMB_ToVersion {
	Param (
		[Parameter(Mandatory = $true)] [string]$Version
	)

	$Version = $Version -Replace '[^\d\.].*$', ''
	$Version = "$Version.0.0.0"
	$Version = $Version -Replace '\.+',     '.'
	$Version = $Version -Replace '\.0+',    '.0'
	$Version = $Version -Replace '\.0(\d)', '.$1'
	$Version = $Version.Split('.')[0,1,2,3] -Join '.'
	Return [version]$Version
}

################################################################

# Run MSI or EXE with timeout control
Function SWMB_RunExec {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)] [string]$Name,
		[Parameter(Mandatory = $True)] [string]$FilePath,
		[Parameter(Mandatory = $True)] [string]$ArgumentList,
		[Parameter(Mandatory = $False)] [int]$Timeout = 300
	)

	$Proc = Start-Process -FilePath "$FilePath" -ArgumentList "$ArgumentList" -WindowStyle 'Hidden' -ErrorAction 'SilentlyContinue' -PassThru
	If ($PSBoundParameters["Verbose"]) {
		Write-Output " RunExec: `"$FilePath`" $ArgumentList"
	}

	$Timeouted = $Null # Reset any previously set timeout
	# Wait up to 180 seconds for normal termination
	$Proc | Wait-Process -Timeout $Timeout -ErrorAction SilentlyContinue -ErrorVariable Timeouted
	If ($Timeouted) {
		# Terminate the process
		$Proc | Kill
		Write-Output " Error: kill $Name uninstall exe"
		Return
	} ElseIf ($Proc.ExitCode -ne 0) {
		Write-Output " Error: $Name uninstall return code $($Proc.ExitCode)"
		Return
	}
}

################################################################

# Remove Appx
Function SWMB_RemoveAppx {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)] [string]$Name,
		[Parameter(Mandatory = $False)] [string]$Message = ''
	)

	If ($Message) {
		Write-Output "$Message"
	}

	$Packages = Get-AppxPackage -AllUsers -Name $Name
	If ($Packages) {
		ForEach ($Package in $Packages) {
			Remove-AppxPackage -Package $Package.PackageFullName -ErrorAction SilentlyContinue
		}

		If ($PSBoundParameters["Verbose"]) {
			$PackagesAfterRemoval = Get-AppxPackage -AllUsers -Name $Name
			If ($PackagesAfterRemoval) {
				Write-Output " Error: Appx still installed $Name"
			} Else {
				Write-Output " Info: Appx removed $Name"
			}
		}
	}
}

# Add Appx
Function SWMB_AddAppx {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)] [string]$Name,
		[Parameter(Mandatory = $False)] [string]$Message = ''
	)

	If ($Message) {
		Write-Output "$Message"
	}

	$Packages = Get-AppxPackage -AllUsers -Name $Name
	If ($Packages) {
		ForEach ($Package in $Packages) {
			Add-AppxPackage -DisableDevelopmentMode -Register "$($Package.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
		}

		If ($PSBoundParameters["Verbose"]) {
			$PackagesAfterInstalling = Get-AppxPackage -AllUsers -Name $Name
			If ($PackagesAfterInstalling) {
				Write-Output " Info: Appx add $Name"
			} Else {
				Write-Output " Error: Appx was not installed $Name"
			}
		}
	}
}

# View Appx
Function SWMB_ViewAppx {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)] [string]$Name,
		[Parameter(Mandatory = $False)] [string]$Message = ''
	)

	If ($Message) {
		Write-Output "$Message"
	}

	$Packages = Get-AppxPackage -AllUsers -Name $Name
	If ($Package) {
		ForEach ($Package in $Packages) {
			Write-Output " Appx $Name - $($Package.InstallLocation)"
		}
	} Else {
		Write-Output " No Appx $Name"
	}
}

################################################################

# Load .ini config file (use to parse secedit export)
Function SWMB_LoadIniFile {
	Param(
		[Parameter(Mandatory)] [string]$Path
	)

	$Ini = [ordered]@{}
	$CurrentSection = ''

	ForEach ($Line in Get-Content $Path) {
		$Line = $Line.Trim()
		If ($Line -match '^\s*#') { Continue }
		If ($Line -match '^\s*\[([^\]]+)\]\s*$') {
			$CurrentSection = $Matches[1]
			if (-not $Ini.Contains($CurrentSection)) {
				$Ini[$CurrentSection] = [ordered]@{}
			}
			Continue
		}
		If ($Line -match '^\s*(\w+)\s*=\s*(.+)$') {
			$Key = $Matches[1]
			$Value = $Matches[2]
			$Ini[$CurrentSection][$Key] = $Value
		}
	}
	return $Ini
}

################################################################

Function SWMB_GetRegistrySettings {
	Param (
		[Parameter(Mandatory)] [string]$Path,
		[Parameter(Mandatory)] [System.Collections.IDictionary]$Rules
	)

	$Props = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue

	ForEach ($Name in $Rules.Keys) {
		$Rule     = $Rules[$Name]
		$HasValue = $Props -and ($Props.PSObject.Properties.Name -contains $Name)
		$HasOkDef = $Rule -and $Rule.ContainsKey('OkValues')

		If (-not $HasValue) {
			If ($HasOkDef -and ($Rule.OkValues -contains $Null)) {
				$Status = 'OK'
			} ElseIf ($HasOkDef) {
				$Status = 'NOT OK'
			} Else {
				$Status = 'INFO'
			}

			[PSCustomObject]@{
				Path   = $Path
				Name   = $Name
				Value  = $null
				Exists = $False
				Status = $Status
				Remediation = If ($Rule.ContainsKey('Remediation')) { $Rule.Remediation } Else { $Null }
			}
			Continue
		}

		$Value = $Props.$Name
		If (-not $HasOkDef) {
			$Status = 'INFO'
		} Else {
			$Status = 'NOT OK' # By default
			# Check OkValues
			ForEach ($OkValue in $Rule.OkValues) {
				# If OkValue is a test (cf '>8')
				If ($OkValue -match '^>(\d+)$') {  # OkValue is a test >
					$Threshold = [int]$Matches[1]
					If ($Value -gt $Threshold) {
						$Status = 'OK'
						Break
					}
				} ElseIf ($OkValue -match '^<(\d+)$') {  # OkValue is a test <
					$Threshold = [int]$Matches[1]
					If ($Value -lt $Threshold) {
						$Status = 'OK'
						Break
					}
				} ElseIf ($Value -eq $OkValue) {  # OkValue is a value
					$Status = 'OK'
					Break
				}
			}
		}

		[PSCustomObject]@{
			Path   = $Path
			Name   = $Name
			Value  = $Value
			Exists = $True
			Status = $Status
			Remediation = If ($Rule.ContainsKey('Remediation')) { $Rule.Remediation } Else { $Null }
		}
	}
}

################################################################

Function SWMB_GetIniSettings {
	Param (
		[Parameter(Mandatory)] [System.Collections.IDictionary]$IniData,
		[Parameter(Mandatory)] [string]$Section,
		[Parameter(Mandatory)] [System.Collections.IDictionary]$Rules
	)

	$SectionData = $IniData[$Section]

	If (-not $SectionData) {
		Write-Output "Section '$Section' not exist in INI database."
		Return
	}

	ForEach ($Name in $Rules.Keys) {
		$Rule	 = $Rules[$Name]
		$HasValue = $SectionData.Contains($Name)  # Check Key exist
		$HasOkDef = $Rule -and $Rule.ContainsKey('OkValues')

		If (-not $HasValue) {
			# No value for Key
			If ($HasOkDef -and ($Rule.OkValues -contains $Null)) {
				$Status = 'OK'
			} ElseIf ($HasOkDef) {
				$Status = 'NOT OK'
			} Else {
				$Status = 'INFO'
			}

			[PSCustomObject]@{
				Section = $Section
				Name    = $Name
				Value   = $Null
				Exists  = $False
				Status  = $Status
				Remediation = If ($Rule.ContainsKey('Remediation')) { $Rule.Remediation } Else { $Null }
			}
			Continue
		}

		$Value = $SectionData[$Name]
		If (-not $HasOkDef) {
			$Status = 'INFO'
		} Else {
			$Status = 'NOT OK'
			ForEach ($OkValue in $Rule.OkValues) {
				If ($OkValue -match '^>(\d+)$') {
					$Threshold = [int]$Matches[1]
					If ($Value -gt $Threshold) {
						$Status = 'OK'
						Break
					}
				} ElseIf ($OkValue -match '^<(\d+)$') {
					$Threshold = [int]$Matches[1]
					If ($Value -lt $Threshold) {
						$Status = 'OK'
						Break
					}
				} ElseIf ($Value -eq $OkValue) {
					$Status = 'OK'
					Break
				}
			}
		}

		[PSCustomObject]@{
			Section = $Section
			Name    = $Name
			Value   = $Value
			Exists  = $True
			Status  = $Status
			Remediation = If ($Rule.ContainsKey('Remediation')) { $Rule.Remediation } Else { $Null }
		}
	}
}

################################################################

Function SWMB_WriteSettings {
	Param (
		[Parameter(Mandatory, ValueFromPipeline)] [PSCustomObject]$InputObject
	)

	Process {
		$DisplayValue = If ($InputObject.Exists) {
			$InputObject.Value
		} Else {
			'not exist'
		}

		$Icon = @{
			'OK'     = '✅'
			'NOT OK' = '❌'
			'INFO'   = 'ℹ️'
		}
		$OutPut = " {0,-32} {1,-10} {2} {3}" -F $InputObject.Name, $DisplayValue, $Icon[$InputObject.Status], $InputObject.Status
		If ($InputObject.Status -ne 'OK' -and $InputObject.Remediation -ne $Null) {
			$OutPut += " → Suggested fix: $($InputObject.Remediation)"
			}
		If ([Console]::IsOutputRedirected) {
			Write-Output $OutPut
			Return
		}
		Switch ($InputObject.Status) {
			"OK"     { Write-Host $OutPut -ForegroundColor Green }
			"NOT OK" { Write-Host $OutPut -ForegroundColor Red }
			'INFO'   { Write-Host $OutPut -ForegroundColor Cyan }
			default  { Write-Host $OutPut }
		}
	}
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function *
