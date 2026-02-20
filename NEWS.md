# NEWS

## Version 3.20 (in progress)

Move the `git subtree` documentation from the [README](README.md) file to the [CONTRIBUTING](CONTRIBUTING.md) document.

Begin the project Secure Windows Compliance Enforcement (SWCE).
Some (many) Tweak Views have been adapted to the new way of displaying results and remediation proposals.

* Secure - Security, protection
* Windows - Target all Windows PCs
* Compliance - Configurations/settings/GPO
* Enforcement - Strict check and verification

The `wisemoui.ps1` graphical interface has been updated.
Here's a quick summary:

* The operating system version is now in fours color (Green, Blue, Orange, Red). Yellow has been replace by Bue.
* LThe size of the SWMB logo has been reduced.
* A new `Compliance Enforcement` frame has appeared with the `LocalMachine` check button.

In Bitlocker tweak GPO, now force the PIN pre-boot authentication to the minimum of 6.

New presets/rules:

* 2026/02/20 - `UninstallTFTPClient`/`InstallTFTPClient`/`ViewTFTPClient` -> Uninstall TFTP Client
* 2026/02/19 - `ViewBitlockerTPM` -> View Bitlocker TPM and PIN pre-boot authentication
* 2026/02/19 - `ViewTelnetClient` -> View Telnet Client
* 2026/02/19 - `ViewPowershell2` -> View Powershell v2 Status
* 2026/02/16 - `DisableCameraFromLockScreen`/`EnableCameraFromLockScreen`/`ViewCameraFromLockScreen` -> Disable Camera access from the lock screen
* 2026/02/11 - `ViewRemoteDesktop` -> View Remote Desktop
* 2026/02/11 - `ViewAntivirusServices` -> View active antivirus program
* 2026/01/21 - `ViewPasswordPolicy` -> View Password Policy
* 2026/01/20 - `ViewBitlocker` -> View Bitlocker status on all fixed drives
* 2026/01/20 - `DisableAnonymousShareAccess`/`EnableAnonymousShareAccess`/`ViewAnonymousShareAccess` -> Disable Anonymous access to Named Pipes and Shares (RestrictNullSessAccessValue)
* 2026/01/16 - `DisableAutoplay`/`EnableAutoplay`/`ViewAutoplay` -> Disable Autoplay for non Volume (NoAutoplayfornonVolume)
* 2026/01/16 - `ViewAutorun` -> View AutoRun status (NoDriveTypeAutoRun)
* 2026/01/15 - `DisableAutorun_CU`/`EnableAutorun_CU`/`ViewAutorun_CU` -> Disable AutoRun Key for all drive type (same exist by default for HKLM)
* 2026/01/15 - `ViewAutoplay_CU` -> Add view Autoplay tweak

## Version 3.19 (2026/01/09)

Updated HTML documentation theme, switching to mkdocs material theme.

The `wisemoui.ps1` graphical interface has been updated.
Here's a quick summary:

* A new `Help` button  opens the online documentation.
* Clicking on the logo opens the SWMB Git URL in a browser.
* Add a task manager button (`T`).
* A better color (green, yellow, orange, red) depending on the version number of Windows and UBR.
  The less up-to-date the computer is, the redder the color!

PowerShell scripts and modules are now checked before Git commit using the `analyze-ps` script (see `make check`).

Tilde (HOME) management in the script that compares your files with the SWMB files in your version of SWLN.

