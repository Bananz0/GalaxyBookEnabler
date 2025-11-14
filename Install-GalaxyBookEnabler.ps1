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
    irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
    Installs in one line from GitHub.

.NOTES
    File Name      : Install-GalaxyBookEnabler.ps1
    Prerequisite   : PowerShell 7.0 or later
    Requires Admin : Yes
    Version        : 2.0.0
    Repository     : https://github.com/Bananz0/GalaxyBookEnabler
#>

param(
    [switch]$Uninstall
)

# VERSION CONSTANT - Update this when releasing new versions
$SCRIPT_VERSION = "2.0.0"
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
        [array]$Packages
    )
    
    $installed = 0
    $failed = 0
    $skipped = 0
    
    Write-Host "`nInstalling $($Packages.Count) package(s)...`n" -ForegroundColor Cyan
    
    foreach ($pkg in $Packages) {
        Write-Host "[$($installed + $failed + $skipped + 1)/$($Packages.Count)] " -NoNewline -ForegroundColor Gray
        Write-Host "$($pkg.Name)" -ForegroundColor White
        
        if ($pkg.Warning) {
            Write-Host "  ⚠ $($pkg.Warning)" -ForegroundColor Yellow
        }
        
        try {
            # Check if package is already installed
            Write-Host "  Checking installation status..." -ForegroundColor Gray
            $checkResult = winget list --id $pkg.Id 2>&1
            
            if ($LASTEXITCODE -eq 0 -and $checkResult -match $pkg.Id) {
                Write-Host "  ✓ Already installed (skipping)" -ForegroundColor Cyan
                $skipped++
            } else {
                Write-Host "  Installing..." -ForegroundColor Gray
                winget install --accept-source-agreements --accept-package-agreements --id $pkg.Id 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Installed successfully" -ForegroundColor Green
                    $installed++
                } else {
                    Write-Host "  ✗ Installation failed" -ForegroundColor Red
                    $failed++
                }
            }
        } catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
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
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Galaxy Book Enabler INSTALLER" -ForegroundColor Cyan
Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

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

# ==================== STEP 5: PACKAGE INSTALLATION ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 5: Samsung Software Installation" -ForegroundColor Cyan
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
    $installResult = Install-SamsungPackages -Packages $packagesToInstall
    
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

# ==================== STEP 6: APPLY SPOOF NOW ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 6: Applying Registry Spoof" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Applying Samsung Galaxy Book spoof..." -ForegroundColor Yellow
Start-Process -FilePath $batchScriptPath -Wait -NoNewWindow
Write-Host "✓ Registry spoof applied!" -ForegroundColor Green
Write-Host "  Your PC now identifies as a Samsung Galaxy Book3 Ultra" -ForegroundColor Gray

# ==================== COMPLETION ====================
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

Write-Host "`n"
pause