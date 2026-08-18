##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Explorer UI Tweaks
##########

################################################################

# Show full directory path in Explorer title bar
Function TweakShowExplorerTitleFullPath_CU {
	Write-Output "Showing full directory path in Explorer title bar for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 1
}

# Hide full directory path in Explorer title bar, only directory name will be shown
Function TweakHideExplorerTitleFullPath_CU {
	Write-Output "Hiding full directory path in Explorer title bar for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -ErrorAction SilentlyContinue
}

################################################################

# Show known file extensions
Function TweakShowKnownExtensions_CU {
	Write-Output "Showing known file extensions for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
}

# Hide known file extensions
Function TweakHideKnownExtensions_CU {
	Write-Output "Hiding known file extensions for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
}

# View
Function TweakViewKnownExtensions_CU { # RESINFO
	Write-Output "Viewing known file extensions for CU (0: Show, 1: Hide)..."
	Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt"
}

################################################################

# Show hidden files
Function TweakShowHiddenFiles_CU {
	Write-Output "Showing hidden files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
}

# Hide hidden files
Function TweakHideHiddenFiles_CU {
	Write-Output "Hiding hidden files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
}

################################################################

# Show protected operating system files
Function TweakShowSuperHiddenFiles_CU {
	Write-Output "Showing protected operating system files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 1
}

# Hide protected operating system files
Function TweakHideSuperHiddenFiles_CU {
	Write-Output "Hiding protected operating system files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 0
}

################################################################

# Show empty drives (with no media)
Function TweakShowEmptyDrives_CU {
	Write-Output "Showing empty drives (with no media) for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideDrivesWithNoMedia" -Type DWord -Value 0
}

# Hide empty drives (with no media)
Function TweakHideEmptyDrives_CU {
	Write-Output "Hiding empty drives (with no media) for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideDrivesWithNoMedia" -ErrorAction SilentlyContinue
}

################################################################

# Show folder merge conflicts
Function TweakShowFolderMergeConflicts_CU {
	Write-Output "Showing folder merge conflicts for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideMergeConflicts" -Type DWord -Value 0
}

# Hide folder merge conflicts
Function TweakHideFolderMergeConflicts_CU {
	Write-Output "Hiding folder merge conflicts for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideMergeConflicts" -ErrorAction SilentlyContinue
}

################################################################

# Enable Explorer navigation pane expanding to current folder
Function TweakEnableNavPaneExpand_CU {
	Write-Output "Enabling navigation pane expanding to current folder for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Type DWord -Value 1
}

# Disable Explorer navigation pane expanding to current folder
Function TweakDisableNavPaneExpand_CU {
	Write-Output "Disabling navigation pane expanding to current folder for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -ErrorAction SilentlyContinue
}

################################################################

# Show all folders in Explorer navigation pane
Function TweakShowNavPaneAllFolders_CU {
	Write-Output "Showing all folders in Explorer navigation pane for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -Type DWord -Value 1
}

# Hide all folders from Explorer navigation pane except the basic ones (Quick access, OneDrive, This PC, Network), some of which can be disabled using other tweaks
Function TweakHideNavPaneAllFolders_CU {
	Write-Output "Hiding all folders in Explorer navigation pane (except the basic ones) for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -ErrorAction SilentlyContinue
}

################################################################

