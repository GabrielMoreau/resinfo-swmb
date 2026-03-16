# Template to extend SWMB on your Local Network

## Context

SWLN (Local Network) is just a template to show you how to use and deploy SWMB on your network.
You can use SWMB differently from SWLN,
see for example the [Kaspersky uninstall](../uninstall-kaspersky/) project for workstations or the [SWCE](../swce) compliance enforcement project..
With SWLN, all your extensions / developments / modifications are in your project space and you can use SWMB without any modification.

SWLN allows you to create a ZIP archive containing the latest version of SWMB along with all the configuration files specific to your IT infrastructure.
The creation of this archive is automated.
Currently, SWLN is designed for use on **Linux**, as programming and automating tasks to build a package is simpler on this operating system.
However, the final package is intended for deployment on Windows wo

## Minimal configuration

In order to have a fully functional SWMB, we must place these files in the `C:\ProgramData\SWMB` tree.
In practice, other files can be used to fine-tune the configuration, as we will see later.

```
CurrentUser-Logon.preset        -> Presets/
LocalMachine-Boot.preset        -> Presets/
LocalMachine-PostInstall.preset -> Presets/
Custom-VarOverload.psm1         -> Modules/
Local-Addon.psm1                -> Modules/
```

You can use a special preset file that is applied only once during the software's post-installation phase (`LocalMachine-PostInstall.preset`).
This can be useful for setting parameters that are identical to, and/or different from, those used when the computer starts up.
This is especially useful if you are deploying SWLN (SWMB) on-the-fly rather than only at system startup or shutdown.
Thus, on some sites, only a few rules are defined during the post-installation step, as some PCs are not restarted frequently.

The implementation of your rules (LocalMachine and CurrentUser) are written in the `Local-Addon.psm1` module
and you can define some parameters in the `Custom-VarOverload.psm1` module,
for example the IP of your time server if you use this tweak.

## Build

With this SWLN template you can easily create your packages under GNU/Linux or MacOS.
The core in the build process is a `Makefile` which uses the `curl` program to fetch the right version of SWMB.
The `Makefile` could have been written as a Bash script,
but `make` is a good program for building objects with dependencies.

At the end of the process, a ZIP archive is created with a version number.
This version number combines the SWLN version number with the SWMB version number.

To build the archive, you'll need the following packages on your Linux system (for Debian):

```bash
apt install coreutils findutils grep sed curl gawk dos2unix zip unzip make readpe
```

In a terminal, just type `make`, and if everything goes well, the archive will build automatically!

```bash
make
```

To ensure compatibility with your existing infrastructure, do not attempt to modify the `Makefile` at first
However, you can extend it using the `extend-variables.mk` and `extend-rules.mk` files.
The first file allows you to set site-specific parameters, and the second allows you to add your own rules to the Makefile.

```
extend-variables.mk
extend-rules.mk
```

## Installation

Inside the archive is a DOS file named `install.bat`.
This file runs the PowerShell installer `installer.ps1`.
This script installs only the files strictly necessary for SWMB to run on the workstation.
To function, the computer must allow the execution of unsigned PowerShell scripts.
This is because we currently do not have the means to digitally sign these files.

At the end of the installation process, a registry key is added for SWLN.
Thus, on a workstation, there are two software registry keys: one for SWMB and the other for your local SWLN instance.

## Uninstallation

Since SWLN and SWMB are installed as Windows programs, they have a registry key that allows for automatic uninstallation.
To remove them from a workstation, simply go to Add or Remove Programs.

## Advanced configuration: Host files

Sometimes, a tweak or a specific setting needs to be applied to a machine.
Simply create files with the machine's `hostname` in lowercase.

During installation, these files will be placed in the correct location and will be read after the general files.
Specific tweaks are therefore always taken into account.

```
CurrentUser-Logon-Host-hostname.preset
LocalMachine-Boot-Host-hostname.preset
LocalMachine-PostInstall-Host-hostname.preset
Custom-VarOverload-Host-hostname.psm1
```

If a counter-tweak needs to be applied to this machine, the correct method is to disable the general tweak and then add its counter-tweak to the end of the preset file.
For example, in the general preset, we have the `EnableAudio` tweak.
On a specific machine, we can therefore have the preset file `LocalMachine-Boot-Host-hostname.preset` with the following two lines.
The first cancels the general tweak if it exists in the list, and the second adds it.

```
!EnableAudio
DisableAudio
```

It is even possible to push a tweak implementation that will only be used on a single machine.
This can be useful for testing or on very specific computers. 

```
Local-Addon-Host-hostname.psm1
```

The `Custom-VarAutodel-Host-hostname.psm1` settings file, which is deleted after the first load, is also supported.
Its use is even rarer.

## References

See the [REFERENCES](../../REFERENCES.md) file.
