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

## List of GPOs tested for compliance

 | ViewAutoplay                     | Disable Autoplay for non Volume - [STIG V-253386](https://system32.eventsentry.com/stig/viewer/V-253386) |
 | ViewAutorun                      | Disable Autorun on all kinds of drives - [STIG V-253388](https://system32.eventsentry.com/stig/viewer/V-253388) |
 | ViewBitlocker                    | Enable Bitlocker on all fixed drives (Tweak Enable is done interactively) |
 | ViewPasswordPolicy               | Disable password complexity and maximum age requirements |
 | ViewPasswordClearText            |  |
 | ViewAnonymousShareAccess         | Disable Anonymous access to Named Pipes and Shares - [STIG V-253456](https://system32.eventsentry.com/stig/viewer/V-253456) |
 | ViewAntivirusServices            | Windows must use an antivirus program - [STIG V-253264](https://system32.eventsentry.com/stig/viewer/V-253264) |
 | ViewRemoteDesktop                | Disable Remote Desktop |
 | ViewRemoteAssistance             | Disable (Sollicited) Remote Assistance - [STIG V-253382](https://system32.eventsentry.com/stig/viewer/V-253382) |
 | ViewAdobeEnhancedSecurity        | Adobe Enhanced Security in a Standalone Application or In Browser - [STIG V-213168](https://system32.eventsentry.com/stig/viewer/V-213168)  - [STIG V-213169](https://system32.eventsentry.com/stig/viewer/V-213169) |
 | ViewVolumeBadlyFormatted         | Local volumes must be formatted using NTFS - [STIG V-253265](https://system32.eventsentry.com/stig/viewer/V-253265) |
