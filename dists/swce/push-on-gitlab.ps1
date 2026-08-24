
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
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm"  # Date and time
$CommitMessage = "SWCE from $MachineName at $DateTime"  # Commit message
$ScriptPath = ".\LocalMachine-SWCE.ps1"

# Execute the script
$TXT_TempFile = [System.IO.Path]::GetTempFileName()
$CSV_TempFile = [System.IO.Path]::GetTempFileName()
Start-Transcript -Path $TXT_TempFile
& $ScriptPath 6> $CSV_TempFile
Stop-Transcript

$ContentHash = @{
	"LocalMachine-SWCE-$MachineName.txt" = Get-Content $TXT_TempFile | Out-String
	"LocalMachine-SWCE-$MachineName.csv" = Get-Content $CSV_TempFile | Out-String
	}

Remove-Item -Path $TXT_TempFile
Remove-Item -Path $CSV_TempFile

# Upload on GITLAB server
If ($GITLAB_Server -ne '') {
	ForEach ($FileName in $ContentHash.Key) {

		# JSON
		$Body = @{
			'branch'         = $GITLAB_Branch
			'content'        = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ContentHash[$FileName]))
			'commit_message' = $CommitMessage
			'encoding'       = 'base64'
		} | ConvertTo-Json -Compress

		$EncodedPath = [System.Web.HttpUtility]::UrlEncode($FileName)
		$ApiUrl = "https://$GITLAB_Server/api/v4/projects/$GITLAB_ProjectId/repository/files/$EncodedPath"

		$Headers = @{
			'PRIVATE-TOKEN' = $GITLAB_Token
			'Content-Type'  = 'application/json'
		}

		Try {
			# Attempt to update (PUT)
			$Response = Invoke-RestMethod -Method PUT -Uri $ApiUrl -Headers $Headers -Body $Body -ErrorAction Stop
			Write-Host "File updated: $FileName. Response: $($Response | ConvertTo-Json)"
		} Catch {
			Try {
				Write-Host "The file does not exist: $FileName. Creation with POST..."
				$Response = Invoke-RestMethod -Method POST -Uri $ApiUrl -Headers $Headers -Body $Body -ErrorAction Stop
				Write-Host "File created. Response : $($Response | ConvertTo-Json)"
			} Catch {
				Write-Host "Error : $($_.Exception.Message)"
				Throw $_
			}
		}
	}
} Else {
	# Write on STDOUT
	Write-Output $ContentHash["LocalMachine-SWCE-$MachineName.txt"]
}
