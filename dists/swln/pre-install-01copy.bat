ECHO.
ECHO Begin pre-install-01copy.bat

ECHO Adds the rights to run powershell scripts
%pwrsh% Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine

ECHO Deletes the %softname% directory
IF EXIST "%ProgramFiles%\%softname%" RMDIR /S /Q "%ProgramFiles%\%softname%"

ECHO Clean the ProgramData folder
ECHO Presets
SET "PRESETDIR=%ProgramData%\SWMB\Presets"
DEL /F /Q "%PRESETDIR%\*.bak"
FOR %%F IN (CurrentUser-Logon.preset LocalMachine-Boot.preset LocalMachine-PostInstall.preset) DO (
  FOR %%G IN (
    "%PRESETDIR%\%%F"
    "%PRESETDIR%\%%~nF-Host-%COMPUTERNAME%%%~xF"
  ) DO (
    IF EXIST "%%~G.old" DEL /F /Q "%%~G.old"
    IF EXIST "%%~G"     MOVE /Y "%%~G" "%%~G.old"
  )
)
ECHO Modules
SET "MODULEDIR=%ProgramData%\SWMB\Modules"
DEL /F /Q "%MODULEDIR%\*.bak"
FOR %%F IN (Custom-VarOverload.psm1 Local-Addon.psm1) DO (
  FOR %%G IN (
    "%MODULEDIR%\%%F"
    "%MODULEDIR%\%%~nF-Host-%COMPUTERNAME%%%~xF"
  ) DO (
    IF EXIST "%%~G.old" DEL /F /Q "%%~G.old"
    IF EXIST "%%~G"     MOVE /Y "%%~G" "%%~G.old"
  )
)
ECHO Specific Modules Autodel
DEL /F /Q "%MODULEDIR%\Custom-VarAutodel.psm1" "%MODULEDIR%\Custom-VarAutodel.psm1.*"

ECHO Creation of the install directory
MKDIR "%ProgramFiles%\%softname%"

ECHO Copy installer script
COPY /Y installer.ps1 "%ProgramFiles%\%softname%"

ECHO Execution right installer.ps1
%pwrsh% "Unblock-File -Path ${Env:ProgramFiles}\%softname%\installer.ps1"

ECHO End pre-install-01copy.bat
