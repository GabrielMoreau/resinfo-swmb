# Secure Windows Compliance Enforcement

SWCE stands for Secure Windows Compliance Enforcement.
It is a tool from the SWMB galaxy.

SWCE is a tool that allows you to check the compliance of a workstation with a number of rules.
The rules are not enforced.
An assessment is carried out to identify what needs to be remedied in order to achieve compliance.

There is therefore no risk in running the tool on a workstation.
It is a PowerShell script (`swce.ps1`).
The lines of code are extracted from SWMB modules.
These are only read-only functions on the system.

Download: [SWCE](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/SWCE-Latest.zip) - lastest version.

## List of GPOs tested for compliance

Run the “make” command in the current folder and read the “tmp/swce.ps1” file in the temporary folder to get a more accurate list.

| Rule Name       | Description |
|-----------------|-------------|
| `ViewAutoplay`                   | Disable Autoplay for non Volume - [STIG V-253386](https://system32.eventsentry.com/stig/search?query=NoAutoplayfornonVolume) |
| `ViewAutorun`                    | Disable Autorun on all kinds of drives - [STIG V-253388](https://system32.eventsentry.com/stig/search?query=NoDriveTypeAutoRun) |
| `ViewAnonymousShareAccess`       | Disable Anonymous access to Named Pipes and Shares - [STIG V-253456](https://system32.eventsentry.com/stig/search?query=RestrictNullSessAccessValue) |
| `ViewRemoteAssistance`           | Disable (Sollicited) Remote Assistance - [STIG V-253382](https://system32.eventsentry.com/stig/viewer/V-253382) |
| `ViewRemoteDesktop`              | Disable Remote Desktop |
| `ViewAdobeEnhancedSecurity`      | Adobe Enhanced Security in a Standalone Application or In Browser - [STIG V-213168](https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213168) - [STIG V-213169](https://www.stigviewer.com/stigs/adobe_acrobat_reader_dc_continuous_track/2021-06-22/finding/V-213169) |
| `ViewPasswordPolicy`             | Disable password complexity and maximum age requirements |
| `ViewPasswordClearText`          |  |
| `ViewBitlocker`                  | Enable Bitlocker on all fixed drives (Tweak Enable is done interactively) |
| `ViewAntivirusServices`          | Windows must use an antivirus program - [STIG V-253264](https://system32.eventsentry.com/stig/viewer/V-253264) |
| `ViewVolumeBadlyFormatted`       | Local volumes must be formatted using NTFS - [STIG V-253265](https://system32.eventsentry.com/stig/viewer/V-253265) |
| `ViewBitlockerTPM`               | Windows 10 must use a BitLocker PIN for pre-boot authentication - W10 [STIG V-220703](https://www.stigviewer.com/stigs/microsoft_windows_10/2025-02-25/finding/V-220703) |
