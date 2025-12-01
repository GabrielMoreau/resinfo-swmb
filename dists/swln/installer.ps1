
$SWLN_Name = "__SWLN_NAME__"
$SWLN_Version = "__SWLN_VERSION__"
$SWMB_Version = "__SWMB_VERSION__"

If (Test-Path "${Env:ProgramFiles}\$SWLN_Name\version.txt" -PathType Leaf) {
	$SWLN_VersionOld = Get-Content -Path "${Env:ProgramFiles}\$SWLN_Name\version.txt"
	# $SWLN_VersionOld_number = [float]$SWLN_VersionOld
}

# Host extension
$HostExt="Host-$(${Env:ComputerName}.ToLower())"

# Copy of scripts and configuration files in install folder
ForEach ($FileItem in @(
	__ALLINSTALLFILES__
)) {
	If ("$FileItem" -match '^(install\.bat|installer\.ps1|post-install-.*|pre-install-.*)$') {
		Continue
	} ElseIf (Test-Path -LiteralPath "$FileItem" -PathType Leaf) {
		Copy-Item -LiteralPath "$FileItem" -Destination "${Env:ProgramFiles}\$SWLN_Name" -Force
	} ElseIf (Test-Path -LiteralPath "$FileItem" -PathType Container) {
		Copy-Item -LiteralPath "$FileItem" -Destination "${Env:ProgramFiles}\$SWLN_Name" -Force -Recurse
	}
}

# Create main ProgramData folder (SWLN is installed before SWMB)
If (!(Test-Path -LiteralPath "${Env:ProgramData}\SWMB")) {
	Write-Output "Create ${Env:ProgramData}\SWMB directory"
	New-Item -Path "${Env:ProgramData}\SWMB" -ItemType "directory" -Force
}

# Push config files in ProgramData before install SWMB
ForEach ($FileItem in @(
	"${Env:ProgramData}\SWMB\Presets\CurrentUser-Logon.preset"
	"${Env:ProgramData}\SWMB\Presets\LocalMachine-Boot.preset"
	"${Env:ProgramData}\SWMB\Presets\LocalMachine-PostInstall.preset"
	"${Env:ProgramData}\SWMB\Modules\Custom-VarOverload.psm1"
	"${Env:ProgramData}\SWMB\Modules\Local-Addon.psm1"
	"${Env:ProgramData}\SWMB\Presets\CurrentUser-Logon-$HostExt.preset"
	"${Env:ProgramData}\SWMB\Presets\LocalMachine-Boot-$HostExt.preset"
	"${Env:ProgramData}\SWMB\Presets\LocalMachine-PostInstall-$HostExt.preset"
	"${Env:ProgramData}\SWMB\Modules\Custom-VarOverload-$HostExt.psm1"
	"${Env:ProgramData}\SWMB\Modules\Local-Addon-$HostExt.psm1"
)) {
	$FileName   = Split-Path -Path "$FileItem" -Leaf
	$FolderName = Split-Path -Path "$FileItem" -Parent
	# If (!(Test-Path -LiteralPath "$FileName")) { Continue }
	If (!(Test-Path -LiteralPath "$FolderName")) {
		New-Item -Path "$FolderName" -ItemType "directory" -Force
		}
	If (Test-Path -LiteralPath "${Env:ProgramFiles}\$SWLN_Name\$FileName") {
		If (Test-Path -LiteralPath "$FileItem") {
			Rename-Item -LiteralPath "$FileItem" -NewName ("$FileItem" + ".old") -Force -ErrorAction Ignore
		}
		Write-Output "Copy ${Env:ProgramFiles}\$SWLN_Name\$FileName in $FileItem"
		Copy-Item -LiteralPath "${Env:ProgramFiles}\$SWLN_Name\$FileName" -Destination "$FileItem" -Force
	}
}

# Add exception for Microsoft Defender
If ($(Get-MpComputerStatus).AntivirusEnabled  -eq $True ) {
	Write-Host "Microsoft Defender Antivirus is enabled"
	Write-Host "Microsoft Defender exclude OCS Temporary file"
	Write-Host "Script path $PSScriptRoot"
	Add-MpPreference -ExclusionPath "${Env:ProgramFiles}\$SWLN_Name" -Force
	Add-MpPreference -ExclusionPath "$PSScriptRoot" -Force
	Write-Host "Current path $PWD"
	Add-MpPreference -ExclusionPath "$PWD" -Force
} Else {
	Write-Host "Microsoft Defender Antivirus is disabled"
}

# Allow PowerShell scripts in the SWLN directory
Write-Output " Unblock scripts"
Get-ChildItem -LiteralPath "${Env:ProgramFiles}\$SWLN_Name\"  -Recurse | Unblock-File
Get-ChildItem -LiteralPath "${Env:ProgramData}\SWMB\Modules\" -Recurse | Unblock-File

# Silent SWMB install
Write-Output "Install SWMB - version $SWMB_Version"
& .\SWMB-Setup-"$SWMB_Version".exe /S

# Creation of the version file with the version number
New-Item -Path "${Env:ProgramFiles}\$SWLN_Name\version.txt" -Type File -Force
$SWLN_Version | Set-Content -LiteralPath "${Env:ProgramFiles}\$SWLN_Name\version.txt"
