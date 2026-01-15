################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2025, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
# Authors:
#  2020 - Olivier de Marchi (Grenoble INP / LEGI)
#  2020 - David Gras (CNRS / DR11)
#  2020 - Clément Deiber (CNRS / DR11)
#  2020 - Gabriel Moreau (CNRS / LEGI)
################################################################

################################################################

# 2021/07/05
# https://www.cert.ssi.gouv.fr/alerte/CERTFR-2021-ALE-013/
# CVE-2021-34527 exploit to keep your Print Servers running while a patch is not available
# Disable
Function TweakDisablePrintForSystem { # RESINFO
	Write-Output "Disabling print for System user (CVE-2021-34527)..."
	$acl = Get-Acl -Path "${Env:SystemRoot}\System32\spool\drivers"
	$ruleOrg1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$ruleOrg2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')
	$ruleNew1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Modify',      'ContainerInherit,ObjectInherit', 'None',        'Deny')
	$ruleNew2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Read',        'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$acl.RemoveAccessRule($ruleOrg1)
	$acl.RemoveAccessRule($ruleOrg2)
	$acl.AddAccessRule($ruleNew1)
	$acl.AddAccessRule($ruleNew2)
	$acl | Set-Acl -Path "${Env:SystemRoot}\System32\spool\drivers"
}

# Enable
Function TweakEnablePrintForSystem { # RESINFO
	Write-Output "Enabling print for System user (CVE-2021-34527)..."
	$acl = Get-Acl -Path "${Env:SystemRoot}\System32\spool\drivers"
	$ruleOrg1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$ruleOrg2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')
	$ruleNew1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Modify',      'ContainerInherit,ObjectInherit', 'None',        'Deny')
	$ruleNew2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Read',        'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$acl.RemoveAccessRule($ruleNew1)
	$acl.RemoveAccessRule($ruleNew2)
	$acl.AddAccessRule($ruleOrg1)
	$acl.AddAccessRule($ruleOrg2)
	$acl | Set-Acl -Path "${Env:SystemRoot}\System32\spool\drivers"
}

# View
Function TweakViewPrintForSystem { # RESINFO
	Write-Output "Viewing print for System user (CVE-2021-34527)..."
	Get-Acl -Path "${Env:SystemRoot}\System32\spool\drivers" | Select -Expand Access | Out-GridView
}

################################################################

# 2021/09/10
# http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-40444
# https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-40444
# Microsoft MSHTML Remote Code Execution Vulnerability
# Disable
Function TweakDisableMSHTMLActiveX { # RESINFO
	Write-Output "Disabling ActiveX in MSHTML (CVE-2021-40444)..."
	For ($Zone = 0 ; $Zone -le 3 ; $Zone++) {
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone" -Name "1001" -Type DWord -Value 00000003
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone" -Name "1004" -Type DWord -Value 00000003
	}
}

# Enable
Function TweakEnableMSHTMLActiveX { # RESINFO
	Write-Output "Enabling ActiveX in MSHTML (CVE-2021-40444)..."
	For ($Zone = 0 ; $Zone -le 3 ; $Zone++) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone" -Name "1001" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone" -Name "1004" -ErrorAction SilentlyContinue
	}
}

# View
Function TweakViewMSHTMLActiveX { # RESINFO
	Write-Output "Viewing ActiveX in MSHTML (not exist - Enable, 3 Disable)..."
	For ($Zone = 0 ; $Zone -le 3 ; $Zone++) {
		$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$Zone"
		If ((Get-ItemProperty $path -Name "1001" -ea 0)."1001" -ne $null) {
			Get-ItemProperty -Path $path -Name "1001"
		} Else {
			Write-Output "$path name 1001 not exist"
		}
		If ((Get-ItemProperty $path -Name "1004" -ea 0)."1004" -ne $null) {
			Get-ItemProperty -Path $path -Name "1004"
		} Else {
			Write-Output "$path name 1004 not exist"
		}
	}
}

################################################################

# 2022/06/02
# http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-30190
# https://msrc-blog.microsoft.com/2022/05/30/guidance-for-cve-2022-30190-microsoft-support-diagnostic-tool-vulnerability/
# Disable
Function TweakDisableMSDT { # RESINFO
	Write-Output "Disabling MSDT (CVE-2022-30190)..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	If (Test-Path "HKCR:\ms-msdt") {
		$DataFolder = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
		$CachesFolder = (Join-Path -Path $DataFolder -ChildPath "Caches" )
		$RegFile = (Join-Path -Path $CachesFolder -ChildPath "MSDT.reg")
		If (!(Test-Path $DataFolder)) {
			New-Item -Path $DataFolder -ItemType Directory
		}
		If (!(Test-Path $CachesFolder)) {
			New-Item -Path $CachesFolder -ItemType Directory
		}
		If (!(Test-Path $RegFile)) {
			# save the keys
			REG EXPORT HKEY_CLASSES_ROOT\ms-msdt "$RegFile"
		}
		# delete the reg tree
		REG DELETE HKEY_CLASSES_ROOT\ms-msdt /f
	}
}

# Enable
Function TweakEnableMSDT { # RESINFO
	Write-Output "Enabling MSDT..."
	If (!(Test-Path "HKCR:\ms-msdt")) {
		$DataFolder = (Join-Path -Path ${Env:ProgramData} -ChildPath "SWMB")
		$CachesFolder = (Join-Path -Path $DataFolder -ChildPath "Caches" )
		$RegFile = (Join-Path -Path $CachesFolder -ChildPath "MSDT.reg")
		If (Test-Path $RegFile) {
			# import the reg tree
			REG IMPORT "$RegFile"
			# delete the cache reg file
			Remove-Item -Path $RegFile -Force -ErrorAction SilentlyContinue
		}
	}
}

# View
Function TweakViewMSDT { # RESINFO
	Write-Output "Viewing MSDT (ms-msdt exist - Enable, not exist - Disable)..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	If (Test-Path "HKCR:\ms-msdt") {
		Get-ChildItem HKCR:\ms-msdt
	}
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function Tweak*
