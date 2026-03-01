# SWMB - Secure Windows Mode Batch

![](./logo-swmb.png){ align=right }

## Main links

* The latest version of the SWMB **documentation** can be found [online](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/docs/).
* The latest version of the SWMB **setup installer** is available on the [download page](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/).
* For your update scripts (for example), you have the **version number** of the latest SWMB release
  in the first line of the [version.txt](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/version.txt) file.
  This last version is rebuilt at each modification pushed on the Git server, so the code can change.
* The master Git repository in on the [IN2P3 Gitlab](https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb).
  Other Git repository are mirror or fork.

**Main sub-menu**:

* [CONTRIBUTING](./CONTRIBUTING.md)
* [FAQ](./FAQ.md)
* [LICENSE](./LICENSE.md)
* [NEWS](./NEWS.md)
* [REFERENCES](./REFERENCES.md)
* [USE CASE (distribution)](./dists/README.md)

## Preamble

This is a PowerShell script for automation of routine tasks done after fresh installations of Windows 10, Windows 11 and Windows Server 2016 / 2019.
This is by no means any complete set of all existing Windows tweaks and neither is it another "antispying" type of script.
It's simply a setting which I like to use and which in my opinion make the system less obtrusive.

SWMB is a project from the SWMB working group of the RESINFO business network of CNRS and the French higher education.
It is about managing security, confidentiality and privacy under the Windows 10 operating system with the help of scripts,
thus without using a graphical interface.
The objective is to be able to easily deploy security tweaks (strategy) on a computer park,
whether or not the computers are in an Active Directory domain.
In a concern of tracing (quality) and knowledge sharing, all possible actions are readable in a text format.
The chosen programming language is Microsoft Powershell.
All the code and documentation is available on a Git forge.

The choice to implement a scripting system is therefore a complementary choice to a solution with GPO associated with Active Directory servers.
The question of how SWMB is deployed on the workstations is not directly linked to the SWMB project itself.
It is software like any other and can therefore be integrated into any configuration management system.

