# Check if the script is running with administrative privileges
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"

if (-not $isAdmin) {
    # Relaunch the script as an administrator
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    # Exit the current (non-elevated) script
    Exit
}


$Username = [System.Environment]::UserName

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
$TaskTrigger.ExecutionTimeLimit = 'PT0S'
$TaskTrigger.Enabled = $true
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskCondition = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$TaskName = "GalaxyBookEnabler"
$TaskDescription = "This spoofs a working Samsung Galaxy Book for QuickShare and other Samsung features."
$TaskPrincipal.RunLevel = "Highest"




Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskCondition -Description $TaskDescription
Start-ScheduledTask -TaskName $TaskName
Start-ScheduledTask -TaskName $TaskName



$timeoutInSeconds = 2

$taskCompleted = $false
$endTime = (Get-Date).AddSeconds($timeoutInSeconds)

while ((Get-Date) -lt $endTime) {
    if (Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }) {
        $taskCompleted = $true
        break
    } else {
        Start-Sleep -Seconds 5 
    }
}
if ($taskCompleted) {
    Write-Host "The scheduled task completed successfully."
    Write-Host ""
    Write-Host "Please manually delete the current working directory: $PSScriptRoot"
    Write-Host "To install Samsung Continuity Sevice, Samsung Account and Samsung Cloud Assistant, Press (Y) or type Yes: "
    Write-Host ""
    $UserPrompt = Read-Host
    If ($UserPrompt = 'Y'){ 

        winget install  --accept-source-agreements --accept-package-agreements --id  9P98T77876KZ 
        winget install  --accept-source-agreements --accept-package-agreements --id  9NGW9K44GQ5F
        winget install  --accept-source-agreements --accept-package-agreements --id  9NFWHCHM52HQ
    } else {

        Write-Host "You can install the apps from the Microsoft Store but it might not show up. If it doesn't, use an alternative method to get the excecutable app installer using the links in the github repo."
        Write-Host ""
    }

} else {
    Write-Host "The scheduled task did not complete successfully. Current working directory has been left as is."
}





Write-Host "Press any key to exit..."
$null = Read-Host

