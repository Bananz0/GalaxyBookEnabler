Import-Module ScheduledTasks

# Define the script directory
$Username = [System.Environment]::UserName
$UserFolder = "C:\Users\$Username"
$GalaxyBookEnablerDirectory = Join-Path -Path $UserFolder -ChildPath 'GalaxyBookEnablerScript'
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'QS.bat'
$firstrun = $true
$TaskName = "GalaxyBookEnabler2"

# Set up a log file path
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'InstallScriptLog.txt'
$ScriptDirectory = $PSScriptRoot

#Task details
$TaskAction = New-ScheduledTaskAction -Execute $BatchFilePath
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$TaskTrigger.Repetition = $null  # Remove the repetition settings
$TaskTrigger.ExecutionTimeLimit = 'PT1M'
$TaskTrigger.Enabled = $true
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskCondition = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$TaskDescription = "This spoofs a working Samsung Galaxy Book for QuickShare and other Samsung features."
$TaskPrincipal.RunLevel = "Highest"

# Function to install a package
function InstallPackage($packageName, $packageId) {
    try {
        Write-Host "Installing $packageName..."
        winget install --accept-source-agreements --accept-package-agreements --id $packageId
        Write-Host "Installation of $packageName completed successfully."
    } catch {
        Write-Host "Error installing $packageName $_"
        Write-Log "Error installing $packageName $_"
    }
} 

# Function to install all packages
function InstallAllPackages {
    InstallPackage 'Samsung Multi Control' '9N3L4FZ03Q99'
    InstallPackage 'Quick Share' '9PCTGDFXVZLJ'
    InstallPackage 'Samsung Notes' '9NBLGGH43VHV'
}



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


# Check if the script is running with administrative privileges
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544" -or ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-18"

if (-not $isAdmin) {
    # Explain the importance of running the script with administrative privileges
    Write-Host "Please note that this script needs administrative privileges to perform these tasks."
    Write-Host
    # Prompt user for consent
    $confirmation = Read-Host "Do you want to run this script with administrative privileges? Press 'Y' to agree, or any other key to exit"
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        try {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs -ErrorAction Stop
            # Exit the current instance of the script after triggering the relaunch
            exit
        } catch {
            Write-Host "Error relaunching the script as an administrator: $_"
            Write-Log "Error relaunching the script as an administrator: $_"
            Write-Host "Exiting..."
            Write-Host
            exit 1
        }
    } else {
        exit 0
    }
} else {
    Write-Host "Script is  running with administrative privileges."
    Write-Host
}

# Check if the QS.bat file already exists in the GalaxyBookEnabler directory
if (Test-Path -Path $BatchFilePath) {
    Write-Host "The QS.bat file is already present in the GalaxyBookEnabler directory."
    Write-Log "The QS.bat file is already present in the GalaxyBookEnabler directory."
    $firstrun = $false
}

# Check if the scheduled task with the name "GalaxyBookEnabler" already exists
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Host "The scheduled task with the name 'GalaxyBookEnabler' is already present."
    Write-Log "The scheduled task with the name 'GalaxyBookEnabler' is already present."
    $firstrun = $false
}

if ($firstrun -ne $true) {
    Write-Host
    Write-Host "This script has already been run. Skipping the initial setup steps."
    Write-Host
    $userchoice = Read-Host "Press (C) to continue with the installation of software packages,
(D) to delete the GalaxyBookEnabler directory and remove the scheduled task, or any other key to exit."
    Write-Host
    if ($userchoice -eq'D')
    {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Scheduled task and GalaxyBookEnabler directory have been removed."
            Write-Log "Scheduled task and GalaxyBookEnabler directory have been removed."
            #Ask to exit or continue with the script
            $userchoice2 = Read-Host "Press (C) to continue with the installation of software packages, or any other key to exit."
            if ($userchoice2 -eq 'C') {
                Write-Host "Continuing with the installation of software packages..."
                Write-Host
            } else {
                Write-Host "Exiting..."
                Write-Host
                exit 0
            }

        } catch {
            Write-Host "Error removing scheduled task and GalaxyBookEnabler directory: $_"
            Write-Log "Error removing scheduled task and GalaxyBookEnabler directory: $_"
        }
    } elseif ($userchoice -eq 'C') {
        Write-Host "Continuing with the installation of software packages..."
    } else {
        Write-Host "Exiting..."
        Write-Host
        exit 0
    }
}

# Inform the user about the purpose of the script and ask for consent
Write-Host "This script is designed to automate the installation of certain software packages on your system."
Write-Host "It will also create a scheduled task to run a batch file at startup for software installation."
Write-Host 
Write-Host "Please read and understand the actions it will perform before proceeding."
Write-Host

# Provide a brief description of the script's actions
Write-Host "Actions to be performed:"
Write-Host "1. Creation of 'GalaxyBookEnabler' directory in your user folder."
Write-Host "2. Scheduling a task to run a batch file at startup for software installation."
Write-Host "3. Prompting you to select and install software packages."
Write-Host