The project is intended to be modular.
It must be easy to maintain, easy to understand, easy to extend and easy to use.
The website [comparison-of-windows-10-privacy-tools](https://www.ghacks.net/2015/08/14/comparison-of-windows-10-privacy-tools/) references many possible solutions.
SWMB chose to take as a starting point the code of Disassembler0 which is now archived: `Win10-Initial-Setup-Script`,
because it met all our criteria above.

Regarding the applicable security strategies,
SWMB is mainly based on the tweaks enacted by the French National Agency for Information Systems Security ([ANSSI](https://www.ssi.gouv.fr/)).
There are thus three levels of possible tweaks in SWMB:

* `Modules\SWMB\Win10` - tweaks extracted from the ANSSI documentation, or from certain instructions of the RSSI of the CNRS,
   applicable in the whole ESR (Higher Education and Research in France);
* `Modules\SWMB\Custom` - interesting tweaks that you can extend for your site.
* `Modules\SWMB\Experimental` - future tweaks under active development and not fully tested.
   Feedback from users may be interesting.

Each tweak can be enabled (`enable`) or disabled (`disable`) very easily in a configuration file (`preset`).
Sample files are available.
Each tweak is associated with a comment in French or English referring to its origin.
The French language has sometimes been chosen in order to follow the ANSSI's terminology
and because of the French version of Windows 10 which is used in most of our computers in the ESR.

For `Custom` tweaks, it is possible to set them with a variable file in order to adapt them to your park.
A set of default parameters is proposed.
The other tweaks are not configurable, because they are, at first, to take or to leave!
The upstream project on which we based ourselves had not planned to be able to parameterize tweaks.
It is an extension that we added.

**Some references**:

* Upstream project [Win10-Initial-Setup-Script](https://github.com/Disassembler0/Win10-Initial-Setup-Script) by Disassembler0 user
* Document from the [ANSSI](https://fr.wikipedia.org/wiki/Agence_nationale_de_la_s%C3%A9curit%C3%A9_des_syst%C3%A8mes_d%27information)
  (Agence Nationale de la Sécurité des Systèmes d'Information - France) :
  [restreindre-la-collecte-de-donnees-sous-windows-10](https://www.ssi.gouv.fr/administration/guide/restreindre-la-collecte-de-donnees-sous-windows-10/)
* Document of the [BSI](https://fr.wikipedia.org/wiki/Office_f%C3%A9d%C3%A9ral_de_la_s%C3%A9curit%C3%A9_des_technologies_de_l%27information)
  (Federal Office for Information Technology Security - Germany) :
  [Hardening_Guideline.pdf](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Cyber-Security/SiSyPHuS/AP11/Hardening_Guideline.pdf)
* [Sécuriser son parc Windows avec le projet modulaire et communautaire SWMB](https://hal.science/hal-03608835) (french 2022)

More references on the page [REFERENCES](./REFERENCES.md).


## Installation

You can find on the [download page](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/) the latest versions of the SWMB setup installer,
and also a [WAPT](https://www.wapt.fr) package, a ZIP archive usable with [OCS inventory](https://ocsinventory-ng.org/)...
These setup packages are made with the [NSIS](https://sf.net/projects/nsis/) software (Nullsoft Scriptable Install System).
It is possible not to install and activate scheduled tasks at computer startup and user logon.

![SWMB Graphical Installer 1](Images/swmb-setup-1.png)
![SWMB Graphical Installer 2](Images/swmb-setup-2.png)

It is possible to do a silent installation with the `/S` flag.
The `/ACTIVATED_PRESET` flag can be set to 0 if you do not want the default presets
to be installed for predefined scheduled tasks (see [Tasks](#task)).

```
SWMB-Setup-XXX.XXX.XXX.exe /S /ACTIVATED_PRESET=0
```

You will also find, in the [dists](dists) directory, examples of deployment or use
of the SWMB software environment
(manual, at machine startup, with [OCS inventory](https://ocsinventory-ng.org/),
[WAPT](https://www.wapt.fr) package, volume encryption,
uninstall [Kasperky Endpoint](dists/uninstall-kaspersky/README.md)...).

* Please note that the uninstallation of
  [Kaspersky Endpoint](dists/uninstall-kaspersky/README.md)
  and its network agent on the client computer is a stand-alone distribution
  in the form of an archive that is self-sufficient
  and does not need to be installed on the computer.

* The [SWLN](dists/swln/README.md) is a template distribution
  for deploying and extending SWMB for use on your local network machines
  (SWMB for your Local Network).

* The [SWCE](dists/swce/README.md) is a compliance script designed to verify your secure Windows environment after applying GPOs or SWMB.
  This script is standalone, does not modify your system in any way, and does not apply any GPOs.
  It simply checks the status of the system and suggests corrections if necessary.

* The [README](dists/manual-use/README.md) file in the "manual-use" directory
  reminds some principles about PowerShell execution policies.

**Exception for antivirus and EDR**

Some antivirus programs, such as WithSecure, consider SWMB to be a virus.
In reality, it's the [Nullsoft NSIS-based](https://nsis.sourceforge.io/Docs/) `setup.exe` installer and uninstaller that's to blame.
SWMB itself does not pose a problem for this antivirus.
Perhaps we'll change the tool we use to build an installer in the future.
The development team is looking for a good tool to build an MSI package from a Linux virtual machine.

Exceptions must therefore be made based on either the path or a hash of the programs.
The easiest way is to set an exception on the SHA-1 hash of the installation program for each SWMB version (see [download](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/) page)
and an exception on the path `C:\Program Files\SWMB\uninst.exe` of the uninstall program (which will then be valid for all versions).

As far as EDRs ([Endpoint Detection and Response](https://en.wikipedia.org/wiki/Endpoint_detection_and_response)) are concerned, SWMB is bound to raise alarms.
Indeed, this program touches on the system's low-level configuration, which an EDR doesn't like by default.
You'll need to set up whitelists in your EDR to accept some of your system settings.
This is inherent to the EDR concept...

## Usage

If you just want to run the script with the default preset,
download and unpack the [latest release](https://github.com/Disassembler0/Win10-Initial-Setup-Script/releases)
and then simply double-click on the *Default.cmd* file and confirm *User Account Control* prompt.
Make sure your account is a member of *Administrators* group as the script attempts to run with elevated privileges.

The script supports command line options and parameters which can help you customize the tweak selection or even add your own custom tweaks,
however these features require some basic knowledge of command line usage and PowerShell scripting.
Refer to [Advanced usage](#advanced-usage) section for more details.

### Direct use from PowerShell

```ps1
# Execution of a single function / tweak
.\swmb.ps1 NameOfTheTweak

# Execution of a preset of tweaks
.\swmb.ps1 -preset "Presets\LocalMachine-Default.preset"
```

### Integrated use in a PowerShell script

```ps1
# Loading the SWMB base engine with all the main modules (neested)
# Put only SWMB.psm1 if you want only the core
Import-Module Modules\SWMB.psd1

# Initialize
SWMB_Init

# Load a preset file (can be called several times)
# Each preset file is a suite of tweaks
SWMB_LoadTweakFile "Presets\LocalMachine-Default.preset"

# Load one tweak (can be called multiple times)
# Unloads the tweak if it starts with the exclamation mark (!)
SWMB_AddOrRemoveTweak "NomFonction"

# If you want to check the consistency of tweaks
SWMB_CheckTweaks

# Execute all loaded tweaks (presets)
SWMB_RunTweaks
```

### Advanced usage

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 [-import filename] [-preset filename] [-log logname] [[!]tweakname]

    -import filename        load module with user-defined tweaks
    -preset filename        load preset with tweak names to apply
    -log logname            save script output to a file
    tweakname               apply tweak with this particular name
    !tweakname              remove tweak with this particular name from selection

### All command line option

`swmb.ps1` currently supports the following parameters:

* `-core` : if used, it must be the first option.
  Import only the core (minimal) module `SWMB.psm1`,
  not all the neested module declared in `SWMB.psd1`.
* `-import module_file.psm1` : imports the module into SWMB.
  You can extend SWMB, as is, with your own tweaks.
  This option can be declare as many times as necessary.
* `-preset preset_file.preset` : loads all the tweak groups defined in a preset file.
  This option can be declared as many times as necessary.
* `-log log_file` : messages will be written to the log file file
  and not in the terminal.
* `-check` : does not execute the tweaks but only checks if they exist
  (in accordance with the preset file).
* `-print` : does not execute the tweaks but only print them.
* `-version` : print the SWMB version.
* `-exp` : this is just a shortcut to import the `Experimental.psm1` module.
  This option is mainly used by developers to help test new tweaks.
* `-hash hash_file.hash` makes a hash of the tweak list (preset)
  and compares it with the old hash stored in filename.
  If the hashes differ, a system checkpoint is performed.
  It is a good idea to put the hash file in the `C:\ProgramData\SWMB\Caches` folder
  with the name of the most important preset followed by the `.hash` extension.

### Graphical User Interface

There is a minimal graphical user interface, but it has been expanded over time.
A link to it appears in the start menu under the name SWMB Secure Windows.
This interface allows to force the execution of some tasks: boot, disk encryption, etc.
To make the interface easier to understand, each button has an associated tooltip.

![SWMB Graphical User Interface](Images/capture-wisemoui.png)

The GUI is divided into several sections:

* A `Help` button opens your default browser to [online documentation](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/docs/).
  Clicking on the logo takes you to the Gitlab forge website hosting the SWMB [source code](https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/).

* A frame concerning Bitlocker.
  It is possible to `Crypt` all disks, `Suspend` Bitlocker and launch the TPM console (`T` button).
  A status line shows the encryption status in three colors: no encryption (red), encryption but caution (orange), correct encryption (green).

* A frame for scheduled tasks (tweak/preset).
  This is the most complex area, yet quite simple to understand, because it's the same thing three times:  one for boot, one for application post-installation and the last for user logon.
  The same buttons appear three times.
	* `Run`: Immediately starts the scheduled task in manual mode.
	  This allows you to test the task, for example.
	* `C`: Check if the tweaks defined in the preset file exist and are not executed several times.
	  See the `-check` option in the `swmb.ps1` program.
	* `P`: Displays the list of tweaks defined in the preset file that will be executed by the scheduled task, but nothing is actually executed.
	  See the `-print` option in the `swmb.ps1` program.
	* `L`: Displays the log file of the last execution of the scheduled task
	* `E`: Edits the main preset file associated with the scheduled task.
	  If there is a secondary file specifically associated with the workstation, this is not edited.
	  Note: if [Notepad++](https://notepad-plus-plus.org/) is installed, this editor is used, otherwise the Windows built-in Notepad is launched.
	* `M`: The [WinMerge](https://winmerge.org/) application is launched and compares your main preset file with the preset file containing all the tweaks in the SWMB distribution (`LocalMachine-All.preset` or `CurrentUser-All.preset`).
	  This comparison lets you see if there are any new tweaks easily and gives you a visual view of the specifics of your security policy.
	  Note: This button only appears if [WinMerge](https://winmerge.org/) is installed on the workstation.

* A frame concerns the host machine.
  There's the SWMB version (and the number of the latest software version if different), there's the host name, the host id, its OS with its version in green, orange or red depending on whether it seems more or less up to date.
  There are two buttons in this section: `Property` for the machine properties (where you can change the name and performance parameters, for example) and the Windows `Update` console.

* A specialized software frame.
  A button `View` lists all software registered in all registry hives.
  The `R` button opens the console for adding or removing programs.
  The following buttons are optional, depending on your machine:
	* `B`: Launches the [BleachBit](https://www.bleachbit.org/) program if installed.
	* `S`: Launches the [WinDirStat](https://windirstat.net/) program if installed.
	* `C`: Launches the [CCleaner](https://www.ccleaner.com/) program if installed.

* A frame with system consoles.
	* The `GPO` button launches `secpol`, the console for Local Security Policies.
	* The `E` button opens the GPedit console.
	* The `P` button launches the [Procmon](https://en.wikipedia.org/wiki/Sysinternals) application (if installed under `C:\Program Files\Sysinternals`).
	  This GPO zone can be used to develop new tweaks.
	* `Management` is the global console for managing a workstation.
	* `Net` is the console for managing network interfaces (changing dhcp, managing metrics, etc.).

* Finally, an `Exit` button lets you quit SWMB!

### Tasks

The goal is to not change anything in the SWMB installation folder.
Three scheduled tasks are configured.
One takes place when the machine is started (Boot),
the other when the user logs in (Logon) and finally the third is
a bit special because it starts just after the installation of SWMB (PostInstall).

These three tasks will look for their parameters in the `C:\ProgramData\SWMB\Presets` folder.

* `CurrentUser-Logon.ps1` - Load preset at user logon `C:\ProgramData\SWMB\Presets\CurrentUser-Logon.preset`
* `LocalMachine-Boot.ps1` - Load preset at boot `C:\ProgramData\SWMB\Presets\LocalMachine-Boot.preset`
* `LocalMachine-PostInstall.ps1` - Load preset after SMWB install `C:\ProgramData\SWMB\Presets\LocalMachine-PostInstall.preset`

By default, the presets [CurrentUser-Logon-Recommanded.preset](Presets/CurrentUser-Logon-Recommanded.preset)
and [LocalMachine-Boot-Recommanded.preset](Presets/LocalMachine-Boot-Recommanded.preset) are copied
to the `C:\ProgramData\SWMB\Presets` folder.
They are automatically updated with each new version of SWMB because they contain the magic string "`file automatically updated`".
If you have your own preset files, they will not be updated.
Moreover, during the installation,
it is possible not to set these preset files by default by unchecking a box in the installer
(flag `/ACTIVATED_PRESET=0` in command line).

Note that there is no default preset for the PostInstall task.
Thus, the task starts shortly after installation,
but does nothing in the minimal configuration.
If you want to benefit from this task,
you will have to think about putting a preset file `LocalMachine-PostInstall.preset`
in the `C:\ProgramData\SWMB\Presets` folder before installing SWMB.

If a module with the same name (with the extension `.psm1`) exists
in the folder `C:\ProgramData\SWMB\Modules`, it will be imported.
For example, if there is a `C:\ProgramData\SWMB\Modules\LocalMachine-Boot.psm1` module,
then it is loaded at the beginning of the `LocalMachine-Boot.ps1` task.
In order to mutualize the code of the modules in a single module,
which can be more practical on the development and deployment side,
if there is no module of the name of the task,
but there is the generic module `Local-Addon.psm1` in the `C:\ProgramData\SWMB\Modules` folder,
then it is loaded.

An event is created in Application journal at begin and end of the task.
Output of the task are redirected in a log file inside the folder `C:\ProgramData\SWMB\Logs`.

Two preset `CurrentUser-Logon-Test.preset` and `LocalMachine-Boot-Test.preset`
are copied on folder `C:\ProgramData\SWMB\Presets`.
They could serve for test or as simple example.
Do not modify these examples directly, they will be updated in the next software update.
Rename them and modify them.


## Presets

The tweak library consists of separate idempotent functions, containing one tweak each. The functions can be grouped to *presets*.
Preset is simply a list of function names which should be called.
Any function which is not present or is commented in a preset will not be called, thus the corresponding tweak will not be applied.
In order for the script to do something, you need to supply at least one tweak library via `-import` and at least one tweak name,
either via `-preset` or directly as command line argument.

The tweak names can be prefixed with exclamation mark (`!`) which will instead cause the tweak to be removed from selection.
This is useful in cases when you want to apply the whole preset, but omit a few specific tweaks in the current run.
Alternatively, you can have a preset which "patches" another preset by adding and removing a small amount of tweaks.

The preset file is in practice a list of tweaks to apply.
There is one tweak per line.
It is possible to have empty lines, comments.
These are identified with the # character, as in many scripting languages.

The presets are classified in the folder `Presets`.
Currently, there is one preset per paragraph of the ANSSI concerning the settings for the computer configuration.

* Telemetry preset
* Cortana and search preset
* User experience preset
* Universal Applications preset
* Cloud preset

**Prefix** - Moreover, some presets concern the computer while others concern the current user.
In one case, the tweaks affect the overall operation of the operating system and must be run as an administrator (or under the SYSTEM user),
in the other case, the actions are to be launched, for example at login, with the identity of the person.
Preset files are therefore prefixed with the extensions `LocalMachine-` and `CurrentUser-`.

It is possible to include a set of presets in another file with the keyword `$PRESET`.
The preset `LocalMachine-Default.preset` gathers all the recommended presets mentioned above for the machine.

**Path** -  It is possible to put a wildcard, for example `*`, in the name of a preset.
All presets that match the rule are then loaded.
It is also possible to have a space in the path name by protecting the entire string with double quotation marks `"`
(and only double quote), otherwise these quotation marks are optional.
The path can be both relative and absolute (local path to the machine like `C:\` or UNC network path starting with `\\`).
If you have a space and a double quote in your path,
it is always possible to put a wildcard like a `*` or a `?` to get around either one.
Normally, no standard path uses both symbols.

```ps1
$PRESET LocalMachine-Cloud.preset
$PRESET LocalMachine-CortanaSearch.preset
...
```
In order to facilitate the deployment,
the modularity and the management of programmed tasks,
it is also possible to import a module within a preset file, with the keyword `$IMPORT`.
This is the same way ans same rules for the path as the `$PRESET` keyword.
Note the support of wildcards in the name of the module to import, allowing to import several of them.
The module path must be relative to the preset file or absolute.
```ps1
$IMPORT ..\Modules\MyModule.psm1
$IMPORT "C:\Program Files\MyLocalProgram\Modules\MyModule.psm1"
```
You can import as many modules as you want.


To supply a customized preset, you can either pass the function names directly as arguments.

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 -import Win10.psm1 EnableFirewall EnableDefender

Or you can create a file where you write the function names (one function name per line, no commas or quotes, whitespaces allowed, comments starting with `#`) and then pass the filename using `-preset` parameter.
Example of a preset file `mypreset.txt`:

    # Security tweaks
    EnableFirewall
    EnableDefender

    # UI tweaks
    ShowKnownExtensions
    ShowHiddenFiles   # Only hidden, not system

Command using the preset file above:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 -import Win10.psm1 -preset mypreset.txt

### Summary of the total number of tweaks

LM stands for LocalMachine and CU for CurrentUser.
The first column for each category (LM and CU) is, for example, for the `Install` type, and the second for its opposite, `Uninstall`.
The middle column is a global summary (All).

 | Status | Number of tweaks                       |         LM ||  All |         CU ||
 | :---   | :---                                   | ---: | ---: | ---: | ---: | ---: |
 | Info   | Number of RESINFO tweaks               |        225 ||  241 |         16 ||
 | Info   | Number of Enable and Disable tweaks    |  189 |  189 |  454 |   38 |   38 |
 | Warn   | Number of Install and Uninstall tweaks |   21 |   48 |   73 |    1 |    3 |
 | Warn   | Number of Show and Hide tweaks         |   29 |   29 |  115 |   30 |   27 |
 | Info   | Number of Add and Remove tweaks        |    3 |    3 |    8 |    1 |    1 |
 | Warn   | Number of Set and Unset tweaks         |   25 |   10 |   53 |   18 |    0 |
 | Warn   | Number of Pin and Unpin tweaks         |    0 |    0 |    2 |    0 |    2 |
 | Info   | Number of total tweaks GPO             |      |      |  705 |      |      |
 | Info   | Number of Sys tweaks (system)          |      |      |    9 |      |      |
 | Info   | Number of View tweaks (debug)          |      |      |  107 |      |      |
 | Info   | Number of Obsolete tweaks              |      |      |    3 |      |      |
 | Info   | Number of total tweaks functions       |      |      |  824 |      |      |

### Import your lib

The script also supports inclusion of custom tweaks from user-supplied modules passed via `-import` parameter. The content of the user-supplied module is completely up to the user, however it is strongly recommended to have the tweaks separated in respective functions as the main tweak library has. The user-supplied scripts are loaded into the main script via `Import-Module`, so the library should ideally be a `.psm1` PowerShell module.
Example of a user-supplied tweak library `mytweaks.psm1`:

```powershell
Function MyTweak1 {
    Write-Output "Running MyTweak1..."
    # Do something
}

Function MyTweak2 {
    Write-Output "Running MyTweak2..."
    # Do something else
}
```

Command using the script above:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 -import mytweaks.psm1 MyTweak1 MyTweak2

### Combination

All features described above can be combined. You can have a preset which includes both tweaks from the original script and your personal ones. Both `-import` and `-preset` options can be used more than once, so you can split your tweaks into groups and then combine them based on your current needs. The `-import` modules are always imported before the first tweak is applied, so the order of the command line parameters doesn't matter and neither does the order of the tweaks (except for `RequireAdmin`, which should always be called first and `Restart`, which should be always called last). It can happen that some tweaks are applied more than once during a singe run because you have them in multiple presets. That shouldn't cause any problems as the tweaks are idempotent.
Example of a preset file `otherpreset.txt`:

    MyTweak1
    MyTweak2
    !ShowHiddenFiles   # Will remove the tweak from selection
    WaitForKey

Command using all three examples combined:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 -import Win10.psm1 -import mytweaks.psm1 -preset mypreset.txt -preset otherpreset.txt Restart


### Definition of your own variable values

If you want to define your own variable values used in the `Custom.psm1` module, do the following:

* Create a file named `Custom-VarOverload.psm1` in the same directory as the `Custom-VarDefault.psm1` module,
  or in any parent `..` or sub-folder `Modules` of a parent folder!
  This leaves a lot of choices...
  It's also possible to create it inside the program data folder dedicated to SWMB
  (`C:\ProgramData\SWMB\Modules`).
* Set the hash values of your global variables
  (Don't change the whole hash table like in the `Custom-VarDefault.psm1` file)
* Example:
  ```ps
  $Global:SWMB_Custom.NTP_ManualPeerList = "0.fr.pool.ntp.org, 1.fr.pool.ntp.org"
  ```

Order in which the `Custom-VarOverload.psm1` module will be loaded into memory:
first to the current folder (`(Get-Location).Path`),
second to the program data folder
and last to the module installation folder.
For each of these folders, it will recursively search folder after folder
until it reaches the root folder.

1. `.\Custom-VarOverload.psm1`
1. `.\Modules\Custom-VarOverload.psm1`
1. `..\Custom-VarOverload.psm1`
1. `..\Modules\Custom-VarOverload.psm1`
1. `..\..\Custom-VarOverload.psm1`
1. `..\..\Modules\Custom-VarOverload.psm1`
1. and so on...
1. `${Env:ProgramData}\SWMB\Custom-VarOverload.psm1`
1. `${Env:ProgramData}\SWMB\Modules\Custom-VarOverload.psm1`
1. and so on...
1. `${Env:ProgramFiles}\SWMB\Modules\SWMB\Custom-VarOverload.psm1`
1. `${Env:ProgramFiles}\SWMB\Modules\SWMB\Modules\Custom-VarOverload.psm1`

For sensitive keys, it is possible to define a `Custom-VarAutodel.psm1` module.
This one works exactly the same way as the `Custom-VarOverload.psm1` module
except that SWMB **deletes this module file** for security reasons right **after loading** it into memory.
So it is only valid once unless you recreate it between two SWMB launches.

The module `Custom-VarAutodel.psm1` is searched in the same folder as the module `Custom-VarOverload.psm1`.
The `VarOverload` module **is loaded first** if it exists, however **both modules are loaded if they are in the same folder**.
The recursive search in subfolders stops as soon as one or both modules are found in a folder.

### Logging

If you'd like to store output from the script execution,
you can do so using `-log` parameter followed by a filename of the log file you want to create.
For example:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File swmb.ps1 -import Win10.psm1 -preset mypreset.txt -log myoutput.log

The logging is done using PowerShell `Start-Transcript` cmdlet,
which writes extra information about current environment (date, machine and user name, command used for execution etc.)
to the beginning of the file and logs both standard output and standard error streams.