Add the link to [FlyOOBE](https://github.com/builtbybel/FlyOOBE) to the [REFERENCES](REFERENCES.md) file.

New presets/rules:

* 2025/12/05 - `EnableAdobeEnhancedSecurity`/`DisableAdobeEnhancedSecurity`/`ViewAdobeEnhancedSecurity` -> Adobe Enhanced Security in a Standalone Application or In Browser
* 2025/12/01 - `DisableRecall`/`EnableRecall`/`ViewRecall` -> Recall is a feature that allows you to quickly access your documents, applications, and personal information through indexing
* 2025/11/14 - `ViewDellBuiltInApps` -> View all Dell Appx
* 2025/11/14 - `UninstallNordVPN`/`ViewNordVPN` -> Uninstall NordVPN - Lithuanian VPN service
* 2025/11/13 - `UninstallCCleaner`/`ViewCCleaner` -> Uninstall Piriform CCleaner
* 2025/11/13 - `UninstallTeamViewer`/`ViewTeamViewer` -> Uninstall TeamViewer
* 2025/11/07 - `DisableAdobeAutoUpdate`/`EnableAdobeAutoUpdate`/`ViewAdobeAutoUpdate` -> Disables automatic updates service from Adobe (enabled by default after a new installation)
* 2025/11/07 - `DisableAdobeCollabSync`/`EnableAdobeCollabSync`/`ViewAdobeCollabSync` -> Deletes the binary file that enables synchronization with Adobe cloud collaboration.
* 2025/05/23 - `DisableRemovableStorageExe`/`EnableRemovableStorageExe`/`ViewRemovableStorageExe` -> Disable program execution on removable media (USB)
* 2025/05/14 - `UninstallSkype`/`ViewSkype` -> Uninstall Skype
* 2025/04/29 - `UninstallPDFXChange`/`ViewPDFXChange` -> Uninstall PDF-XChange software (also PDF-Viewer)
* 2025/04/15 - `ViewHibernation` -> View Hibernation status, inversion of tweak Enable and Disable in the preset file
* 2025/04/15 - `RemoveAppxMsOfficeHub`/`AddAppxMsOfficeHub`/`ViewAppxMsOfficeHub` -> Remove Appx Microsoft OfficeHub (Microsoft 365 Copilot) (already part of the `UninstallMsftBloat` tweak)


## Version 3.18 (2025/02/25)

The `wisemoui.ps1` graphical interface has been updated.
Here's a quick summary:

* The Bitlocker status is now in color (Green, Orange, Red).
* There's now an `C` (Check), `P` (Print), `L` (Log) and `E` (Edit) and `Run` buttons next to each scheduled task to check the preset file, print current tweaks list, view the last log file (last run), edit the task's preset file and run now the task.
* If the [WinMerge](https://winmerge.org/) software is installed, a `M` button appear near all the task button to help diff, merge and update preset files.
* Many management consoles (TPM, indows Update, System Property, Add/Remove Software, Secpol, GPedit, Network interface and Global Management) have also been added to the interface.
* If the [BleachBit](https://www.bleachbit.org/) software is installed, a `B` button appear near the Software button.
* If the [CCleaner](https://www.ccleaner.com/) software is installed, a `C` button appear near the Software button.
* If the [WinDirStat](https://windirstat.net/) software is installed, a `S` button appear near the Software button.
* If the [Procmon](https://en.wikipedia.org/wiki/Sysinternals) software is installed, a `P` button appear near the GPO button.

Add SHA-1 hash on download package web page.

Add the link to [Win11Debloat](https://github.com/Raphire/Win11Debloat) and to the [JRES 2024 conference in Rennes](https://hal.science/hal-04893850v1) to the [REFERENCES](REFERENCES.md) file.

New presets/rules:

* 2025/02/17 - `ViewInsecureGuestLogons` -> Disable SMB client to use insecure guest logons to an SMB server
* 2025/02/17 - `EnableSMBClientSigning`/`DisableSMBClientSigning`/`ViewSMBClientSigning` -> Require SMB client to sign message
* 2025/02/17 - `EnableSMBServerSigning`/`DisableSMBServerSigning`/`ViewSMBServerSigning` -> Require SMB server to sign message
* 2025/02/14 - `DisableMSOfficeFeedback_CU`/`EnableMSOfficeFeedback_CU`/`ViewMSOfficeFeedback_CU` -> Disable Feedback and Telemetry in MS Office
* 2025/02/13 - `ViewWebSearch_CU` -> Add view tweak
* 2025/02/13 - `DisableMSOfficeConnectedExperiences_CU`/`EnableMSOfficeConnectedExperiences_CU`/`ViewMSOfficeConnectedExperiences_CU` -> Disable Connected Experiences in Microsoft Office
* 2025/01/29 - `UninstallRealVNC4` -> Uninstall old RealVNC version 4
* 2025/01/29 - `UninstallRealVNCServer`/`ViewRealVNCServer` -> Uninstall RealVNC version 4 server software
* 2025/01/29 - `UninstallRealVNCViewer`/`ViewRealVNCViewer` -> Uninstall RealVNC version 4 server client (viewer)
* 2025/01/29 - `UninstallUltraVNC`/`ViewUltraVNC` -> Uninstall UltraVNC (viewer and server)
* 2024/11/28 - `DisableCloudOptimizedContent`/`EnableCloudOptimizedContent`/`ViewCloudOptimizedContent` -> Turn off cloud optimized content in all Windows experiences
* 2024/11/28 - `DisableWindowsTips`/`EnableWindowsTips`/`ViewWindowsTips` -> Prevents Windows tips from being shown to users


## Version 3.17 (2024/10/01)

The [SWLN](./dists/swln/) template is more generic (LEGI now uses the same files without any changes)
and it now supports the file with the `-Host-HOSTNAME` extension
in order to push a different file (e.g. specific tweaks) to a particular computer.
Each site can add its own pre and post-installation scripts.

Tweaks have a better message at launch, clearly indicating the type of tweak they are
(Enable, Disable, Set, Unistall...).

Correction of a gross error when launching a checkpoint (calling a function with the wrong name!).
The hash function has also been updated to take into account the UBR (Revision) version of the OS
(a number that changes regularly following the big monthly update).

The `wisemoui.ps1` graphical interface has been updated.
OS version is now shown in color.

The Target Release tweak must take into account the Windows version.
Windows 10 and Windows 11 do not have synchronized version names.
In the `Custom-VarOverload.psm1` variable file, there's now a `windows10` (or `windows11`) sub-key to define the Target Release associated with the correct system.
This naming process will be generalized in the future if there is a need to dissociate parameters according to OS.
However, it should be used as little as possible, to keep workstation administration as homogeneous as possible.

```ps1
# Target Release
$Global:SWMB_Custom.Windows10.ProductVersion           = 'Windows 10'
$Global:SWMB_Custom.Windows10.TargetReleaseVersionInfo = '22H2'
$Global:SWMB_Custom.Windows11.ProductVersion           = 'Windows 11'
$Global:SWMB_Custom.Windows11.TargetReleaseVersionInfo = '23H2'
```

New presets/rules:

* 2024/09/26 - `DisableWindowsCopilot_CU`/`EnableWindowsCopilot_CU`/`ViewWindowsCopilot_CU` -> Disable Windows Copilot for current user (Windows11)
* 2024/07/02 - `UninstallVMwarePlayer`/`ViewVMwarePlayer` -> Uninstall VMware Player
* 2024/06/05 - `DisableEdgeSendBrowsingHistory`/`EnableEdgeSendBrowsingHistory`/`ViewEdgeSendBrowsingHistory` -> Disable sending browsing history to Microsoft
* 2024/05/28 - `DisableBackupMessages`/`EnableBackupMessages`/`ViewBackupMessages` -> Disable backup and restore of cellular text messages to Microsoft's cloud services
* 2024/05/28 - `DisableBluetoothAdvertising`/`EnableBluetoothAdvertising`/`ViewBluetoothAdvertising` -> Disable Advertisements via Bluetooth
* 2024/05/27 - `DisableTypingRecognition_CU`/`EnableTypingRecognition_CU`/`ViewTypingRecognition_CU` -> Don't send inking and typing data to Microsoft to improve the language recognition
* 2024/05/16 - `UninstallDellSoftware` -> Uninstall Dell MSI or Setup.exe software
* 2024/05/16 - `UninstallDellBuiltInApps` -> Uninstall some Dell Appx - use the global variable `$Global:SWMB_Custom.DellAppx`
* 2024/05/09 - `EnableOffice2016AutoUpdate`/`DisableOffice2016AutoUpdate`/`ViewOffice2016AutoUpdate` -> Enable auto update for MS Office 2016 Click-To-Run installations
* 2024/05/09 - `EnableOffice2013AutoUpdate`/`DisableOffice2013AutoUpdate`/`ViewOffice2013AutoUpdate` -> Enable auto update for MS Office 2013 Click-To-Run installations
* 2024/04/10 - `DisableAutoLogon`/`EnableAutoLogon`/`ViewAutoLogon` -> Disable or Enable AutoLogon (`$Global:SWMB_Custom` key `AutoLogon_UserName`)
* 2024/04/09 - `DisableUpgradesOnUnsupportedHard`/`EnableUpgradesOnUnsupportedHard`/`ViewUpgradesOnUnsupportedHard` -> Force a registry key so that hardware not supported for accepting Windows 11 upgrades can continue to benefit from updates (use at your own risk).


## Version 3.16 (2024/04/09)

This version offers specific initial support for Windows11.
Indeed, initial tweaks have been written and made default to limit searches and data leaks for Windows 11.
Tweaks can be deployed on Windows 11 and Windows 10 without disruption to the latter.

Continuous integration package creation now increments the version counter for each commit.
SWMB installation no longer generates a unique GUID by default (better GDPR compliant),
just put the EnableSWMBUniqueId tweak in a preset file, for example `LocalMachine-Boot.preset` and/or `LocalMachine-PostInstall.preset`,
so that each computer has a unique `HostId` on your park.

The `wisemoui.ps1` graphical interface has been updated.
The unique HostId is displayed if it exists.
Add a link to the project web page when the version is too old.

The SWLN template is more generic and its main files do not need to be modified.
SWLN defaults to the latest available version of SWMB.

Add link to the [Harden Community](https://hardenad.net/) in [REFERENCES](REFERENCES.md).

Most of the tweaks marked with the Windows11 tag are also available on Windows10,
but were not deactivated (or activated) at the time, because they were unknown!

Remove modules (move code to other modules):

* `Modules/SWMB/Resinfo.psm1` - dispatch tweaks in other module
* `Modules/SWMB/BSI.psm1` - dispatch tweaks in other module
* `Modules/SWMB/Contrib.psm1` - dispatch tweaks in other module

Remove presets (push preset in one file):

* `CurrentUser-Resinfo.preset` - only one preset!
* `CurrentUser-UserExperience.preset` - only one preset!

Update default `LocalMachine-All` preset:

* Activate `DisableCortanaAboveLock`, `DisableDisplayWebResults`, `DisableWebSearch`,
  `DisablePrivacyExperience`, `DisableStepsRecorder`, `DisableSendAdditionalData`,
  `DisableSharedInformationSearch`, `EnableSearchOnTaskbar`, `DisableUWPNotifications`,
  `DisableUWPAccountInfo`, `DisableUWPDiagInfo`, `DisableUWPAccessLocation`, `DisableWindowsCopilot`

Update default `CurrentUser-All` preset:

* Activate `DisableWebSearch_CU`, `DisableFeedback_CU`

Two tweaks (`OneDriveSync` and `WindowsStoreAccess`) have been renamed in order to have uniqueness in tweak names,
whether they start with `Enable/Disable`, `Install/Uninstall`, `Show/Hide`...
The `check-project` script has been updated to check that this tweak uniqueness property is respected.

New presets/rules:

* 2024/03/05 - `UninstallAnyDesk`/`ViewAnyDesk` -> Uninstall AnyDesk remote desktop application
* 2024/02/29 - `DisableWindowsStoreAccess` is the new name for old `DisableWindowsStore`. It's the same for `EnableWindowsStoreAccess`
* 2024/02/29 - `DisableOneDriveSync` is the new name for old `DisableOneDrive`. It's the same for `EnableOneDriveSync`
* 2024/02/23 - `EnableLSOon10Gbps`/`DisableLSOon10Gbps`/`ViewLSOon10Gbps` -> Disable LSO (Large Send Offload v2) on all 10Gbps network interface (Enable by default)
* 2024/02/19 - `UninstallNovaPDF`/`ViewNovaPDF` -> Uninstall NovaPDF
* 2024/02/19 - `DisableWindowsCopilot`/`EnableWindowsCopilot`/`ViewWindowsCopilot` -> Disable Windows Copilot (Windows11)
* 2024/02/19 - `DisableOneSettingsDownloads`/`EnableOneSettingsDownloads`/`ViewOneSettingsDownloads` -> Windows will not download configuration settings from the OneSettings service (Windows11)
* 2024/02/19 - `DisableDiagnosticLogs`/`EnableDiagnosticLogs`/`ViewDiagnosticLogs` -> Diagnostic logs collected
* 2024/02/07 - `UninstallHPWolfSecurity`/`ViewHPWolfSecurity` -> Uninstall HP Wolf Security
* 2024/02/07 - `UninstallHPBuiltInApps` -> Uninstall HP built-in apps
* 2024/02/07 - `UninstallHPBloatware` -> Uninstall HP Bloatware Software
* 2024/01/25 - `HideRecommendedSection`/`ShowRecommendedSection` -> Hide Recommended Section in start menu (Windows11)
* 2024/01/25 - `DisableSearchInternetInMenu_CU`/`EnableSearchInternetInMenu_CU`/`ViewSearchInternetInMenu_CU` -> No Search Internet In StartMenu
* 2024/01/23 - `DisableSearchOnTaskbar`/`EnableSearchOnTaskbar`/`ViewSearchOnTaskbar` -> Disable Search on Taskbar and Start Menu for All Users (Windows11)
* 2024/01/22 - `DisableCloudSearch`/`EnableCloudSearch`/`ViewCloudSearch` -> No search on cloud by default in menu (Windows11)
* 2024/01/22 - `DisableHighlightsSearch`/`EnableHighlightsSearch`/`ViewHighlightsSearch` -> Limit Highlights search (Windows11)
* 2024/01/11 - `DisableWidgetsNewsAndInterests`/`EnableWidgetsNewsAndInterests`/`ViewWidgetsNewsAndInterests` -> Limit news in menu (Windows11)
* 2024/01/11 - `HideMostUsedApps`/`ShowMostUsedApps`/`ViewMostUsedApps` -> Remove most used applications (Windows11)
* 2024/01/11 - `DisableTelemetry` -> Better code with more test
* 2023/12/12 - `SetPendingReboot`/`ViewPendingReboot` -> Restart computer if PendingReboot
* 2023/11/16 - `EnableStorageSense`/`DisableStorageSense`/`ViewStorageSense` -> Active global cleanup
* 2023/11/16 - `EnableStorageSenseTempCleanup`/`DisableStorageSenseTempCleanup`/`ViewStorageSenseTempCleanup` -> Active cleanup of temporary files
* 2023/11/16 - `EnableStorageSenseTrashCleanup`/`DisableStorageSenseTrashCleanup`/`ViewStorageSenseTrashCleanup` -> Active cleanup of user Recycle Bin
* 2023/11/15 - `UninstallGoogleToolbar`/`ViewGoogleToolbar` -> Uninstall Google Toolbar for Internet Explorer (very old!)
* 2023/11/06 - `EnableSWMBUniqueId`/`DisableSWMBUniqueId`/`ViewSWMBUniqueId` -> Add a unique `HostId` identifier for each host for better identification


## Version 3.15 (2023/11/02)

SWMB can also be used to block the installation of certain software on
computers. The tested solution consists in making tweaks that silently
remove these programs, for example at each startup via the scheduled task.

It is then enough to put in its preset list, rather towards the end, a
list of tweaks corresponding to the software that you do not want to see
on your park. To give an example, why have WinRAR when the 7-Zip software
exists ? The UninstallWinRAR tweak removes any instance installed on the
computer.

The aim is not to turn SWMB into a fleet management software, but to
emphasize its security role by listing some software that should not be
installed on your computer.

The `wisemoui.ps1` graphical interface has been updated.
Now you can launch all tasks manually (`Boot`, `Post-Install` and `Logon`)
and a panel has been added to list all software installed on your computer (`HKLM`, `HKU` and `HKCU`).
Computer uptime has been added to the title bar.

During installation, SWMB writes a unique GUID to the registry
so that it can be used later in webhook calls to always have the same identifier for a computer.

New presets/rules:

* 2023/09/20 - `UninstallTelegram_CU`/`ViewTelegram_CU` -> Uninstall Telegram Desktop
* 2023/09/20 - `UninstallBalenaEtcher_CU`/`ViewBalenaEtcher_CU` -> Uninstall BalenaEtcher
* 2023/09/01 - `EnableEdgeClearCacheOnExit`/`DisableEdgeClearCacheOnExit`/`ViewEdgeClearCacheOnExit` -> Clear Microsoft Edge on exit
* 2023/07/07 - `EnableVisualStudioCache`/`DisableVisualStudioCache`/`ViewVisualStudioCache` -> Disable VisualStudio Cache
* 2023/04/16 - `UninstallEdgeWebView2`/`ViewEdgeWebView2` -> Uninstall Microsoft Edge WebView2 Runtime
* 2023/04/16 - `EnableEdgeUpdate`/`DisableEdgeUpdate`/`ViewEdgeUpdate` -> Enable or disable Microsoft Edge auto update
* 2023/04/11 - `SetRemoteDesktopPort`/`UnsetRemoteDesktopPort`/`ViewRemoteDesktopPort` -> Set RemoteDesktop port service and push Firewall open rules (`$Global:SWMB_Custom` key `RemoteDesktop_PortNumber`)
* 2023/04/11 - `SetInterfaceMetricOn1Gbps`/`UnsetInterfaceMetricOn1Gbps`/`ViewInterfaceMetricOn1Gbps` -> Set Metric (priority) for all 1Gbps network interface (`$Global:SWMB_Custom` key `InterfaceMetricOn1Gbps`)
* 2023/04/11 - `SetInterfaceMetricOn10Gbps`/`UnsetInterfaceMetricOn10Gbps`/`ViewInterfaceMetricOn10Gbps` -> Set Metric (priority) for all 10Gbps network interface (`$Global:SWMB_Custom` key `InterfaceMetricOn10Gbps`)
* 2023/04/11 - `EnableJumboFrameOn10Gbps`/`DisableJumboFrameOn10Gbps`/`ViewJumboFrameOn10Gbps` -> Set Jumbo Frame on all 10Gbps network interface
* 2023/03/07 - `UninstallOneDrive_CU`/`InstallOneDrive_CU`/`ViewOneDrive_CU` -> Install or uninstall OneDrive per User
* 2022/10/14 - `UninstallGlassWire` -> Remove GlassWire software if installed
* 2022/07/21 - `UninstallOpenOffice` -> Remove OpenOffice software if installed
* 2022/07/13 - `UninstallTotalCommander` -> Remove TotalCommander software if installed
* 2022/07/11 - `SetWorkgroupName`/`UnsetWorkgroupName`/`ViewWorkgroupName` -> Set Windows Workgroup name (`$Global:SWMB_Custom` key `WorkgroupName`)
* 2022/07/07 - Move all the `UninstallKaspersky*` tweaks to the `LocalMachine-Uninstall.psm1` module
* 2022/07/06 - `UninstallWinRAR` -> Remove WinRAR software if installed
* 2022/07/06 - `UninstallRealPlayer` -> Remove RealPlayer software if installed

Change to global parameter:

* SWMB_Custom.LocalAdminNameEffective replace SWMB_Custom.LocalAdminNameToSet

The new module `LocalMachine-Uninstall.psm1` is dedicated to all software
that need to be uninstall on a Windows park, with no rules to install them.
So they are one way rules only !

A new PostInstall task has been defined.
It starts shortly after SWMB installation if and only if there is a
`LocalMachine-PostInstall.preset` file in the `C:\ProgramData\SWMB\Presets` folder.
There is no default preset file in the SWMB distribution.
So for this to work, you have to put this preset file before the installation.
The purpose of this new task is to be able to push presets immediately,
without waiting for a possible reboot which can take place a long time later.

The tasks import by default the PowerShell module having the same name as the preset,
but having the extension `.psm1` and located in the folder `C:\ProgramData\Modules`.
If this module does not exist, but there is a module in this same folder
with the name `Local-Addon.psm1`, then this one is loaded instead.
This mechanism allows to have one common module for all tasks,
or to specialize a module for a task.
Since 2023/04/28, Schedule tasks now always import the `Local-Addon.psm1` module, if exists,
before the module specific to the task.

Thus it is not necessary to load a module at the beginning of a preset file
(`$IMPORT`) if we follow this naming convention.
The goal is to simplify the use and configuration of SWMB
to your machine environment.

If a module with the name `Local-Addon-Host-$(HOSTNAME).psm1` (hostname in lower case) exists,
it is also loaded, after the other modules.
We don't define the **host module** per task, because too much is too much.
We have to be simple in the end. One module for all tasks specific to one machine is enough.
An **host preset** is now also loaded.
If a hostname preset `LocalMachine-PostInstall-Host-$(HOSTNAME).preset` exists,
it is loaded after the **site preset**.
You can have a global preset for all computers
and some computers can have more or less preset (the preset can be deleted with the symbol !)
if a specific preset has been defined.
The host module and host preset are active for Logon, Boot and PostInstall scheduling tasks.

The **Host naming system** is extended to the `Overload` and `Autodel` modules.
Thus, when the `-VarOverload` and `-VarAutodel` modules are searched,
the associated `-VarOverload-Host-$(HOSTNAME)` and `-VarAutodel-Host-$(HOSTNAME)` modules are also searched.

With the **host module** and **host presets**, you can **deploy the same configuration** (set of files) to your fleet of computers
and **have some specific rules** for some computers.

In [dists](dists/) folder, a template [SWLN](dists/swln/) have been defined.
[SWLN](dists/swln/) is SWMB for your Local Network.
This template help you to create a Zip archive to deploy SWMB
with your configuration on your computer park with OCS, WAPT, PDQ Deploy, etc.

In [dists](dists/) folder, a very simple [webhook server](dists/webhook)
have been defined. The objective is to implement a webhook client inside
SWMB.


## Version 3.14 (2022/07/07)

The string `Tweak` has been added in front of the name of all tweak functions.
This means that preset files can no longer call standard Powershell functions.
If needed, a specific tweak function must be written for security reasons.

New presets/rules:

* 2022/06/01 - `DisableMSDT`/`EnableMSDT`/`ViewMSDT` -> Disable MSDT - Microsoft Support Diagnostic Tool Vulnerability - CVE-2022-30190
* 2022/05/09 - `ViewKasperskyProduct` -> View all the Kaspersky product
* 2022/05/09 - `UninstallKasperskyConsole` -> Remove the Kaspersky Console
* 2022/03/16 - `UninstallKasperskyEndpoint` ([see more](dists/uninstall-kaspersky/)) -> use Custom configuration module
* 2022/03/16 - `SetTargetRelease`/`UnsetTargetRelease` -> For fix the target Feature Update version ([see more](https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsUpdate::TargetReleaseVersion))
* 2022/03/02 - `EnableClearPageFile`/`DisableClearPageFile` -> Clean PAGEFILE.SYS at shutdown
* 2022/02/02 - `EnableASLR`/`DisableASLR` -> Address Space Layout Randomisation

There is now a special distribution of SWMB to just uninstall Kaspersky antivirus.
See [Uninstall Kaspersky](dists/uninstall-kaspersky/).

The overload modules for the configuration `*-varOverload.psm1`,
e.g. `Custom-varOverload.psm1` are now searched in the current folder,
then in the `ProgramData` folder and then in the installation folder.
For these three cases, we start with the current folder,
the subfolder `Modules` and then we go back up to the root of the file system.

* `(Get-Location).Path`  # `$PWD`
* `${Env:ProgramData}\SWMB`
* Module Script Path  # `${Env:ProgramFiles}\SWMB\Modules\SWMB`

The `Custom.psm1` module is now loaded by default.
The `SWMB_ImportModuleParameter` function has been moved from `SWMB.psm1`
to the Custom module (no other choice was found) and this module is loaded
first in the list of nested modules (see `SWMB.psd1`).
In case the `-core` option is used on the `swmb.ps1` command line,
you must load the Custom module in order for the `SWMB_ImportModuleParameter`
function to be used.

Many tweaks had not been classified in preset files.
This work on all the latest tweaks is already well underway.


## Version 3.13 (2021/11/22)

Add a setup file, juste write `make pkg` under Linux (Add a `Makefile`).
Continuous integration build the package
([here](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/)).
A Zip file is created for OCS Inventory.
A Zip file is also created for WAPT package.
You can use it as-is.

Add a minimal UI with `wisemoui.ps1` program. Launch it via the Start Menu.

Automatically search `Overload` and `Autodel` module in `C:\ProgramData\SWMB` folder
(and `Modules` subfolder).

Create two tasks:

* `CurrentUser-Logon.ps1` - Execute at user logon `C:\ProgramData\SWMB\Presets\CurrentUser-Logon.preset`
* `LocalMachine-Boot.ps` - Execute at boot `C:\ProgramData\SWMB\Presets\LocalMachine-Boot.preset`

If a module with the same name exist in `C:\ProgramData\SWMB\Modules`, it's will be launch.

An event is created in Application at begin and end.
Output is redirect in a log file inside the folder `C:\ProgramData\SWMB\Logs`.

Two presets `CurrentUser-Logon-Test.preset` and `LocalMachine-Boot-Test.preset`
are copied on folder `C:\ProgramData\SWMB\Presets`.
They could serve for test or as simple examples.

Two presets [CurrentUser-Logon-Recommanded.preset](Presets/CurrentUser-Logon-Recommanded.preset)
and [LocalMachine-Boot-Recommanded.preset](Presets/LocalMachine-Boot-Recommanded.preset)
are copied on folder `C:\ProgramData\SWMB\Presets`
with the names `CurrentUser-Logon.preset` and `LocalMachine-Boot.preset`.
They are execute at logon (account SYSTEM) and at boot (account CurrentUser).
Configuration tweaks are thus performed on any workstation that installs SWMB.
These tweaks are selected by the SWMB working group (RESINFO).
The default boot preset is not empty.
If you don't want any tweaks, replace these two files with empty ones
or don't activate them with the installer.
On the command line you can do this with:
```ps1
SWMB-Setup-XXX.exe /S /ACTIVATED_PRESET=0
```
Any value other than 0 (or nothing) will activate the default preset.

New presets/rules:

* 2021/10/21 - `$PRESET` and `$IMPORT` can open absolute and relative path file (before only relative path was possible)
* 2021/10/21 - `$PRESET` replace `$INCLUDE` to include a preset file.
* 2021/10/20 - `SysCheckpoint` - Make a system checkpoint if possible (max one per day)
* 2021/10/19 - `$INCLUDE` (`$PRESET`) and `$IMPORT` can open filename with space in PATH. Protect the string with double quote `"`.
* 2021/10/16 - `SysBox` - Like `SysMessage` but open a Box (experimental)
* 2021/10/15 - `SysEvent` - Like `SysMessage` but send an Event
* 2021/10/11 - `$IMPORT` - Like `$PRESET` but import a module from a preset file

New CLI parameter:

* `-import` replace `-include` to be more clear.
  As `$PRESET` replace `$INCLUDE` in preset file.
  The word `include` is not use anymore because sometime it was on modules and sometime on preset files.
* `-hash filename` makes a hash of the tweak list (preset)
  and compares it with the old hash stored in filename.
  If the hashes differ, a system checkpoint is performed.
  A folder `Caches` is created in `C:\ProgramData\SWMB`
  to store all the hashes.
* `-version` print the program version.

New module architecture, Win10- prefix has been replaced by LocalMachine-.
This is better for the new Windows 11 operating system.


## Version 3.12 (2021/09/14)

Rename main program Win10.ps1 to swmb.ps1
Add a compatibility program for upgrade Win10.ps1

New modules architecture:

* `Modules/SWMB.psd1` - Generic preload module (`Modules/SWMB.psm1`)
* `Modules/SWMB/Custom.psm1` - Additionnal rules with parameter
* `Modules/SWMB/Resinfo.psm1` - ANSSI rules
* `Modules/SWMB/Experimental.psm1` - Experimentals rules
* `Modules/SWMB/Win10-*.psm1` - Initial module from Disassembler0
* `Modules/SWMB/CurrentUser-*.psm1` - Initial module from Disassembler0 base on HKCU
* `Modules/SWMB/TemporaryBypass.psm1` - Temporary Bypass Strategy Module

Parameter module now use global hash table (via the `*-VarOverload.psm1` plugin).
Automatically search `Overload` variable module in parent folder.
Added support for the `Autodel` plugin in addition to the `Overload` plugin.
As the name suggests, the plug-in file `*-VarAutodel.psm1` will be deleted right after loading.

Add `View*` function to help debugging

New dists:

* [crypt-with-bitlocker](./dists/crypt-with-bitlocker/)

New CLI parameter:

* `-core`  - Load minimal SWMB code module. Must be the first parameter
* `-check` - Check for duplicated tweak preset and tweak implementations. Do not execute any preset
* `-exp`  - Load Experimental module (add Experimental feature)

New preset selection:

* `Post-Install.preset` - Enable Bitlocker after installation
* `Current-User.preset` - Preset for Current User and not Local Machine
* `System-Resinfo.preset` - Preset on system and network
* `LocalMachine-*.preset` - Rename `*-Resinfo.preset` file for local machine tweak
* `LocalMachine-Default.preset` - New global preset file with $INCLUDE directive

Preset file could now include other files with the $INCLUDE directive

New presets/rules:

* 2021/09/10 - `DisableMSHTMLActiveX`/`EnableMSHTMLActiveX`/`ViewMSHTMLActiveX` -> Disable ActiveX in MSHTML (Internet Explorer) CVE-2021-40444
* 2021/08/28 - `DisableAutoloadDriver`/`EnableAutoloadDriver` -> Zero day on autoload driver on network
* 2021/07/10 - `SysRequireAdmin` replace `RequireAdmin`
* 2021/07/07 - `SysAutoUpgrade` -> Auto Upgrade your SWMB folder! Need an internet access to the Git repository
* 2021/07/02 - `DisablePrintForSystem`/`EnablePrintForSystem`/`ViewPrintForSystem` -> Pseudo patch for CVE-2021-34527
* 2021/06/14 - `EnableInsecureGuestLogons`/`DisableInsecureGuestLogons` -> Disable by default
* 2021/06/13 - `DisableSMB1Protocol`/`EnableSMB1Protocol` -> SMBv1 protocol
* 2021/06/13 - `DisableSMB1`/`EnableSMB1` rename -> `DisableSMB1Server`/`EnableSMB1Server`
* 2021/06/05 - `SetNTPConfig`/`UnsetNTPConfig` -> NTP service configuration
* 2021/06/05 - `EnableGodMod_CU`/`DisableGodMod_CU` -> God Mod for Current user
* 2021/06/05 - Rename `Restart` -> `SysRestart` and `WaitForKey` -> `SysPause`
* 2021/06/05 - `SysHalt` -> Halt computer and not Reboot
* 2021/06/04 - `SysMessage` -> Just write a message on terminal for debugging purpose (like WaitForKey)
* 2021/06/04 - `DisableUWPAccessLocation`/`EnableUWPAccessLocation` -> Let UWP Apps Access Location
* 2021/06/01 - `DisableWindowsFeeds`/`EnableWindowsFeeds` -> News and Interests on Taskbar
* 2021/05/12 - `EnableBitlocker`/`DisableBitlocker` -> Crypt hard drive with bitlocker
* 2021/04/29 - `DisableWindowsHello`/`EnableWindowsHello` -> Windows Hello Authentification


## Version 3.11 (never publish)

All ANSSI rules integration.

First paramter module implementation with global variable.

New dists folder with use case examples.

New presets selection:

* `Cloud-Resinfo.preset`
* `CortanaSearch-Resinfo.preset`
* `Post-Install.preset`
* `Telemetry-Resinfo.preset`
* `UniversalApps-Resinfo.preset`
* `UserExperience-Resinfo.preset`


## Version 3.10

Initial version from Disassembler0 `Win10-Initial-Setup-Script` project
