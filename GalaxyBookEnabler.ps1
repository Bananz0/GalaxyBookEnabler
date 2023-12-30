Import-Module ScheduledTasks

# Set up a log file path
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'InstallScriptLog.txt'

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )

    # Get the current timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format the log message
    $LogMessage = "$Timestamp - $Message"

    # Append the log message to the log file
    Add-Content -Path $LogFilePath -Value $LogMessage
}

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
    exit 1
}else{
    Write-Log "User consent obtained." }

# If the user consents, the script continues to check for administrative privileges and perform the actions.
# Check if the script is running with administrative privileges
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544" -or ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-18"

if (-not $isAdmin) {
    # Relaunch the script as an administrator
    try {
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Host "Error relaunching the script as an administrator: $_"
        exit 1
    }
}


$Username = [System.Environment]::UserName

# Define the user folder based on the current username
$UserFolder = "C:\Users\$Username"

# Create a new directory 'GalaxyBookEnabler' in the user's folder
$GalaxyBookEnablerDirectory = Join-Path -Path $UserFolder -ChildPath 'GalaxyBookEnabler'
# Create a new directory 'GalaxyBookEnabler' if it doesn't exist
try {
    if (-not (Test-Path $GalaxyBookEnablerDirectory -PathType Container)) {
        New-Item -Path $GalaxyBookEnablerDirectory -ItemType Directory -ErrorAction Stop
    }
} catch {
    Write-Host "Error creating directory: $_"
    Write-Log "Error creating directory: $_"
    exit 1
}

# Define the source path for the batch file (assuming it's in the same directory as the script)
$SourceBatchFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'QS.bat'
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'QS.bat'


# Copy the batch file to the 'GalaxyBookEnabler' directory

# Check if the source and destination paths are the same if second time running
if ((Test-Path $SourceBatchFilePath) -and (Test-Path $BatchFilePath) -and (Get-Item $SourceBatchFilePath).FullName -eq (Get-Item $BatchFilePath).FullName) {
    Write-Host "Source and destination paths are the same. No need to copy."
} else {
    try {
        Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force -ErrorAction Stop
        Write-Host "Batch file copied successfully."
        Write-Log "Batch file copied successfully."
    } catch {
        Write-Host "Error copying batch file: $_"
        Write-Log "Error copying batch file: $_"
        exit 1
    }
}


$TaskAction = New-ScheduledTaskAction -Execute $BatchFilePath
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$TaskTrigger.Repetition = $null  # Remove the repetition settings
$TaskTrigger.ExecutionTimeLimit = 'PT1M'
$TaskTrigger.Enabled = $true
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskCondition = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$TaskName = "GalaxyBookEnabler"
$TaskDescription = "This spoofs a working Samsung Galaxy Book for QuickShare and other Samsung features."
$TaskPrincipal.RunLevel = "Highest"

try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskCondition -Description $TaskDescription -ErrorAction Stop
    Write-Host "Scheduled task registered successfully."
} catch {
    Write-Host "Error registering scheduled task: $_"
    Write-Log "Error registering scheduled task: $_"
    exit 1
}


try {
    Start-ScheduledTask -TaskName $TaskName

    # Wait for the task to complete, checking its status directly
    $taskCompleted = $false
    while (-not $taskCompleted) {
        $taskStatus = Get-ScheduledTask -TaskName $TaskName | Select-Object -ExpandProperty State
        if ($taskStatus -eq 'Ready') {
            $taskCompleted = $true
        } else {
            Start-Sleep -Seconds 5  # Wait for a few seconds before checking again
        }
    }

    if ($taskCompleted) {
        Write-Host "The scheduled task completed successfully."
        Write-Host ""
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
        
        try {
            # Attempt to install the package
            winget install --accept-source-agreements --accept-package-agreements --id $selectedPackage.Id -ErrorAction Stop

            # Check if this is a core package installation
            if ($UserPrompt -eq '4') {
                $CoreInstall = $true
            }

            Write-Host "Installation of $($selectedPackage.Name) completed successfully."
            Write-Log  "Installation of $($selectedPackage.Name) completed successfully."
        } catch {
        # Handle installation errors
        $ErrorMessage = "Error installing $($selectedPackage.Name): $_"
        Write-Host $ErrorMessage
        Write-Log $ErrorMessage
        Write-Host "No valid option selected. If needed, you can install the apps from the Microsoft Store or an alternative source."
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
    if ($AltInstall -or $CoreInstall) {
        Write-Host "You have successfully installed the selected packages."
        } else {
            Write-Host "No packages were installed."
        }       
        } else {
            Write-Host "The scheduled task did not complete successfully. Current working directory has been left as is."
    }
    Write-Log "Script execution completed."

    Write-Host "Do you want to delete the GalaxyBookEnabler directory? (Y/N)"
    $deleteConfirmation = Read-Host
    Write-Log "User decision about directory deletion: $deleteConfirmation"
    } catch {
        Write-Host "Error checking task completion: $_"
        Write-Log "Error checking task completion: $_"
}

if ($deleteConfirmation -eq 'Y') {
    # Delete the directory 
    Write-Log "Deleting the GalaxyBookEnabler directory..."
    try {
        Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error deleting the directory: $_"
        Write-Log "Error deleting the directory: $_"

        while ($true) {
            Write-Host "Would you like to:"
            Write-Host "1. Retry deleting the directory (not recommended if files are locked)."
            Write-Host "2. Manually delete the directory from File Explorer."
            Write-Host "3. Skip directory deletion and continue."
      
            $retryChoice = Read-Host
      
            # Handle user choice
            switch ($retryChoice) {
              '1' {
                try {
                  Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction Stop
                  Write-Log "Directory successfully deleted after retry."
                  break
                } catch {
                  Write-Host "Retry failed. Please manually delete the directory."
                  Write-Log "Retry failed: $_"
                  break 2
                }
              }
              '2' {
                break
              }
              '3' {
                Write-Host "Directory left intact."
                Write-Log "Directory deletion skipped."
                break
              }
              default {
                Write-Host "Invalid choice. Please enter 1, 2, or 3."
              }
            }
          }
    }
} else {
    Write-Host "The directory will not be deleted."
}

Write-Host "Press any key to exit..."
$null = Read-Host