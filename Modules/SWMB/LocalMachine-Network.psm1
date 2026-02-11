##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz>
# Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
##########

##########
#region Network Tweaks
##########

################################################################

# Set current network profile to private (allow file sharing, device discovery, etc.)
Function TweakSetCurrentNetworkPrivate {
	Write-Output "Setting current network profile to private..."
	Set-NetConnectionProfile -NetworkCategory Private
}

# Set current network profile to public (deny file sharing, device discovery, etc.)
Function TweakSetCurrentNetworkPublic {
	Write-Output "Setting current network profile to public..."
	Set-NetConnectionProfile -NetworkCategory Public
}

################################################################

# Set unknown networks profile to private (allow file sharing, device discovery, etc.)
Function TweakSetUnknownNetworksPrivate {
	Write-Output "Setting unknown networks profile to private..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1
}

# Set unknown networks profile to public (deny file sharing, device discovery, etc.)
Function TweakSetUnknownNetworksPublic {
	Write-Output "Setting unknown networks profile to public..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -ErrorAction SilentlyContinue
}

################################################################

# Disable automatic installation of network devices
Function TweakDisableNetDevicesAutoInst {
	Write-Output "Disabling automatic installation of network devices..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0
}

# Enable automatic installation of network devices
Function TweakEnableNetDevicesAutoInst {
	Write-Output "Enabling automatic installation of network devices..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -ErrorAction SilentlyContinue
}

################################################################

# Stop and disable Home Groups services - Not applicable since 1803. Not applicable to Server
Function TweakDisableHomeGroups {
	Write-Output "Disabling and stopping Home Groups services..."
	If (Get-Service "HomeGroupListener" -ErrorAction SilentlyContinue) {
		Stop-Service "HomeGroupListener" -WarningAction SilentlyContinue
		Set-Service "HomeGroupListener" -StartupType Disabled
	}
	If (Get-Service "HomeGroupProvider" -ErrorAction SilentlyContinue) {
		Stop-Service "HomeGroupProvider" -WarningAction SilentlyContinue
		Set-Service "HomeGroupProvider" -StartupType Disabled
	}
}

# Enable and start Home Groups services - Not applicable since 1803. Not applicable to Server
Function TweakEnableHomeGroups {
	Write-Output "Enabling and starting Home Groups services..."
	Set-Service "HomeGroupListener" -StartupType Manual
	Set-Service "HomeGroupProvider" -StartupType Manual
	Start-Service "HomeGroupProvider" -WarningAction SilentlyContinue
}

################################################################

# Disable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function TweakDisableSMB1Protocol { # RESINFO
	Write-Output "Disabling SMB 1.0 protocol..."
	Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Norestart
}

# Enable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function TweakEnableSMB1Protocol { # RESINFO
	Write-Output "Enabling SMB 1.0 protocol..."
	Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Norestart
	If ((Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -match 'SMB1' -And $_.State -eq 'Enabled'} | Measure-Object).Count -lt 4) {
		# Under some Windows 11, need to restart sometime
		Write-Output " Warning: Not all SMB 1.0 features are enabled. Stop and start the SMB feature."
		Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Norestart
		Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Norestart
		}
}

Function TweakViewSMB1Protocol { # RESINFO
	Write-Output "Viewing SMB 1.0 protocol..."
	Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -match 'SMB1'}
}

################################################################

# Change name by Resinfo
# Disable obsolete SMB 1.0 protocol on server - Disabled by default since 1709
Function TweakDisableSMB1Server {
	Write-Output "Disabling SMB 1.0 protocol on server..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force
}

# Enable obsolete SMB 1.0 protocol on server - Disabled by default since 1709
Function TweakEnableSMB1Server {
	Write-Output "Enabling SMB 1.0 protocol on server..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $True -Force
}

################################################################

# Disable SMB Server - Completely disables file and printer sharing, but leaves the system able to connect to another SMB server as a client
# Note: Do not run this if you plan to use Docker and Shared Drives (as it uses SMB internally), see https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/216
Function TweakDisableSMBServer {
	Write-Output "Disabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force
	Set-SmbServerConfiguration -EnableSMB2Protocol $False -Force
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_server"
}

# Enable SMB Server
Function TweakEnableSMBServer {
	Write-Output "Enabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB2Protocol $True -Force
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_server"
}

################################################################

# Disable NetBIOS over TCP/IP on all currently installed network interfaces
Function TweakDisableNetBIOS {
	Write-Output "Disabling NetBIOS over TCP/IP..."
	Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*" -Name "NetbiosOptions" -Type DWord -Value 2
}

# Enable NetBIOS over TCP/IP on all currently installed network interfaces
Function TweakEnableNetBIOS {
	Write-Output "Enabling NetBIOS over TCP/IP..."
	Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*" -Name "NetbiosOptions" -Type DWord -Value 0
}