# Ask for user consent
$confirmation = Read-Host "Do you consent to run this script? (Type 'Y' for Yes, or any other key to exit)"

# Check if the user consents
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Write-Host "You chose not to run the script. Exiting..."
    Write-Host
    exit 1
}else{
    Write-Log "User consent obtained." }
    

# Create a new directory 'GalaxyBookEnabler' if it doesn't exist
try {
    if (-not (Test-Path $GalaxyBookEnablerDirectory -PathType Container)) {
        New-Item -Path $GalaxyBookEnablerDirectory -ItemType Directory -ErrorAction Stop
    }
} catch {
    Write-Host "Error creating directory: $_"
    Write-Host "Exiting..."
    Write-Host
    Write-Log "Error creating directory: $_"
    exit 1
}

# Define the source path for the batch file (assuming it's in the same directory as the script)
$SourceBatchFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'QS.bat'
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'QS.bat'

# Check if the source and destination paths are the same if second time running
$sourceContentHash = Get-FileHash -Path $SourceBatchFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
if (Test-Path $BatchFilePath) {
    $destinationContentHash = Get-FileHash -Path $BatchFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    if ((Test-Path $SourceBatchFilePath) -and (Test-Path $BatchFilePath) -and ($sourceContentHash -eq $destinationContentHash)) {
        Write-Host "Source and destination file contents are the same. No need to copy."
    } else {
        # Prompt user for confirmation to replace the file
        $replaceConfirmation = Read-Host "Destination file already exists and has different contents. Do you want to replace it? (Y/N)"

        if ($replaceConfirmation -eq 'Y') {
            try {
                # Copy the batch file to the 'GalaxyBookEnabler' directory
                Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force -ErrorAction Stop
                Write-Host "Batch file copied successfully."
                Write-Host
                Write-Log "Batch file copied successfully."
            } catch {
                Write-Host "Error copying batch file: $_"
                Write-Log "Error copying batch file: $_"
                Write-Host "Exiting..."
                Write-Host
                exit 1
            }
        } else {
            Write-Host "User chose not to replace the file. Exiting..."
            Write-Log "User chose not to replace the file. Exiting..."
            Write-Host
            break
        }
    }
} else {
    # Destination file doesn't exist, proceed with copying
    try {
        Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force -ErrorAction Stop
        Write-Host "Batch file copied successfully."
        Write-Host
        Write-Log "Batch file copied successfully."
    } catch {
        Write-Host "Error copying batch file: $_"
        Write-Log "Error copying batch file: $_"
        Write-Host "Exiting..."
        Write-Host
        exit 1
    }
}

Clear-Host

try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskCondition -Description $TaskDescription -ErrorAction Stop
    Write-Host "Scheduled task registered successfully."
    Write-Host
} catch {
    Write-Host "Error registering scheduled task: $_"
    Write-Log "Error registering scheduled task: $_"
    Write-Host "Exiting..."
    Write-Host
    exit 1
}
 
