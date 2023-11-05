# Get the current username using whoami
$Username = $Username = [System.Environment]::UserName


# Define the user folder based on the current username
$UserFolder = "C:\Users\$Username"

# Create a new directory 'GalaxyBookEnabler' in the user's folder
$GalaxyBookEnablerDirectory = Join-Path -Path $UserFolder -ChildPath 'GalaxyBookEnabler'
# Create a new directory 'GalaxyBookEnabler' if it doesn't exist
if (-not (Test-Path $GalaxyBookEnablerDirectory -PathType Container)) {
    New-Item -Path $GalaxyBookEnablerDirectory -ItemType Directory
}


# Define the source path for the batch file (assuming it's in the same directory as the script)
$SourceBatchFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'QS.bat'

# Copy the batch file to the 'GalaxyBookEnabler' directory
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'QS.bat'
Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force

$TaskAction = New-ScheduledTaskAction -Execute $BatchFilePath
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$TaskTrigger.Repetition = $null  # Remove the repetition settings
$TaskTrigger.LogonType = 1
$TaskTrigger.ExecutionTimeLimit = 'PT0S'
$TaskTrigger.Enabled = $true

# Set the task to run with highest privileges (as an administrator)
$TaskTrigger.Principal.RunLevel = [System.Security.Principal.TaskRunLevel]::Highest

$TaskPrincipal.RunLevel = [System.Security.Principal.TaskRunLevel]::Highest