################################################################

# Disable Link-Local Multicast Name Resolution (LLMNR) protocol
Function TweakDisableLLMNR {
	Write-Output "Disabling Link-Local Multicast Name Resolution (LLMNR)..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Type DWord -Value 0
}

# Enable Link-Local Multicast Name Resolution (LLMNR) protocol
Function TweakEnableLLMNR {
	Write-Output "Enabling Link-Local Multicast Name Resolution (LLMNR)..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
}

################################################################

# Disable Local-Link Discovery Protocol (LLDP) for all installed network interfaces
Function TweakDisableLLDP {
	Write-Output "Disabling Local-Link Discovery Protocol (LLDP)..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_lldp"
}

# Enable Local-Link Discovery Protocol (LLDP) for all installed network interfaces
Function TweakEnableLLDP {
	Write-Output "Enabling Local-Link Discovery Protocol (LLDP)..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_lldp"
}

################################################################

# Disable Local-Link Topology Discovery (LLTD) for all installed network interfaces
Function TweakDisableLLTD {
	Write-Output "Disabling Local-Link Topology Discovery (LLTD)..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_lltdio"
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_rspndr"
}

# Enable Local-Link Topology Discovery (LLTD) for all installed network interfaces
Function TweakEnableLLTD {
	Write-Output "Enabling Local-Link Topology Discovery (LLTD)..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_lltdio"
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_rspndr"
}

################################################################

# Disable Client for Microsoft Networks for all installed network interfaces
Function TweakDisableMSNetClient {
	Write-Output "Disabling Client for Microsoft Networks..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_msclient"
}

# Enable Client for Microsoft Networks for all installed network interfaces
Function TweakEnableMSNetClient {
	Write-Output "Enabling Client for Microsoft Networks..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_msclient"
}

################################################################

# Disable Quality of Service (QoS) packet scheduler for all installed network interfaces
Function TweakDisableQoS {
	Write-Output "Disabling Quality of Service (QoS) packet scheduler..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_pacer"
}

# Enable Quality of Service (QoS) packet scheduler for all installed network interfaces
Function TweakEnableQoS {
	Write-Output "Enabling Quality of Service (QoS) packet scheduler..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_pacer"
}

################################################################

# Disable IPv4 stack for all installed network interfaces
Function TweakDisableIPv4 {
	Write-Output "Disabling IPv4 stack..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip"
}

# Enable IPv4 stack for all installed network interfaces
Function TweakEnableIPv4 {
	Write-Output "Enabling IPv4 stack..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip"
}

################################################################

# Disable IPv6 stack for all installed network interfaces
Function TweakDisableIPv6 {
	Write-Output "Disabling IPv6 stack..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip6"
}

# Enable IPv6 stack for all installed network interfaces
Function TweakEnableIPv6 {
	Write-Output "Enabling IPv6 stack..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip6"
}

################################################################

# Disable Network Connectivity Status Indicator active test
# Note: This may reduce the ability of OS and other components to determine internet access, however protects against a specific type of zero-click attack.
# See https://github.com/Disassembler0/Win10-Initial-Setup-Script/pull/111 for details
Function TweakDisableNCSIProbe {
	Write-Output "Disabling Network Connectivity Status Indicator (NCSI) active test..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Name "NoActiveProbe" -Type DWord -Value 1
}

# Enable Network Connectivity Status Indicator active test
Function TweakEnableNCSIProbe {
	Write-Output "Enabling Network Connectivity Status Indicator (NCSI) active test..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Name "NoActiveProbe" -ErrorAction SilentlyContinue
}

################################################################

# Disable Internet Connection Sharing (e.g. mobile hotspot)
Function TweakDisableConnectionSharing {
	Write-Output "Disabling Internet Connection Sharing..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" -Name "NC_ShowSharedAccessUI" -Type DWord -Value 0
}

# Enable Internet Connection Sharing (e.g. mobile hotspot)
Function TweakEnableConnectionSharing {
	Write-Output "Enabling Internet Connection Sharing..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" -Name "NC_ShowSharedAccessUI" -ErrorAction SilentlyContinue
}

################################################################

# Disable Anonymous access to Named Pipes and Shares
# STIG V-253456 (Window 11)
# https://system32.eventsentry.com/stig/search?query=RestrictNullSessAccessValue

# Disable
Function TweakDisableAnonymousShareAccess { # RESINFO
	Write-Output "Disabling Anonymous access to Named Pipes and Shares..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters'
	Set-ItemProperty -Path $RegPath -Name "RestrictNullSessAccessValue" -Type DWord -Value 1
}

