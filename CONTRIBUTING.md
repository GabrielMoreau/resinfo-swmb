# Contributing to SWMB

## Contents

* [Maintaining own forks](#maintaining-own-forks)
* [Contribution guidelines](#contribution-guidelines)
* [Windows builds overview](#windows-builds-overview)


## Maintaining own Git forks

### Retrieve the SWMB project repository

It is preferable to use SSH keys rather than HTTPS.
However, you must not forget to put a passphrase to protect your private key.
Then, we use the SSH agent to avoid having to put the passphrase every time
(be careful not to transmit your private keys to a remote SSH agent
agent if you are not sure of this remote server!)

```bash
# Creation of the key
ssh-keygen  -t rsa -b 409 # passphrase

# Add the key in the SSH agent
ssh-add ~/.ssh/id_rsa
```

Then we get the SWMB repository.
Note: the SWMB repository is public,
so it is possible to retrieve the source code at any time without SSH key,
the account and the SSH key are only useful and necessary for contributions.

```bash
git clone git@gitlab.in2p3.fr:resinfo-gt/swmb.git
cd swmb
```

### Synchronization with the upstream project

The upstream project has been stopped for the moment.
It has been archived.
However, its activity may resume one day...
More probably, you will be asked to do a project yourself,
for which SWMB is the upstream project.
The following is for you if you find yourself in this context.

You have to add the link with the upstream subtree `Win10-Initial-Setup-Script`
in order to manage the updates.
The `--squash` option allows to get all the patches of the upstream project
project in the form of a single commit.
So we don't import the whole history in our project.

The `subtree pull` command allows to do a `fetch` and a `merge` in one step.

Before doing this, it is better to think about pushing (`push`)
all your patches into the main tree.

```bash
git remote add -f Win10-Initial https://github.com/Disassembler0/Win10-Initial-Setup-Script.git
git subtree add --prefix Win10-Initial-Setup-Script/ Win10-Initial master --squash

#git subtree pull --prefix Win10-Initial-Setup-Script/ Win10-Initial master --squash
git subtree pull --prefix Win10-Initial-Setup-Script/ https://github.com/Disassembler0/Win10-Initial-Setup-Script.git master --squash
```

Make a difference in a terminal or in graphics
to see what is new in the upstream project.
In the following commands,
on the left is the state of the current project,
on the right is the state of the upstream project.

```bash
git diff origin/master...HEAD
git difftool origin/master...HEAD
git status
```

There are two cases:
validate or cancel the upstream development for this time,
because one day it will have to be done...

#### Validate the upstream development

```bash
git push
```

#### Cancel the upstream development if it is not ready for the moment

However, it will be necessary to update to keep the synchronization operational as much as possible.

```bash
git reset HEAD~1
git checkout -- Win10-Initial-Setup-Script/
```

### Global step for fork

The easiest way to customize the script settings it is to create your own preset and,
if needed, your own tweak scripts as described above.
For easy start, you can base the modifications on the *Default.cmd* and *Default.preset* and maintain just that.
If you choose to fork the script anyway, you don't need to comment or remove the actual functions in *Win10.psm1*,
because if they are not called, they are not used.

If you wish to make more elaborate modifications of the basic script and incorporate some personal tweaks or adjustments,
then I suggest doing it in a following way:

1. Fork the repository on GitHub (obviously).
2. Clone your fork on your computer.

    ```
    git clone https://github.com/<yournamehere>/Win10-Initial-Setup-Script
    cd Win10-Initial-Setup-Script
    ```

3. Add the original repository as a remote (*upstream*).

    ```
    git remote add upstream https://github.com/Disassembler0/Win10-Initial-Setup-Script
    ```

4. Commit your modifications as you see fit.
5. Once there are new additions in the upstream, create a temporary branch,
   fetch the changes and reset the branch to be identical with this repository.

    ```
    git branch upstream
    git checkout upstream
    git fetch upstream
    git reset --hard upstream/master
    ```

6. When you have the upstream branch up to date, check back your master and rebase it based on the upstream branch.
   If there are some conflicts between the changesets, you'll be asked to resolve them manually.

    ```
    git checkout master
    git rebase upstream
    ```

7. Eventually, delete the upstream branch and force push your changes back onto GitHub.

    ```
    git branch -D upstream
    git push -f master
    ```

**Word of warning:** Rebasing and force-pushing will change the history of your commits.
The upside is that your adjustments will always stay on top of the commit history.
The downside is that everybody remote-tracking your repository will always have to rebase and force-push too,
otherwise their commit history will not match yours.


### Advanced features

#### Reverse the order of the commits

It is only possible to push or cancel commits in the order
in which they were made.
If this order does not suit you,
it is possible to change it.

```bash
git rebase -i
```

#### Push all but the last commit

If you had a commit that had not been pushed,
or if you make a commit afterwards (and rebase to reorder them),
it is possible to push all but the last commit.

```bash
git push origin HEAD~1:master
```

Obviously, by putting 2 instead of 1,
pushes all the commits except the last two!


## Contribution guidelines

Following is a list of rules which I'm trying to apply in this project.
The rules are not binding and I accept pull requests even if they don't adhere to them, as long as their purpose and content are clear.
In cases when there are too many rule violations, I might simply redo the whole functionality and reject the PR while still crediting you.
If you'd like to make my work easier, please consider adhering to the following rules too.

### Function naming

Try to give a function a meaningful name up to 25 characters long, which gives away the purpose of the function.
Use verbs like `Enable`/`Disable`, `Show`/`Hide`, `Install`/`Uninstall`, `Add`/`Remove` in the beginning of the function name.
In case the function doesn't fit any of these verbs, come up with another name,
beginning with the verb `Set`, which indicates what the function does, e.g. `SetCurrentNetworkPrivate` and `SetCurrentNetworkPublic`.
System functions begin with `Sys`, they are all defined in the core module `SWMB.psm1`. For example, `SysMessage`, `SysRestart`...

### Context of the current user or the local machine

Functions can be applied on the local machine under the administrator (or SYSTEM) account or under the current user.
Functions that can be applied by the current user have the postfix `_CU` in their names.

### Revert functions

Always add a function with opposite name (or equivalent) which reverts the behavior to default.
The default is considered freshly installed Windows 10 or Windows Server 2016 / 2019 with no adjustments made during or after the installation.
If you don't have access to either of these, create the revert function to the best of your knowledge and I will fill in the rest if necessary.

### View functions

It is useful for debugging to add a `View` function that allows you to quickly see what has changed between the Enable and Disable functions.
For example `ViewCurrentNetwork`.

### Function similarities

Check if there isn't already a function with similar purpose as the one you're trying to add.
As long as the name and objective of the existing function is unchanged, feel free to add your tweak to that function rather than creating a new one.

### Function grouping

Try to group functions thematically.
There are already several major groups (privacy, security, services etc.), but even within these, some tweaks may be related to each other.
In such case, add a new tweak below the existing one and not to the end of the whole group.

Group functions concerning the current machine under module names prefixed with `LocalMachine-`.
Modules of functions for the current user will be prefixed with `CurrentUser-`.

### Default preset

Always add a reference to the tweak and its revert function in the *Default.preset*.
Add references to both functions on the same line (mind the spaces) and always comment out the revert function.
Whether to comment out also the tweak in the default preset is a matter of personal preference.
The rule of thumb is that if the tweak makes the system faster, smoother, more secure and less obtrusive, it should be enabled by default.
Usability has preference over performance (that's why e.g. indexing is kept enabled).

### Repeatability

Unless applied on unsupported system, all functions have to be applicable repeatedly without any errors.
When you're creating a registry key, always check first if the key doesn't happen to already exist.
When you're deleting registry value, always append `-ErrorAction SilentlyContinue` to prevent errors while deleting already deleted values.

### Input / output hiding

Suppress all output generated by commands and cmdlets using `| Out-Null` or `-ErrorAction SilentlyContinue` where applicable.
Whenever an input is needed, use appropriate arguments to suppress the prompt and programmatically provide values for the command to run
(e.g. using `-Confirm:$False`).
The only acceptable output is from the `Write-Output` cmdlets in the beginning of each function and from non-suppressible cmdlets like `Remove-AppxPackage`.

### Registry

Create the registry keys only if they don't exist on fresh installation if Windows 10 or Windows Server 2016 / 2019.
When deleting registry, delete only registry values, not the whole keys.
When you're setting registry values, always use `Set-ItemProperty` instead of `New-ItemProperty`.
When you're removing registry values, choose either `Set-ItemProperty` or `Remove-ItemProperty` to reinstate the same situation
as it was on the clean installation.
Again, if you don't know what the original state was, let me know in PR description and I will fill in the gaps.
When you need to use `HKEY_USERS` registry hive, always add following snippet before the registry modification to ensure portability.

```powershell
If (!(Test-Path "HKU:")) {
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
}
```

### Force usage

Star Wars jokes aside, don't use `-Force` option unless absolutely necessary.
The only permitted case is when you're creating a new registry key (not a value) and you need to ensure that all parent keys will be created as well.
In such case always check first if the key doesn't already exist, otherwise you will delete all its existing values.

### Comments

Always add a simple comment above the function briefly describing what the function does,
especially if it has an ambiguous name or if there is some logic hidden under the hood.
If you know that the tweak doesn't work on some editions of Windows 10 or on Windows Server, state it in the comment too.
Add a `Write-Output` cmdlet with the short description of action also to the first line of the function body,
so the user can see what is being executed and which function is the problematic one whenever an error occurs.
The comment is written in present simple tense, the `Write-Output` in present continuous with ellipsis (resp. three dots) at the end.

### Coding style

Indent using tabs, enclose all string values in double quotes (`"`) and strictly use `PascalCase` wherever possible.
Put opening curly bracket on the same line as the function name or condition, but leave the closing bracket on a separate line for readability.

### Examples

**Naming example**: Consider function `EnableFastMenu`.
What does it do? Which menu? How fast is *fast*?
A better name might be `EnableFastMenuFlyout`, so it's a bit clearer that we're talking about the menu flyouts delays.
But the counterpart function would be `DisableFastMenuFlyouts` which is not entirely true.
We're not *disabling* anything, we're just making it slow again. So even better might be to name them `SetFastMenuFlyouts` and `SetSlowMenuFlyouts`.
Or better yet, just add the functionality to already existing `SetVisualFXPerformance`/`SetVisualFXAppearance`.
Even though the names are not 100% match, they aim to tweak similar aspects and operate within the same registry keys.

**Coding example:** The following code applies most of the rules mentioned above (naming, output hiding, repeatability, force usage, comments and coding style).

```powershell
# Enable some feature
Function TweakEnableSomeFeature {
	Write-Output "Enabling some feature..."
	If (!(Test-Path "HKLM:\Some\Registry\Key")) {
		New-Item -Path "HKLM:\Some\Registry\Key" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Some\Registry\Key" -Name "SomeValueName" -Type String -Value "SomeValue"
}

# Disable some feature
Function TweakDisableSomeFeature {
	Write-Output "Disabling some feature..."
	Remove-ItemProperty -Path "HKLM:\Some\Registry\Key" -Name "SomeValueName" -ErrorAction SilentlyContinue
}
```


## Tools and ancillary data

If you'd like to contribute, the tools and/or values provided below may help.


### Windows builds overview

* See [Windows 11 version history](https://en.wikipedia.org/wiki/Windows_11_version_history)

  See also release information (last UBR) - https://learn.microsoft.com/fr-fr/windows/release-health/windows11-release-information

  | Version |        Code name        |      Release date      | Build |
  | :-----: | ----------------------- | ---------------------- | :---: |
  |  21H2   | Sun Valley              | October 4, 2021        | 22000 |
  |  22H2   | Sun Valley 2            | September 20, 2022     | 22621 |
  |  23H2   | Sun Valley 3            | October 31, 2023       | 22631 |
  |  24H2   | Hudson Valley           | October 1, 2024        | 26100 |
  |  25H2   | Hudson Valley 2         | September 30, 2025     | 26200 |

* See [Windows 10 version history](https://en.wikipedia.org/wiki/Windows_10_version_history)

  See also release information (last UBR) - https://learn.microsoft.com/fr-fr/windows/release-health/release-information

  | Version |        Code name        |     Marketing name     | Build |
  | :-----: | ----------------------- | ---------------------- | :---: |
  |  1507   | Threshold 1 (TH1 / RTM) | N/A                    | 10240 |
  |  1511   | Threshold 2 (TH2)       | November Update        | 10586 |
  |  1607   | Redstone 1 (RS1)        | Anniversary Update     | 14393 |
  |  1703   | Redstone 2 (RS2)        | Creators Update        | 15063 |
  |  1709   | Redstone 3 (RS3)        | Fall Creators Update   | 16299 |
  |  1803   | Redstone 4 (RS4)        | April 2018 Update      | 17134 |
  |  1809   | Redstone 5 (RS5)        | October 2018 Update    | 17763 |
  |  1903   | 19H1                    | May 2019 Update        | 18362 |
  |  1909   | 19H2                    | November 2019 Update   | 18363 |
  |  2004   | 20H1                    | May 2020 Update        | 19041 |
  |  20H2   | 20H2                    | October 2020 Update    | 19042 |
  |  21H1   | 21H1                    | May 2021 Update        | 19043 |
  |  21H2   | 21H2                    | November 2021 Update   | 19044 |
  |  22H2   | 22H2                    | 2022 Update            | 19045 |


### MSC Windows 10 and 11 Consoles

Here's a list of Windows administration consoles.
It has been taken from the ITECHTICS website https://www.itechtics.com/msc-files/.
These consoles can help you better manage your workstations and improve their security.

 | MSC File | Console Name | Details |
 | :------- | :----------- | :------ |
 | `azman.msc` | Authorization Manager | Manage Authorization Stores |
 | `certlm.msc` | Certificates Local Computer | Loads the list of certificates of the local computer |
 | `certmgr.msc` | Certificates | Loads the list of certificates of the user |
 | `comexp.msc` | Component Services | Loads Component Services, Event Viewer, and Services |
 | `compmgmt.msc` | Computer Management | Includes System Tools (Task Scheduler, Event Viewer, Shared Folders, Local Users and Groups, Performance and Device Manager), Storage (Disk Management), and Services and Applications (Services and WMI Control) |
 | `devmgmt.msc` | Device Manager | Opens the Device Manager to manage hardware and devices |
 | `devmoderunasuserconfig.msc` |  | To manage the Start Menu, Taskbar, and Notification settings |
 | `diskmgmt.msc` | Disk Management | Opens Disk Management to administrate connected storage devices |
 | `eventvwr.msc` | Event Viewer | Opens the Event Viewer which displays the operating system, software, and hardware events |
 | `fsmgmt.msc` | Shared Folders | Loads the list of shared folders, sessions, and open files |
 | `gpedit.msc` | Group Policy Editor | Loads Group Policy Editor to manage system policies |
 | `lusrmgr.msc` | Local Users and Groups | Interface to manage local users and user groups |
 | `perfmon.msc` | Performance Monitor | Loads Windows Performance Monitor |
 | `printmanagement.msc` | Print Management | Manage printers |
 | `rsop.msc` | Resultant Set of Policies | List policies, full results only available through command-line tool gpresult |
 | `secpol.msc` | Local Security Policy | Loads policies such as account policies, public key policies, or advanced audit policy configuration |
 | `services.msc` | Services Manager | Loads the list of installed services to manage them. |
 | `taskschd.msc` | Task Scheduler | Loads the Task Scheduler to manage tasks |
 | `tpm.msc` | Trusted Platform Module Management | Manage the TPM on the local device. |
 | `wf.msc` | Windows Firewall | Starts Windows Firewall with Advanced Security |
 | `wmimgmt.msc` | WMI Management | Configure and Control the Windows Management Instrumentation Service |


### Sysinternals and admx

The `procmon` (`procmon64`) software is a utility developed by Sysinternals.
It can be used, for example, to trace changes in the registry when a program is used.
This makes it possible to detect or validate registry keys that are important for workstation security.

The [admx](https://admx.help/) website has integrated most Windows GPOs into its database.
It can be searched.
It can be used to find most of the registry keys handled by SWMB and GPOs.It's a good place to start contributing.

These tools are complementary to full-scale testing to fully validate new tweaks in SWMB, before release.
