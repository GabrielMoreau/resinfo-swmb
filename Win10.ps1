################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2026, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2021 - Gabriel Moreau (CNRS / LEGI)
################################################################

# Since 2021/07
# Obsolete script, now use swmb.ps1
# Script for compatibility

Write-Output "Warning: obsolete command Win10.ps1, now use swmb.ps1"

$Cmd = (Get-PSCallStack)[0].ScriptName
$Cmd = (($Cmd -replace 'Win10.ps1$', 'swmb.ps1') -replace ' ', '` ') + ' ' + $Args

Invoke-Expression -Command $Cmd
