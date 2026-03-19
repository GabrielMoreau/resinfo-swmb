# SWLN - Template to extend SWMB on your Local Network

## Context

SWLN (Local Network) is just a template to show you how to use and deploy SWMB on your network.
You can use SWMB differently from SWLN,
see for example the [Kaspersky uninstall](../uninstall-kaspersky/) project for workstations or the [SWCE](../swce) compliance enforcement project..
With SWLN, all your extensions / developments / modifications are in your project space and you can use SWMB without any modification.

SWLN allows you to create a ZIP archive containing the latest version of SWMB along with all the configuration files specific to your IT infrastructure.
The creation of this archive is automated.
Currently, SWLN is designed for use on **Linux**, as programming and automating tasks to build a package is simpler on this operating system.
However, the final package is intended for deployment on Windows wo

## Download the SWLN template

The latest version of the SWLN template is available on the [download page](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/).
However, the website still has the latest versions.

The most recent version is available under the name [SWLN-Latest](https://resinfo-gt.pages.in2p3.fr/swmb/resinfo-swmb/SWLN-Latest.zip).

## Usage

### Minimal configuration

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

### Build your own local SWLN package

With this SWLN template you can easily create your packages under GNU/Linux or MacOS.
The core in the build process is a `Makefile` which uses the `curl` program to fetch the right version of SWMB.
The `Makefile` could have been written as a Bash script,
but `make` is a good program for building objects with dependencies.

At the end of the process, a ZIP archive is created with a version number.
This version number combines the SWLN version number with the SWMB version number.

To build the archive, you'll need the following packages on your Linux system (for Debian):

```bash
apt install coreutils findutils grep sed gawk curl \
  make dos2unix readpe zip unzip \
  diffutils meld git
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

### Deploy your SWLN package

Inside the archive is a DOS file named `install.bat`.
This file runs the PowerShell installer `installer.ps1`.
This script installs only the files strictly necessary for SWMB to run on the workstation.
To function, the computer must allow the execution of unsigned PowerShell scripts.
This is because we currently do not have the means to digitally sign these files.

At the end of the installation process, a registry key is added for SWLN.
Thus, on a workstation, there are two software registry keys: one for SWMB and the other for your local SWLN instance.

### Redeploy (Update) your SWLN package

When you update your site's rules or upgrade the version of SWMB integrated into SWLN, you redeploy your package to the workstations.
The installer removes the old versions of the configuration files before installing the new ones.

Thus, if a specific file existed in a previous version — for example, `Local-Addon.psm1` — and you no longer have that module (or preset file) in your new image, that file is effectively removed from the workstation and nothing replaces it.

SWLN modifies only the files it manages and that are listed in this documentation.
If you have other files in the `Presets` and `Modules` folders within the `C:\ProgramData\SWMB` directory tree, they will neither be modified nor deleted.

### Uninstall your SWLN package

Since SWLN and SWMB are installed as Windows programs, they have a registry key that allows for automatic uninstallation.
To remove them from a workstation, simply go to Add or Remove Programs.

Please note that only files managed by SWLN will be deleted from the `Presets` and `Modules` folders in the `C:\ProgramData\SWMB` directory.
If you have other files in these folders, they will not be modified or deleted.

### Keep in sync with the SWLN reference package integrated into SWMB

It’s a good idea to keep your version of SWLN in a Git repository or similar to maintain a history of your fleet management.
However, in the meantime, it’s likely and normal for SWMB and SWLN to evolve and change.
You should therefore regularly check whether you need to resynchronize.

The `check-with-swln` script does exactly that.
It loops through all SWLN files and compares them with yours.
To make this easier, the comparison is visual and uses the `meld` tool on Linux (see the [Build](#build) section).
You can compare changes to scripts, Makefiles, presets, and more, and update your versions if needed.

To do this, however, you must have a local copy of the SWMB files (the comparison currently does not work with online files).
There are two options:

* Either let the script download the latest files from the SWMB download site to perform the comparison, and create a `SWMB-Fake` folder in the temporary `tmp` folder.
  In a terminal, within your SWLN installation directory, simply run the script `./check-with-swln`.

* Or you must clone the SWMB Git repository, then update it (pull) before running the comparison script.
  Please note that, by default, your SWLN template does not use your local copy of SWMB when creating the ZIP file.
  This local instance of SWMB is used solely for comparison purposes.

```bash
# First time - Clone SWMB
git clone https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb.git

# Regularly - Update your SWMB repository
cd ~/path-to-your-swmb-installation
git pull
```

In a terminal, within your SWLN installation directory, simply run the script:

```bash
./check-with-swln ~/path-to-your-swmb-installation
```

If you have developed interesting features that are clearly not specific to your site, consider submitting them to the SWMB community so they can be integrated into the core of the engine.
This is how the project moves forward.
It’s tested in one place, then the code is reviewed and tagged RESINFO.

### Check your package before deploying it

It’s best to verify that your code is valid before deploying it to your network of computers.
Even if you have a few test machines, performing a syntax check beforehand is helpful.
Currently, the most reliable way to do this is to load the code into Microsoft’s PowerShell interpreter.
You must therefore first install the `powershell` package on your Linux machine.
On Debian, one method is to add the Debian repository provided by Microsoft.

```bash
source /etc/os-release 
curl "https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb" --output packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt update
apt install -y powershell
```

You now have the `pwsh` command available on your Linux system.

The `check-quality` script can detect simple errors, such as syntax errors.
```bash
./check-quality 
```

## Advanced configurations

### Host files

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

### Group files

Sometimes there is a group of machines with the exact same specific situation...
It’s not very practical to duplicate the same settings N times.
SWLN automates this for you.

For example, let's create a machine group named `acquisition`.
We then have the following files:

```
Group-acquisition.txt
CurrentUser-Logon-Group-acquisition.preset
LocalMachine-Boot-Group-acquisition.preset
LocalMachine-PostInstall-Group-acquisition.preset
Custom-VarOverload-Group-acquisition.psm1
```

The file `Group-acquisition.txt` lists all the machines in the group, with each machine name written in lowercase on a separate line.
Lines beginning with `#` are ignored.

The SWLN Makefile generates `*-Host-hostname.*` files for all the machines in the group.
If a computer is in multiple groups, they are sorted alphabetically, with the first ones processed first!
If the machine also has a specific `Host` file, it is added last.

The SWLN groups also manage the two files `Local-Addon-Group-acquisition.psm1` and `Custom-VarAutodel-Group-acquisition.psm1`.
However, it is not necessarily a good idea to overcomplicate your deployment.
The purpose of SWMB is to enhance security, and a complex architecture becomes difficult to audit.

## References

See the [REFERENCES](../../REFERENCES.md) file.