# Enable
Function TweakEnableAnonymousShareAccess { # RESINFO
	Write-Output "Enabling Anonymous access to Named Pipes and Shares..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters'
	Remove-ItemProperty -Path $RegPath -Name "RestrictNullSessAccessValue" -ErrorAction SilentlyContinue
}

# View
Function TweakViewAnonymousShareAccess { # RESINFO
	Write-Output "Viewing Anonymous access to Named Pipes and Shares (0 or not exist: Enable (Default), 1: Disable (Recommanded))..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters'
	$RegFields = @{
		RestrictNullSessAccessValue = @{
			OkValues = @(1, $Null)   # 1 or not exist
			Description = "Disable anonymous access to Named Pipes and Shares"
			Remediation = "DisableAnonymousShareAccess"
		}
	}
	SWMB_GetRegistrySettings -Path $RegPath -Rules $RegFields | SWMB_WriteSettings
	}

################################################################

# Disable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function TweakDisableRemoteAssistance {
	Write-Output "Disabling Remote Assistance..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "App.Support.QuickAssist*" } | Remove-WindowsCapability -Online | Out-Null
}

# Enable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function TweakEnableRemoteAssistance {
	Write-Output "Enabling Remote Assistance..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "App.Support.QuickAssist*" } | Add-WindowsCapability -Online | Out-Null
}

################################################################

# Enable Remote Desktop
Function TweakEnableRemoteDesktop {
	Write-Output "Enabling Remote Desktop..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
	Enable-NetFirewallRule -Name "RemoteDesktop*"
}

# Disable Remote Desktop
Function TweakDisableRemoteDesktop {
	Write-Output "Disabling Remote Desktop..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
	Disable-NetFirewallRule -Name "RemoteDesktop*"
}

# View
Function TweakViewRemoteDesktop { # RESINFO
	Write-Output "Viewing Remote Desktop (0: Enable (Default), 1: Disable (Recommanded))..."
	$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
	$RegFields = @{
		fDenyTSConnections = @{
			OkValues = @(1)
			Description = "Disable Remote Desktop"
			Remediation = "DisableRemoteDesktop"
		}
	}
	SWMB_GetRegistrySettings -Path $RegPath -Rules $RegFields | SWMB_WriteSettings
}

################################################################

# https://www.it-connect.fr/chapitres/gerer-le-pare-feu-en-powershell/
# https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/change-listening-port
# Get-NetFirewallProfile | ft Name,Enabled

# View
Function TweakViewRemoteDesktopPort { # RESINFO
	Write-Output "Viewing RemoteDesktop Port..."
	$RDPActualPort = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").PortNumber
	Write-Output " RDP Port fix to $RDPActualPort"
	Get-NetFirewallRule | Where-Object { $_.DisplayName -match 'SWMB-RDP' -or $_.Description -match 'RDP.*3389' }  | Select DisplayName, Enabled, Profile, Description
	Get-Service -Name "TermService" | Select Status, Name, DisplayName
}

# Set
Function TweakSetRemoteDesktopPort { # RESINFO
	Write-Output "Setting RemoteDesktop Port..."
	$RDPActualPort = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").PortNumber
	$RDPNewPort = $RDPActualPort
	If ($($Global:SWMB_Custom.RemoteDesktop_PortNumber) -gt 0) {
		$RDPNewPort = $($Global:SWMB_Custom.RemoteDesktop_PortNumber)
	}

	If ($RDPNewPort -ne $RDPActualPort) {
		# Set Port
		Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value $RDPNewPort

		# Firewall on $RDPNewPort and 3389
		Get-NetFirewallRule -DisplayName 'SWMB-RDP-*-IN' | ForEach-Object { Remove-NetFirewallRule -Name $_.Name }
		New-NetFirewallRule -DisplayName 'SWMB-RDP-TCP-IN' -Profile 'Any' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $RDPNewPort
		New-NetFirewallRule -DisplayName 'SWMB-RDP-UDP-IN' -Profile 'Any' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $RDPNewPort
		Get-NetFirewallRule | Where-Object { $_.Description -match '[TCP|UDP]\s3389\S' } | ForEach-Object { Set-NetFirewallRule -Name $_.Name -Enabled False }

		# Restart service
		Get-Service -Name 'TermService' | Where-Object {$_.Status -eq 'Running'} | Restart-Service -Force
	}
}

# Unset
Function TweakUnsetRemoteDesktopPort { # RESINFO
	Write-Output "Unsetting RemoteDesktop Port (return to 3389)..."

	$RDPNewPort = 3389

	$RDPActualPort = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").PortNumber
	If ($RDPNewPort -ne $RDPActualPort) {
		# Set Port
		Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value $RDPNewPort

		# Firewall on $RDPNewPort and 3389
		Get-NetFirewallRule | Where-Object { $_.Description -match '[TCP|UDP]\s3389\S' } | ForEach-Object { Set-NetFirewallRule -Name $_.Name -Enabled True }
		Get-NetFirewallRule -DisplayName 'SWMB-RDP-*-IN' | ForEach-Object { Remove-NetFirewallRule -Name $_.Name }

		# Restart service
		Get-Service -Name 'TermService' | Where-Object {$_.Status -eq 'Running'} | Restart-Service -Force
	}
}

