/*

# SWMB NSIS Installer
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2021 - Gabriel Moreau (CNRS / LEGI)

*/

Unicode True

!include nsDialogs.nsh
!include x64.nsh
!include LogicLib.nsh
;!include Integration.nsh
!include FileFunc.nsh

!insertmacro GetParameters
!insertmacro GetOptions

!define NAME "SWMB"
!define VERSION "3.19.0.0"
!define DESCRIPTION "Secure Windows Mode Batch"
!define PUBLISHER "CNRS France, RESINFO / GT SWMB"
!define PUBLISHERLIGHT "CNRS France"
!define /date YEAR "%Y"
!define REGPATH_UNINSTSUBKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
Name "${NAME}"
OutFile "${NAME}-Setup-${VERSION}.exe"
RequestExecutionLevel Admin ; Request admin rights on WinVista+ (when UAC is turned on)
InstallDir "$ProgramFiles64\${NAME}"
InstallDirRegKey HKLM "${REGPATH_UNINSTSUBKEY}" "UninstallString"
;AutoCloseWindow true ; Setup close automatically when you finish use
Icon "logo-swmb.ico" ; Select your Icon file

; Version Information
VIAddVersionKey "ProductName" "${NAME}"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "LegalTrademarks" "${NAME} is a name create by ${PUBLISHERLIGHT}"
VIAddVersionKey "LegalCopyright" "© 2020-${YEAR} ${PUBLISHERLIGHT}"
VIAddVersionKey "FileDescription" "${DESCRIPTION}"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIProductVersion "${VERSION}"

Page Directory
Page custom ActivatedPresetWindow ActivatedPresetCall
Page InstFiles

Uninstpage UninstConfirm
Uninstpage InstFiles

Var ActivatedPreset_ID
Var ActivatedPreset_Val

!macro EnsureAdminRights
  UserInfo::GetAccountType
  Pop $0
  ${If} $0 != "admin" ; Require admin rights on WinNT4+
    MessageBox MB_IconStop "Administrator rights required!"
    SetErrorLevel 740 ; ERROR_ELEVATION_REQUIRED
    Quit
  ${EndIf}
!macroend

Function TrimQuotes
  Exch $R0
  Push $R1
  StrCpy $R1 $R0 1
  StrCmp $R1 `"` 0 +2
  StrCpy $R0 $R0 `` 1
  StrCpy $R1 $R0 1 -1
  StrCmp $R1 `"` 0 +2
  StrCpy $R0 $R0 -1
  Pop $R1
  Exch $R0
FunctionEnd

!macro _TrimQuotes Input Output
  Push `${Input}`
  Call TrimQuotes
  Pop ${Output}
!macroend
!define TrimQuotes `!insertmacro _TrimQuotes`

Function ActivatedPresetWindow
  nsDialogs::Create 1018
  Pop $0

  ${NSD_CreateLabel} 0 40u 75% 40u "SWMB will install three Schedule tasks :$\n * one task at boot,$\n * one task shortly after installation,$\n * one task when the current user logon.$\nThese tasks will apply a minimally invasive tweak preset by default.$\nPlease note that these default presets have been developed as part of a corporate$\nstrategy with centralized computer management and authentication."
  Pop $0

  ${NSD_CreateCheckbox} 0 -50 100% 8u "Deploy and active default preset (tweaks) for all tasks"
  Pop $ActivatedPreset_ID
  ${NSD_SetState} $ActivatedPreset_ID ${BST_CHECKED}

  nsDialogs::Show
FunctionEnd

Function ActivatedPresetCall
  ${NSD_GetState} $ActivatedPreset_ID $0
  ${If} $0 <> ${BST_UNCHECKED}
    StrCpy $ActivatedPreset_Val "ENABLE"
  ${Else}
    StrCpy $ActivatedPreset_Val "DISABLE"
  ${EndIf}
FunctionEnd

Function .onInit
  SetShellVarContext All
  !insertmacro EnsureAdminRights

  StrCpy $INSTDIR "$ProgramFiles64\${NAME}"

  ${If} ${RunningX64}
    ${EnableX64FSRedirection}
  ${Else}
    MessageBox MB_OK "Sorry this application runs only on x64 machines"
    Abort
  ${EndIf}

  ReadRegStr $R0 HKLM "${REGPATH_UNINSTSUBKEY}" "UninstallString"
  ; $R0 has the double quote around
  StrCmp $R0 "" done

  ${TrimQuotes} $R0 $R1
  ${If} ${FileExists} "$R1"
    ${If} ${Silent}
      ClearErrors
      nsExec::ExecToStack '$R0 /S  '
