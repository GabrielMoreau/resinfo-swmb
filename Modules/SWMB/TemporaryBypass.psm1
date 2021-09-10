################################################################
# Project CNRS RESINFO SWMB
# Copyright (C) 2020-2021, CNRS, France
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb
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
Function DisablePrintForSystem {
	Write-Output "Disable print for System user (CVE-2021-34527)..."
	$acl = Get-Acl -Path "$Env:SystemRoot\System32\spool\drivers"
	$ruleOrg1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$ruleOrg2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')
	$ruleNew1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Modify',      'ContainerInherit,ObjectInherit', 'None',        'Deny')
	$ruleNew2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Read',        'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$acl.RemoveAccessRule($ruleOrg1)
	$acl.RemoveAccessRule($ruleOrg2)
	$acl.AddAccessRule($ruleNew1)
	$acl.AddAccessRule($ruleNew2)
	$acl | Set-Acl -Path "$Env:SystemRoot\System32\spool\drivers"
}

# Enable
Function EnablePrintForSystem {
	Write-Output "Enable print for System user (CVE-2021-34527)..."
	$acl = Get-Acl -Path "$Env:SystemRoot\System32\spool\drivers"
	$ruleOrg1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$ruleOrg2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'FullControl', 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')
	$ruleNew1 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Modify',      'ContainerInherit,ObjectInherit', 'None',        'Deny')
	$ruleNew2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\System', 'Read',        'ContainerInherit,ObjectInherit', 'None',        'Allow')
	$acl.RemoveAccessRule($ruleNew1)
	$acl.RemoveAccessRule($ruleNew2)
	$acl.AddAccessRule($ruleOrg1)
	$acl.AddAccessRule($ruleOrg2)
	$acl | Set-Acl -Path "$Env:SystemRoot\System32\spool\drivers"
}

# View
Function ViewPrintForSystem {
	Get-Acl -Path "$Env:SystemRoot\System32\spool\drivers" | Select -Expand Access | Out-GridView
}

################################################################

# 2021/09/10
# http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-40444
# https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-40444
# Microsoft MSHTML Remote Code Execution Vulnerability
Function DisableMSHTMLActiveX {
	Write-Output "Disable ActiveX in MSHTML (CVE-2021-40444)..."
	For ($zone = 0 ; $zone -le 3 ; $zone++){
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone")) {
			New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1001" -Type DWord -Value 00000003
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1004" -Type DWord -Value 00000003
	}
}

# Enable
Function EnableMSHTMLActiveX {
	Write-Output "Enable ActiveX in MSHTML (CVE-2021-40444)..."
	For ($zone = 0 ; $zone -le 3 ; $zone++){
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1001" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1004" -ErrorAction SilentlyContinue
	}
}

# View
Function ViewMSHTMLActiveX {
	Write-Output 'ActiveX in MSHTML (not exist - enable, 3 disable)'
	For ($zone = 0 ; $zone -le 3 ; $zone++){
		Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1001"
		Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone" -Name "1004"
	}
}


################################################################
###### Export Functions
################################################################

# Export functions
Export-ModuleMember -Function *