################################################################

# Set the priority of all interce 1Gbps with the global parameter $Global:SWMB_Custom.InterfaceMetricOn10Gbps
# For example : $Global:SWMB_Custom.InterfaceMetricOn1Gbps = 100
# Unset push default AutomaticMetric

# View
Function TweakViewInterfaceMetricOn1Gbps { # RESINFO
	Write-Output "Viewing Interface Metric on 1Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "1 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex
	}
}

# Set
Function TweakSetInterfaceMetricOn1Gbps { # RESINFO
	Write-Output "Setting Interface Metric on 1Gbps interface..."

	$InterfaceMetric = 0
	If ($($Global:SWMB_Custom.InterfaceMetricOn1Gbps) -gt 0) {
		$InterfaceMetric = $($Global:SWMB_Custom.InterfaceMetricOn1Gbps)
	}
	If ($InterfaceMetric -gt 0) {
		Get-NetAdapter | where { $_.LinkSpeed -eq "1 Gbps" } | Select InterfaceIndex | ForEach-Object {
			Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -InterfaceMetric $InterfaceMetric
		}
	}
}

# Unset
Function TweakUnsetInterfaceMetricOn1Gbps { # RESINFO
	Write-Output "Unsetting Interface Metric on 1Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "1 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -AutomaticMetric Enabled
	}
}

################################################################

# Set the priority of all interce 10Gbps with the global parameter $Global:SWMB_Custom.InterfaceMetricOn10Gbps
# For example : $Global:SWMB_Custom.InterfaceMetricOn10Gbps = 100
# Unset push default AutomaticMetric

# View
Function TweakViewInterfaceMetricOn10Gbps { # RESINFO
	Write-Output "Viewing Interface Metric on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex
	}
}

# Set
Function TweakSetInterfaceMetricOn10Gbps { # RESINFO
	Write-Output "Setting Interface Metric on 10Gbps interface..."

	$InterfaceMetric = 0
	If ($($Global:SWMB_Custom.InterfaceMetricOn10Gbps) -gt 0) {
		$InterfaceMetric = $($Global:SWMB_Custom.InterfaceMetricOn10Gbps)
	}
	If ($InterfaceMetric -gt 0) {
		Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
			Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -InterfaceMetric $InterfaceMetric
		}
	}
}

# Unset
Function TweakUnsetInterfaceMetricOn10Gbps { # RESINFO
	Write-Output "Unsetting Interface Metric on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -AutomaticMetric Enabled
	}
}

################################################################

# Enable JumboFrame (9000) on all 10Gbps network interface
# Disable will push Ethernet frame of size 1500.

# View
Function TweakViewJumboFrameOn10Gbps { # RESINFO
	Write-Output "Viewing Jumbo Frame on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex | Select ifIndex, InterfaceAlias,AddressFamily, NlMtu
	}
}

# Enable
Function TweakEnableJumboFrameOn10Gbps { # RESINFO
	Write-Output "Enabling Jumbo Frame on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -NlMtuBytes 9000
	}
}

# Disable
Function TweakDisableJumboFrameOn10Gbps { # RESINFO
	Write-Output "Disabling Jumbo Frame on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select InterfaceIndex | ForEach-Object {
		Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -NlMtuBytes 1500
	}
}

################################################################

# Enable or Disable LSO (Large Send Offload v2) on all 10Gbps network interface
# Default is enable
# Sometimes disable is faster!
# Message on the ASR mailing list on 2024/02/22 at 10:15
# Test before deploy!

# View
Function TweakViewLSOon10Gbps { # RESINFO
	Write-Output "Viewing LSO Status (Large Send Offload v2) on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select Name | ForEach-Object {
		Get-NetAdapterLso -Name $_.Name -ErrorAction SilentlyContinue
	}
}

# Enable
Function TweakEnableLSOon10Gbps { # RESINFO
	Write-Output "Enabling LSO (Large Send Offload v2) on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select Name | ForEach-Object {
		Enable-NetAdapterLso -Name $_.Name -ErrorAction SilentlyContinue
	}
}

# Disable
Function TweakDisableLSOon10Gbps { # RESINFO
	Write-Output "Disabling LSO (Large Send Offload v2) on 10Gbps interface..."
	Get-NetAdapter | where { $_.LinkSpeed -eq "10 Gbps" } | Select Name | ForEach-Object {
		Disable-NetAdapterLso -Name $_.Name -ErrorAction SilentlyContinue
	}
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
