
REM
REM   LocalMachine-SWCE
REM

REM Name
SET softname=LocalMachine-SWCE

SET logdir=__LOGDIR__
IF "%logdir:~0,2%"=="__" IF "%logdir:~-2%"=="__" (
  SET logdir=%SystemDrive%\Temp
)
IF NOT EXIST "%logdir%" (
  MKDIR "%logdir%"
)
CALL :INSTALL 1> "%logdir%\%softname%.log" 2>&1
EXIT /B

:INSTALL

@ECHO [BEGIN] %date%-%time%


@ECHO [INFO] Search PowerShell
SET pwrsh=%WINDIR%\System32\WindowsPowerShell\V1.0\powershell.exe
IF EXIST "%WINDIR%\Sysnative\WindowsPowerShell\V1.0\powershell.exe" SET pwrsh=%WINDIR%\Sysnative\WindowsPowerShell\V1.0\powershell.exe

@ECHO [INFO] Add rights
%pwrsh% Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine

@ECHO [INFO] Unblock PowerShell Script
%pwrsh% "Unblock-File -Path .\*.ps1"
SET RETURNCODE=0


@ECHO [INFO] Execute post script
IF EXIST ".\push-on-gitlab.ps1" %pwrsh% -File ".\push-on-gitlab.ps1" 1> "%logdir%\%softname%-PS1.log" 2>&1
IF %RETURNCODE% EQU 0 SET RETURNCODE=%ERRORLEVEL%


:END
@ECHO [END] %date%-%time%
EXIT %RETURNCODE%
