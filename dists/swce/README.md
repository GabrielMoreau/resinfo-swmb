# Secure Windows Compliance Enforcement

SWCE stands for Secure Windows Compliance Enforcement.
It is a tool from the SWMB galaxy.

SWCE is a tool that allows you to check the compliance of a workstation with a number of rules.
The rules are not enforced.
An assessment is carried out to identify what needs to be remedied in order to achieve compliance.

There is therefore no risk in running the tool on a workstation.
It is a PowerShell script (`LocalMachine-SWCE.ps1`).
The lines of code are extracted from SWMB modules.
These are only read-only functions on the system.

## Download

* [SWCE](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/SWCE-Latest.zip) - latest version.


## Usage

Unzip the SWCE archive, for example into a temporary folder (this is not best practice, however).
Open a PowerShell console in administrator mode.
Then, if necessary, unlock the script to allow it to run.

```ps1
cd C:\Temp
powershell.exe Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine
powershell.exe "Unblock-File -Path .\LocalMachine-SWCE.ps1"
& .\LocalMachine-SWCE.ps1
```

And that's it!

## List of GPOs tested for compliance

Run the `make` command in the current folder and read the `tmp/LocalMachine-SWCE.ps1` file in the temporary folder to get a more accurate list.

| Rule Name       | Description |
|-----------------|-------------|
| `ViewInsecureGuestLogons`        | Disable SMB client to use insecure guest logons to an SMB server - [W11 STIG V-253360](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253360) - https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.LanmanWorkstation::Pol_EnableInsecureGuestLogons |
| `ViewPowershell2`                | PowerShell 2.0 feature must be disabled - [W11 STIG V-253285](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253285) |
| `ViewSMB1Protocol`               | Disable Server Message Block (SMB) v1 protocol [W11 STIG V-253287](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253287) |
| `ViewDEP`                        | Data Execution Prevention (DEP) must be configured for at least OptOut - [W11 STIG V-253283](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253283) |
| `ViewAnonymousShareAccess`       | Disable Anonymous access to Named Pipes and Shares - [W11 STIG V-253456](https://system32.eventsentry.com/stig/search?query=RestrictNullSessAccessValue) |
| `ViewRemoteAssistance`           | Disable (Solicited) Remote Assistance - [W11 STIG V-253382](https://system32.eventsentry.com/stig/viewer/V-253382) |
| `ViewRemoteDesktop`              | Disable Remote Desktop |
| `ViewAutoplay`                   | Disable Autoplay for non Volume - [W11 STIG V-253386](https://system32.eventsentry.com/stig/search?query=NoAutoplayfornonVolume) |
| `ViewAutorun`                    | Disable Autorun on all kinds of drives - [W11 STIG V-253388](https://system32.eventsentry.com/stig/search?query=NoDriveTypeAutoRun) |
| `ViewCameraFromLockScreen`       | Camera access from the lock screen must be disabled - [W11 STIG V-253350](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253350) |
| `ViewTelnetClient`               | Uninstall Telnet Client - [W11 STIG V-253278](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253278) |
| `ViewTFTPClient`                 | Uninstall TFTP Client - [W11 STIG V-253279](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253279) |
| `ViewAdobeEnhancedSecurity`      | Adobe Enhanced Security in a Standalone Application or In Browser - [W11 STIG V-213168](https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213168) - [W11 STIG V-213169](https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213169) |
| `ViewPasswordPolicy`             | Disable password complexity and maximum age requirements |
| `ViewPasswordClearText`          |  |
| `ViewBitlocker`                  | Enable Bitlocker on all fixed drives (Tweak Enable is done interactively) - [W11 STIG V-253259](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253259) |
| `ViewBitlockerTPM`               | BitLocker PIN for pre-boot authentication - [W11 STIG V-253260](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253260) - BitLocker PIN with a minimum length for pre-boot authentication - [W11 STIG V-253261](https://www.stigviewer.com/stigs/microsoft-windows-11-security-technical-implementation-guide/2025-05-15/finding/V-253261) |
| `ViewAntivirusServices`          | Windows must use an antivirus program - [W11 STIG V-253264](https://system32.eventsentry.com/stig/viewer/V-253264) |
| `ViewVolumeBadlyFormatted`       | Local volumes must be formatted using NTFS - [W11 STIG V-253265](https://system32.eventsentry.com/stig/viewer/V-253265) |