loop:
      Sleep 1000 ; one second
      ReadRegStr $R1 HKLM "${REGPATH_UNINSTSUBKEY}" "UninstallString"
      StrCmp $R1 "" done
      Goto loop
    ${Else}
      MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
        "${NAME} is already installed. $\n$\nClick `OK` to remove the \
        previous version or `Cancel` to cancel this upgrade." \
        IDOK uninst
      Abort
    ${EndIf}
  ${EndIf}
  Goto done

uninst:
  ClearErrors
  Exec $R0

done:
  ${If} ${Silent}
    StrCpy $ActivatedPreset_Val "ENABLE"
    ${GetParameters} $0
    ClearErrors
    ${GetOptions} '$0' '/ACTIVATED_PRESET=' $1
    ${If} $1 == "0"
      StrCpy $ActivatedPreset_Val "DISABLE"
    ${EndIf}
  ${EndIf}
FunctionEnd

Function un.onInit
  SetShellVarContext All
  !insertmacro EnsureAdminRights
FunctionEnd


Section "Program files (Required)"
  SectionIn Ro

  SetOutPath $INSTDIR
  WriteUninstaller "$INSTDIR\Uninst.exe"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayName" "${NAME} release ${VERSION}"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "Comments" "${NAME} (${VERSION})"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "URLInfoAbout" "https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "DisplayIcon" "$INSTDIR\logo-swmb.ico"
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "UninstallString" '"$INSTDIR\Uninst.exe"'
  WriteRegStr HKLM "${REGPATH_UNINSTSUBKEY}" "InstallFolder" "$INSTDIR"
  WriteRegDWORD HKLM "${REGPATH_UNINSTSUBKEY}" "NoModify" 1
  WriteRegDWORD HKLM "${REGPATH_UNINSTSUBKEY}" "NoRepair" 1
  ${If} $ActivatedPreset_Val == "ENABLE"
    WriteRegDWORD HKLM "${REGPATH_UNINSTSUBKEY}" "ActivatedPreset" 1
  ${Else}
    WriteRegDWORD HKLM "${REGPATH_UNINSTSUBKEY}" "ActivatedPreset" 0
  ${EndIf}
  File "swmb.ps1"
  File "wisemoui.ps1"
  File "logo-swmb.ico"
  File "CONTRIBUTING.md"
  File "FAQ.md"
  File "LICENSE.md"
  File "NEWS.md"
  File "README.md"
  File "REFERENCES.md"

  SetOutPath $INSTDIR\Setup
  File "Setup\post-install.ps1"
  File "Setup\pre-remove.ps1"

  SetOutPath $INSTDIR\Modules
  File "tmp\SWMB.psd1"
  File "Modules\SWMB.psm1"
  File "Modules\WiSeMoUI.psm1"

  SetOutPath $INSTDIR\Modules\SWMB
  File "tmp\Version.psd1"
  File "Modules\SWMB\CurrentUser-Application.psm1"
  File "Modules\SWMB\CurrentUser-ExplorerUI.psm1"
  File "Modules\SWMB\CurrentUser-Privacy.psm1"
  File "Modules\SWMB\CurrentUser-Service.psm1"
  File "Modules\SWMB\CurrentUser-UI.psm1"
  File "Modules\SWMB\CurrentUser-Unpinning.psm1"
  File "Modules\SWMB\CurrentUser-Uninstall.psm1"
  File "Modules\SWMB\CurrentUser-UWPPrivacy.psm1"
  File "Modules\SWMB\Custom.psm1"
  File "Modules\SWMB\Custom-VarDefault.psm1"
  File "Modules\SWMB\Experimental.psm1"
  File "Modules\SWMB\LocalMachine-Application.psm1"
  File "Modules\SWMB\LocalMachine-ExplorerUI.psm1"
  File "Modules\SWMB\LocalMachine-Network.psm1"
  File "Modules\SWMB\LocalMachine-Privacy.psm1"
  File "Modules\SWMB\LocalMachine-Security.psm1"
  File "Modules\SWMB\LocalMachine-Server.psm1"
  File "Modules\SWMB\LocalMachine-Service.psm1"
  File "Modules\SWMB\LocalMachine-UI.psm1"
  File "Modules\SWMB\LocalMachine-Uninstall.psm1"
  File "Modules\SWMB\LocalMachine-UWPPrivacy.psm1"
  File "Modules\SWMB\TemporaryBypass.psm1"

  SetOutPath $INSTDIR\dists
  File "dists\README.md"

  SetOutPath $INSTDIR\dists\uninstall-kaspersky
  File "dists\uninstall-kaspersky\get-password-cleartext.ps1"
  File "dists\uninstall-kaspersky\README.md"
  File "dists\uninstall-kaspersky\set-password-encrypted.ps1"
  File "dists\uninstall-kaspersky\uninstall-kaspersky-integrated.ps1"

  SetOutPath $INSTDIR\Presets
  File "Presets\CurrentUser-All.preset"
  File "Presets\CurrentUser-Logon-Recommanded.preset"
  File "Presets\CurrentUser-Logon-Test.preset"
  File "Presets\LocalMachine-All.preset"
  File "Presets\LocalMachine-Boot-Recommanded.preset"
  File "Presets\LocalMachine-Boot-Test.preset"
  File "Presets\LocalMachine-Cloud.preset"
  File "Presets\LocalMachine-CortanaSearch.preset"
  File "Presets\LocalMachine-Default.preset"
  File "Presets\LocalMachine-Service.preset"
  File "Presets\LocalMachine-Telemetry.preset"
  File "Presets\LocalMachine-UniversalApps.preset"
  File "Presets\LocalMachine-UserExperience.preset"
  File "Presets\Post-Install.preset"

  SetOutPath $INSTDIR\Tasks
  File "Tasks\CurrentUser-Logon.ps1"
  File "Tasks\LocalMachine-Boot.ps1"
  File "Tasks\LocalMachine-PostInstall.ps1"
  File "Tasks\LocalMachine-Crypt-With-Bitlocker.ps1"
  File "Tasks\View-All-Software.ps1"