try{
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
        Clear-Host
        Write-Host "For most of the Samsung Services to work, the following need to be installed."
        # Initialize variables
        $CoreInstall = $false
        $AltInstall = $false

        # Define software package options
        $packageOptions = [ordered]@{
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
        Write-Host ""
        Write-Host "Please select the packages to install:"
        foreach ($option in $packageOptions.Keys) {
            Write-Host "$option. $($packageOptions[$option].Name)"
        }


        # Get user input
        $UserPrompt = Read-Host "Do you want to proceed with the installation? (Y)es or (N)o:"
        Write-Host ""


        # Validate user input
        if ($UserPrompt -eq 'Y' -or $UserPrompt -eq 'y') {
                $CoreInstall = $true
                $selectedPackage = $packageOptions[$UserPrompt]
                Write-Host "Installing $($selectedPackage.Name)..."                
                try {
                    # Install all the packages with for loop
                    foreach ($packageKey in $packageOptions.Keys) {
                        $selectedPackage = $packageOptions[$packageKey]
                        #winget install --accept-source-agreements --accept-package-agreements --id $selectedPackage.Id 
                        InstallPackage $selectedPackage.Name $selectedPackage.Id
                        Write-Log  "Installation of $($selectedPackage.Name) completed successfully."
                        Write-Host ""
                    }
                } catch {
                    # Handle installation errors
                    Write-Host ""
                    $ErrorMessage = "Error installing $($selectedPackage.Name): $_"
                    Write-Host $ErrorMessage
                    Write-Log $ErrorMessage
                }

        } else {
            Write-Host "No valid option selected. If needed, you can install the apps from the Microsoft Store or an alternative source."
            Write-Host ""
        }


# If core packages were installed, offer the option to install additional packages
if ($CoreInstall) {
    $selectedPackages = @()
    do {
        Clear-Host  # Clear the console screen
        
        # Print currently selected packages
        Write-Host "Selected packages: $($selectedPackages -join ', ')"
        Write-Host ""         
        $packageOptions = @{
            '1' = 'Samsung Multi Control'
            '2' = 'Quick Share'
            '3' = 'Samsung Notes'
            '4' = 'All'
            '5' = 'Finish selection'
        }

        foreach ($key in ($packageOptions.Keys | Sort-Object)) {
            Write-Host "$key. $($packageOptions[$key])"
        }

  
        $UserPrompt = Read-Host "Select a package to install (or 5 to finish selection)"


        


# Validate user input
if ($UserPrompt -in $packageOptions.Keys){
    switch ($UserPrompt) {
        '1' {
            if ('Samsung Multi Control' -in $selectedPackages) {
                $selectedPackages = $selectedPackages -ne 'Samsung Multi Control'
            } else {
                $selectedPackages += 'Samsung Multi Control'
            }
        }
        '2' {
            if ('Quick Share' -in $selectedPackages) {
                $selectedPackages = $selectedPackages -ne 'Quick Share'
            } else {
                $selectedPackages += 'Quick Share'
            }
        }
        '3' {
            if ('Samsung Notes' -in $selectedPackages) {
                $selectedPackages = $selectedPackages -ne 'Samsung Notes'
            } else {
                $selectedPackages += 'Samsung Notes'
            }
        }
        '4' {
            # Define all packages
            $allPackages = @('Samsung Multi Control', 'Quick Share', 'Samsung Notes')
        
            # Iterate over all packages
            foreach ($package in $allPackages) {
                # Check if package is not already in the selected packages
                if ($selectedPackages -notcontains $package) {
                    # Add package to the selected packages
                    $selectedPackages += $package
                }
            }
        }
        '5' {
            Write-Host "Finishing package selection."
        }
    }          
}
    } while  ($UserPrompt -ne '5')

    # Install selected packages
    if ($selectedPackages.Count -gt 0) {
        Clear-Host 
        Write-Host "Installing selected packages..."
        foreach ($package in $selectedPackages) {
            switch ($package) {
                'Samsung Multi Control' {
                    InstallPackage 'Samsung Multi Control' '9N3L4FZ03Q99'
                }
                'Quick Share' {
                    InstallPackage 'Quick Share' '9PCTGDFXVZLJ'
                }
                'Samsung Notes' {
                    InstallPackage 'Samsung Notes' '9NBLGGH43VHV'
                }
            }
        }
    } else {
        Write-Host "No additional packages were selected for installation."
    }
} else {
    Write-Host "No core packages were installed, skipping additional package installation."
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

    Write-Host "Please delete the Script directory after the installation is complete."
    $deleteConfirmation = Read-Host
    # Write-Log "User decision about directory deletion: $deleteConfirmation"
    } catch {
        Write-Host "Error checking task completion: $_"
        Write-Log "Error checking task completion: $_"
}

# if ($deleteConfirmation -eq 'Y' -or $deleteConfirmation -eq 'y') {
#     # Delete the directory 
#     Write-Log "Deleting the GalaxyBookEnabler directory..."
#     try {
#         Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction SilentlyContinue
#     } catch {
#         Write-Host "Error deleting the directory: $_"
#         Write-Log "Error deleting the directory: $_"

#         while ($true) {
#             Write-Host "Would you like to:"
#             Write-Host "1. Retry deleting the directory (not recommended if files are locked)."
#             Write-Host "2. Manually delete the directory from File Explorer."
#             Write-Host "3. Skip directory deletion and continue."
      
#             $retryChoice = Read-Host
      
#             # Handle user choice
#             switch ($retryChoice) {
#               '1' {
#                 try {
#                   Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction Stop
#                   Write-Log "Directory successfully deleted after retry."
#                   break
#                 } catch {
#                   Write-Host "Retry failed. Please manually delete the directory."
#                   Write-Log "Retry failed: $_"
#                   break 2
#                 }
#               }
#               '2' {
#                 break
#               }
#               '3' {
#                 Write-Host "Directory left intact."
#                 Write-Log "Directory deletion skipped."
#                 break
#               }
#               default {
#                 Write-Host "Invalid choice. Please enter 1, 2, or 3."
#               }
#             }
#           }
#     }
# } else {
#     Write-Host "The directory will not be deleted."
# }

# if ($deleteConfirmation -eq 'Y' -or $deleteConfirmation -eq 'y') {
#     # Create a new scheduled task to delete files with multiple names in the script's directory
#     $ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path
#     $FileNames = @("name1*", "name2*", "name3*")  # Replace with the names of the files you want to delete
#     $DeleteCommands = $FileNames | ForEach-Object { "Get-ChildItem -Path '$ScriptDirectory' -File -Filter '$_' | Remove-Item;" }
#     $TaskName = "DeleteScriptFilesTask"
#     $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"$DeleteCommands Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:$false`""
#     $TaskTrigger = New-ScheduledTaskTrigger -At ((Get-Date) + (New-TimeSpan -Minutes 1))
#     Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger
# } else {
#     Write-Host "The files in the script's directory will not be deleted."
# }

Write-Host "Press any key to exit..."
$null = Read-Host