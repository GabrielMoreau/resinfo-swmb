################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2021, CNRS, France
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
	Write-Output "Message separator " $Script:SWMB_MsgCount
}

################################################################

# Write event message
$Script:SWMB_EventCount = 0

Function TweakSysEvent {
	$Script:SWMB_EventCount++
	Write-EventLog -LogName "Application" -Source "SWMB" -EntryType "Information" -EventID $Script:SWMB_EventCount `
		-Message "SWMB Event Message $Script:SWMB_EventCount"
}

################################################################

# Wait for box ok
Function TweakSysBox {
	[System.Windows.MessageBox]::Show('SWMB: Press OK to continue')
}

################################################################

# Wait for key press
Function TweakSysPause {
	Write-Output "`nPress any key to continue..."
	[Console]::ReadKey($true) | Out-Null
}

################################################################

# Halt computer
Function TweakSysHalt {
	Write-Output "Shutdown now..."
	Stop-Computer -ComputerName localhost -Force
}

################################################################

# Restart computer
Function TweakSysRestart {
	Write-Output "Restarting..."
	Restart-Computer
}

################################################################

# Checkpoint computer
Function TweakSysCheckpoint {
	Write-Output "Make a System Checkpoint..."
	$Date = (Get-Date -Format "yyyy/MM/dd HH:mm")
	Checkpoint-Computer -Description "SWMB Checkpoint performed at $Date"
}

################################################################

# Implementation used in powershell script
# The main implementation in swmb.ps1 is used otherwise in the CLI
Function TweakSysRequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Write-Output "You must run this script with administrator privileges"
		Exit
	}
}

################################################################

Function TweakSysAutoUpgrade {
	$moduleScriptPath = (Get-Item (Get-PSCallStack)[0].ScriptName).DirectoryName
	$swmbCorePath = (Resolve-Path (Join-Path -Path $moduleScriptPath -ChildPath '..') -ErrorAction SilentlyContinue)

	$gitUrl = 'https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/-/archive/master/resinfo-swmb-master.zip'
	$tmpFolder = (Join-Path -Path $Env:SystemDrive -ChildPath "SWMB-$(New-Guid)")
	If ($Env:Temp -ne '') {
		$tmpFolder = (Join-Path -Path $Env:Temp -ChildPath "SWMB-$(New-Guid)")
	}
	New-Item -Path $tmpFolder -ItemType Directory | Out-Null

	$outZipFile = (Join-Path -Path $tmpFolder -ChildPath swmb-bitlocker.zip)

	Invoke-WebRequest -Uri $gitUrl -OutFile $outZipFile -ErrorAction SilentlyContinue
	Expand-Archive -Path $outZipFile -DestinationPath $tmpFolder
	If (Test-Path "$tmpFolder\resinfo-swmb-master") {
		Write-Output "Upgrade of SWMB installation..."
		Copy-Item -Path "$tmpFolder\resinfo-swmb-master\*" -Destination "$swmbCorePath" -Recurse -Force
		Get-ChildItem -Path "$swmbCorePath" -Recurse | Unblock-File
	} Else {
		Write-Output "Error: Upgrade of SWMB impossible..."
	}

	if (Test-Path "$tmpFolder") {
		Remove-Item -Path "$tmpFolder" -Force -Recurse -ErrorAction SilentlyContinue
	}
}

################################################################
### Obsolete function
################################################################

# Since 2021/06
# Wait for key press
Function TweakWaitForKey {
	Write-Output "Warning: obsolete tweak WaitForKey, now use SysPause"
	SysPause
}

################################################################

# Since 2021/06
# Restart computer
Function TweakRestart {
	Write-Output "Warning: obsolete tweak Restart, now use SysRestart"
	SysRestart
}

################################################################

# Since 2021/07
# Require administrator privileges
Function TweakRequireAdmin {
	Write-Output "Warning: obsolete tweak RequireAdmin, now use SysRequireAdmin"
	SysRequireAdmin
}

################################################################
### Region Internal Functions
################################################################

Function SWMB_Init {
	$Global:SWMB_Tweaks = @()
	$Global:SWMB_PSCommandArgs = @()
	# $Global:SWMB_ChkSumFile = (Join-Path -Path (Join-Path -Path (Join-Path -Path $Env:ProgramData -ChildPath "SWMB") -ChildPath "Caches") -ChildPath "last.chksum")
}

################################################################

