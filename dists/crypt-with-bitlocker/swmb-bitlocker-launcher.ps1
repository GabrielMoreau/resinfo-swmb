#Requires -Version 4.0
#Requires -RunAsAdministrator


$GitUrl = "https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/-/archive/master/resinfo-swmb-master.zip"
$SwmbBitlockerDirectory = "C:\SWMB"

Write-Host @"
This script aims to configure Bitlocker on your computer (cf. README)
This script creates a $SwmbBitlockerDirectory\resinfo-swmb-master subdirectory if not exsists
or delete it and recreate if exists
This script download the main script from gitlab.in2p3.fr
To work correctly, this script needs:
   - To be run with an administrator account and elevated privileges
   - BIOS in UEFI
   - SecureBoot enabled
   - TPM activated

"@ -ForegroundColor Green

$Confirmation = Read-Host "Do you want to proceed? [y/N]"
If ($Confirmation -ne "y") {
    Write-Host @"
------------------
Stop processing!
------------------
"@ -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

$OutZipFile = Join-Path  -Path (Get-Location) -ChildPath swmb-bitlocker.zip

Write-Host @"
------------------
Processing directory $SwmbBitlockerDirectory...
------------------
"@ -ForegroundColor Green

If (!(Test-Path $SwmbBitlockerDirectory)) {
    New-Item -Path $SwmbBitlockerDirectory -ItemType Directory
}
If (Test-Path "$SwmbBitlockerDirectory\resinfo-swmb-master") {
    Remove-Item "$SwmbBitlockerDirectory\resinfo-swmb-master" -Force -Recurse
}

Write-Host @"
------------------
Downloading file...
------------------
"@ -ForegroundColor Green
Invoke-WebRequest $GitUrl -OutFile $OutZipFile -ErrorAction Stop


Write-Host @"
------------------
Decompressing file...
------------------
"@ -ForegroundColor Green
Expand-Archive -Path $OutZipFile -DestinationPath $SwmbBitlockerDirectory
If (!(Test-Path "$SwmbBitlockerDirectory\resinfo-swmb-master")) {
    Write-Host @"
------------------
Error decompressing. Stop script!
------------------
"@ -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

Write-Host @"
------------------
Unblocking files...
------------------
"@ -ForegroundColor Green
dir -Path "$SwmbBitlockerDirectory\resinfo-swmb-master" -Recurse  | Unblock-File

Write-Host @"
------------------
Launching...
------------------
"@ -ForegroundColor Green

cd "$SwmbBitlockerDirectory\resinfo-swmb-master"
& .\swmb.ps1 `
   SysRequireAdmin `
   EnableBitlocker