SectionEnd

Section "Task Scheduler"
  ; ProgramData and sets all user permissions
  CreateDirectory "$APPDATA\${NAME}\Logs"
  CreateDirectory "$APPDATA\${NAME}\Caches"
  CreateDirectory "$APPDATA\${NAME}\Modules"
  CreateDirectory "$APPDATA\${NAME}\Presets"

  ; Copy Simple Sample Test
  SetOutPath $APPDATA\${NAME}\Presets
  File "Presets\CurrentUser-Logon-Test.preset"
  File "Presets\LocalMachine-Boot-Test.preset"

  ; ACL on Logs and Register Task
  nsExec::ExecToStack 'powershell -InputFormat None -ExecutionPolicy Bypass -File "$INSTDIR\Setup\post-install.ps1"  '
  Pop $0 ; return value/error/timeout
  Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
  DetailPrint '"$INSTDIR\Setup\post-install.ps1"'
  DetailPrint "  Printed: $1"
  DetailPrint "  Return value: $0"
  DetailPrint ""
SectionEnd

Section "Start Menu shortcut"
  ;CreateDirectory "$SMPrograms\${NAME}"
  CreateShortcut /NoWorkingDir "$SMPrograms\${NAME} Secure Windows.lnk" powershell.exe '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$INSTDIR\wisemoui.ps1"' "$INSTDIR\logo-swmb.ico"
SectionEnd


Section -Uninstall
  nsExec::ExecToStack 'powershell -InputFormat None -ExecutionPolicy Bypass -File "$INSTDIR\Setup\pre-remove.ps1"  '
  Pop $0 ; return value/error/timeout
  Pop $1 ; printed text, up to ${NSIS_MAX_STRLEN}
  DetailPrint '"$INSTDIR\Setup\pre-remove.ps1"'
  DetailPrint "  Printed: $1"
  DetailPrint "  Return value: $0"
  DetailPrint ""

  ;${UnpinShortcut} "$SMPrograms\${NAME}\${NAME}.lnk"
  Delete "$SMPrograms\${NAME} Secure Windows.lnk"
  ;Delete "$SMPrograms\${NAME}\${NAME}.lnk"
  ;Delete "$SMPrograms\${NAME}\SWMB-Crypt-With-Bitlocker.lnk"
  ;RMDir "$SMPrograms\${NAME}"

  RMDir "$APPDATA\${NAME}\Logs"
  RMDir "$APPDATA\${NAME}\Caches"
  RMDir "$APPDATA\${NAME}\Modules"
  Delete "$APPDATA\${NAME}\Presets\CurrentUser-Logon-Test.preset"
  Delete "$APPDATA\${NAME}\Presets\LocalMachine-Boot-Test.preset"
  RMDir "$APPDATA\${NAME}\Presets"
  RMDir "$APPDATA\${NAME}"

  Delete "$INSTDIR\Uninst.exe"
  Delete "$INSTDIR\swmb.ps1"
  Delete "$INSTDIR\wisemoui.ps1"
  Delete "$INSTDIR\logo-swmb.ico"
  Delete "$INSTDIR\CONTRIBUTING.md"
  Delete "$INSTDIR\FAQ.md"
  Delete "$INSTDIR\LICENSE.md"
  Delete "$INSTDIR\NEWS.md"
  Delete "$INSTDIR\README.md"
  Delete "$INSTDIR\REFERENCES.md"
  RMDir /r "$INSTDIR\dists"
  RMDir /r "$INSTDIR\Modules"
  RMDir /r "$INSTDIR\Presets"
  RMDir /r "$INSTDIR\Tasks"
  RMDir /r "$INSTDIR\Setup"
  RMDir "$INSTDIR"
  DeleteRegKey HKLM "${REGPATH_UNINSTSUBKEY}"
SectionEnd
