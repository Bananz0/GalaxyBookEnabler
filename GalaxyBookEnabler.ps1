# Inform the user about the purpose of the script and ask for consent

Write-Host "This script is designed to automate the installation of certain software packages on your system."
Write-Host "Please read and understand the actions it will perform before proceeding."

# Provide a brief description of the script's actions
Write-Host "Actions to be performed:"
Write-Host "1. Creation of 'GalaxyBookEnabler' directory in your user folder."
Write-Host "2. Scheduling a task to run a batch file at startup for software installation."
Write-Host "3. Prompting you to select and install software packages."

# Explain the importance of running the script with administrative privileges
Write-Host "Please note that this script needs administrative privileges to perform these tasks."

# Ask for user consent
$confirmation = Read-Host "Do you consent to run this script? (Type 'Y' for Yes, or any other key to exit)"

# Check if the user consents
if ($confirmation -ne 'Y') {
    Write-Host "You chose not to run the script. Exiting..."
    exit
}

# If the user consents, the script continues to check for administrative privileges and perform the actions.


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



    Write-Host "To install Samsung Continuity Service, Samsung Account, and Samsung Cloud Assistant, select the packages to install:"
    Write-Host "1. Samsung Continuity Service"
    Write-Host "2. Samsung Account"
    Write-Host "3. Samsung Cloud Assistant"
    Write-Host "4. Install all packages (Core installation)"
    Write-Host ""

    $UserPrompt = Read-Host


    if ($taskCompleted) {
        Write-Host "The scheduled task completed successfully."
        Write-Host ""
        Write-Host "Please manually delete the current working directory: $PSScriptRoot"
        Write-Host "To install Samsung Continuity Service, Samsung Account, and Samsung Cloud Assistant, select the packages to install:"
        Write-Host "1. Samsung Continuity Service"
        Write-Host "2. Samsung Account"
        Write-Host "3. Samsung Cloud Assistant"
        Write-Host "4. Install all packages (Core installation)"
        Write-Host ""
    
        $UserPrompt = Read-Host
    
# Initialize variables
$CoreInstall = $false
$AltInstall = $false

# Define software package options
$packageOptions = @{
    '1' = @{
        Name = "Samsung Continuity Service"
        Id = "9P98T77876KZ"
    }
    '2' = @{
        Name = "Samsung Account"
        Id = "9NGW9K44GQ5F"
    }
    '3' = @{
        Name = "Samsung Cloud Assistant"
        Id = "9NFWHCHM52HQ"
    }
}

# Display package options
Write-Host "Please select the packages to install:"
foreach ($option in $packageOptions.Keys) {
    Write-Host "$option. $($packageOptions[$option].Name)"
}

# Get user input
$UserPrompt = Read-Host

# Validate user input
if ($packageOptions.ContainsKey($UserPrompt)) {
    $selectedPackage = $packageOptions[$UserPrompt]
    Write-Host "Installing $($selectedPackage.Name)..."
    winget install --accept-source-agreements --accept-package-agreements --id $selectedPackage.Id

    # Check if this is a core package installation
    if ($UserPrompt -eq '4') {
        $CoreInstall = $true
    }
} else {
    Write-Host "No valid option selected. If needed, you can install the apps from the Microsoft Store or an alternative source."
}

# If core packages were installed, offer the option to install additional packages
if ($CoreInstall) {
    Write-Host "Do you want to install additional packages? (Enter 1 for 'Samsung Multi Control', 2 for 'Quick Share', 3 for 'Samsung Notes', or 4 to skip)"
    $UserPrompt = Read-Host

    # Validate user input
    if ($UserPrompt -in '1', '2', '3', '4') {
        switch ($UserPrompt) {
            '1' {
                Write-Host "Installing Samsung Multi Control..."
                winget install --accept-source-agreements --accept-package-agreements --id 9N3L4FZ03Q99
            }
            '2' {
                Write-Host "Installing Quick Share..."
                winget install --accept-source-agreements --accept-package-agreements --id 9PCTGDFXVZLJ
            }
            '3' {
                Write-Host "Installing Samsung Notes..."
                winget install --accept-source-agreements --accept-package-agreements --id 9NBLGGH43VHV
            }
            default {
                Write-Host "Skipping additional package installation."
            }
        }

        # If any packages were installed, indicate success
        if ($UserPrompt -ne '4') {
            $AltInstall = $true
        }
    } else {
        Write-Host "No valid option selected for additional packages."
    }
}

# Final message
if ($AltInstall || $CoreInstall) {
    Write-Host "You have successfully installed the selected packages."
} else {
    Write-Host "No packages were installed."
}

                

    } else {
        Write-Host "The scheduled task did not complete successfully. Current working directory has been left as is."
    }
}




Write-Host "Press any key to exit..."
$null = Read-Host

