ECHO.
ECHO Begin post-install-01reg.bat

ECHO Clean same file in the ProgramData folder
SET "PRESETDIR=%ProgramData%\SWMB\Presets"
SET "MODULEDIR=%ProgramData%\SWMB\Modules"
FOR %%F IN ("%PRESETDIR%\*" "%MODULEDIR%\*") DO (
  IF EXIST "%%F.old" (
    FC "%%F" "%%F.old" >NUL
    IF %ERRORLEVEL% EQU 0 DEL /F /Q "%%F.old"
  )
)

ECHO Change Add and Remove values in the register
 > tmp_install.reg ECHO Windows Registry Editor Version 5.00
>> tmp_install.reg ECHO.
>> tmp_install.reg ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%softregkey%]
>> tmp_install.reg ECHO "DisplayVersion"="%softversion%"
>> tmp_install.reg ECHO "Comments"="%softname% (%DATE:~-4%/%DATE:~-7,-5%/%DATE:~-10,-8%)"
>> tmp_install.reg ECHO "DisplayName"="%softname% (%softversion%-%softrevision% / %swmbversion%)"
>> tmp_install.reg ECHO "DisplayIcon"="C:\\Program Files\\%softname%\\logo-swmb.ico"
>> tmp_install.reg ECHO "InstallFolder"="C:\\Program Files\\%softname%"
>> tmp_install.reg ECHO "Publisher"="%softpublisher%"
>> tmp_install.reg ECHO "UninstallString"="C:\\Program Files\\%softname%\\uninstall.bat"
>> tmp_install.reg ECHO "NoModify"=dword:00000001
>> tmp_install.reg ECHO "NoRepair"=dword:00000001
>> tmp_install.reg ECHO.
regedit.exe /S "tmp_install.reg"

ECHO End post-install-01reg.bat
