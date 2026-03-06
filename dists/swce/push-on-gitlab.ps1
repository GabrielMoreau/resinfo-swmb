
########################################################################

# [Default]
# GITLAB_Server=
# GITLAB_ProjectId=
# GITLAB_Branch=
# GITLAB_Token=

# Get Config from file
Function GetConfig {
	Param (
		[Parameter(Mandatory = $True)] [string]$FilePath
	)

	If (!(Test-Path 'push-config.ini')) {
		Return Echo '' | ConvertFrom-StringData
	}
	Return Get-Content "$FilePath" | Where-Object { $_ -Match '=' } | ForEach-Object { $_ -Replace "#.*", "" } | ForEach-Object { $_ -Replace "\\", "\\" } | ForEach-Object { $_ -Replace "\s*=\s*", "=" } | ConvertFrom-StringData
}

########################################################################

#$GITLAB_Server    = "gitlab.example.fr"
#$GITLAB_ProjectId = "1294"
#$GITLAB_Branch    = "upload"
#$GITLAB_Token     = "F6EKJHKJJHKSBKBJHdhdgk.04.0z0b1ofxb"

# Get Config: Version
$Config = GetConfig -FilePath 'push-config.ini'
$GITLAB_Server    = $Config.GITLAB_Server
$GITLAB_ProjectId = $Config.GITLAB_ProjectId
$GITLAB_Branch    = $Config.GITLAB_Branch
$GITLAB_Token     = $Config.GITLAB_Token

########################################################################

$MachineName = ${Env:ComputerName}  # Computer Hostname
$FilePathInRepo = "LocalMachine-SWCE-$MachineName.txt"  # Repository file name
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm"  # Date and time
$CommitMessage = "SWCE from $MachineName at $DateTime"  # Commit message
$ScriptPath = ".\LocalMachine-SWCE.ps1"

# Execute the script
$TempFile = [System.IO.Path]::GetTempFileName()
Start-Transcript -Path $TempFile
& $ScriptPath
Stop-Transcript
$Output = Get-Content $TempFile | Out-String
Remove-Item -Path $TempFile
$Base64Content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Output))

# Upload on GITLAB server
If ($GITLAB_Server -ne '') {
	# JSON
	$Body = @{
		'branch'         = $GITLAB_Branch
		'content'        = $Base64Content
		'commit_message' = $CommitMessage
		'encoding'       = 'base64'
	} | ConvertTo-Json -Compress

	$EncodedPath = [System.Web.HttpUtility]::UrlEncode($FilePathInRepo)
	$ApiUrl = "https://$GITLAB_Server/api/v4/projects/$GITLAB_ProjectId/repository/files/$EncodedPath"

	$Headers = @{
		'PRIVATE-TOKEN' = $GITLAB_Token
		'Content-Type'  = 'application/json'
	}

	Try {
		# Attempt to update (PUT)
		$Response = Invoke-RestMethod -Method PUT -Uri $ApiUrl -Headers $Headers -Body $Body -ErrorAction Stop
		Write-Host "File updated. Response : $($Response | ConvertTo-Json)"
	} Catch {
		Try {
			Write-Host "The file does not exist. Creation with POST..."
			$Response = Invoke-RestMethod -Method POST -Uri $ApiUrl -Headers $Headers -Body $Body -ErrorAction Stop
			Write-Host "File created. Response : $($Response | ConvertTo-Json)"
		} Catch {
			Write-Host "Error : $($_.Exception.Message)"
			Throw $_
		}
	}
}