Function SWMB_AddOrRemoveTweak() {
	Param (
		[string]$Tweak,
		[string]$Path = '.'
	)

	Function _MergePath {
		Param (
			[Parameter(Mandatory = $true)] [string]$Path,
			[Parameter(Mandatory = $true)] [string]$FilePath
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
			Import-Module -Name "$_.Path" -ErrorAction Stop
		}
	} ElseIf ($Tweak -cmatch '^\$IMPORT\s+[^\s]') {
		# Import the file as a module, wildcard possible
		$ModuleFile = (_MergePath -Path $Path -FilePath ($Tweak -creplace '^\$IMPORT\s+([^\s])', '$1'))
		Resolve-Path $ModuleFile -ErrorAction Stop | ForEach-Object {
			Import-Module -Name "$_.Path" -ErrorAction Stop
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
		Invoke-Expression "Tweak$_"
	}
}

################################################################

Function SWMB_CheckTweaks {
	$uniqueTweak = @{}

	ForEach ($tweak in $Global:SWMB_Tweaks) {
		# Test if tweak function really exists
		If (-not(Get-Command -Name "Tweak$tweak" -ErrorAction SilentlyContinue)) {
			Write-Output "Tweak $tweak is not defined!"
		}

		# Push tweak in a hash table
		$key = $tweak -Replace '^(Enable|Disable|Install|Uninstall|Show|Hide|Add|Remove|Set|Unset|Pin|Unpin)',''
		$uniqueTweak[$key]++
	}

	ForEach ($tweak in $uniqueTweak.keys) {
		If ($uniqueTweak[$tweak] -eq 1) {
			Continue
		}
		$message = "Tweak {0} is defined {1} times!" -f $tweak, $uniqueTweak[$tweak]
		Write-Output $message
	}
}

################################################################

Function SWMB_PrintTweaks {
	ForEach ($tweak in $Global:SWMB_Tweaks) {
		# Test if tweak function really exists
		If (-not(Get-Command -Name "Tweak$tweak" -ErrorAction SilentlyContinue)) {
			Write-Output "# $tweak"
		} Else {
			Write-Output "$tweak"
		}
	}
}

################################################################

Function SWMB_ImportModuleParameter() {
	Param (
		[Parameter(Mandatory = $true)] [string]$moduleScriptName
	)

	Function _ModuleAutoLoad() {
		Param (
			[Parameter(Mandatory = $true)] [string]$PathBase
		)

		$VarOverload = $PathBase + '-VarOverload.psm1'
		$VarAutodel  = $PathBase + '-VarAutodel.psm1'

		If ((Test-Path -LiteralPath $VarOverload) -Or (Test-Path -LiteralPath $VarAutodel)) {
			If (Test-Path -LiteralPath $VarOverload) {
				Import-Module -Name $VarOverload -ErrorAction Stop
			}
			If (Test-Path -LiteralPath $VarAutodel) {
				Import-Module -Name $VarAutodel -ErrorAction Stop
				Remove-Item $VarAutodel -ErrorAction Stop
			}
			Return $true
		}
		Return $false
	}

	$moduleScriptPath = (Get-Item $moduleScriptName).DirectoryName
	$moduleScriptBasename = (Get-Item $moduleScriptName).Basename

	# Try to load default parameter module with extension -VarDefault
	$moduleScriptVarDefault = (Join-Path -Path $moduleScriptPath -ChildPath $moduleScriptBasename) + '-VarDefault.psm1'
	If (Test-Path -LiteralPath $moduleScriptVarDefault) {
		Import-Module -Name $moduleScriptVarDefault -ErrorAction Stop
	}
	# Try to load local overload parameter module with extension -VarOverload
	While (Test-Path -LiteralPath $moduleScriptPath) {
		# Module VarOverload directly in the current folder
		If (_ModuleAutoLoad -PathBase (Join-Path -Path $moduleScriptPath -ChildPath $moduleScriptBasename)) {
			Return $true
		}

		# Or module VarOverload directly in the subfolder Modules
		If (_ModuleAutoLoad -PathBase (Join-Path -Path $moduleScriptPath -ChildPath (Join-Path -Path "Modules" -ChildPath $moduleScriptBasename))) {
			Return $true
		}

		# Search module in the parent folder .. and so on
		$newPath = (Resolve-Path (Join-Path -Path $moduleScriptPath -ChildPath "..") -ErrorAction SilentlyContinue) 
		If ("$newPath" -eq "$moduleScriptPath") {
			Break
		}
		$moduleScriptPath = $newPath
	}

	# Search module in ProgramData folder
	$DataFolder = (Join-Path -Path $Env:ProgramData -ChildPath "SWMB")
	$DataModule = (Join-Path -Path $DataFolder      -ChildPath "Modules")
	If (_ModuleAutoLoad -PathBase (Join-Path -Path $DataFolder -ChildPath $moduleScriptBasename)) {
		Return $true
	}
	If (_ModuleAutoLoad -PathBase (Join-Path -Path $DataModule -ChildPath $moduleScriptBasename)) {
		Return $true
	}
}

################################################################

Function SWMB_MakeCkeckpoint() {
	Param (
		[Parameter(Mandatory = $true)] [string]$Path
	)

	Function _String2Sha256 {
		Param (
			[Parameter(Mandatory=$true)] [string]$Text
		)

		$Hasher = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
		$Hash = $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Text))
		$HashString = [System.BitConverter]::ToString($Hash)
		Return $HashString.Replace('-', '')
	}

	SysRequireAdmin
	$HashPrev = "UNKNOWN"
	If (Test-Path -LiteralPath $Path) {
		$HashPrev = Get-Content -Path $Path
	}

	$Build = [System.Environment]::OSVersion.Version.Build # Windows version
	$Text = "BuildOSVersion-" + $Build + "/" + ($Global:SWMB_Tweaks -Join '/')
	$HashNext = _String2Sha256 -Text $Text
	# Checkpoint when OS version change or tweak list change
	If ($HashNext -ne $HashPrev) {
		SysCheckpoint
		Write-Output $HashNext > $Path
	}
}

################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function *
