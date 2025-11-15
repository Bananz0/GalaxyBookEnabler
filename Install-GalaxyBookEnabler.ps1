# Galaxy Book Enabler Installer/Uninstaller
# Enables Samsung Galaxy Book features on non-Galaxy Book devices

<#
.SYNOPSIS
    Galaxy Book Enabler - Enable Samsung Galaxy Book features on any Windows PC

.DESCRIPTION
    This tool spoofs your device as a Samsung Galaxy Book to enable features like:
    - Quick Share
    - Multi Control
    - Samsung Notes
    - AI Select (with keyboard shortcut setup)
    - System Support Engine (advanced/experimental)
    
    It handles automatic startup configuration and Wi-Fi compatibility detection.

.PARAMETER Uninstall
    Removes the Galaxy Book Enabler from your system.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1
    Installs the Galaxy Book Enabler with interactive configuration.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1 -Uninstall
    Removes the Galaxy Book Enabler from your system.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1 -TestMode
    Runs in test mode without applying registry changes, creating tasks, or installing packages.

.EXAMPLE
    irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
    Installs in one line from GitHub.

.NOTES
    File Name      : Install-GalaxyBookEnabler.ps1
    Prerequisite   : PowerShell 7.0 or later
    Requires Admin : Yes
    Version        : 3.0.0
    Repository     : https://github.com/Bananz0/GalaxyBookEnabler
#>

param(
    [switch]$Uninstall,
    [switch]$TestMode
)

# VERSION CONSTANT - Update this when releasing new versions
$SCRIPT_VERSION = "3.0.0"
$GITHUB_REPO = "Bananz0/GalaxyBookEnabler"
$UPDATE_CHECK_URL = "https://api.github.com/repos/$GITHUB_REPO/releases/latest"

# ==================== HELPER FUNCTIONS ====================

function Test-UpdateAvailable {
    try {
        $response = Invoke-RestMethod -Uri $UPDATE_CHECK_URL -ErrorAction Stop
        $latestVersion = $response.tag_name -replace '^v', ''
        
        if ([version]$latestVersion -gt [version]$SCRIPT_VERSION) {
            $downloadUrl = $null
            if ($response.assets) {
                $downloadUrl = $response.assets | Where-Object { $_.name -like "Install-*.ps1" } | Select-Object -First 1 -ExpandProperty browser_download_url
            }

            return @{
                Available = $true
                LatestVersion = $latestVersion
                CurrentVersion = $SCRIPT_VERSION
                ReleaseUrl = $response.html_url
                DownloadUrl = $downloadUrl
                ReleaseNotes = $response.body
            }
        }
        
        return @{
            Available = $false
            LatestVersion = $latestVersion
            CurrentVersion = $SCRIPT_VERSION
        }
    } catch {
        Write-Verbose "Failed to check for updates: $_"
        return @{
            Available = $false
            Error = $_.Exception.Message
        }
    }
}

function Update-GalaxyBookEnabler {
    param (
        [string]$DownloadUrl
    )
    
    try {
        Write-Host "Downloading latest version..." -ForegroundColor Yellow
        $tempFile = Join-Path $env:TEMP "Install-GalaxyBookEnabler-Latest.ps1"
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempFile -ErrorAction Stop
        
        Write-Host "✓ Downloaded successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "Starting updated installer..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        
        # Launch the new installer
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs
        
        # Exit current installer
        exit
    } catch {
        Write-Host "✗ Failed to download update: $_" -ForegroundColor Red
        Write-Host "Please download manually from: $GITHUB_REPO/releases" -ForegroundColor Yellow
        return $false
    }
}

# ==================== PACKAGE DEFINITIONS ====================
$PackageDatabase = @{
    # CORE PACKAGES - Required for basic functionality
    Core = @(
        @{
            Name = "Samsung Account"
            Id = "9NGW9K44GQ5F"
            Category = "Core"
            Description = "Required for Samsung ecosystem authentication"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Settings"
            Id = "9P2TBWSHK6HJ"
            Category = "Core"
            Description = "Central configuration for Samsung apps"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Settings Runtime"
            Id = "9NL68DVFP841"
            Category = "Core"
            Description = "Required runtime for Samsung Settings"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Cloud Assistant"
            Id = "9NFWHCHM52HQ"
            Category = "Core"
            Description = "Cloud storage and sync service"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Continuity Service"
            Id = "9P98T77876KZ"
            Category = "Core"
            Description = "Enables cross-device continuity features"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Intelligence Service"
            Id = "9NS0SHL4PQL9"
            Category = "Core"
            Description = "Required for Galaxy AI features and AI Select"
            Status = "Working"
            Required = $true
        },
        @{
            Name = "Samsung Bluetooth Sync"
            Id = "9NJNNJTTFL45"
            Category = "Core"
            Description = "Bluetooth device synchronization"
            Status = "Working"
            Required = $true
        }
    )
    
    # RECOMMENDED PACKAGES - Full Samsung experience (everything that works)
    Recommended = @(
        @{
            Name = "Quick Share"
            Id = "9PCTGDFXVZLJ"
            Category = "Connectivity"
            Description = "Fast file sharing between devices"
            Status = "Working"
            RequiresIntelWiFi = $true
            Warning = "Requires Intel Wi-Fi adapter for full functionality"
        },
        @{
            Name = "Galaxy Book Experience"
            Id = "9P7QF37HPMGX"
            Category = "Experience"
            Description = "Enhanced Galaxy Book features and optimizations"
            Status = "Working"
            Recommended = $true
        },
        @{
            Name = "Samsung Notes"
            Id = "9NBLGGH43VHV"
            Category = "Productivity"
            Description = "Note-taking with stylus support"
            Status = "Working"
        },
        @{
            Name = "Multi Control"
            Id = "9N3L4FZ03Q99"
            Category = "Connectivity"
            Description = "Control multiple devices with one keyboard/mouse"
            Status = "Working"
        },
        @{
            Name = "Samsung Gallery"
            Id = "9NBLGGH4N9R9"
            Category = "Media"
            Description = "Photo and video gallery with cloud sync"
            Status = "Working"
        },
        @{
            Name = "Samsung Studio"
            Id = "9P312B4TZFFH"
            Category = "Media"
            Description = "Photo and video editing suite"
            Status = "Working"
        },
        @{
            Name = "Samsung Studio for Gallery"
            Id = "9NND8BT5WFC5"
            Category = "Media"
            Description = "Gallery-integrated editing tools"
            Status = "Working"
        },
        @{
            Name = "Samsung Screen Recorder"
            Id = "9P5025MM7WDT"
            Category = "Productivity"
            Description = "Screen recording with annotations"
            Status = "Working"
        },
        @{
            Name = "Samsung Flow"
            Id = "9NBLGGH5GB0M"
            Category = "Connectivity"
            Description = "Phone-PC integration features"
            Status = "Working"
        },
        @{
            Name = "SmartThings"
            Id = "9N3ZBH5V7HX6"
            Category = "Smart Home"
            Description = "Control SmartThings devices"
            Status = "Working"
        },
        @{
            Name = "Galaxy Buds"
            Id = "9NHTLWTKFZNB"
            Category = "Accessories"
            Description = "Galaxy Buds management and settings"
            Status = "Working"
        },
        @{
            Name = "Samsung Device Care"
            Id = "9NBLGGH4XDV0"
            Category = "Maintenance"
            Description = "Device optimization and diagnostics"
            Status = "Working"
        },
        @{
            Name = "Samsung Parental Controls"
            Id = "9N5GWJTCZKGS"
            Category = "Security"
            Description = "Manage children's device usage"
            Status = "Working"
        },
        @{
            Name = "AI Select"
            Id = "9PM11FHJQLZ4"
            Category = "Productivity"
            Description = "Smart screenshot tool with text extraction and AI features"
            Status = "Working"
        },
        @{
            Name = "Nearby Devices"
            Id = "9PHL04NJNT67"
            Category = "Connectivity"
            Description = "Manage and connect to nearby Samsung devices"
            Status = "Working"
        },
        @{
            Name = "Storage Share"
            Id = "9MVNW0XH7HS5"
            Category = "Utilities"
            Description = "Share storage between devices"
            Status = "Working"
        },
        @{
            Name = "Second Screen"
            Id = "9PLTXW5DX5KB"
            Category = "Productivity"
            Description = "Use tablet as secondary display"
            Status = "Working"
        },
        @{
            Name = "Live Wallpaper"
            Id = "9N1G7F25FXCB"
            Category = "Personalization"
            Description = "Animated wallpapers"
            Status = "Working"
        },
        @{
            Name = "Galaxy Book Smart Switch"
            Id = "9PJ0J9KQWCLB"
            Category = "Utilities"
            Description = "Transfer data to new Galaxy Book"
            Status = "Working"
        }
    )
    
    # EXTRA STEPS REQUIRED - Need additional configuration
    ExtraSteps = @(
        @{
            Name = "Samsung Phone"
            Id = "9MWJXXLCHBGK"
            Category = "Connectivity"
            Description = "Phone app integration"
            Status = "RequiresExtraSteps"
            Warning = "Requires additional configuration steps to work properly"
        },
        @{
            Name = "Samsung Find"
            Id = "9MWD59CZJ1RN"
            Category = "Security"
            Description = "Find your Samsung devices"
            Status = "RequiresExtraSteps"
            Warning = "Requires additional configuration steps to work properly"
        },
        @{
            Name = "Quick Search"
            Id = "9N092440192Z"
            Category = "Productivity"
            Description = "Fast system-wide search"
            Status = "RequiresExtraSteps"
            Warning = "Requires additional configuration steps to work properly"
        },        
        @{
            Name = "Samsung Pass"
            Id = "9MVWDZ5KX9LH"
            Category = "Security"
            Description = "Password manager with biometric auth"
            Status = "RequiresExtraSteps"
            Warning = "Requires additional configuration steps to work properly"
        }
    )
    
    # NON-WORKING - User can install but won't function
    NonWorking = @(
        @{
            Name = "Samsung Recovery"
            Id = "9NBFVH4X67LF"
            Category = "Maintenance"
            Description = "Factory reset and recovery options"
            Status = "NotWorking"
            Warning = "This app will NOT work on non-Samsung devices (requires genuine hardware)"
        },
        @{
            Name = "Samsung Update"
            Id = "9NQ3HDB99VBF"
            Category = "Maintenance"
            Description = "Firmware and driver updates"
            Status = "NotWorking"
            Warning = "This app will NOT work on non-Samsung devices (requires genuine hardware)"
        },
        @{
            Name = "Camera Share"
            Id = "9NPCS7FN6VB9"
            Category = "Connectivity"
            Description = "Use phone camera with PC apps"
            Status = "NotWorking"
            Warning = "This app is currently not working (reason unknown)"
        }
    )
    
    # LEGACY - Not recommended
    Legacy = @(
        @{
            Name = "Samsung Studio Plus (Legacy)"
            Id = "9PLPF77D2R18"
            Category = "Media"
            Description = "Old version of Studio"
            Status = "Legacy"
            Warning = "Use Samsung Studio instead (newer version)"
        }
    )
}

# ==================== HELPER FUNCTIONS (continued) ====================