# Show Libraries in Explorer navigation pane
Function TweakShowNavPaneLibraries_CU {
	Write-Output "Showing Libraries icon in Explorer namespace for CU..."
	If (!(Test-Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}")) {
		New-Item -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 1
}

# Hide Libraries from Explorer navigation pane
Function TweakHideNavPaneLibraries_CU {
	Write-Output "Hiding Libraries icon from Explorer namespace for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue
}

################################################################

# Enable launching folder windows in a separate process
Function TweakEnableFldrSeparateProcess_CU {
	Write-Output "Enabling launching folder windows in a separate process for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Type DWord -Value 1
}

# Disable launching folder windows in a separate process
Function TweakDisableFldrSeparateProcess_CU {
	Write-Output "Disabling launching folder windows in a separate process for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Type DWord -Value 0
}

################################################################

# Enable restoring previous folder windows at logon
Function TweakEnableRestoreFldrWindows_CU {
	Write-Output "Enabling restoring previous folder windows at logon for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistBrowsers" -Type DWord -Value 1
}

# Disable restoring previous folder windows at logon
Function TweakDisableRestoreFldrWindows_CU {
	Write-Output "Disabling restoring previous folder windows at logon for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistBrowsers" -ErrorAction SilentlyContinue
}

################################################################

# Show coloring of encrypted or compressed NTFS files (green for encrypted, blue for compressed)
Function TweakShowEncCompFilesColor_CU {
	Write-Output "Showing coloring of encrypted or compressed NTFS files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptCompressedColor" -Type DWord -Value 1
}

# Hide coloring of encrypted or compressed NTFS files
Function TweakHideEncCompFilesColor_CU {
	Write-Output "Hiding coloring of encrypted or compressed NTFS files for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptCompressedColor" -ErrorAction SilentlyContinue
}

################################################################

# Disable Sharing Wizard
Function TweakDisableSharingWizard_CU {
	Write-Output "Disabling Sharing Wizard for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -Type DWord -Value 0
}

# Enable Sharing Wizard
Function TweakEnableSharingWizard_CU {
	Write-Output "Enabling Sharing Wizard for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -ErrorAction SilentlyContinue
}

################################################################

# Hide item selection checkboxes
Function TweakHideSelectCheckboxes_CU {
	Write-Output "Hiding item selection checkboxes for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type DWord -Value 0
}

# Show item selection checkboxes
Function TweakShowSelectCheckboxes_CU {
	Write-Output "Showing item selection checkboxes for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type DWord -Value 1
}

################################################################

# Hide sync provider notifications
Function TweakHideSyncNotifications_CU {
	Write-Output "Hiding sync provider notifications for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
}

# Show sync provider notifications
Function TweakShowSyncNotifications_CU {
	Write-Output "Showing sync provider notifications for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 1
}

################################################################

# Hide recently and frequently used item shortcuts in Explorer
# Note: This is only UI tweak to hide the shortcuts. In order to stop creating most recently used (MRU) items lists everywhere, use privacy tweak 'DisableRecentFiles' instead.
Function TweakHideRecentShortcuts_CU {
	Write-Output "Hiding recent shortcuts in Explorer for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
}

# Show recently and frequently used item shortcuts in Explorer
Function TweakShowRecentShortcuts_CU {
	Write-Output "Showing recent shortcuts in Explorer for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -ErrorAction SilentlyContinue
}

################################################################

# Change default Explorer view to This PC
Function TweakSetExplorerThisPC_CU {
	Write-Output "Setting (changing) default Explorer view to This PC for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
}

# Change default Explorer view to Quick Access
Function TweakSetExplorerQuickAccess_CU {
	Write-Output "Setting (changing) default Explorer view to Quick Access for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
}

################################################################

# Hide Recycle Bin shortcut from desktop
Function TweakHideRecycleBinFromDesktop_CU {
	Write-Output "Hiding Recycle Bin shortcut from desktop for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
}

# Show Recycle Bin shortcut on desktop
Function TweakShowRecycleBinOnDesktop_CU {
	Write-Output "Showing Recycle Bin shortcut on desktop for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -ErrorAction SilentlyContinue
}

################################################################

# Show This PC shortcut on desktop
Function TweakShowThisPCOnDesktop_CU {
	Write-Output "Showing This PC shortcut on desktop for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
}

# Hide This PC shortcut from desktop
Function TweakHideThisPCFromDesktop_CU {
	Write-Output "Hiding This PC shortcut from desktop for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
}

################################################################

# Show User Folder shortcut on desktop
Function TweakShowUserFolderOnDesktop_CU {
	Write-Output "Showing User Folder shortcut on desktop for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
}

# Hide User Folder shortcut from desktop
Function TweakHideUserFolderFromDesktop_CU {
	Write-Output "Hiding User Folder shortcut from desktop for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
}

################################################################

# Show Control panel shortcut on desktop
Function TweakShowControlPanelOnDesktop_CU {
	Write-Output "Showing Control panel shortcut on desktop for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type DWord -Value 0
}

# Hide Control panel shortcut from desktop
Function TweakHideControlPanelFromDesktop_CU {
	Write-Output "Hiding Control panel shortcut from desktop for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -ErrorAction SilentlyContinue
}

################################################################

# Show Network shortcut on desktop
Function TweakShowNetworkOnDesktop_CU {
	Write-Output "Showing Network shortcut on desktop for CU..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" )) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"  -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" )) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Type DWord -Value 0
}

# Hide Network shortcut from desktop
Function TweakHideNetworkFromDesktop_CU {
	Write-Output "Hiding Network shortcut from desktop for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -ErrorAction SilentlyContinue
}

################################################################

# Hide all icons from desktop
Function TweakHideDesktopIcons_CU {
	Write-Output "Hiding all icons from desktop for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
}

# Show all icons on desktop
Function TweakShowDesktopIcons_CU {
	Write-Output "Showing all icons on desktop for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 0
}

################################################################

# Show Windows build number and Windows edition (Home/Pro/Enterprise) from bottom right of desktop
Function TweakShowBuildNumberOnDesktop_CU {
	Write-Output "Showing Windows build number on desktop for CU..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 1
}

# Remove Windows build number and Windows edition (Home/Pro/Enterprise) from bottom right of desktop
Function TweakHideBuildNumberFromDesktop_CU {
	Write-Output "Hiding Windows build number from desktop for CU..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 0
}

################################################################

# Disable thumbnails, show only file extension icons
Function TweakDisableThumbnails_CU {
	Write-Output "Disabling thumbnails for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 1
}

# Enable thumbnails
Function TweakEnableThumbnails_CU {
	Write-Output "Enabling thumbnails for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
}

################################################################

# Disable creation of thumbnail cache files
Function TweakDisableThumbnailCache_CU {
	Write-Output "Disabling creation of thumbnail cache files for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
}

# Enable creation of thumbnail cache files
Function TweakEnableThumbnailCache_CU {
	Write-Output "Enabling creation of thumbnail cache files for CU..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -ErrorAction SilentlyContinue
}

################################################################

# Disable creation of Thumbs.db thumbnail cache files on network folders
Function TweakDisableThumbsDBOnNetwork_CU {
	Write-Output "Disabling creation of Thumbs.db on network folders for CU..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1
}

# Enable creation of Thumbs.db thumbnail cache files on network folders
Function TweakEnableThumbsDBOnNetwork_CU {
	Write-Output "Enabling creation of Thumbs.db on network folder for CUs..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -ErrorAction SilentlyContinue
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
