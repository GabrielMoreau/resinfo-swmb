ECHO OFF

SET softversion=1.0
SET softpatch=1
SET softname=SWMB - Configuration RESINFO
SET regkey=SWMB
SET softpublisher=RESINFO GT SWMB
SET logfile="C:\Program Files\SWMB\logfile.txt"

SET pwrsh=%WINDIR%\System32\WindowsPowerShell\V1.0\powershell.exe
IF EXIST "%WINDIR%\Sysnative\WindowsPowerShell\V1.0\powershell.exe" SET pwrsh=%WINDIR%\Sysnative\WindowsPowerShell\V1.0\powershell.exe

COPY /y NUL "C:\Program Files\SWMB\logfile.txt" >NUL  
ECHO %date%-%time%>>%logfile%


REM ajoute les droits pour l'execution de scripts powershell
%pwrsh% Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine


REM creation du répertoire
IF NOT EXIST "C:\Program Files\SWMB" MKDIR "C:\Program Files\SWMB"
IF NOT EXIST "C:\Program Files\SWMB\Presets" MKDIR "C:\Program Files\SWMB\Presets"
IF NOT EXIST "C:\Program Files\SWMB\Win10-Initial-Setup-Script" MKDIR "C:\Program Files\SWMB\Win10-Initial-Setup-Script"

REM copie des scripts
COPY /Y Presets/*.preset "C:\Program Files\SWMB\Presets"
COPY /Y Win10-Initial-Setup-Script\Win10.* "C:\Program Files\SWMB\Win10-Initial-Setup-Script"
COPY /Y Win10-My-Swmb.psm1 "C:\Program Files\SWMB"
COPY /Y Win10-My-Swmb-VarDefault.psm1 "C:\Program Files\SWMB"
COPY /Y Win10-Resinfo-Swmb.psm1 "C:\Program Files\SWMB"

REM droits execution sur Win10.ps1
%pwrsh% "Unblock-File -Path ${env:ProgramFiles}\SWMB\Win10-Initial-Setup-Script\Win10.ps1"

REM execeution de Win10.ps1
ECHO SWMBPowershell>>%logfile% 2>&1
CD C:
CD "C:\Program Files\SWMB"
%pwrsh% -File "C:\Program Files\SWMB\Win10-Initial-Setup-Script\Win10.ps1" -include "Win10-Initial-Setup-Script\Win10.psm1" -include "Win10-My-Swmb.psm1" -include "Win10-Resinfo-Swmb.psm1" -preset "Preset/Cloud-Resinfo.preset" -preset "Preset/CortanaSearch-Resinfo.preset" -preset "Preset/My.preset" -preset "Preset/Telemetry-Resinfo.preset" -preset "Preset/UniversalApps-Resinfo.preset" -preset "Preset/UserExperience-Resinfo.preset" ">>%logfile% 2>&1

EXIT