function Get-SamsungDriverCab {
    <#
    .SYNOPSIS
        Downloads Samsung System Support Service CAB from Microsoft Update Catalog
    
    .PARAMETER Version
        Specific version to download. If not specified, shows interactive menu.
    
    .PARAMETER OutputPath
        Where to save the CAB file. Defaults to current directory.
    #>
    
    param(
        [string]$Version,
        [string]$OutputPath = $PWD
    )
    
    $searchUrl = "https://www.catalog.update.microsoft.com/Search.aspx?q=sam0428"
    
    Write-Host "Searching Microsoft Update Catalog for Samsung drivers..." -ForegroundColor Cyan
    
    try {
        # Create output directory if it doesn't exist
        if (-not (Test-Path $OutputPath)) {
            New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
        }
        
        # Initial search request
        $searchResponse = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing
        
        # Extract all driver entries
        $rows = [regex]::Matches($searchResponse.Content, '(?s)<tr[^>]*>(.*?)</tr>')
        
        $drivers = @()
        
        foreach ($row in $rows) {
            $rowContent = $row.Groups[1].Value
            
            # Skip header rows and rows without Samsung
            if ($rowContent -notmatch 'Samsung.*SoftwareComponent') {
                continue
            }
            
            # Extract title
            $title = $null
            if ($rowContent -match '>([^<]*Samsung\s*-\s*SoftwareComponent\s*-\s*[\d\.]+[^<]*)</') {
                $title = $Matches[1].Trim()
            }
            
            if (-not $title) { continue }
            
            # Extract version number
            if ($title -match '(\d+\.\d+\.\d+\.\d+)') {
                $driverVersion = $Matches[1]
            } else {
                continue
            }
            
            # Extract the update GUID
            $updateId = $null
            if ($rowContent -match "goToDetails\([`"']([^`"']+)[`"']") {
                $updateId = $Matches[1]
            } elseif ($rowContent -match 'id=([a-f0-9-]{36})') {
                $updateId = $Matches[1]
            }
            
            if (-not $updateId) { continue }
            
            # Extract last updated date
            $lastUpdated = Get-Date
            if ($rowContent -match '(\d{1,2}/\d{1,2}/\d{4})') {
                try {
                    $lastUpdated = [DateTime]::Parse($Matches[1])
                } catch {
                    # Keep default date
                }
            }
            
            $drivers += [PSCustomObject]@{
                Title = $title
                Version = $driverVersion
                UpdateId = $updateId
                LastUpdated = $lastUpdated
            }
        }
        
        if ($drivers.Count -eq 0) {
            Write-Error "No Samsung System Support Service drivers found"
            return $null
        }
        
        # Sort by version (descending)
        $drivers = $drivers | Sort-Object { [version]$_.Version } -Descending
        
        Write-Host "`nFound $($drivers.Count) driver(s):" -ForegroundColor Green
        
        # Select driver to download
        $selectedDriver = if ($Version) {
            $found = $drivers | Where-Object { $_.Version -eq $Version } | Select-Object -First 1
            if (-not $found) {
                Write-Host "Version $Version not found. Available versions:" -ForegroundColor Red
                $drivers | ForEach-Object { Write-Host "  $($_.Version)" -ForegroundColor Yellow }
                return $null
            }
            $found
        } else {
            # Interactive selection
            Write-Host ""
            for ($i = 0; $i -lt $drivers.Count; $i++) {
                $driver = $drivers[$i]
                $label = if ($i -eq 0) { " (Latest)" } else { "" }
                Write-Host ("{0,2}. Version {1,-12} - {2}{3}" -f ($i + 1), $driver.Version, $driver.LastUpdated.ToString("MM/dd/yyyy"), $label) -ForegroundColor Cyan
            }
            
            Write-Host ""
            do {
                $selection = Read-Host "Select version to download (1-$($drivers.Count))"
                $selectionNum = $null
                $validInput = [int]::TryParse($selection, [ref]$selectionNum) -and $selectionNum -ge 1 -and $selectionNum -le $drivers.Count
                
                if (-not $validInput) {
                    Write-Host "Invalid selection. Please enter a number between 1 and $($drivers.Count)" -ForegroundColor Red
                }
            } while (-not $validInput)
            
            $drivers[$selectionNum - 1]
        }
        
        Write-Host "`nSelected: $($selectedDriver.Title)" -ForegroundColor Green
        Write-Host "Version: $($selectedDriver.Version)" -ForegroundColor Cyan
        Write-Host "Update ID: $($selectedDriver.UpdateId)" -ForegroundColor Gray
        Write-Host ""
        
        # Get download link
        Write-Host "Getting download link..." -ForegroundColor Yellow
        
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $detailsUrl = "https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=$($selectedDriver.UpdateId)"
        $detailsResponse = Invoke-WebRequest -Uri $detailsUrl -WebSession $session -UseBasicParsing
        
        $downloadUrl = $null
        $postUrl = "https://www.catalog.update.microsoft.com/DownloadDialog.aspx"
        $postBody = @{
            updateIDs = "[{`"size`":0,`"languages`":`"`",`"uidInfo`":`"$($selectedDriver.UpdateId)`",`"updateID`":`"$($selectedDriver.UpdateId)`"}]"
        }
        
        try {
            $downloadResponse = Invoke-WebRequest -Uri $postUrl -Method Post -Body $postBody -WebSession $session -UseBasicParsing -ContentType "application/x-www-form-urlencoded"
            
            if ($downloadResponse.Content -match 'downloadInformation\[\d+\]\.files\[\d+\]\.url\s*=\s*[''"]([^''"]+)[''"]') {
                $downloadUrl = $Matches[1]
            } elseif ($downloadResponse.Content -match 'https?://[^''"\s]+\.cab') {
                $downloadUrl = $Matches[0]
            }
        } catch {
            Write-Host "Post method failed, trying alternative extraction..." -ForegroundColor Yellow
            if ($detailsResponse.Content -match 'https?://[^''"\s]+\.cab') {
                $downloadUrl = $Matches[0]
            }
        }
        
        if (-not $downloadUrl) {
            Write-Error "Could not extract download URL"
            return $null
        }
        
        $fileName = [System.IO.Path]::GetFileName($downloadUrl)
        $outputFile = Join-Path $OutputPath $fileName
        
        Write-Host "Download URL: $downloadUrl" -ForegroundColor Gray
        Write-Host "Saving to: $outputFile" -ForegroundColor Cyan
        Write-Host ""
        
        # Download the CAB file
        Write-Host "Downloading CAB file..." -ForegroundColor Yellow
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        if (Test-Path $outputFile) {
            $fileInfo = Get-Item $outputFile
            if ($fileInfo.Length -lt 1KB) {
                Write-Error "Downloaded file is too small (corrupted download)"
                Remove-Item $outputFile -Force
                return $null
            }
            
            $fileSize = [math]::Round($fileInfo.Length / 1MB, 2)
            Write-Host "✓ Download complete!" -ForegroundColor Green
            Write-Host "  File: $outputFile" -ForegroundColor Cyan
            Write-Host "  Size: $fileSize MB" -ForegroundColor Cyan
            
            return [PSCustomObject]@{
                Version = $selectedDriver.Version
                FilePath = $outputFile
                FileName = $fileName
                UpdateId = $selectedDriver.UpdateId
                FileSize = $fileSize
            }
        } else {
            Write-Error "Download failed - file not found"
            return $null
        }
        
    } catch {
        Write-Error "Failed to download CAB: $($_.Exception.Message)"
        return $null
    }
}

function Install-SystemSupportEngine {
    <#
    .SYNOPSIS
        Downloads, extracts, patches, installs SSSE to C:\GalaxyBook and creates service
    
    .DESCRIPTION
        Complete SSSE installation following the original tutorial:
        1. Downloads CAB from Microsoft Update Catalog
        2. Extracts main CAB and inner settings_x64.cab
        3. Patches SamsungSystemSupportEngine.exe
        4. Installs ALL files to C:\GalaxyBook (including .inf and .cat)
        5. Stops/disables conflicting Samsung services
        6. Creates new service pointing to patched executable
        7. Automatically installs driver using Device Manager automation
    
    .PARAMETER InstallPath
        Installation directory (defaults to C:\GalaxyBook)
    
    .PARAMETER TestMode
        If enabled, simulates installation without creating services or installing drivers
    #>
    
    param(
        [string]$InstallPath = "C:\GalaxyBook",
        [bool]$TestMode = $false
    )
    
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "  ⚠️  ADVANCED FEATURE WARNING ⚠️" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
    
    Write-Host "This step involves:" -ForegroundColor White
    Write-Host "  • Binary executable patching (modifies Samsung software)" -ForegroundColor Gray
    Write-Host "  • System service installation (runs at startup)" -ForegroundColor Gray
    Write-Host "  • Driver installation (automated via Device Manager)" -ForegroundColor Gray
    
    Write-Host "`nThis is EXPERIMENTAL and may:" -ForegroundColor Yellow
    Write-Host "  ⚠ Cause system instability" -ForegroundColor Red
    Write-Host "  ⚠ Trigger antivirus warnings" -ForegroundColor Red
    Write-Host "  ⚠ Require manual cleanup if something goes wrong" -ForegroundColor Red
    
    Write-Host "`nCompatibility:" -ForegroundColor Cyan
    Write-Host "  ✓ Windows 11 x64 only" -ForegroundColor Green
    Write-Host "  ✗ Windows 10 NOT supported" -ForegroundColor Red
    Write-Host "  ✗ ARM devices NOT supported" -ForegroundColor Red
    
    Write-Host "`nRecommended for advanced users only." -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "Do you want to install System Support Engine? (y/N)"
    if ($continue -notlike "y*") {
        Write-Host "Skipping System Support Engine installation." -ForegroundColor Cyan
        return $false
    }
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 22000)) {
        Write-Host "`n✗ Windows 11 is required for SSSE!" -ForegroundColor Red
        Write-Host "  Your version: Windows $($osVersion.Major).$($osVersion.Minor) Build $($osVersion.Build)" -ForegroundColor Yellow
        Write-Host "  Required: Windows 11 (Build 22000+)" -ForegroundColor Yellow
        return $false
    }
    
    # Check for existing SSSE installations
    Write-Host "`nChecking for existing installations..." -ForegroundColor Cyan
    
    $existingInstallations = @()
    $possiblePaths = @(
        "C:\GalaxyBook",
        "C:\SamSysSupSvc",
        "C:\Samsung"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $exePath = Join-Path $path "SamsungSystemSupportEngine.exe"
            if (Test-Path $exePath) {
                $fileInfo = Get-Item $exePath
                $version = $fileInfo.VersionInfo.FileVersion
                if (-not $version) { $version = "Unknown" }
                
                # Only track user installations, not DriverStore
                if ($path -notlike "*DriverStore*" -and $path -notlike "*Windows\System32*") {
                    $existingInstallations += [PSCustomObject]@{
                        Path = $path
                        Version = $version
                        Size = [math]::Round($fileInfo.Length / 1KB, 2)
                        Modified = $fileInfo.LastWriteTime
                    }
                }
            }
        }
    }
    
    # Check for running services
    $existingServices = @()
    $serviceNames = @("GBeSupportService", "SamsungSystemSupportEngine", "SamsungSystemSupportService")
    foreach ($svcName in $serviceNames) {
        $service = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($service) {
            $svcPath = (Get-CimInstance Win32_Service -Filter "Name='$svcName'" -ErrorAction SilentlyContinue).PathName
            $isDriverStore = $svcPath -like "*DriverStore*" -or $svcPath -like "*Windows\System32*"
            
            $existingServices += [PSCustomObject]@{
                Name = $service.Name
                Status = $service.Status
                StartType = $service.StartType
                Path = $svcPath
                IsOriginal = ($svcName -eq "SamsungSystemSupportService")
                IsDriverStore = $isDriverStore
            }
        }
    }
    
    # Check if original Samsung service needs to be disabled
    $originalService = $existingServices | Where-Object { $_.IsOriginal -eq $true }
    if ($originalService -and $originalService.StartType -ne 'Disabled') {
        Write-Host "`n⚠️  Original Samsung Service Detected" -ForegroundColor Yellow
        Write-Host "========================================`n" -ForegroundColor Yellow
        Write-Host "The original 'SamsungSystemSupportService' is currently: $($originalService.StartType)" -ForegroundColor White
        Write-Host "Status: $($originalService.Status)" -ForegroundColor $(if ($originalService.Status -eq 'Running') { 'Green' } else { 'Gray' })
        Write-Host ""
        Write-Host "This service MUST be disabled to avoid conflicts with the patched version." -ForegroundColor Yellow
        Write-Host ""
        
        $disableOriginal = Read-Host "Disable original Samsung service? (Y/n)"
        if ($disableOriginal -notlike "n*") {
            Write-Host "  Disabling SamsungSystemSupportService..." -ForegroundColor Cyan
            
            if ($originalService.Status -eq 'Running') {
                Write-Host "    Stopping service..." -ForegroundColor Gray
                Stop-Service -Name "SamsungSystemSupportService" -Force -ErrorAction SilentlyContinue
            }
            
            Write-Host "    Setting startup type to Disabled..." -ForegroundColor Gray
            Set-Service -Name "SamsungSystemSupportService" -StartupType Disabled -ErrorAction SilentlyContinue
            
            $verifyDisabled = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
            if ($verifyDisabled.StartType -eq 'Disabled') {
                Write-Host "  ✓ Original service disabled successfully" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ Failed to disable service - you may need to do this manually" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠ WARNING: Service conflicts may occur!" -ForegroundColor Red
            Write-Host "    The patched and original services may interfere with each other." -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    # Show existing installations and ask what to do
    if ($existingInstallations.Count -gt 0 -or $existingServices.Count -gt 0) {
        Write-Host "`n⚠️  Existing SSSE Installation Detected" -ForegroundColor Yellow
        Write-Host "========================================`n" -ForegroundColor Yellow
        
        if ($existingInstallations.Count -gt 0) {
            Write-Host "Found installations:" -ForegroundColor Cyan
            foreach ($install in $existingInstallations) {
                Write-Host "  📁 $($install.Path)" -ForegroundColor White
                Write-Host "     Version: $($install.Version)" -ForegroundColor Gray
                Write-Host "     Size: $($install.Size) KB" -ForegroundColor Gray
                Write-Host "     Modified: $($install.Modified)" -ForegroundColor Gray
                Write-Host ""
            }
        }
        
        if ($existingServices.Count -gt 0) {
            Write-Host "Found services:" -ForegroundColor Cyan
            foreach ($svc in $existingServices) {
                $displayColor = if ($svc.IsDriverStore) { 'DarkGray' } else { 'White' }
                Write-Host "  🔧 $($svc.Name)" -ForegroundColor $displayColor
                if ($svc.IsDriverStore) {
                    Write-Host "     [Windows Managed - Will Not Touch]" -ForegroundColor DarkGray
                }
                Write-Host "     Status: $($svc.Status)" -ForegroundColor $(if ($svc.Status -eq 'Running') { 'Green' } else { 'Gray' })
                Write-Host "     Start Type: $($svc.StartType)" -ForegroundColor Gray
                if ($svc.Path) {
                    Write-Host "     Path: $($svc.Path)" -ForegroundColor Gray
                }
                Write-Host ""
            }
        }
        
        Write-Host "What would you like to do?" -ForegroundColor Yellow
        Write-Host "  [1] Upgrade to new version (stops services, replaces files)" -ForegroundColor White
        Write-Host "  [2] Keep existing installation (skip SSSE setup)" -ForegroundColor White
        Write-Host "  [3] Clean install (removes old, installs fresh)" -ForegroundColor White
        Write-Host "  [4] Cancel" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-4]"
        
        switch ($choice) {
            "1" {
                Write-Host "`n📦 Upgrading existing installation..." -ForegroundColor Cyan
                
                # If multiple installations found, let user choose which to upgrade
                if ($existingInstallations.Count -gt 1) {
                    Write-Host "`nMultiple installations found. Which one to upgrade?" -ForegroundColor Yellow
                    for ($i = 0; $i -lt $existingInstallations.Count; $i++) {
                        Write-Host "  [$($i + 1)] $($existingInstallations[$i].Path) (v$($existingInstallations[$i].Version))" -ForegroundColor White
                    }
                    Write-Host ""
                    
                    do {
                        $upgradeChoice = Read-Host "Enter choice [1-$($existingInstallations.Count)]"
                        $upgradeIndex = [int]$upgradeChoice - 1
                    } while ($upgradeIndex -lt 0 -or $upgradeIndex -ge $existingInstallations.Count)
                    
                    $InstallPath = $existingInstallations[$upgradeIndex].Path
                } else {
                    # Use the first (only) found installation path for upgrade
                    $InstallPath = $existingInstallations[0].Path
                }
                
                Write-Host "  Upgrade target: $InstallPath" -ForegroundColor Cyan
                
                # Stop user-installed services only (not DriverStore)
                foreach ($svc in $existingServices) {
                    if (-not $svc.IsDriverStore -and $svc.Status -eq 'Running') {
                        Write-Host "  Stopping service: $($svc.Name)..." -ForegroundColor Yellow
                        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            "2" {
                Write-Host "`n✓ Keeping existing installation" -ForegroundColor Green
                return $true
            }
            "3" {
                Write-Host "`n🗑️  Removing old installations..." -ForegroundColor Yellow
                
                # Stop and remove user services only (not DriverStore)
                foreach ($svc in $existingServices) {
                    if (-not $svc.IsDriverStore) {
                        if ($svc.Status -eq 'Running') {
                            Write-Host "  Stopping service: $($svc.Name)..." -ForegroundColor Gray
                            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                        }
                        Write-Host "  Removing service: $($svc.Name)..." -ForegroundColor Gray
                        & sc.exe delete $svc.Name | Out-Null
                    } else {
                        Write-Host "  Skipping Windows-managed service: $($svc.Name)" -ForegroundColor DarkGray
                    }
                }
                
                # Remove installation directories
                foreach ($install in $existingInstallations) {
                    Write-Host "  Removing: $($install.Path)..." -ForegroundColor Gray
                    Remove-Item -Path $install.Path -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                Write-Host "  ✓ Cleanup complete" -ForegroundColor Green
                
                # Use default path for clean install
                $InstallPath = "C:\GalaxyBook"
            }
            default {
                Write-Host "`nCancelled." -ForegroundColor Yellow
                return $false
            }
        }
    }
    
    # Download CAB
    Write-Host "`nDownloading Samsung System Support Service CAB..." -ForegroundColor Cyan
    Write-Host "Recommended version: 6.3.3.0 (tested and stable)" -ForegroundColor Gray
    Write-Host ""
    
    $useRecommended = Read-Host "Use recommended version 6.3.3.0? (Y/n)"
    $cabVersion = if ($useRecommended -like "n*") { $null } else { "6.3.3.0" }
    
    $tempDir = Join-Path $env:TEMP "GalaxyBookEnabler_SSSE"
    if (-not (Test-Path $tempDir)) {
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    }
    
    $cabResult = Get-SamsungDriverCab -Version $cabVersion -OutputPath $tempDir
    
    if (-not $cabResult) {
        Write-Error "Failed to download CAB file"
        return $false
    }
    
    # Extract and patch
    Write-Host "`nExtracting and patching binary..." -ForegroundColor Cyan
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $extractDir = Join-Path $tempDir "CAB_Extract_$timestamp"
    $level1Dir = Join-Path $extractDir "Level1"
    $level2Dir = Join-Path $extractDir "Level2_settings_x64"
    
    try {
        # Create extraction directories
        New-Item -Path $level1Dir -ItemType Directory -Force | Out-Null
        New-Item -Path $level2Dir -ItemType Directory -Force | Out-Null
        
        # LEVEL 1: Extract main CAB
        Write-Host "  [1/7] Extracting main CAB..." -ForegroundColor Yellow
        $expandResult = & expand.exe "$($cabResult.FilePath)" -F:* "$level1Dir" 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract main CAB: $expandResult"
        }
        Write-Host "  ✓ Main CAB extracted" -ForegroundColor Green
        
        # Find the .inf and .cat files (driver files)
        $infFile = Get-ChildItem -Path $level1Dir -Filter "*.inf" -File | Select-Object -First 1
        $catFile = Get-ChildItem -Path $level1Dir -Filter "*.cat" -File | Select-Object -First 1
        
        if (-not $infFile -or -not $catFile) {
            Write-Warning "Driver files (.inf/.cat) not found in main CAB"
        }
        
        # LEVEL 2: Extract inner settings_x64.cab
        $settingsCab = Get-ChildItem -Path $level1Dir -Filter "settings_x64.cab" -File
        if (-not $settingsCab) {
            throw "settings_x64.cab not found in main CAB"
        }
        
        Write-Host "  [2/7] Extracting inner CAB..." -ForegroundColor Yellow
        $expandResult = & expand.exe "$($settingsCab.FullName)" -F:* "$level2Dir" 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract settings_x64.cab: $expandResult"
        }
        Write-Host "  ✓ Inner CAB extracted" -ForegroundColor Green
        
        # List all files extracted
        Write-Host "`n  Extracted files:" -ForegroundColor Cyan
        $level2Files = Get-ChildItem -Path $level2Dir -Recurse -File
        foreach ($file in $level2Files) {
            Write-Host "    → $($file.Name)" -ForegroundColor Gray
        }
        Write-Host ""
        
        # Find the executables (search recursively in case they're in subdirectories)
        $ssseExe = Get-ChildItem -Path $level2Dir -Filter "SamsungSystemSupportEngine.exe" -File -Recurse
        $ssseService = Get-ChildItem -Path $level2Dir -Filter "SamsungSystemSupportService.exe" -File -Recurse
        
        if (-not $ssseExe) {
            Write-Host "  ✗ SamsungSystemSupportEngine.exe not found in extracted files!" -ForegroundColor Red
            Write-Host "  Available .exe files:" -ForegroundColor Yellow
            $exeFiles = Get-ChildItem -Path $level2Dir -Filter "*.exe" -File -Recurse
            if ($exeFiles) {
                foreach ($exe in $exeFiles) {
                    Write-Host "    • $($exe.Name) in $($exe.DirectoryName)" -ForegroundColor Gray
                }
            } else {
                Write-Host "    (No .exe files found)" -ForegroundColor Gray
            }
            throw "SamsungSystemSupportEngine.exe not found"
        }
        
        Write-Host "  ✓ Found executable: $($ssseExe.Name)" -ForegroundColor Green
        if ($ssseService) {
            Write-Host "  ✓ Found service: $($ssseService.Name)" -ForegroundColor Green
        }
        
        # Create C:\SamSysSupSvc directory
        Write-Host "  [3/7] Creating installation directory..." -ForegroundColor Yellow
        if (Test-Path $InstallPath) {
            Write-Host "  ⚠ Directory exists, backing up..." -ForegroundColor Yellow
            $backupPath = "$InstallPath`_backup_$timestamp"
            Copy-Item -Path $InstallPath -Destination $backupPath -Recurse -Force
            Write-Host "  ✓ Backup created: $backupPath" -ForegroundColor Green
        }
        
        New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
        Write-Host "  ✓ Created: $InstallPath" -ForegroundColor Green
        
        # Kill any running Samsung processes before copying
        Write-Host "  [4/7] Stopping Samsung processes..." -ForegroundColor Yellow
        
        $samsungProcesses = @(
            "SamsungSystemSupportEngine",
            "SamsungSystemSupportService", 
            "SamsungSystemSupportOSD",
            "SamsungActiveScreen",
            "SamsungHideWindow",
            "SettingsEngineTest",
            "SettingsExtensionLauncher"
        )
        
        $killedProcesses = @()
        foreach ($procName in $samsungProcesses) {
            $processes = Get-Process -Name $procName -ErrorAction SilentlyContinue
            if ($processes) {
                foreach ($proc in $processes) {
                    try {
                        Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                        $killedProcesses += $procName
                    } catch {
                        Write-Host "    ⚠ Failed to stop: $procName" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        if ($killedProcesses.Count -gt 0) {
            Write-Host "    ✓ Stopped $($killedProcesses.Count) process(es)" -ForegroundColor Green
            Start-Sleep -Seconds 2  # Give processes time to fully exit
        } else {
            Write-Host "    ✓ No running processes found" -ForegroundColor Green
        }
        
        # Copy ALL files to installation directory
        Write-Host "  [5/7] Copying files to installation directory..." -ForegroundColor Yellow
        
        # Copy all files from Level 2 (settings_x64 contents) - search recursively
        $level2AllFiles = Get-ChildItem -Path $level2Dir -File -Recurse
        $copyErrors = 0
        foreach ($file in $level2AllFiles) {
            try {
                Copy-Item -Path $file.FullName -Destination $InstallPath -Force -ErrorAction Stop
                Write-Host "    → $($file.Name)" -ForegroundColor Gray
            } catch {
                Write-Host "    ✗ Failed to copy: $($file.Name)" -ForegroundColor Red
                Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
                $copyErrors++
            }
        }
        
        # Copy driver files from Level 1 (.inf and .cat)
        if ($infFile) {
            Copy-Item -Path $infFile.FullName -Destination $InstallPath -Force
            Write-Host "    → $($infFile.Name) (driver)" -ForegroundColor Gray
        }
        if ($catFile) {
            Copy-Item -Path $catFile.FullName -Destination $InstallPath -Force
            Write-Host "    → $($catFile.Name) (driver)" -ForegroundColor Gray
        }
        
        if ($copyErrors -gt 0) {
            Write-Host "  ⚠ Files copied with $copyErrors error(s)" -ForegroundColor Yellow
        } else {
            Write-Host "  ✓ All files copied" -ForegroundColor Green
        }
        
        # Patch the executable
        Write-Host "  [6/7] Patching binary..." -ForegroundColor Yellow
        
        $targetExePath = Join-Path $InstallPath "SamsungSystemSupportEngine.exe"
        $backupExePath = "$targetExePath.backup"
        
        # Create backup
        Copy-Item $targetExePath $backupExePath -Force
        Write-Host "    ✓ Backup created: $(Split-Path $backupExePath -Leaf)" -ForegroundColor Green
        
        # Patch patterns
        $originalPattern = @(0x00, 0x4C, 0x8B, 0xF0, 0x48, 0x83, 0xF8, 0xFF, 0x0F, 0x85, 0x8A, 0x00, 0x00, 0x00, 0xFF, 0x15)
        $targetPattern = @(0x00, 0x4C, 0x8B, 0xF0, 0x48, 0x83, 0xF8, 0xFF, 0x48, 0xE9, 0x8A, 0x00, 0x00, 0x00, 0xFF, 0x15)
        
        $fileBytes = [System.IO.File]::ReadAllBytes($targetExePath)
        
        # Find pattern
        $offset = -1
        for ($i = 0; $i -le ($fileBytes.Length - $originalPattern.Length); $i++) {
            $match = $true
            for ($j = 0; $j -lt $originalPattern.Length; $j++) {
                if ($fileBytes[$i + $j] -ne $originalPattern[$j]) {
                    $match = $false
                    break
                }
            }
            if ($match) {
                $offset = $i
                break
            }
        }
        
        if ($offset -eq -1) {
            # Check if already patched
            $patchedOffset = -1
            for ($i = 0; $i -le ($fileBytes.Length - $targetPattern.Length); $i++) {
                $match = $true
                for ($j = 0; $j -lt $targetPattern.Length; $j++) {
                    if ($fileBytes[$i + $j] -ne $targetPattern[$j]) {
                        $match = $false
                        break
                    }
                }
                if ($match) {
                    $patchedOffset = $i
                    break
                }
            }
            
            if ($patchedOffset -ne -1) {
                Write-Host "  ✓ Binary already patched!" -ForegroundColor Green
                Write-Host "    Target pattern found at offset: 0x$($patchedOffset.ToString('X8'))" -ForegroundColor Cyan
                Write-Host "    Patched bytes: $(($targetPattern | ForEach-Object { $_.ToString('X2') }) -join ' ')" -ForegroundColor Gray
            } else {
                Write-Warning "Original pattern not found - binary may be a different version"
                Write-Host "    Files copied but not patched." -ForegroundColor Yellow
                Write-Host "    You can try manually patching or use a different version." -ForegroundColor Gray
            }
        } else {
            # Apply patch
            Write-Host "    Found original pattern at offset: 0x$($offset.ToString('X8'))" -ForegroundColor Cyan
            Write-Host "    Current bytes: $(($fileBytes[$offset..($offset + $originalPattern.Length - 1)] | ForEach-Object { $_.ToString('X2') }) -join ' ')" -ForegroundColor Gray
            Write-Host "    Patching: 0F 85 (JNZ) → 48 E9 (JMP)" -ForegroundColor Yellow
            
            for ($i = 0; $i -lt $targetPattern.Length; $i++) {
                $fileBytes[$offset + $i] = $targetPattern[$i]
            }
            [System.IO.File]::WriteAllBytes($targetExePath, $fileBytes)
            
            # Verify the patch
            $verifyBytes = [System.IO.File]::ReadAllBytes($targetExePath)
            $verifyOffset = -1
            for ($i = 0; $i -le ($verifyBytes.Length - $targetPattern.Length); $i++) {
                $match = $true
                for ($j = 0; $j -lt $targetPattern.Length; $j++) {
                    if ($verifyBytes[$i + $j] -ne $targetPattern[$j]) {
                        $match = $false
                        break
                    }
                }
                if ($match) {
                    $verifyOffset = $i
                    break
                }
            }
            
            if ($verifyOffset -eq $offset) {
                Write-Host "  ✓ Binary patched and verified successfully!" -ForegroundColor Green
                Write-Host "    From: $(($originalPattern | ForEach-Object { $_.ToString('X2') }) -join ' ')" -ForegroundColor Red
                Write-Host "    To:   $(($targetPattern | ForEach-Object { $_.ToString('X2') }) -join ' ')" -ForegroundColor Green
            } else {
                Write-Error "Patch verification failed! The file may not have been written correctly."
            }
        }
        
        # Handle conflicting services
        Write-Host "  [7/7] Configuring service..." -ForegroundColor Yellow
        
        if ($TestMode) {
            Write-Host "    [TEST MODE] Skipping service operations" -ForegroundColor Yellow
            Write-Host "      Would stop/disable conflicting Samsung services" -ForegroundColor Gray
            Write-Host "      Would create: GBeSupportService" -ForegroundColor Gray
            Write-Host "      Settings: LocalSystem account, Auto startup, Running" -ForegroundColor Gray
            Write-Host "      Binary: $targetExePath" -ForegroundColor Gray
        } else {
            # Check for existing Samsung services (NOT including GBeSupportService)
            $conflictingServices = @(
                "SamsungSystemSupportService",
                "SamsungSystemSupportEngine Service",
                "SamsungSystemSupportEngine"  # Without space variant
            )
            
            foreach ($serviceName in $conflictingServices) {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                Write-Host "    ⚠ Found existing Samsung service: $serviceName" -ForegroundColor Yellow
                
                # Stop service
                if ($service.Status -eq 'Running') {
                    Write-Host "      Stopping service..." -ForegroundColor Gray
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                }
                
                # Disable service (don't delete, just disable)
                Write-Host "      Disabling service..." -ForegroundColor Gray
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "      ✓ Service disabled" -ForegroundColor Green
            }
        }
        
        # Now handle GBeSupportService (our custom service)
        Write-Host "    Configuring GBeSupportService..." -ForegroundColor Cyan
        $newServiceName = "GBeSupportService"
        $service = Get-Service -Name $newServiceName -ErrorAction SilentlyContinue
        
        $binPath = Join-Path $InstallPath "SamsungSystemSupportEngine.exe"
        $displayName = "Galaxy Book Enabler Support Service"
        $description = "Samsung System Support Engine service (patched by Galaxy Book Enabler). Enables Samsung Settings and device features."
        
        if ($service) {
            Write-Host "    Service exists - deleting and recreating..." -ForegroundColor Yellow
            
            # Stop service if running
            if ($service.Status -eq 'Running') {
                Write-Host "      Stopping service..." -ForegroundColor Gray
                Stop-Service -Name $newServiceName -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
            
            # Delete existing service
            Write-Host "      Deleting old service..." -ForegroundColor Gray
            $deleteResult = & sc.exe delete $newServiceName 2>&1
            Write-Host "      ✓ Service deletion initiated" -ForegroundColor Green
            
            # Wait for Windows to complete the deletion (marked for deletion issue)
            Write-Host "      Waiting for Windows to complete deletion..." -ForegroundColor Gray
            $maxWait = 30  # Maximum 30 seconds
            $waited = 0
            $serviceDeleted = $false
            
            while ($waited -lt $maxWait) {
                Start-Sleep -Seconds 2
                $waited += 2
                
                # Check if service still exists
                $checkService = Get-Service -Name $newServiceName -ErrorAction SilentlyContinue
                if (-not $checkService) {
                    $serviceDeleted = $true
                    Write-Host "      ✓ Service fully deleted after $waited seconds" -ForegroundColor Green
                    break
                }
                
                if ($waited % 6 -eq 0) {
                    Write-Host "      Still waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
                }
            }
            
            if (-not $serviceDeleted) {
                Write-Host "      ⚠ Service still marked for deletion after $maxWait seconds" -ForegroundColor Yellow
                Write-Host "      This usually resolves after a reboot" -ForegroundColor Yellow
            }
            
            # Extra pause before recreation
            Start-Sleep -Seconds 2
        }
        
        # Create new service with correct configuration
        Write-Host "    Creating service..." -ForegroundColor Gray
        $scResult = & sc.exe create $newServiceName binPath= "`"$binPath`"" start= auto obj= LocalSystem DisplayName= $displayName 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ Service created successfully!" -ForegroundColor Green
            
            # Set service description
            $descResult = & sc.exe description $newServiceName $description 2>&1
            
            Write-Host "      Name: $newServiceName" -ForegroundColor Gray
            Write-Host "      Display: $displayName" -ForegroundColor Gray
            Write-Host "      Description: $description" -ForegroundColor Gray
            Write-Host "      Binary: $binPath" -ForegroundColor Gray
            Write-Host "      Startup: Automatic" -ForegroundColor Gray
            Write-Host "      Account: LocalSystem" -ForegroundColor Gray
            
            # Start the service immediately
            Write-Host "    Starting service..." -ForegroundColor Gray
            try {
                Start-Service -Name $newServiceName -ErrorAction Stop
                Start-Sleep -Seconds 2
                
                $serviceStatus = (Get-Service -Name $newServiceName -ErrorAction SilentlyContinue).Status
                if ($serviceStatus -eq 'Running') {
                    Write-Host "    ✓ Service started successfully" -ForegroundColor Green
                } else {
                    Write-Host "    ⚠ Service created but not running (status: $serviceStatus)" -ForegroundColor Yellow
                }
            } catch {
                Write-Warning "Failed to start service: $_"
                Write-Host "      Service will start automatically on next reboot" -ForegroundColor Gray
            }
        } else {
            Write-Warning "Service creation failed: $scResult"
            Write-Host "    You can manually create it with this command:" -ForegroundColor Yellow
            Write-Host "    sc create `"$newServiceName`" binPath=`"$binPath`" start=auto obj=LocalSystem DisplayName=`"$displayName`"" -ForegroundColor Cyan
            Write-Host "    sc description `"$newServiceName`" `"$description`"" -ForegroundColor Cyan
        }
        }
        
        # Install driver automatically
        
        # Install driver automatically
        Write-Host "  [8/8] Installing driver..." -ForegroundColor Yellow
        
        if ($TestMode) {
            Write-Host "    [TEST MODE] Skipping driver installation" -ForegroundColor Yellow
            if ($infFile) {
                Write-Host "      Would install: $($infFile.Name)" -ForegroundColor Gray
                Write-Host "      Command: pnputil /add-driver /install" -ForegroundColor Gray
            } else {
                Write-Host "      No .inf file found" -ForegroundColor Gray
            }
        } else {
            if (-not $infFile) {
                Write-Warning "No .inf file found - skipping driver installation"
            } else {
                $infPath = Join-Path $InstallPath $infFile.Name
                
                Write-Host "    Using: $($infFile.Name)" -ForegroundColor Gray
            Write-Host "    This will trigger automatic installation of Samsung Settings & Continuity Service" -ForegroundColor Cyan
            
            try {
                # Use pnputil to add and install the driver
                Write-Host "    Adding driver to driver store..." -ForegroundColor Gray
                $pnpResult = & pnputil.exe /add-driver "$infPath" /install 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Driver installed successfully!" -ForegroundColor Green
                    Write-Host "    Samsung Settings and Continuity Service should install automatically" -ForegroundColor Cyan
                } else {
                    Write-Warning "Automated driver installation failed"
                    Write-Host "    Error: $pnpResult" -ForegroundColor Red
                    Write-Host "`n    Manual installation required:" -ForegroundColor Yellow
                    Write-Host "    1. Open Device Manager" -ForegroundColor White
                    Write-Host "    2. Find any device under 'Other devices' or any unused device" -ForegroundColor White
                    Write-Host "    3. Right-click → Update driver → Browse → Let me pick" -ForegroundColor White
                    Write-Host "    4. Show All Devices → Have Disk → Browse to:" -ForegroundColor White
                    Write-Host "       $InstallPath" -ForegroundColor Cyan
                    Write-Host "    5. Select the .inf file and install" -ForegroundColor White
                }
            } catch {
                Write-Warning "Driver installation error: $($_.Exception.Message)"
                Write-Host "    You may need to install manually via Device Manager" -ForegroundColor Yellow
            }
        }
        }
        
        # Cleanup temp extraction
        Write-Host "`n  Cleaning up temporary files..." -ForegroundColor Gray
        Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        
        # Final verification: Ensure original Samsung service is disabled and GBeSupportService is enabled
        Write-Host "`n  Verifying service configuration..." -ForegroundColor Cyan
        
        $originalSvc = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
        if ($originalSvc) {
            if ($originalSvc.StartType -ne 'Disabled') {
                Write-Host "    ⚠ Original Samsung service not disabled, fixing..." -ForegroundColor Yellow
                Set-Service -Name "SamsungSystemSupportService" -StartupType Disabled -ErrorAction SilentlyContinue
                if ($originalSvc.Status -eq 'Running') {
                    Stop-Service -Name "SamsungSystemSupportService" -Force -ErrorAction SilentlyContinue
                }
            }
            $verifyOriginal = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
            if ($verifyOriginal.StartType -eq 'Disabled') {
                Write-Host "    ✓ Original Samsung service: Disabled" -ForegroundColor Green
            } else {
                Write-Host "    ⚠ Original Samsung service: $($verifyOriginal.StartType) (should be Disabled)" -ForegroundColor Yellow
            }
        }
        
        $gbeSvc = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
        if ($gbeSvc) {
            Write-Host "    ✓ GBeSupportService: $($gbeSvc.StartType), $($gbeSvc.Status)" -ForegroundColor Green
            if ($gbeSvc.StartType -ne 'Automatic') {
                Write-Host "    ⚠ Warning: Service is not set to Automatic startup" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    ⚠ GBeSupportService not found" -ForegroundColor Yellow
        }
        
        # Show completion summary
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  ✓ SSSE Installation Complete!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        
        Write-Host "Installation Summary:" -ForegroundColor Cyan
        Write-Host "  Location: $InstallPath" -ForegroundColor White
        Write-Host "  Service: GBeSupportService" -ForegroundColor White
        Write-Host "  Binary: Patched ✓" -ForegroundColor Green
        Write-Host "  Driver: Installed ✓" -ForegroundColor Green
        
        Write-Host "`nFiles installed:" -ForegroundColor Cyan
        $installedFiles = Get-ChildItem -Path $InstallPath -File | Select-Object -First 10
        foreach ($file in $installedFiles) {
            Write-Host "  • $($file.Name)" -ForegroundColor Gray
        }
        if ((Get-ChildItem -Path $InstallPath -File).Count -gt 10) {
            Write-Host "  • ... and $((Get-ChildItem -Path $InstallPath -File).Count - 10) more files" -ForegroundColor Gray
        }
        
        Write-Host "`nNext Steps:" -ForegroundColor Cyan
        Write-Host "  1. Complete the rest of the installer" -ForegroundColor White
        Write-Host "  2. Reboot your PC" -ForegroundColor White
        Write-Host "  3. Check if Samsung Settings appears in Start Menu" -ForegroundColor White
        Write-Host "  4. If not, wait a few minutes for automatic installation" -ForegroundColor White
        Write-Host "  5. Launch Samsung Settings and configure features" -ForegroundColor White
        
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "  If Samsung Settings doesn't appear:" -ForegroundColor Gray
        Write-Host "    • Wait 5-10 minutes (apps install in background)" -ForegroundColor Gray
        Write-Host "    • Check Store for 'Samsung Settings' and install manually" -ForegroundColor Gray
        Write-Host "    • Verify service is running:" -ForegroundColor Gray
        Write-Host "      Get-Service 'GBeSupportService'" -ForegroundColor DarkGray
        Write-Host "    • Check Event Viewer for errors" -ForegroundColor Gray
        Write-Host "    • Ensure antivirus isn't blocking the patched executable" -ForegroundColor Gray
        
        Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        return $true
        
    } catch {
        Write-Error "Installation failed: $($_.Exception.Message)"
        Write-Host "`nStack trace:" -ForegroundColor Red
        Write-Host $_.ScriptStackTrace -ForegroundColor Gray
        
        # Cleanup on error
        if (Test-Path $extractDir) {
            Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "`nInstallation was unsuccessful." -ForegroundColor Red
        Write-Host "Files may be partially copied to: $InstallPath" -ForegroundColor Yellow
        Write-Host "You can manually clean up if needed." -ForegroundColor Gray
        
        Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        return $false
    }
}

function Show-PackageSelectionMenu {
    param (
        [bool]$HasIntelWiFi
    )
    
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Samsung Package Selection" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Select installation profile:`n" -ForegroundColor Yellow
    
    Write-Host "  [1] Core Only" -ForegroundColor White
    Write-Host "      Essential packages only (Account, Settings, Cloud)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [2] Recommended" -ForegroundColor Green
    Write-Host "      Core + All working Samsung apps (Gallery, Notes, Multi Control, etc.)" -ForegroundColor Gray
    if (-not $HasIntelWiFi) {
        Write-Host "      ⚠ Note: Quick Share may not work without Intel Wi-Fi" -ForegroundColor Yellow
    }
    Write-Host ""
    
    Write-Host "  [3] Full Experience" -ForegroundColor Cyan
    Write-Host "      Recommended + Apps requiring extra setup (Phone, Find, Quick Search)" -ForegroundColor Gray
    Write-Host "      ⚠ Some apps need additional configuration after install" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "  [4] Everything" -ForegroundColor Magenta
    Write-Host "      All packages including non-working ones (Recovery, Update)" -ForegroundColor Gray
    Write-Host "      ⚠ Some apps will NOT work on non-Samsung devices" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "  [5] Custom Selection" -ForegroundColor Yellow
    Write-Host "      Pick individual packages" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [6] Skip Package Installation" -ForegroundColor DarkGray
    Write-Host ""
    
    do {
        $choice = Read-Host "Enter choice [1-6]"
    } while ($choice -notin "1","2","3","4","5","6")
    
    return $choice
}

function Get-PackagesByProfile {
    param (
        [string]$ProfileName
    )
    
    $packages = @()
    
    switch ($ProfileName) {
        "1" { # Core Only
            $packages = $PackageDatabase.Core
        }
        "2" { # Recommended
            $packages = $PackageDatabase.Core + $PackageDatabase.Recommended
        }
        "3" { # Full Experience
            $packages = $PackageDatabase.Core + $PackageDatabase.Recommended + $PackageDatabase.ExtraSteps
        }
        "4" { # Everything
            $packages = $PackageDatabase.Core + $PackageDatabase.Recommended + $PackageDatabase.ExtraSteps + $PackageDatabase.NonWorking
        }
    }
    
    return $packages
}

function Show-CustomPackageSelection {
    param (
        [bool]$HasIntelWiFi
    )
    
    $selectedPackages = @()
    
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Custom Package Selection" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Group packages by category for better organization
    $categories = @{
        "Core" = $PackageDatabase.Core
        "Connectivity" = @()
        "Productivity" = @()
        "Media" = @()
        "Experience" = @()
        "Security" = @()
        "Maintenance" = @()
        "Other" = @()
    }
    
    foreach ($pkg in ($PackageDatabase.Recommended + $PackageDatabase.ExtraSteps + $PackageDatabase.NonWorking)) {
        if ($categories.ContainsKey($pkg.Category)) {
            $categories[$pkg.Category] += $pkg
        } else {
            $categories["Other"] += $pkg
        }
    }
    
    # Core packages (required)
    Write-Host "CORE PACKAGES (Auto-selected):" -ForegroundColor Green
    foreach ($pkg in $PackageDatabase.Core) {
        Write-Host "  ✓ $($pkg.Name)" -ForegroundColor Gray
        $selectedPackages += $pkg
    }
    Write-Host ""
    
    # Show other categories
    $categoryOrder = @("Connectivity", "Productivity", "Media", "Experience", "Security", "Maintenance", "Other")
    
    foreach ($catName in $categoryOrder) {
        $catPackages = $categories[$catName]
        if ($catPackages.Count -eq 0) { continue }
        
        Write-Host "$catName PACKAGES:" -ForegroundColor Yellow
        $selectAll = Read-Host "  Install all $catName packages? (Y/N/I for individual)"
        
        if ($selectAll -eq "Y" -or $selectAll -eq "y") {
            foreach ($pkg in $catPackages) {
                Write-Host "  ✓ $($pkg.Name)" -ForegroundColor Green
                $selectedPackages += $pkg
            }
        } elseif ($selectAll -eq "I" -or $selectAll -eq "i") {
            foreach ($pkg in $catPackages) {
                Write-Host ""
                Write-Host "  $($pkg.Name)" -ForegroundColor White
                Write-Host "    $($pkg.Description)" -ForegroundColor Gray
                
                if ($pkg.Warning) {
                    Write-Host "    ⚠ $($pkg.Warning)" -ForegroundColor Yellow
                }
                if ($pkg.RequiresIntelWiFi -and -not $HasIntelWiFi) {
                    Write-Host "    ⚠ Your Wi-Fi adapter may not be compatible" -ForegroundColor Red
                }
                
                $install = Read-Host "    Install? (Y/N)"
                if ($install -eq "Y" -or $install -eq "y") {
                    Write-Host "    ✓ Added" -ForegroundColor Green
                    $selectedPackages += $pkg
                }
            }
        }
        Write-Host ""
    }
    
    return $selectedPackages
}

function Install-SamsungPackages {
    param (
        [array]$Packages,
        [bool]$TestMode = $false
    )
    
    $installed = 0
    $failed = 0
    $skipped = 0
    
    if ($TestMode) {
        Write-Host "`n[TEST MODE] Simulating installation of $($Packages.Count) package(s)...`n" -ForegroundColor Yellow
    } else {
        Write-Host "`nInstalling $($Packages.Count) package(s)...`n" -ForegroundColor Cyan
    }
    
    foreach ($pkg in $Packages) {
        Write-Host "[$($installed + $failed + $skipped + 1)/$($Packages.Count)] " -NoNewline -ForegroundColor Gray
        Write-Host "$($pkg.Name)" -ForegroundColor White
        
        if ($pkg.Warning) {
            Write-Host "  ⚠ $($pkg.Warning)" -ForegroundColor Yellow
        }
        
        if ($TestMode) {
            Write-Host "  [TEST] Would check: winget list --id $($pkg.Id)" -ForegroundColor Gray
            Write-Host "  [TEST] Would install: winget install --id $($pkg.Id)" -ForegroundColor Gray
            Write-Host "  ✓ Simulated" -ForegroundColor Green
            $installed++
        } else {
            try {
                # Check if package is already installed
                Write-Host "  Checking installation status..." -ForegroundColor Gray
                $checkResult = winget list --id $pkg.Id 2>&1 | Out-String
                
                if ($checkResult -match $pkg.Id) {
                    Write-Host "  ✓ Already installed (skipping)" -ForegroundColor Cyan
                    $skipped++
                } else {
                    Write-Host "  Installing..." -ForegroundColor Gray
                    $installOutput = winget install --accept-source-agreements --accept-package-agreements --id $pkg.Id 2>&1 | Out-String
                    
                    # Winget always returns 0 even when "already installed" or "no upgrade found"
                    # Parse output to determine actual result
                    if ($installOutput -match "Successfully installed|Installation completed successfully") {
                        Write-Host "  ✓ Installed successfully" -ForegroundColor Green
                        $installed++
                    } elseif ($installOutput -match "already installed|No available upgrade found|No newer package versions") {
                        Write-Host "  ✓ Already installed" -ForegroundColor Cyan
                        $skipped++
                    } elseif ($LASTEXITCODE -ne 0) {
                        Write-Host "  ✗ Installation failed" -ForegroundColor Red
                        $failed++
                    } else {
                        # Exit code 0 but unclear message - assume already installed/up to date
                        Write-Host "  ✓ Already up to date" -ForegroundColor Cyan
                        $skipped++
                    }
                }
            } catch {
                Write-Host "  ✗ Error: $_" -ForegroundColor Red
                $failed++
            }
        }
        
        Write-Host ""
    }
    
    return @{
        Installed = $installed
        Failed = $failed
        Skipped = $skipped
        Total = $Packages.Count
    }
}

function Test-IntelWiFi {
    $wifiAdapters = Get-NetAdapter | Where-Object { 
        $_.InterfaceDescription -like "*Wi-Fi*" -or 
        $_.InterfaceDescription -like "*Wireless*" -or
        $_.InterfaceDescription -like "*802.11*"
    }
    
    if ($wifiAdapters.Count -eq 0) {
        return @{
            HasWiFi = $false
            IsIntel = $false
            AdapterName = "None"
            Model = "None"
        }
    }
    
    $wifiInfo = $wifiAdapters[0].InterfaceDescription
    $isIntel = $wifiInfo -like "*Intel*"
    
    # Detect specific Intel Wi-Fi models
    $model = "Unknown"
    if ($isIntel) {
        if ($wifiInfo -match "(AX\d+|AC \d+|Wi-Fi \d+[E]?)") {
            $model = $matches[1]
        }
    }
    
    return @{
        HasWiFi = $true
        IsIntel = $isIntel
        AdapterName = $wifiInfo
        Model = $model
    }
}

function Get-LegacyBiosValues {
    param (
        [string]$OldBatchPath
    )
    
    if (-not (Test-Path $OldBatchPath)) {
        return $null
    }
    
    try {
        $content = Get-Content $OldBatchPath -Raw
        
        # Default values (Galaxy Book3 Ultra) for comparison
        $defaults = @{
            BIOSVendor = "American Megatrends International, LLC."
            BIOSVersion = "P04RKI.049.220408.ZQ"
            BIOSMajorRelease = "0x04"
            BIOSMinorRelease = "0x11"
            SystemManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            SystemFamily = "Galaxy Book3 Ultra"
            SystemProductName = "NP960XFH-XA2UK"
            ProductSku = "SCAI-A5A5-ADLP-PSLP"
            EnclosureKind = "0x1f"
            BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            BaseBoardProduct = "NP960XFH-XA2UK"
        }
        
        # Extract all 11 registry values using regex
        $values = @{}
        
        # String values (REG_SZ)
        if ($content -match 'BIOSVendor.*?/d\s+"([^"]+)"') {
            $values.BIOSVendor = $Matches[1]
        }
        if ($content -match 'BIOSVersion.*?/d\s+"([^"]+)"') {
            $values.BIOSVersion = $Matches[1]
        }
        if ($content -match 'SystemManufacturer.*?/d\s+"([^"]+)"') {
            $values.SystemManufacturer = $Matches[1]
        }
        if ($content -match 'SystemFamily.*?/d\s+"([^"]+)"') {
            $values.SystemFamily = $Matches[1]
        }
        if ($content -match 'SystemProductName.*?/d\s+"([^"]+)"') {
            $values.SystemProductName = $Matches[1]
        }
        if ($content -match 'ProductSku.*?/d\s+"([^"]+)"') {
            $values.ProductSku = $Matches[1]
        }
        if ($content -match 'BaseBoardManufacturer.*?/d\s+"([^"]+)"') {
            $values.BaseBoardManufacturer = $Matches[1]
        }
        if ($content -match 'BaseBoardProduct.*?/d\s+"([^"]+)"') {
            $values.BaseBoardProduct = $Matches[1]
        }
        
        # DWORD values (REG_DWORD) - can be with or without quotes
        if ($content -match 'BIOSMajorRelease.*?/d\s+["]?([0-9x]+)["]?\s+/f') {
            $values.BIOSMajorRelease = $Matches[1]
        }
        if ($content -match 'BIOSMinorRelease.*?/d\s+["]?([0-9x]+)["]?\s+/f') {
            $values.BIOSMinorRelease = $Matches[1]
        }
        if ($content -match 'EnclosureKind.*?/d\s+["]?([0-9x]+)["]?\s+/f') {
            $values.EnclosureKind = $Matches[1]
        }
        
        # Check if values are custom (different from Galaxy Book3 Ultra defaults)
        $customCount = 0
        foreach ($key in $values.Keys) {
            if ($defaults.ContainsKey($key) -and $values[$key] -ne $defaults[$key]) {
                $customCount++
            }
        }
        
        # Consider it custom if we found values and at least one differs from defaults
        $isCustom = $values.Count -ge 3 -and $customCount -gt 0
        
        if ($isCustom) {
            return @{
                IsCustom = $true
                Values = $values
            }
        }
        
        return $null
    } catch {
        Write-Verbose "Failed to parse legacy batch file: $_"
        return $null
    }
}

function New-RegistrySpoofBatch {
    param (
        [string]$OutputPath,
        [hashtable]$BiosValues = $null
    )
    
    # Default values (Galaxy Book3 Ultra)
    $defaults = @{
        BIOSVendor = "American Megatrends International, LLC."
        BIOSVersion = "P04RKI.049.220408.ZQ"
        BIOSMajorRelease = "0x04"
        BIOSMinorRelease = "0x11"
        SystemManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
        SystemFamily = "Galaxy Book3 Ultra"
        SystemProductName = "NP960XFH-XA2UK"
        ProductSku = "SCAI-A5A5-ADLP-PSLP"
        EnclosureKind = "0x1f"
        BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
        BaseBoardProduct = "NP960XFH-XA2UK"
    }
    
    # Use custom values if provided, otherwise use defaults
    $values = if ($BiosValues) { $BiosValues } else { $defaults }
    
    # Ensure all keys exist (fill missing ones with defaults)
    foreach ($key in $defaults.Keys) {
        if (-not $values.ContainsKey($key)) {
            $values[$key] = $defaults[$key]
        }
    }
    
    # Helper function to format registry value
    function Format-RegValue {
        param($Key, $Value)
        
        $isDword = $Key -match '(Release|Kind)$'
        $type = if ($isDword) { "REG_DWORD" } else { "REG_SZ" }
        $formattedValue = if ($isDword) { $Value } else { "`"$Value`"" }
        
        return "reg add `"HKLM\HARDWARE\DESCRIPTION\System\BIOS`" /v $Key /t $type /d $formattedValue /f"
    }
    
    $batchContent = @"
@echo off
REM ============================================================================
REM Galaxy Book Enabler - Registry Spoof Script
REM Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
REM ============================================================================

$(Format-RegValue "BIOSVendor" $values.BIOSVendor)
$(Format-RegValue "BIOSVersion" $values.BIOSVersion)
$(Format-RegValue "BIOSMajorRelease" $values.BIOSMajorRelease)
$(Format-RegValue "BIOSMinorRelease" $values.BIOSMinorRelease)
$(Format-RegValue "SystemManufacturer" $values.SystemManufacturer)
$(Format-RegValue "SystemFamily" $values.SystemFamily)
$(Format-RegValue "SystemProductName" $values.SystemProductName)
$(Format-RegValue "ProductSku" $values.ProductSku)
$(Format-RegValue "EnclosureKind" $values.EnclosureKind)
$(Format-RegValue "BaseBoardManufacturer" $values.BaseBoardManufacturer)
$(Format-RegValue "BaseBoardProduct" $values.BaseBoardProduct)

REM ============================================================================
REM Model: $($values.SystemFamily) ($($values.SystemProductName))
REM ============================================================================
"@
    
    $batchContent | Set-Content $OutputPath -Encoding ASCII
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    pause
    exit
}

$taskName = "GalaxyBookEnabler"
$installPath = Join-Path $env:USERPROFILE ".galaxy-book-enabler"
$batchScriptPath = Join-Path $installPath "GalaxyBookSpoof.bat"
$configPath = Join-Path $installPath "gbe-config.json"

# ==================== UNINSTALL MODE ====================
if ($Uninstall) {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  Galaxy Book Enabler UNINSTALLER" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    
    Write-Host "This will remove:" -ForegroundColor Yellow
    Write-Host "  • Scheduled task: $taskName" -ForegroundColor Gray
    Write-Host "  • Installation folder: $installPath" -ForegroundColor Gray
    Write-Host "  • Registry spoofing will remain until next reboot" -ForegroundColor Gray
    Write-Host ""
    
    $confirm = Read-Host "Are you sure you want to uninstall? (Y/N)"
    
    if ($confirm -notlike "y*") {
        Write-Host "`nUninstall cancelled." -ForegroundColor Yellow
        pause
        exit
    }
    
    Write-Host "`nUninstalling..." -ForegroundColor Yellow
    
    # Remove scheduled task
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "  Removing scheduled task..." -ForegroundColor Gray
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "  ✓ Task removed" -ForegroundColor Green
    }
    
    # Remove installation folder
    if (Test-Path $installPath) {
        Write-Host "  Removing installation folder..." -ForegroundColor Gray
        Remove-Item -Path $installPath -Recurse -Force
        Write-Host "  ✓ Folder removed" -ForegroundColor Green
    }
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Uninstall Complete!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    Write-Host "Note: Registry spoof will remain until you reboot." -ForegroundColor Yellow
    Write-Host "After rebooting, Samsung features will no longer work.`n" -ForegroundColor Gray
    
    pause
    exit
}

# ==================== INSTALL MODE ====================
Clear-Host

if ($TestMode) {
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  Galaxy Book Enabler INSTALLER" -ForegroundColor Magenta
    Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Magenta
    Write-Host "  *** TEST MODE - NO CHANGES APPLIED ***" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Magenta
    Write-Host "Test mode will simulate the installation without:" -ForegroundColor Yellow
    Write-Host "  • Creating scheduled tasks" -ForegroundColor Gray
    Write-Host "  • Modifying registry values" -ForegroundColor Gray
    Write-Host "  • Installing packages via winget" -ForegroundColor Gray
    Write-Host "  • Creating/starting services" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Galaxy Book Enabler INSTALLER" -ForegroundColor Cyan
    Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

# Check if already installed
$alreadyInstalled = (Test-Path $installPath) -or (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)

# Initialize BIOS values variable (may be set during reinstall)
$biosValuesToUse = $null

if ($alreadyInstalled) {
    Write-Host "⚠ Galaxy Book Enabler is already installed!" -ForegroundColor Yellow
    
    $currentVersion = "Unknown"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath | ConvertFrom-Json
            $currentVersion = if ($config.InstalledVersion) { $config.InstalledVersion } else { "1.0.0" }
        } catch {
            Write-Verbose "Failed to read config file, using default version"
        }
    }
    Write-Host "Current version: $currentVersion" -ForegroundColor Gray
    Write-Host "Installer version: $SCRIPT_VERSION" -ForegroundColor Gray
    
    # Check for updates from GitHub
    Write-Host "`nChecking for updates..." -ForegroundColor Cyan
    $updateCheck = Test-UpdateAvailable
    
    if ($updateCheck.Available) {
        Write-Host "✨ New version available: v$($updateCheck.LatestVersion)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Release notes:" -ForegroundColor Yellow
        if ($updateCheck.ReleaseNotes) {
            $noteLength = [Math]::Min(500, $updateCheck.ReleaseNotes.Length)
            Write-Host $updateCheck.ReleaseNotes.Substring(0, $noteLength) -ForegroundColor Gray
            if ($updateCheck.ReleaseNotes.Length -gt 500) {
                Write-Host "..." -ForegroundColor Gray
            }
        }
        Write-Host ""
        
        Write-Host "What would you like to do?" -ForegroundColor Cyan
        Write-Host "  [1] Download and install latest version (v$($updateCheck.LatestVersion))" -ForegroundColor Green
        Write-Host "  [2] Update to installer version (v$SCRIPT_VERSION)" -ForegroundColor Gray
        Write-Host "  [3] Reinstall current version" -ForegroundColor Gray
        Write-Host "  [4] Uninstall" -ForegroundColor Gray
        Write-Host "  [5] Cancel" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-5]"
        
        if ($choice -eq "1") {
            if (Update-GalaxyBookEnabler -DownloadUrl $updateCheck.DownloadUrl) {
                # Will exit if successful
            } else {
                Write-Host "Falling back to installer version..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    } else {
        if ($updateCheck.Error) {
            Write-Host "⚠ Could not check for updates (offline?)" -ForegroundColor Yellow
        } else {
            Write-Host "✓ You have the latest version" -ForegroundColor Green
        }
        
        Write-Host "`nWhat would you like to do?" -ForegroundColor Cyan
        Write-Host "  [1] Update to installer version (v$SCRIPT_VERSION)" -ForegroundColor Gray
        Write-Host "  [2] Reinstall" -ForegroundColor Gray
        Write-Host "  [3] Uninstall" -ForegroundColor Gray
        Write-Host "  [4] Cancel" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-4]"
    }
    
    switch ($choice) {
        "1" {
            Write-Host "`nUpdating to version $SCRIPT_VERSION..." -ForegroundColor Cyan
            
            # Check if there's a custom BIOS config to preserve
            if (Test-Path $batchScriptPath) {
                $backupBiosValues = Get-LegacyBiosValues -OldBatchPath $batchScriptPath
                if ($backupBiosValues -and $backupBiosValues.IsCustom) {
                    Write-Host "`nDetected custom BIOS configuration:" -ForegroundColor Yellow
                    Write-Host "  Model: $($backupBiosValues.Values.SystemFamily) ($($backupBiosValues.Values.SystemProductName))" -ForegroundColor Cyan
                    Write-Host ""
                    $preserveChoice = Read-Host "Keep your custom config? (Y=Keep custom, N=Use default GB3U)"
                    
                    if ($preserveChoice -eq "Y" -or $preserveChoice -eq "y") {
                        $biosValuesToUse = $backupBiosValues.Values
                        Write-Host "  ✓ Will preserve your custom BIOS values" -ForegroundColor Green
                    } else {
                        Write-Host "  ✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
                    }
                }
            }
        }
        "2" {
            Write-Host "`nReinstalling..." -ForegroundColor Yellow
            
            # Backup existing BIOS configuration before reinstall
            $backupBiosValues = $null
            if (Test-Path $batchScriptPath) {
                Write-Host "  Backing up current BIOS configuration..." -ForegroundColor Cyan
                $backupBiosValues = Get-LegacyBiosValues -OldBatchPath $batchScriptPath
                if ($backupBiosValues -and $backupBiosValues.IsCustom) {
                    Write-Host "  ✓ Custom BIOS values backed up" -ForegroundColor Green
                }
            }
            
            # Remove existing installation
            if (Test-Path $installPath) {
                Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
            }
            $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($existingTask) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            }
            
            # Ask user if they want to restore backed up BIOS values
            if ($backupBiosValues -and $backupBiosValues.IsCustom) {
                Write-Host "`nDetected custom BIOS configuration:" -ForegroundColor Yellow
                Write-Host "  Model: $($backupBiosValues.Values.SystemFamily) ($($backupBiosValues.Values.SystemProductName))" -ForegroundColor Cyan
                Write-Host ""
                $preserveChoice = Read-Host "Keep your custom config? (Y=Keep custom, N=Use default GB3U)"
                
                if ($preserveChoice -eq "Y" -or $preserveChoice -eq "y") {
                    $biosValuesToUse = $backupBiosValues.Values
                    Write-Host "  ✓ Will restore your custom BIOS values" -ForegroundColor Green
                } else {
                    Write-Host "  ✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
                }
            }
        }
        "3" {
            # Run uninstall inline
            Write-Host "`nUninstalling..." -ForegroundColor Yellow
            
            $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($existingTask) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                Write-Host "  ✓ Task removed" -ForegroundColor Green
            }
            
            if (Test-Path $installPath) {
                Remove-Item -Path $installPath -Recurse -Force
                Write-Host "  ✓ Folder removed" -ForegroundColor Green
            }
            
            Write-Host "`nUninstall complete!" -ForegroundColor Green
            pause
            exit
        }
        "4" {
            # Uninstall (for 5-option menu) or Cancel (for 4-option menu)
            # Check which menu was shown based on update availability
            if ($updateCheck.Available) {
                # 5-option menu: option 4 is Uninstall
                Write-Host "`nUninstalling..." -ForegroundColor Yellow
                
                $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
                if ($existingTask) {
                    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                    Write-Host "  ✓ Task removed" -ForegroundColor Green
                }
                
                if (Test-Path $installPath) {
                    Remove-Item -Path $installPath -Recurse -Force
                    Write-Host "  ✓ Folder removed" -ForegroundColor Green
                }
                
                Write-Host "`nUninstall complete!" -ForegroundColor Green
                pause
                exit
            } else {
                # 4-option menu: option 4 is Cancel
                Write-Host "`nCancelled." -ForegroundColor Yellow
                pause
                exit
            }
        }
        "5" {
            # Cancel (only for 5-option menu when update is available)
            Write-Host "`nCancelled." -ForegroundColor Yellow
            pause
            exit
        }
        default {
            Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
            pause
            exit
        }
    }
}

# ==================== STEP 1: SYSTEM COMPATIBILITY CHECK ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 1: System Compatibility Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Checking Wi-Fi adapter..." -ForegroundColor Yellow
$wifiCheck = Test-IntelWiFi

if ($wifiCheck.HasWiFi) {
    Write-Host "Detected: $($wifiCheck.AdapterName)" -ForegroundColor Green
    
    if ($wifiCheck.IsIntel) {
        Write-Host "✓ Intel Wi-Fi adapter - Full Samsung Quick Share compatibility!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Non-Intel Wi-Fi adapter detected" -ForegroundColor Yellow
        Write-Host "  Quick Share may have limited functionality" -ForegroundColor Gray
        Write-Host "  Alternative: Google Nearby Share works with any adapter" -ForegroundColor Cyan
        Write-Host "  https://www.android.com/better-together/nearby-share-app/" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠ No Wi-Fi adapter detected" -ForegroundColor Yellow
    Write-Host "  Quick Share requires Wi-Fi to function" -ForegroundColor Gray
}

Write-Host ""

# ==================== STEP 2: CREATE INSTALLATION ====================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 2: Setting Up Files" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (-not (Test-Path $installPath)) {
    New-Item -Path $installPath -ItemType Directory -Force | Out-Null
}

# Check for legacy v1.x installation
$legacyPath = Join-Path $env:USERPROFILE "GalaxyBookEnablerScript"
$legacyBatchPath = Join-Path $legacyPath "QS.bat"

# Skip legacy check if reinstalling (BIOS values already backed up)
if ((Test-Path $legacyBatchPath) -and -not $biosValuesToUse) {
    Write-Host "Detected legacy installation (v1.x)" -ForegroundColor Yellow
    
    $legacyValues = Get-LegacyBiosValues -OldBatchPath $legacyBatchPath
    
    if ($legacyValues -and $legacyValues.IsCustom) {
        Write-Host "`nCustom BIOS values detected in old QS.bat:" -ForegroundColor Cyan
        
        # Display all detected custom values
        $defaults = @{
            BIOSVendor = "American Megatrends International, LLC."
            BIOSVersion = "P04RKI.049.220408.ZQ"
            BIOSMajorRelease = "0x04"
            BIOSMinorRelease = "0x11"
            SystemManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            SystemFamily = "Galaxy Book3 Ultra"
            SystemProductName = "NP960XFH-XA2UK"
            ProductSku = "SCAI-A5A5-ADLP-PSLP"
            EnclosureKind = "0x1f"
            BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            BaseBoardProduct = "NP960XFH-XA2UK"
        }
        
        $customCount = 0
        foreach ($key in $legacyValues.Values.Keys | Sort-Object) {
            $value = $legacyValues.Values[$key]
            $isCustom = $defaults[$key] -ne $value
            $marker = if ($isCustom) { "→" } else { " " }
            $color = if ($isCustom) { "Green" } else { "DarkGray" }
            Write-Host "  $marker $($key.PadRight(25)) = $value" -ForegroundColor $color
            if ($isCustom) { $customCount++ }
        }
        
        Write-Host "`nDetected model: $($legacyValues.Values.SystemFamily) ($($legacyValues.Values.SystemProductName))" -ForegroundColor Cyan
        Write-Host "Custom values: $customCount/$($legacyValues.Values.Count) keys modified from GB3U defaults" -ForegroundColor Yellow
        Write-Host ""
        
        $preserve = Read-Host "Would you like to preserve these custom values? (Y/N)"
        
        if ($preserve -eq "Y" -or $preserve -eq "y") {
            $biosValuesToUse = $legacyValues.Values
            Write-Host "✓ Will use your custom BIOS values" -ForegroundColor Green
        } else {
            Write-Host "✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
        }
    } else {
        Write-Host "✓ Legacy installation uses standard values" -ForegroundColor Green
    }
    Write-Host ""
}

# Create the batch file for registry spoofing
Write-Host "Creating registry spoof script..." -ForegroundColor Yellow
New-RegistrySpoofBatch -OutputPath $batchScriptPath -BiosValues $biosValuesToUse

if ($biosValuesToUse) {
    Write-Host "✓ Registry spoof script created (custom values preserved)" -ForegroundColor Green
} else {
    Write-Host "✓ Registry spoof script created (Galaxy Book3 Ultra)" -ForegroundColor Green
}

# Clean up legacy installation if it exists
if (Test-Path $legacyPath) {
    Write-Host "Cleaning up legacy installation files..." -ForegroundColor Yellow
    try {
        Remove-Item $legacyPath -Recurse -Force -ErrorAction Stop
        Write-Host "✓ Legacy files removed" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not remove legacy files: $_" -ForegroundColor Yellow
        Write-Host "  You can manually delete: $legacyPath" -ForegroundColor Gray
    }
}

# Save configuration
$config = @{
    InstalledVersion = $SCRIPT_VERSION
    InstallDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    WiFiAdapter = $wifiCheck.AdapterName
    IsIntelWiFi = $wifiCheck.IsIntel
}

$config | ConvertTo-Json | Set-Content $configPath
Write-Host "✓ Configuration saved" -ForegroundColor Green

# ==================== STEP 3: SCHEDULED TASK ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 3: Creating Startup Task" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($TestMode) {
    Write-Host "[TEST MODE] Skipping scheduled task creation" -ForegroundColor Yellow
    Write-Host "  Would create task: $taskName" -ForegroundColor Gray
    Write-Host "  Would execute: $batchScriptPath" -ForegroundColor Gray
    Write-Host "  Would run as: SYSTEM (at startup + 10s delay)" -ForegroundColor Gray
} else {
    # Remove existing task if present
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    $taskDescription = "Spoofs system as Samsung Galaxy Book to enable Samsung features"
    $action = New-ScheduledTaskAction -Execute $batchScriptPath
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $trigger.Delay = "PT10S"
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null

    Write-Host "✓ Scheduled task created" -ForegroundColor Green
    Write-Host "  The spoof will run automatically on startup" -ForegroundColor Gray
}

# ==================== STEP 4: AI SELECT KEYBOARD SHORTCUT ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 4: AI Select Configuration" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "AI Select is Samsung's intelligent selection tool." -ForegroundColor White
Write-Host "To launch it, you need to create a keyboard shortcut.`n" -ForegroundColor Gray

Write-Host "The launch command is:" -ForegroundColor Yellow
Write-Host "  explorer.exe shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App" -ForegroundColor Cyan
Write-Host ""

Write-Host "How to set up the keyboard shortcut:" -ForegroundColor Yellow
Write-Host "  1. Create a shortcut to the above command" -ForegroundColor Gray
Write-Host "  2. Right-click shortcut → Properties" -ForegroundColor Gray
Write-Host "  3. Set 'Shortcut key' (e.g., Ctrl+Alt+S)" -ForegroundColor Gray
Write-Host "  4. Click OK" -ForegroundColor Gray
Write-Host ""

$setupShortcut = Read-Host "Would you like to create a shortcut on your Desktop? (Y/N)"

if ($setupShortcut -like "y*") {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "AI Select.lnk")
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "explorer.exe"
    $shortcut.Arguments = "shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App"
    $shortcut.IconLocation = "shell32.dll,23"
    $shortcut.Save()
    
    Write-Host "✓ Shortcut created on Desktop!" -ForegroundColor Green
    Write-Host "  Right-click it → Properties → Set 'Shortcut key' to assign a keyboard shortcut" -ForegroundColor Gray
} else {
    Write-Host "✓ Skipped shortcut creation" -ForegroundColor Green
    Write-Host "  You can manually create it later if needed" -ForegroundColor Gray
}

# ==================== STEP 5: SYSTEM SUPPORT ENGINE (OPTIONAL/ADVANCED) ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 5: System Support Engine (Advanced)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ssseInstalled = Install-SystemSupportEngine -TestMode $TestMode

# ==================== STEP 6: PACKAGE INSTALLATION ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 6: Samsung Software Installation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$installChoice = Show-PackageSelectionMenu -HasIntelWiFi $wifiCheck.IsIntel

$packagesToInstall = @()

if ($installChoice -eq "6") {
    Write-Host "✓ Skipping package installation" -ForegroundColor Green
    Write-Host "  You can install packages manually from the Microsoft Store" -ForegroundColor Gray
} elseif ($installChoice -eq "5") {
    # Custom selection
    $packagesToInstall = Show-CustomPackageSelection -HasIntelWiFi $wifiCheck.IsIntel
} else {
    # Profile-based selection
    $packagesToInstall = Get-PackagesByProfile -ProfileName $installChoice
    
    # Show what will be installed
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Installation Summary" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "The following packages will be installed:`n" -ForegroundColor Yellow
    
    foreach ($pkg in $packagesToInstall) {
        $statusColor = switch ($pkg.Status) {
            "Working" { "Green" }
            "RequiresExtraSteps" { "Yellow" }
            "NotWorking" { "Red" }
            default { "White" }
        }
        
        Write-Host "  • $($pkg.Name)" -ForegroundColor $statusColor
        
        if ($pkg.Warning) {
            Write-Host "    ⚠ $($pkg.Warning)" -ForegroundColor Yellow
        }
        
        if ($pkg.RequiresIntelWiFi -and -not $wifiCheck.IsIntel) {
            Write-Host "    ⚠ May not work with your Wi-Fi adapter" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Total packages: $($packagesToInstall.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    $confirm = Read-Host "Proceed with installation? (Y/N)"
    
    if ($confirm -notlike "y*") {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        pause
        exit
    }
}

# Install packages if any were selected
if ($packagesToInstall.Count -gt 0) {
    $installResult = Install-SamsungPackages -Packages $packagesToInstall -TestMode $TestMode
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Installation Results" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Successfully installed: $($installResult.Installed)/$($installResult.Total)" -ForegroundColor Green
    
    if ($installResult.Skipped -gt 0) {
        Write-Host "Already installed (skipped): $($installResult.Skipped)" -ForegroundColor Cyan
    }
    
    if ($installResult.Failed -gt 0) {
        Write-Host "Failed: $($installResult.Failed)" -ForegroundColor Red
        Write-Host "  Tip: Failed packages can be installed manually from Microsoft Store" -ForegroundColor Gray
    }
    
    Write-Host ""
    
    # Show Quick Share specific warning if selected
    $quickShareSelected = $packagesToInstall | Where-Object { $_.Name -eq "Quick Share" }
    if ($quickShareSelected -and -not $wifiCheck.IsIntel) {
        Write-Host "⚠ QUICK SHARE WARNING:" -ForegroundColor Yellow
        Write-Host "  Quick Share was installed but may not work with your Wi-Fi adapter." -ForegroundColor Yellow
        Write-Host "  If you experience issues, consider Google Nearby Share as an alternative." -ForegroundColor Gray
        Write-Host "  https://www.android.com/better-together/nearby-share-app/" -ForegroundColor Cyan
        Write-Host ""
    }
    
    # Show extra steps warning if applicable
    $extraStepsPackages = $packagesToInstall | Where-Object { $_.Status -eq "RequiresExtraSteps" }
    if ($extraStepsPackages.Count -gt 0) {
        Write-Host "⚠ ADDITIONAL CONFIGURATION REQUIRED:" -ForegroundColor Yellow
        Write-Host "  The following apps need extra setup steps:" -ForegroundColor Yellow
        foreach ($pkg in $extraStepsPackages) {
            Write-Host "    • $($pkg.Name)" -ForegroundColor White
        }
        Write-Host "  Check the documentation for configuration instructions." -ForegroundColor Gray
        Write-Host ""
    }
    
    # Show non-working warning if applicable
    $nonWorkingPackages = $packagesToInstall | Where-Object { $_.Status -eq "NotWorking" }
    if ($nonWorkingPackages.Count -gt 0) {
        Write-Host "⚠ NON-FUNCTIONAL APPS INSTALLED:" -ForegroundColor Red
        Write-Host "  The following apps will NOT work on non-Samsung devices:" -ForegroundColor Red
        foreach ($pkg in $nonWorkingPackages) {
            Write-Host "    • $($pkg.Name)" -ForegroundColor White
        }
        Write-Host ""
    }
}

# ==================== STEP 7: APPLY SPOOF NOW ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 7: Applying Registry Spoof" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($TestMode) {
    Write-Host "[TEST MODE] Skipping registry modification" -ForegroundColor Yellow
    Write-Host "  Would execute: $batchScriptPath" -ForegroundColor Gray
    Write-Host "  Registry keys that would be modified:" -ForegroundColor Gray
    Write-Host "    HKLM\HARDWARE\DESCRIPTION\System\BIOS (11 values)" -ForegroundColor Gray
} else {
    Write-Host "Applying Samsung Galaxy Book spoof..." -ForegroundColor Yellow
    Start-Process -FilePath $batchScriptPath -Wait -NoNewWindow
    Write-Host "✓ Registry spoof applied!" -ForegroundColor Green
    Write-Host "  Your PC now identifies as a Samsung Galaxy Book3 Ultra" -ForegroundColor Gray
}

# ==================== COMPLETION ====================
if ($TestMode) {
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "  Test Run Complete!" -ForegroundColor Magenta
    Write-Host "========================================`n" -ForegroundColor Magenta
    
    Write-Host "Test mode completed successfully." -ForegroundColor Yellow
    Write-Host "No actual changes were made to your system." -ForegroundColor Green
    Write-Host ""
    Write-Host "To perform actual installation, run without -TestMode:" -ForegroundColor Cyan
    Write-Host "  .\\Install-GalaxyBookEnabler.ps1" -ForegroundColor White
} else {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Installation Complete!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green

    Write-Host "Configuration:" -ForegroundColor Cyan
    Write-Host "  Version: $SCRIPT_VERSION" -ForegroundColor White
    Write-Host "  Location: $installPath" -ForegroundColor Gray
    Write-Host "  Task: $taskName" -ForegroundColor Gray
    Write-Host "  Wi-Fi: $($config.WiFiAdapter)" -ForegroundColor Gray

    Write-Host "`nWhat's Next:" -ForegroundColor Cyan
    Write-Host "  1. Reboot your PC for all changes to take effect" -ForegroundColor White
    Write-Host "  2. Sign in to Samsung Account in the Samsung apps" -ForegroundColor White
    Write-Host "  3. Configure Quick Share and other Samsung features" -ForegroundColor White
    if ($setupShortcut -like "y*") {
        Write-Host "  4. Set keyboard shortcut for AI Select (Desktop shortcut)" -ForegroundColor White
    }

    Write-Host "`nUpdate/Manage:" -ForegroundColor Cyan
    Write-Host "  Check for updates: irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex" -ForegroundColor Gray
    Write-Host "  Uninstall: .\Install-GalaxyBookEnabler.ps1 -Uninstall" -ForegroundColor Gray
}

Write-Host "`n"
pause