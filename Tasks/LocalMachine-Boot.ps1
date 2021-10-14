################################################################
# Win 10 / Server 2016 / Server 2019 SWMB Script - Main execution loop
# Project CNRS RESINFO SWMB
# Copyright (c) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2021, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb
# Authors:
#  2017 - Disassembler <disassembler@dasm.cz>
#  2021 - Gabriel Moreau (CNRS / LEGI)
# Version: v3.12, 2021-07-10
################################################################

# Change Path to the root
$ScriptPath = (Get-Item (Get-PSCallStack)[0].ScriptName).DirectoryName
Set-Location --Path (Join-Path -Path $ScriptPath -ChildPath "..")

# Define Boot preset on ProgramData
$DataFolder  = (Join-Path -Path $Env:ProgramData -ChildPath "SWMB")
$BootPreset  = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Presets" -ChildPath "LocalMachine-Boot.preset"))
$BootModule  = (Join-Path -Path $DataFolder -ChildPath (Join-Path -Path "Modules" -ChildPath "LocalMachine-Boot.psm1"))

# Launch SWMB with this preset
If (Test-Path -LiteralPath $BootPreset) {
	If (Test-Path -LiteralPath $BootModule) {
		.\swmb.ps1 -include $BootModule -preset $BootPreset
	} Else {
		.\swmb.ps1 -preset $BootPreset
	}
}