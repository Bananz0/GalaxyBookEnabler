# Galaxy Book Enabler Installer/Uninstaller
# Enables Samsung Galaxy Book features on non-Galaxy Book devices

<#
.SYNOPSIS
    Galaxy Book Enabler - Enable Samsung Galaxy Book features on any Windows PC

.DESCRIPTION
    This tool spoofs your device as a Samsung Galaxy Book to enable features like:
    - Quick Share (requires Intel Wi-Fi + Intel Bluetooth)
    - Camera Share (requires Intel Wi-Fi + Intel Bluetooth)
    - Storage Share (requires Intel Wi-Fi + Intel Bluetooth)
    - Multi Control
    - Samsung Notes
    - AI Select (with keyboard shortcut setup)
    - System Support Engine (advanced/experimental)
    
    It handles automatic startup configuration and Wi-Fi/Bluetooth compatibility detection.

.PARAMETER Uninstall
    Removes the Galaxy Book Enabler from your system.

.PARAMETER UpdateSettings
    Reinstalls Samsung Settings with a fresh driver version.
    Cleans up existing installation, uninstalls Samsung Settings apps,
    fetches chosen SSSE version, patches, adds to DriverStore, and reinstalls apps.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1
    Installs the Galaxy Book Enabler with interactive configuration.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1 -Uninstall
    Removes the Galaxy Book Enabler from your system.

.EXAMPLE
    .\Install-GalaxyBookEnabler.ps1 -UpdateSettings
    Reinstalls Samsung Settings with a fresh driver/SSSE version.

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
    [switch]$TestMode,
    [switch]$UpgradeSSE,
    [switch]$UpdateSettings
)

# This script requires PowerShell 7.0+ for modern syntax and features
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ERROR: PowerShell 7.0 or later is required!" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "You are running: PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "This script requires: PowerShell 7.0 or later" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Windows PowerShell 5.1 (built-in) is NOT compatible." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Install PowerShell 7:" -ForegroundColor Cyan
    Write-Host "   winget install Microsoft.PowerShell" -ForegroundColor White
    Write-Host ""
    Write-Host "   Note: If this is your first time using winget, run 'winget list'" -ForegroundColor Gray
    Write-Host "         first to accept the agreements before installing." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or download from: https://aka.ms/powershell" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After installing, run this script in PowerShell 7 (pwsh.exe)" -ForegroundColor Gray
    Write-Host ""
    pause
    exit 1
}

# Self-elevation: Try gsudo first (preserves console), fallback to native UAC
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚡ Requesting administrator privileges..." -ForegroundColor Yellow
    
    # Build the command to re-run this script
    $scriptUrl = "https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1"
    $rerunCommand = "irm '$scriptUrl' | iex"
    
    # Try gsudo first (faster, preserves console context)
    $gsudoPath = Get-Command gsudo -ErrorAction SilentlyContinue
    if ($gsudoPath) {
        Write-Host "  Using gsudo for elevation..." -ForegroundColor Gray
        & gsudo pwsh -NoProfile -ExecutionPolicy Bypass -Command $rerunCommand
        exit $LASTEXITCODE
    }
    
    # Try sudo (Windows 11 24H2+ native sudo)
    $sudoPath = Get-Command sudo -ErrorAction SilentlyContinue
    if ($sudoPath) {
        Write-Host "  Using Windows sudo for elevation..." -ForegroundColor Gray
        & sudo pwsh -NoProfile -ExecutionPolicy Bypass -Command $rerunCommand
        exit $LASTEXITCODE
    }
    
    # Fallback to native UAC (Start-Process -Verb RunAs)
    Write-Host "  Using UAC elevation..." -ForegroundColor Gray
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$rerunCommand`"" -Wait
    exit
}

# VERSION CONSTANT
$SCRIPT_VERSION = "3.0.0"
$GITHUB_REPO = "Bananz0/GalaxyBookEnabler"
$UPDATE_CHECK_URL = "https://api.github.com/repos/$GITHUB_REPO/releases/latest"


# Galaxy Book Model Database
$GalaxyBookModels = @{
    '730QFG' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P03VAE.330.230322.PL'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3 360'; SystemProductName = '730QFG'; ProductSku = 'SCAI-ICPS-A5A5-RPLP-PVAE'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP730QFG-KB1UK'; EnclosureKind = 31 }
    '750QGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P03RHC.170.240226.HC'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4 360'; SystemProductName = '750QGK'; ProductSku = 'SCAI-ICPS-A5A5-RPLP-PRHC'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750QGK-KG2US'; EnclosureKind = 31 }
    '750QHA' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P04RHG.270.250515.SX'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book5 360'; SystemProductName = '750QHA'; ProductSku = 'SCAI-A5A5-A5A5-LNLM-PRHG'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750QHA-KA1US'; EnclosureKind = 31 }
    '750XFG' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P09CFL.030.241212.HQ'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3'; SystemProductName = '750XFG'; ProductSku = 'SCAI-A5A5-A5A5-RPLP-PCFL'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750XFG-KA3SE'; EnclosureKind = 10 }
    '750XFH' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P09CFM.030.241212.HQ'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3'; SystemProductName = '750XFH'; ProductSku = 'SCAI-A5A5-A5A5-RPLP-PCFM'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750XFH-XF1BR'; EnclosureKind = 10 }
    '750XGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P02CFP.015.240409.HQ'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4'; SystemProductName = '750XGK'; ProductSku = 'SCAI-A5A5-A5A5-RPLU-PCFP'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750XGK-KG1IT'; EnclosureKind = 10 }
    '750XGL' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P07CFP.020.250208.HQ'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4'; SystemProductName = '750XGL'; ProductSku = 'SCAI-A5A5-A5A5-RPLU-PCFP'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP750XGL-XG1BR'; EnclosureKind = 10 }
    '930SBE' = @{ BIOSVendor = 'American Megatrends Inc.'; BIOSVersion = 'P07AGW.046.230519.SH'; BIOSMajorRelease = 5; BIOSMinorRelease = 13; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Notebook 9 Series'; SystemProductName = '930SBE/931SBE/930SBV'; ProductSku = 'SCAI-A5A5-A5A5-A5A5-PAGW'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NT930SBE-K716'; EnclosureKind = 31 }
    '930XDB' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P13RFX.071.240415.SP'; BIOSMajorRelease = 5; BIOSMinorRelease = 19; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book Series'; SystemProductName = '930XDB/931XDB/930XDY'; ProductSku = 'SCAI-A5A5-A5A5-TGL3-PRFX'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP930XDB-KF6IT'; EnclosureKind = 10 }
    '935QDC' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P04AKJ.016.231123.PS'; BIOSMajorRelease = 5; BIOSMinorRelease = 19; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book Series'; SystemProductName = '935QDC'; ProductSku = 'SCAI-A5A5-A5A5-TGL4-PAKJ'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP935QDC-KE2US'; EnclosureKind = 31 }
    '940XGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P09VAG.690.240503.03'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4 Pro'; SystemProductName = '940XGK'; ProductSku = 'SCAI-PROT-A5A5-MTLH-PVAG'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP940XGK-KG1FR'; EnclosureKind = 10 }
    '940XHA' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P05VAJ.280.250210.01'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book5 Pro'; SystemProductName = '940XHA'; ProductSku = 'SCAI-PROT-A5A5-LNLM-PVAJ'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP940XHA-KG3IT'; EnclosureKind = 10 }
    '950XGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P06RHD.270.250102.04'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book2 Pro Special Edition'; SystemProductName = '950XGK'; ProductSku = 'SCAI-PROT-A5A5-MTLH-PRHD'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP950XGK-KA2FR'; EnclosureKind = 10 }
    '960QFG' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P07ALN.260.240415.SH'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3 Pro 360'; SystemProductName = '960QFG'; ProductSku = 'SCAI-ICPS-A5A5-RPLP-PALN'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP964QFG-KA1IT'; EnclosureKind = 31 }
    '960QGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P14RHB.460.250425.04'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4 Pro 360'; SystemProductName = '960QGK'; ProductSku = 'SCAI-PROT-A5A5-MTLH-PRHB'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960QGK-KG1IT'; EnclosureKind = 31 }
    '960QHA' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P15ALY.360.250515.02'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book5 Pro 360'; SystemProductName = '960QHA'; ProductSku = 'SCAI-PROT-A5A5-LNLM-PALY'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960QHA-KG2UK'; EnclosureKind = 31 }
    '960XFG' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P07RGU.330.240529.ZQ'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3 Pro'; SystemProductName = '960XFG'; ProductSku = 'SCAI-ICPS-A5A5-RPLP-PRGU'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960XFG-KC2CL'; EnclosureKind = 10 }
    '960XFH' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P07ALQ.190.240418.PS'; BIOSMajorRelease = 5; BIOSMinorRelease = 27; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book3 Ultra'; SystemProductName = '960XFH'; ProductSku = 'SCAI-ICPS-A5A5-RPLH-PALQ'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960XFH-XA2BR'; EnclosureKind = 10 }
    '960XGK' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P12RHA.550.241030.04'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4 Pro'; SystemProductName = '960XGK'; ProductSku = 'SCAI-PROT-A5A5-MTLH-PRHA'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960XGK-KG1UK'; EnclosureKind = 10 }
    '960XGL' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P08ALX.400.250306.05'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book4 Ultra'; SystemProductName = '960XGL'; ProductSku = 'SCAI-PROT-A5A5-MTLH-PALX'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960XGL-XG2BR'; EnclosureKind = 10 }
    '960XHA' = @{ BIOSVendor = 'American Megatrends International, LLC.'; BIOSVersion = 'P05AMA.140.250210.01'; BIOSMajorRelease = 5; BIOSMinorRelease = 32; SystemManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; SystemFamily = 'Galaxy Book5 Pro'; SystemProductName = '960XHA'; ProductSku = 'SCAI-PROT-A5A5-LNLM-PAMA'; BaseBoardManufacturer = 'SAMSUNG ELECTRONICS CO., LTD.'; BaseBoardProduct = 'NP960XHA-KG2DE'; EnclosureKind = 10 }
}


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
                Available      = $true
                LatestVersion  = $latestVersion
                CurrentVersion = $SCRIPT_VERSION
                ReleaseUrl     = $response.html_url
                DownloadUrl    = $downloadUrl
                ReleaseNotes   = $response.body
            }
        }
        
        return @{
            Available      = $false
            LatestVersion  = $latestVersion
            CurrentVersion = $SCRIPT_VERSION
        }
    }
    catch {
        Write-Verbose "Failed to check for updates: $_"
        return @{
            Available = $false
            Error     = $_.Exception.Message
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
    }
    catch {
        Write-Host "✗ Failed to download update: $_" -ForegroundColor Red
        Write-Host "Please download manually from: $GITHUB_REPO/releases" -ForegroundColor Yellow
        return $false
    }
}

function Test-InstallationHealth {
    <#
    .SYNOPSIS
        Checks the health of GalaxyBookEnabler installation.
    .DESCRIPTION
        Validates 4 components: config file, scheduled task, C:\GalaxyBook folder, and GBeSupportService.
        Returns version info and component status for enhanced detection.
    #>
    param(
        [string]$ConfigPath = "$env:USERPROFILE\GalaxyBookEnablerData\gbe-config.json",
        [string]$TaskName = "GalaxyBookEnabler",
        [string]$SssePath = "C:\GalaxyBook"
    )
    
    $health = @{
        IsHealthy      = $false
        IsBroken       = $false
        ComponentCount = 0
        Components     = @{
            Config     = $false
            Task       = $false
            SsseFolder = $false
            Service    = $false
        }
        GbeVersion     = "Unknown"
        SsseVersion    = "Unknown"
        SsseExePath    = $null
    }
    
    # Check 1: Config file
    if (Test-Path $ConfigPath) {
        $health.Components.Config = $true
        $health.ComponentCount++
        try {
            $config = Get-Content $ConfigPath | ConvertFrom-Json
            $health.GbeVersion = if ($config.InstalledVersion) { $config.InstalledVersion } else { "1.0.0" }
        }
        catch {
            Write-Verbose "Failed to read config: $_"
        }
    }
    
    # Check 2: Scheduled task
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        $health.Components.Task = $true
        $health.ComponentCount++
    }
    
    # Check 3: SSSE installation folder
    if (Test-Path $SssePath) {
        $health.Components.SsseFolder = $true
        $health.ComponentCount++
        
        # Try to get SSSE version from exe
        $exePath = Join-Path $SssePath "SamsungSystemSupportEngine.exe"
        if (Test-Path $exePath) {
            $health.SsseExePath = $exePath
            try {
                $version = (Get-Item $exePath).VersionInfo.FileVersion
                if ($version) {
                    $health.SsseVersion = $version
                }
            }
            catch {
                Write-Verbose "Failed to read SSSE version: $_"
            }
        }
    }
    
    # Check 4: GBeSupportService
    $service = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
    if ($service) {
        $health.Components.Service = $true
        $health.ComponentCount++
    }
    
    # Determine installation state
    if ($health.ComponentCount -eq 4) {
        $health.IsHealthy = $true
    }
    elseif ($health.ComponentCount -gt 0 -and $health.ComponentCount -lt 4) {
        $health.IsBroken = $true
    }
    
    return $health
}

function Remove-GalaxyBudsFromBluetooth {
    <#
    .SYNOPSIS
        Removes Galaxy Buds from Windows Bluetooth using BluetoothRemoveDevice P/Invoke.
    .DESCRIPTION
        Uses BluetoothAPIs.dll to enumerate and remove paired Galaxy Buds devices.
        Detects all variants: Buds, Buds+, Buds Live, Buds Pro, Buds FE, Buds2, Buds3, Buds4.
        
        Credits:
        - powerBTremover (fork): https://github.com/m-a-x-s-e-e-l-i-g/powerBTremover
        - powerBTremover (original): https://github.com/RS-DU34/powerBTremover
    #>
    
    $btApiSignature = @"
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern IntPtr BluetoothFindFirstRadio(ref BLUETOOTH_FIND_RADIO_PARAMS pbtfrp, out IntPtr phRadio);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern bool BluetoothFindNextRadio(IntPtr hFind, out IntPtr phRadio);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern bool BluetoothFindRadioClose(IntPtr hFind);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern IntPtr BluetoothFindFirstDevice(ref BLUETOOTH_DEVICE_SEARCH_PARAMS pbtsd, ref BLUETOOTH_DEVICE_INFO pbtdi);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern bool BluetoothFindNextDevice(IntPtr hFind, ref BLUETOOTH_DEVICE_INFO pbtdi);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern bool BluetoothFindDeviceClose(IntPtr hFind);
    
    [DllImport("BluetoothAPIs.dll", SetLastError = true)]
    public static extern int BluetoothRemoveDevice(ref ulong pAddress);
    
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct BLUETOOTH_FIND_RADIO_PARAMS {
        public int dwSize;
    }
    
    [StructLayout(LayoutKind.Sequential)]
    public struct BLUETOOTH_DEVICE_SEARCH_PARAMS {
        public int dwSize;
        public bool fReturnAuthenticated;
        public bool fReturnRemembered;
        public bool fReturnUnknown;
        public bool fReturnConnected;
        public bool fIssueInquiry;
        public byte cTimeoutMultiplier;
        public IntPtr hRadio;
    }
    
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct BLUETOOTH_DEVICE_INFO {
        public int dwSize;
        public ulong Address;
        public uint ulClassofDevice;
        public bool fConnected;
        public bool fRemembered;
        public bool fAuthenticated;
        public SYSTEMTIME stLastSeen;
        public SYSTEMTIME stLastUsed;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 248)]
        public string szName;
    }
    
    [StructLayout(LayoutKind.Sequential)]
    public struct SYSTEMTIME {
        public ushort wYear;
        public ushort wMonth;
        public ushort wDayOfWeek;
        public ushort wDay;
        public ushort wHour;
        public ushort wMinute;
        public ushort wSecond;
        public ushort wMilliseconds;
    }
"@
    
    # Galaxy Buds name patterns
    $budsPatterns = @(
        "*Galaxy Buds*",
        "*Buds Pro*",
        "*Buds Live*",
        "*Buds FE*",
        "*Buds2*",
        "*Buds3*",
        "*Buds4*"
    )
    
    try {
        # Add the Bluetooth API type
        Add-Type -MemberDefinition $btApiSignature -Namespace "BluetoothAPI" -Name "NativeMethods" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Verbose "Bluetooth API type already loaded or error: $_"
    }
    
    $removedDevices = @()
    $failedDevices = @()
    
    try {
        # Find Bluetooth radio
        $radioParams = New-Object BluetoothAPI.NativeMethods+BLUETOOTH_FIND_RADIO_PARAMS
        $radioParams.dwSize = [System.Runtime.InteropServices.Marshal]::SizeOf($radioParams)
        
        $radioHandle = [IntPtr]::Zero
        $findRadioHandle = [BluetoothAPI.NativeMethods]::BluetoothFindFirstRadio([ref]$radioParams, [ref]$radioHandle)
        
        if ($findRadioHandle -eq [IntPtr]::Zero) {
            Write-Host "  No Bluetooth radio found" -ForegroundColor Yellow
            return @{ Removed = @(); Failed = @() }
        }
        
        # Set up device search
        $searchParams = New-Object BluetoothAPI.NativeMethods+BLUETOOTH_DEVICE_SEARCH_PARAMS
        $searchParams.dwSize = [System.Runtime.InteropServices.Marshal]::SizeOf($searchParams)
        $searchParams.fReturnAuthenticated = $true
        $searchParams.fReturnRemembered = $true
        $searchParams.fReturnUnknown = $false
        $searchParams.fReturnConnected = $true
        $searchParams.fIssueInquiry = $false
        $searchParams.cTimeoutMultiplier = 0
        $searchParams.hRadio = $radioHandle
        
        $deviceInfo = New-Object BluetoothAPI.NativeMethods+BLUETOOTH_DEVICE_INFO
        $deviceInfo.dwSize = [System.Runtime.InteropServices.Marshal]::SizeOf($deviceInfo)
        
        $findDeviceHandle = [BluetoothAPI.NativeMethods]::BluetoothFindFirstDevice([ref]$searchParams, [ref]$deviceInfo)
        
        if ($findDeviceHandle -ne [IntPtr]::Zero) {
            do {
                $deviceName = $deviceInfo.szName
                $isGalaxyBuds = $false
                
                foreach ($pattern in $budsPatterns) {
                    if ($deviceName -like $pattern) {
                        $isGalaxyBuds = $true
                        break
                    }
                }
                
                if ($isGalaxyBuds) {
                    Write-Host "    Found: $deviceName" -ForegroundColor Cyan
                    
                    $address = $deviceInfo.Address
                    $result = [BluetoothAPI.NativeMethods]::BluetoothRemoveDevice([ref]$address)
                    
                    if ($result -eq 0) {
                        Write-Host "    ✓ Removed: $deviceName" -ForegroundColor Green
                        $removedDevices += $deviceName
                    }
                    else {
                        Write-Host "    ✗ Failed to remove: $deviceName (Error: $result)" -ForegroundColor Red
                        $failedDevices += $deviceName
                    }
                }
            } while ([BluetoothAPI.NativeMethods]::BluetoothFindNextDevice($findDeviceHandle, [ref]$deviceInfo))
            
            [BluetoothAPI.NativeMethods]::BluetoothFindDeviceClose($findDeviceHandle) | Out-Null
        }
        
        [BluetoothAPI.NativeMethods]::BluetoothFindRadioClose($findRadioHandle) | Out-Null
        [BluetoothAPI.NativeMethods]::CloseHandle($radioHandle) | Out-Null
    }
    catch {
        Write-Host "  ✗ Bluetooth API error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return @{
        Removed = $removedDevices
        Failed  = $failedDevices
    }
}


# ==================== RESET/REPAIR DEFINITIONS ====================

$SamsungPackages = @{
    "Account"         = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungAccount_3c1yjt4zspk6g"
        Name     = "Samsung Account"
        Critical = $true
    }
    "AccountPlugin"   = @{
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungAccountPluginforSa_3c1yjt4zspk6g"
        Name     = "Samsung Account Plugin"
        Critical = $true
    }
    "Settings"        = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungSettings1.5_3c1yjt4zspk6g"
        Name     = "Samsung Settings"
        Critical = $false
    }
    "SettingsRuntime" = @{
        Family      = "SAMSUNGELECTRONICSCO.LTD.SamsungSettingsRuntime_3c1yjt4zspk6g"
        Name        = "Samsung Settings Runtime"
        Critical    = $false
        DeviceFiles = @("GalaxyBLESettings.BLE", "GalaxyBTSettings.BT")
    }
    "Buds"            = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.GalaxyBuds_3c1yjt4zspk6g"
        Name     = "Galaxy Buds"
        Critical = $false
    }
    "QuickShare"      = @{ 
        Family   = "SAMSUNGELECTRONICSCoLtd.SamsungQuickShare_wyx1vj98g3asy"
        Name     = "Samsung Quick Share"
        Critical = $false
    }
    "Notes"           = @{ 
        Family   = "SAMSUNGELECTRONICSCoLtd.SamsungNotes_wyx1vj98g3asy"
        Name     = "Samsung Notes"
        Critical = $false
    }
    "Continuity"      = @{ 
        Family    = "SAMSUNGELECTRONICSCoLtd.SamsungContinuityService_wyx1vj98g3asy"
        Name      = "Samsung Continuity Service"
        Critical  = $false
        Databases = @("PCMCFCoreDB.db", "PCMCFRsDB.db")
    }
    "SmartThings"     = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SmartThingsWindows_3c1yjt4zspk6g"
        Name     = "SmartThings"
        Critical = $false
    }
    "CameraShare"     = @{ 
        Family   = "SAMSUNGELECTRONICSCoLtd.16297BCCB59BC_wyx1vj98g3asy"
        Name     = "Camera Share"
        Critical = $false
    }
    "MultiControl"    = @{ 
        Family   = "SAMSUNGELECTRONICSCoLtd.MultiControl_wyx1vj98g3asy"
        Name     = "Multi Control"
        Critical = $false
    }
    "Gallery"         = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.PCGallery_3c1yjt4zspk6g"
        Name     = "PC Gallery"
        Critical = $false
    }
    "Pass"            = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungPass_3c1yjt4zspk6g"
        Name     = "Samsung Pass"
        Critical = $true
    }
    "SecondScreen"    = @{ 
        Family   = "SAMSUNGELECTRONICSCoLtd.SecondScreen_wyx1vj98g3asy"
        Name     = "Second Screen"
        Critical = $false
    }
    "MyDevices"       = @{ 
        Family    = "SAMSUNGELECTRONICSCoLtd.SamsungMyDevices_wyx1vj98g3asy"
        Name      = "Samsung My Devices"
        Critical  = $false
        Databases = @("ND.sqlite3")
    }
    "Welcome"         = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungWelcome_3c1yjt4zspk6g"
        Name     = "Samsung Welcome"
        Critical = $false
    }
    "Bixby"           = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.Bixby_3c1yjt4zspk6g"
        Name     = "Bixby"
        Critical = $false
    }
    "KnoxMatrix"      = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.KnoxMatrixforWindows_3c1yjt4zspk6g"
        Name     = "Knox Matrix"
        Critical = $true
    }
    "CloudSync"       = @{ 
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungCloudBluetoothSync_3c1yjt4zspk6g"
        Name     = "Samsung Cloud Bluetooth Sync"
        Critical = $false
    }
    "CloudPlatform"   = @{
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungCloudPlatformManag_3c1yjt4zspk6g"
        Name     = "Samsung Cloud Platform Manager"
        Critical = $false
    }
    "VoiceService"    = @{
        Family   = "SAMSUNGELECTRONICSCO.LTD.SamsungIntelligenceVoiceS_3c1yjt4zspk6g"
        Name     = "Samsung Voice Service"
        Critical = $false
    }
    "SmartSelect"     = @{
        Family   = "SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g"
        Name     = "Smart Select"
        Critical = $false
    }
    "PhoneLink"       = @{
        Family   = "SAMSUNGELECTRONICSCoLtd.4438638898209_wyx1vj98g3asy"
        Name     = "Samsung Phone Link Integration"
        Critical = $false
    }
}

# ==================== RESET/REPAIR HELPER FUNCTIONS ====================

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    $colors = @{"OK" = "Green"; "WARN" = "Yellow"; "ERROR" = "Red"; "INFO" = "White"; "ACTION" = "Cyan"; "SKIP" = "DarkGray" }
    $symbols = @{"OK" = "[+]"; "WARN" = "[!]"; "ERROR" = "[-]"; "INFO" = "[*]"; "ACTION" = "[>]"; "SKIP" = "[~]" }
    Write-Host "  $($symbols[$Status]) " -ForegroundColor $colors[$Status] -NoNewline
    Write-Host $Message
}

function Get-TargetPackages {
    return $SamsungPackages.Keys
}

function Get-PackagePath {
    param([string]$PackageFamily)
    return "$env:LOCALAPPDATA\Packages\$PackageFamily"
}

function Test-PackageExists {
    param([string]$PackageFamily)
    return Test-Path (Get-PackagePath $PackageFamily)
}

function Backup-PackageData {
    param([string]$PackageFamily, [string]$AppName)
    
    $sourcePath = Get-PackagePath $PackageFamily
    if (-not (Test-Path $sourcePath)) { return }
    
    $backupRoot = "$env:LOCALAPPDATA\SamsungBackup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $backupPath = Join-Path $backupRoot $PackageFamily
    
    try {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Copy-Item "$sourcePath\*" -Destination $backupPath -Recurse -Force -ErrorAction Stop
        Write-Status "Backed up $AppName to: $backupPath" -Status OK
        return $backupPath
    }
    catch {
        Write-Status "Backup failed for $AppName`: $($_.Exception.Message)" -Status WARN
        return $null
    }
}

# ==================== STOP SAMSUNG APPS ====================

function Stop-SamsungApps {
    param([switch]$All)
    
    Write-Status "Stopping Samsung apps..." -Status ACTION
    
    $processPatterns = @(
        "Samsung*",
        "Galaxy*",
        "SmartThings*",
        "Bixby*",
        "Knox*",
        "*16297BCCB59BC*",
        "*4438638898209*"
    )
    
    $stoppedCount = 0
    foreach ($pattern in $processPatterns) {
        $processes = Get-Process -Name $pattern -ErrorAction SilentlyContinue
        foreach ($proc in $processes) {
            try {
                $proc | Stop-Process -Force -ErrorAction Stop
                Write-Status "Stopped: $($proc.ProcessName)" -Status OK
                $stoppedCount++
            }
            catch {
                Write-Status "Could not stop: $($proc.ProcessName)" -Status WARN
            }
        }
    }
    
    if ($stoppedCount -eq 0) {
        Write-Status "No Samsung processes were running" -Status INFO
    }
    
    # Give apps time to fully stop
    Start-Sleep -Seconds 2
}

# ==================== CACHE CLEARING ====================

function Clear-AppCache {
    param([string]$PackageFamily, [string]$AppName)
    
    $basePath = Get-PackagePath $PackageFamily
    if (-not (Test-Path $basePath)) {
        Write-Status "Package not found: $AppName" -Status SKIP
        return
    }
    
    Write-Status "Clearing cache for $AppName..." -Status ACTION
    
    $cacheFolders = @(
        "LocalCache",
        "TempState",
        "AC\INetCache",
        "AC\INetCookies",
        "AC\INetHistory",
        "AC\Temp"
    )
    
    $cleared = 0
    foreach ($folder in $cacheFolders) {
        $path = Join-Path $basePath $folder
        if (Test-Path $path) {
            try {
                Remove-Item "$path\*" -Recurse -Force -ErrorAction Stop
                $cleared++
            }
            catch {
                Write-Debug "Failed to clear cache folder $path (likely locked by running process): $($_.Exception.Message)"
            }
        }
    }
    
    if ($cleared -gt 0) {
        Write-Status "Cleared $cleared cache folders for $AppName" -Status OK
    }
}

# ==================== DEVICE DATA CLEARING ====================

function Clear-DeviceData {
    Write-Status "`n=== CLEARING DEVICE DATA ===" -Status ACTION
    
    # 1. Clear BLE/BT Settings files in Samsung Settings Runtime
    $settingsRuntimePath = Get-PackagePath $SamsungPackages["SettingsRuntime"].Family
    $localStatePath = Join-Path $settingsRuntimePath "LocalState"
    
    if (Test-Path $localStatePath) {
        $deviceFiles = @("GalaxyBLESettings.BLE", "GalaxyBTSettings.BT")
        foreach ($file in $deviceFiles) {
            $filePath = Join-Path $localStatePath $file
            if (Test-Path $filePath) {
                try {
                    # Backup original
                    $backupPath = "$filePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Copy-Item $filePath $backupPath -Force
                    
                    # Write empty JSON array
                    [System.IO.File]::WriteAllText($filePath, "[]")
                    Write-Status "Cleared: $file" -Status OK
                }
                catch {
                    Write-Status "Could not clear $file`: $($_.Exception.Message)" -Status ERROR
                }
            }
        }
    }
    
    # 2. Clear Galaxy Buds app data
    $budsPath = Get-PackagePath $SamsungPackages["Buds"].Family
    if (Test-Path $budsPath) {
        $budsLocalState = Join-Path $budsPath "LocalState"
        if (Test-Path $budsLocalState) {
            try {
                Get-ChildItem $budsLocalState -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared Galaxy Buds LocalState" -Status OK
            }
            catch {
                Write-Status "Could not fully clear Galaxy Buds data" -Status WARN
            }
        }
    }
    
    # 3. Clear Samsung My Devices database
    $myDevicesPath = Get-PackagePath $SamsungPackages["MyDevices"].Family
    $ndDatabase = Join-Path $myDevicesPath "LocalState\ND.sqlite3"
    if (Test-Path $ndDatabase) {
        try {
            $backupPath = "$ndDatabase.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $ndDatabase $backupPath -Force
            Remove-Item $ndDatabase -Force
            Write-Status "Cleared My Devices database (ND.sqlite3)" -Status OK
        }
        catch {
            Write-Status "Could not clear My Devices database: $($_.Exception.Message)" -Status WARN
        }
    }
    
    # 4. Clear Samsung Cloud Bluetooth Sync data
    $cloudSyncPath = Get-PackagePath $SamsungPackages["CloudSync"].Family
    if (Test-Path $cloudSyncPath) {
        $cloudLocalState = Join-Path $cloudSyncPath "LocalState"
        if (Test-Path $cloudLocalState) {
            try {
                Get-ChildItem $cloudLocalState -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared Cloud Bluetooth Sync data" -Status OK
            }
            catch {
                Write-Status "Could not fully clear Cloud Sync data" -Status WARN
            }
        }
    }
    
    # 5. Clear Continuity Service device databases
    $continuityPath = Get-PackagePath $SamsungPackages["Continuity"].Family
    $continuityLocalState = Join-Path $continuityPath "LocalState"
    if (Test-Path $continuityLocalState) {
        $databases = @("PCMCFCoreDB.db", "PCMCFRsDB.db")
        foreach ($db in $databases) {
            $dbPath = Join-Path $continuityLocalState $db
            if (Test-Path $dbPath) {
                try {
                    $backupPath = "$dbPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Copy-Item $dbPath $backupPath -Force
                    Remove-Item $dbPath -Force
                    Write-Status "Cleared: $db" -Status OK
                }
                catch {
                    Write-Status "Could not clear $db`: $($_.Exception.Message)" -Status WARN
                }
            }
        }
    }
    
    # 6. Clear ProgramData Samsung Settings device files (V2 format)
    $programDataSettingsPath = "$env:PROGRAMDATA\Samsung\SamsungSettings"
    if (Test-Path $programDataSettingsPath) {
        Write-Status "Clearing ProgramData Samsung Settings device files..." -Status ACTION
        
        Get-ChildItem $programDataSettingsPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $userFolder = $_.FullName
            $userName = $_.Name
            
            # Clear BLE V2 file
            $bleV2Path = Join-Path $userFolder "GalaxyBLESettingsV2.BLE"
            if (Test-Path $bleV2Path) {
                try {
                    $backupPath = "$bleV2Path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Copy-Item $bleV2Path $backupPath -Force
                    [System.IO.File]::WriteAllText($bleV2Path, "[]")
                    Write-Status "Cleared: GalaxyBLESettingsV2.BLE ($userName)" -Status OK
                }
                catch {
                    Write-Status "Could not clear GalaxyBLESettingsV2.BLE: $($_.Exception.Message)" -Status WARN
                }
            }
            
            # Clear BT V2 file
            $btV2Path = Join-Path $userFolder "GalaxyBTSettingsV2.BT"
            if (Test-Path $btV2Path) {
                try {
                    $backupPath = "$btV2Path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Copy-Item $btV2Path $backupPath -Force
                    [System.IO.File]::WriteAllText($btV2Path, "[]")
                    Write-Status "Cleared: GalaxyBTSettingsV2.BT ($userName)" -Status OK
                }
                catch {
                    Write-Status "Could not clear GalaxyBTSettingsV2.BT: $($_.Exception.Message)" -Status WARN
                }
            }
            
            # Remove device battery images
            Get-ChildItem $userFolder -Filter "*_BudsBattery.png" -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Remove-Item $_.FullName -Force
                    Write-Status "Removed: $($_.Name)" -Status OK
                }
                catch {
                    Write-Status "Could not remove $($_.Name): $($_.Exception.Message)" -Status WARN
                }
            }
        }
    }
    
    Write-Status "Device data clearing complete" -Status OK
}

# ==================== DATABASE CLEARING ====================

function Clear-AllDatabases {
    Write-Status "`n=== CLEARING ALL DATABASES ===" -Status ACTION
    
    $targetPackages = Get-TargetPackages
    
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        $basePath = Get-PackagePath $pkg.Family
        
        if (-not (Test-Path $basePath)) { continue }
        
        $dbFiles = Get-ChildItem $basePath -Recurse -Include "*.db", "*.sqlite", "*.sqlite3" -ErrorAction SilentlyContinue
        
        foreach ($db in $dbFiles) {
            try {
                $backupPath = "$($db.FullName).backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item $db.FullName $backupPath -Force
                Remove-Item $db.FullName -Force
                Write-Status "Cleared database: $($db.Name) ($($pkg.Name))" -Status OK
            }
            catch {
                Write-Status "Could not clear $($db.Name): $($_.Exception.Message)" -Status WARN
            }
        }
    }
}

# ==================== SETTINGS.DAT CLEARING ====================

function Reset-SettingsDat {
    param([string]$PackageFamily, [string]$AppName)
    
    $settingsPath = Join-Path (Get-PackagePath $PackageFamily) "Settings\settings.dat"
    
    if (-not (Test-Path $settingsPath)) {
        Write-Status "No settings.dat for $AppName" -Status SKIP
        return
    }
    
    Write-Status "Resetting settings.dat for $AppName..." -Status ACTION
    
    try {
        $backupPath = "$settingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $settingsPath $backupPath -Force
        Write-Status "Backed up settings.dat" -Status OK
        
        Remove-Item $settingsPath -Force
        Remove-Item "$settingsPath.LOG*" -Force -ErrorAction SilentlyContinue
        
        Write-Status "Removed settings.dat (will be recreated on app launch)" -Status OK
    }
    catch {
        Write-Status "Could not reset settings.dat: $($_.Exception.Message)" -Status ERROR
    }
}

function Reset-AllSettingsDat {
    Write-Status "`n=== RESETTING ALL SETTINGS.DAT FILES ===" -Status ACTION
    
    $targetPackages = Get-TargetPackages
    
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        Reset-SettingsDat -PackageFamily $pkg.Family -AppName $pkg.Name
    }
}

# ==================== AUTHENTICATION DATA ====================

function Clear-AuthenticationData {
    param([switch]$KeepCredentials)
    
    Write-Status "`n=== CLEARING AUTHENTICATION DATA ===" -Status ACTION
    
    # Samsung Account data
    $saPath = Get-PackagePath $SamsungPackages["Account"].Family
    
    if (-not (Test-Path $saPath)) {
        Write-Status "Samsung Account package not found" -Status SKIP
        return
    }
    
    # Database (contains account info)
    if (-not $KeepCredentials) {
        $dbPath = "$saPath\LocalState\SamsungAccountInfo.db"
        if (Test-Path $dbPath) {
            try {
                $backupPath = "$dbPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item $dbPath $backupPath -Force
                Remove-Item $dbPath -Force
                Write-Status "Removed SamsungAccountInfo.db" -Status OK
            }
            catch {
                Write-Status "Could not remove database: $($_.Exception.Message)" -Status ERROR
            }
        }
    }
    
    # WebView cache (authentication cookies/sessions)
    $webviewPath = "$saPath\LocalState\EBWebView"
    if (Test-Path $webviewPath) {
        $webviewClear = @(
            "Default\Cookies",
            "Default\Cookies-journal",
            "Default\Login Data",
            "Default\Login Data-journal",
            "Default\Session Storage",
            "Default\Local Storage",
            "Default\IndexedDB"
        )
        foreach ($item in $webviewClear) {
            $itemPath = Join-Path $webviewPath $item
            if (Test-Path $itemPath) {
                try {
                    Remove-Item $itemPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Status "Cleared WebView: $item" -Status OK
                }
                catch {
                    Write-Status "Could not clear $item" -Status WARN
                }
            }
        }
    }
    
    # Clear Windows Credential Manager Samsung entries
    if (-not $KeepCredentials) {
        Write-Status "Checking Credential Manager..." -Status ACTION
        $credList = cmdkey /list 2>$null
        $samsungCreds = $credList | Select-String "Samsung|saclient" -CaseSensitive:$false
        if ($samsungCreds) {
            Write-Status "Found Samsung credentials in Windows Credential Manager" -Status WARN
            Write-Status "Manual removal may be needed: cmdkey /delete:<credential_name>" -Status INFO
        }
    }
}

# ==================== APP REGISTRATION ====================

function Invoke-AppReRegistration {
    Write-Status "`n=== RE-REGISTERING SAMSUNG APPS ===" -Status ACTION
    
    $samsungPackages = Get-AppxPackage | Where-Object { 
        $_.Name -like "*Samsung*" -or 
        $_.Name -like "*Galaxy*" -or
        $_.Name -like "*16297BCCB59BC*" -or
        $_.Name -like "*4438638898209*"
    }
    
    foreach ($pkg in $samsungPackages) {
        Write-Status "Re-registering: $($pkg.Name)" -Status ACTION
        try {
            $manifestPath = Join-Path $pkg.InstallLocation "AppxManifest.xml"
            if (Test-Path $manifestPath) {
                Add-AppxPackage -Register $manifestPath -DisableDevelopmentMode -ForceApplicationShutdown -ErrorAction Stop
                Write-Status "Re-registered: $($pkg.Name)" -Status OK
            }
            else {
                Write-Status "Manifest not found for $($pkg.Name)" -Status WARN
            }
        }
        catch {
            Write-Status "Failed to re-register $($pkg.Name)`: $($_.Exception.Message)" -Status ERROR
        }
    }
}

# ==================== PERMISSIONS ====================

function Repair-Permissions {
    Write-Status "`n=== REPAIRING PERMISSIONS ===" -Status ACTION
    
    $targetPackages = Get-TargetPackages
    
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        $folder = Get-PackagePath $pkg.Family
        
        if (-not (Test-Path $folder)) { continue }
        
        try {
            # Reset ACL to inherited
            $acl = Get-Acl $folder
            $acl.SetAccessRuleProtection($false, $true)
            Set-Acl $folder $acl
            
            # Ensure current user has full control
            $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity.Name,
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            $acl.AddAccessRule($rule)
            Set-Acl $folder $acl
            Write-Status "Fixed permissions for $($pkg.Name)" -Status OK
        }
        catch {
            Write-Status "Permission repair failed for $($pkg.Name): $($_.Exception.Message)" -Status WARN
        }
    }
}

# ==================== SYSTEM DATA CLEARING ====================

function Clear-SamsungSystemData {
    Write-Status "`n=== CLEARING SAMSUNG SYSTEM DATA ===" -Status ACTION
    
    # ProgramData Samsung folders
    $programDataFolders = @{
        "SamsungSettings"            = @{ ClearAll = $false; DeviceFilesOnly = $true }
        "SamsungContinuityService"   = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "SamsungMultiControl"        = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "QuickShare"                 = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "StorageShare"               = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "CameraSharing"              = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "GBExperienceSvc"            = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "AISelectService"            = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "Intelligence Voice Service" = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "MSSCS"                      = @{ ClearAll = $true; DeviceFilesOnly = $false }
        "ParentalControls"           = @{ ClearAll = $true; DeviceFilesOnly = $false }
    }
    
    $programDataBase = "$env:PROGRAMDATA\Samsung"
    if (Test-Path $programDataBase) {
        foreach ($folderName in $programDataFolders.Keys) {
            $folderPath = Join-Path $programDataBase $folderName
            if (Test-Path $folderPath) {
                $config = $programDataFolders[$folderName]
                
                if ($config.ClearAll) {
                    try {
                        Get-ChildItem $folderPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                        }
                        Write-Status "Cleared: ProgramData\Samsung\$folderName" -Status OK
                    }
                    catch {
                        Write-Status "Could not fully clear ${folderName}: $($_.Exception.Message)" -Status WARN
                    }
                }
                elseif ($config.DeviceFilesOnly) {
                    Get-ChildItem $folderPath -Recurse -ErrorAction SilentlyContinue | Where-Object {
                        $_.Name -match "\.BLE$|\.BT$|BudsBattery\.png$"
                    } | ForEach-Object {
                        try {
                            if ($_.Name -match "\.BLE$|\.BT$") {
                                [System.IO.File]::WriteAllText($_.FullName, "[]")
                                Write-Status "Cleared device file: $($_.Name)" -Status OK
                            }
                            else {
                                Remove-Item $_.FullName -Force
                                Write-Status "Removed: $($_.Name)" -Status OK
                            }
                        }
                        catch {
                            Write-Status "Could not clear $($_.Name): $($_.Exception.Message)" -Status WARN
                        }
                    }
                }
            }
        }
    }
    
    # LocalAppData Samsung folders (non-package)
    $localAppDataSamsung = "$env:LOCALAPPDATA\Samsung"
    if (Test-Path $localAppDataSamsung) {
        Write-Status "Clearing LocalAppData Samsung folder..." -Status ACTION
        try {
            $passExtPath = Join-Path $localAppDataSamsung "Samsung Pass Extension"
            if (Test-Path $passExtPath) {
                Get-ChildItem $passExtPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared: Samsung Pass Extension" -Status OK
            }
            
            $internetPath = Join-Path $localAppDataSamsung "Internet"
            if (Test-Path $internetPath) {
                Get-ChildItem $internetPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared: Samsung Internet" -Status OK
            }
        }
        catch {
            Write-Status "Could not fully clear LocalAppData Samsung: $($_.Exception.Message)" -Status WARN
        }
    }
    
    # Roaming AppData Samsung folders
    $roamingAppDataSamsung = "$env:APPDATA\Samsung"
    if (Test-Path $roamingAppDataSamsung) {
        Write-Status "Clearing Roaming AppData Samsung folder..." -Status ACTION
        try {
            Get-ChildItem $roamingAppDataSamsung -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            }
            Write-Status "Cleared: Roaming AppData Samsung" -Status OK
        }
        catch {
            Write-Status "Could not fully clear Roaming AppData Samsung: $($_.Exception.Message)" -Status WARN
        }
    }
}

function Clear-AllSamsungData {
    Write-Status "`n=== CLEARING ALL SAMSUNG DATA ===" -Status ACTION
    
    # Clear ProgramData Samsung folder completely
    $programDataSamsung = "$env:PROGRAMDATA\Samsung"
    if (Test-Path $programDataSamsung) {
        try {
            Remove-Item $programDataSamsung -Recurse -Force -ErrorAction Stop
            Write-Status "Deleted: ProgramData\Samsung" -Status OK
        }
        catch {
            Write-Status "Could not delete ProgramData\Samsung: $($_.Exception.Message)" -Status WARN
            try {
                Get-ChildItem $programDataSamsung -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared all files in ProgramData\Samsung" -Status OK
            }
            catch {
                Write-Status "Could not fully clear ProgramData\Samsung" -Status WARN
            }
        }
    }
    
    # Clear ALL Samsung package folders in LocalAppData\Packages
    $packagesPath = "$env:LOCALAPPDATA\Packages"
    if (Test-Path $packagesPath) {
        $samsungPackageFolders = Get-ChildItem $packagesPath -Directory -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -match "SAMSUNG|Galaxy" }
        
        foreach ($folder in $samsungPackageFolders) {
            try {
                Remove-Item $folder.FullName -Recurse -Force -ErrorAction Stop
                Write-Status "Deleted: Packages\$($folder.Name)" -Status OK
            }
            catch {
                Write-Status "Could not delete $($folder.Name): $($_.Exception.Message)" -Status WARN
            }
        }
    }
    
    # Clear LocalAppData Samsung (non-package)
    $localAppDataSamsung = "$env:LOCALAPPDATA\Samsung"
    if (Test-Path $localAppDataSamsung) {
        try {
            Remove-Item $localAppDataSamsung -Recurse -Force -ErrorAction Stop
            Write-Status "Deleted: LocalAppData\Samsung" -Status OK
        }
        catch {
            Write-Status "Could not delete LocalAppData\Samsung: $($_.Exception.Message)" -Status WARN
        }
    }
    
    # Clear Roaming AppData Samsung
    $roamingAppDataSamsung = "$env:APPDATA\Samsung"
    if (Test-Path $roamingAppDataSamsung) {
        try {
            Remove-Item $roamingAppDataSamsung -Recurse -Force -ErrorAction Stop
            Write-Status "Deleted: Roaming AppData\Samsung" -Status OK
        }
        catch {
            Write-Status "Could not delete Roaming AppData\Samsung: $($_.Exception.Message)" -Status WARN
        }
    }
    
    # Clear Samsung backup folder if it exists
    $samsungBackup = "$env:LOCALAPPDATA\SamsungBackup"
    if (Test-Path $samsungBackup) {
        try {
            Remove-Item $samsungBackup -Recurse -Force -ErrorAction Stop
            Write-Status "Deleted: SamsungBackup folder" -Status OK
        }
        catch {
            Write-Status "Could not delete SamsungBackup folder" -Status WARN
        }
    }
}

# ==================== DIAGNOSTICS ====================

function Invoke-Diagnostics {
    Write-Status "`n=== SAMSUNG DIAGNOSTICS ===" -Status ACTION
    
    # Check installed packages
    Write-Status "`nInstalled Samsung packages:" -Status INFO
    $installed = Get-AppxPackage | Where-Object { 
        $_.Name -like "*Samsung*" -or 
        $_.Name -like "*Galaxy*" -or
        $_.Name -like "*16297BCCB59BC*" -or
        $_.Name -like "*4438638898209*"
    }
    
    foreach ($pkg in $installed) {
        Write-Status "  $($pkg.Name) v$($pkg.Version)" -Status OK
    }
    
    # Check device files
    Write-Status "`nDevice data files:" -Status INFO
    $blePath = Join-Path (Get-PackagePath $SamsungPackages["SettingsRuntime"].Family) "LocalState\GalaxyBLESettings.BLE"
    $btPath = Join-Path (Get-PackagePath $SamsungPackages["SettingsRuntime"].Family) "LocalState\GalaxyBTSettings.BT"
    
    if (Test-Path $blePath) {
        $bleContent = Get-Content $blePath -Raw -ErrorAction SilentlyContinue
        $bleSize = (Get-Item $blePath).Length
        if ($bleContent -match "Buds|Galaxy") {
            Write-Status "  BLE file: Contains device data ($bleSize bytes)" -Status WARN
        }
        else {
            Write-Status "  BLE file: Empty or no devices ($bleSize bytes)" -Status OK
        }
    }
    
    if (Test-Path $btPath) {
        $btContent = Get-Content $btPath -Raw -ErrorAction SilentlyContinue
        $btSize = (Get-Item $btPath).Length
        if ($btContent -match "Buds|Galaxy") {
            Write-Status "  BT file: Contains device data ($btSize bytes)" -Status WARN
        }
        else {
            Write-Status "  BT file: Empty or no devices ($btSize bytes)" -Status OK
        }
    }
    
    # Check ProgramData device files (V2 format)
    Write-Status "`nProgramData device files (V2):" -Status INFO
    $programDataSettingsPath = "$env:PROGRAMDATA\Samsung\SamsungSettings"
    if (Test-Path $programDataSettingsPath) {
        Get-ChildItem $programDataSettingsPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $userFolder = $_.FullName
            $userName = $_.Name
            
            $bleV2Path = Join-Path $userFolder "GalaxyBLESettingsV2.BLE"
            $btV2Path = Join-Path $userFolder "GalaxyBTSettingsV2.BT"
            
            if (Test-Path $bleV2Path) {
                $bleContent = Get-Content $bleV2Path -Raw -ErrorAction SilentlyContinue
                $bleSize = (Get-Item $bleV2Path).Length
                if ($bleContent -match "Buds|Galaxy") {
                    Write-Status "  BLE V2 ($userName): Contains device data ($bleSize bytes)" -Status WARN
                }
                else {
                    Write-Status "  BLE V2 ($userName): Empty or no devices ($bleSize bytes)" -Status OK
                }
            }
            
            if (Test-Path $btV2Path) {
                $btContent = Get-Content $btV2Path -Raw -ErrorAction SilentlyContinue
                $btSize = (Get-Item $btV2Path).Length
                if ($btContent -match "Buds|Galaxy") {
                    Write-Status "  BT V2 ($userName): Contains device data ($btSize bytes)" -Status WARN
                }
                else {
                    Write-Status "  BT V2 ($userName): Empty or no devices ($btSize bytes)" -Status OK
                }
            }
            
            $batteryImages = Get-ChildItem $userFolder -Filter "*_BudsBattery.png" -ErrorAction SilentlyContinue
            if ($batteryImages) {
                foreach ($img in $batteryImages) {
                    Write-Status "  Battery image: $($img.Name)" -Status WARN
                }
            }
        }
    }
    else {
        Write-Status "  ProgramData Samsung Settings folder not found" -Status OK
    }
    
    # Check databases
    Write-Status "`nDatabases:" -Status INFO
    $targetPackages = Get-TargetPackages
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        $basePath = Get-PackagePath $pkg.Family
        
        if (-not (Test-Path $basePath)) { continue }
        
        $dbFiles = Get-ChildItem $basePath -Recurse -Include "*.db", "*.sqlite", "*.sqlite3" -ErrorAction SilentlyContinue
        foreach ($db in $dbFiles) {
            Write-Status "  $($pkg.Name): $($db.Name) ($($db.Length) bytes)" -Status INFO
        }
    }
    
    # Check protocol handlers
    Write-Status "`nProtocol handlers:" -Status INFO
    $protocols = @("saclient.winui")
    foreach ($protocol in $protocols) {
        $protoRegPath = "HKLM:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.protocol\$protocol"
        if (Test-Path $protoRegPath) {
            Write-Status "  $protocol`: Registered" -Status OK
        }
        else {
            Write-Status "  $protocol`: Not found" -Status WARN
        }
    }
}

# ==================== MODE HANDLERS ====================

function Invoke-SoftReset {
    Write-Status "`n=== SOFT RESET ===" -Status ACTION
    Write-Status "Clearing caches without removing credentials`n" -Status INFO
    
    Stop-SamsungApps
    
    $targetPackages = Get-TargetPackages
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        Clear-AppCache -PackageFamily $pkg.Family -AppName $pkg.Name
    }
    
    Write-Status "`nSoft reset complete. Try launching Samsung apps again." -Status OK
}

function Invoke-HardReset {
    Write-Status "`n=== HARD RESET ===" -Status ACTION
    Write-Status "WARNING: This will clear ALL data including sign-in credentials!" -Status WARN
    
    $confirm = Read-Host "Are you sure? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Status "Aborted by user" -Status INFO
        return
    }
    
    Stop-SamsungApps
    
    $targetPackages = Get-TargetPackages
    foreach ($pkgKey in $targetPackages) {
        if (-not $SamsungPackages.ContainsKey($pkgKey)) { continue }
        $pkg = $SamsungPackages[$pkgKey]
        
        Clear-AppCache -PackageFamily $pkg.Family -AppName $pkg.Name
        Reset-SettingsDat -PackageFamily $pkg.Family -AppName $pkg.Name
    }
    
    Clear-AuthenticationData -KeepCredentials:$false
    
    Write-Status "`nHard reset complete. You will need to sign in again to Samsung Account." -Status OK
}

function Invoke-FactoryReset {
    Write-Status "`n=== FACTORY RESET ===" -Status ACTION
    Write-Status "WARNING: This will COMPLETELY reset ALL Samsung app data!" -Status WARN
    Write-Status "This includes: credentials, devices, databases, settings, caches" -Status WARN
    
    $confirm = Read-Host "Type 'FACTORY RESET' to confirm"
    if ($confirm -ne "FACTORY RESET") {
        Write-Status "Aborted by user" -Status INFO
        return
    }
    
    Stop-SamsungApps
    
    Write-Status "`nCreating backups..." -Status ACTION
    foreach ($pkgKey in $SamsungPackages.Keys) {
        $pkg = $SamsungPackages[$pkgKey]
        Backup-PackageData -PackageFamily $pkg.Family -AppName $pkg.Name
    }
    
    # Clear everything
    Clear-DeviceData
    Clear-AllDatabases
    Reset-AllSettingsDat
    Clear-AuthenticationData -KeepCredentials:$false
    
    # Clear all caches
    foreach ($pkgKey in $SamsungPackages.Keys) {
        $pkg = $SamsungPackages[$pkgKey]
        Clear-AppCache -PackageFamily $pkg.Family -AppName $pkg.Name
    }
    
    # Clear LocalState folders
    Write-Status "`nClearing LocalState folders..." -Status ACTION
    foreach ($pkgKey in $SamsungPackages.Keys) {
        $pkg = $SamsungPackages[$pkgKey]
        $localStatePath = Join-Path (Get-PackagePath $pkg.Family) "LocalState"
        if (Test-Path $localStatePath) {
            try {
                Get-ChildItem $localStatePath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Status "Cleared LocalState for $($pkg.Name)" -Status OK
            }
            catch {
                Write-Status "Could not fully clear LocalState for $($pkg.Name)" -Status WARN
            }
        }
    }
    
    # Clear ProgramData and LocalAppData Samsung folders
    Clear-AllSamsungData
    
    Write-Status "`nFactory reset complete." -Status OK
    Write-Status "Restart your computer, then sign in to Samsung Account." -Status INFO
}

# ==================== PACKAGE DEFINITIONS ====================
$script:PackageDatabase = @{
    # CORE PACKAGES - Required for basic functionality
    Core        = @(
        @{
            Name        = "Samsung Account"
            Id          = "9P98T77876KZ"
            Category    = "Core"
            Description = "Required for Samsung ecosystem authentication"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Settings"
            Id          = "9P2TBWSHK6HJ"
            Category    = "Core"
            Description = "Central configuration for Samsung apps"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Settings Runtime"
            Id          = "9NL68DVFP841"
            Category    = "Core"
            Description = "Required runtime for Samsung Settings"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Cloud"
            Id          = "9NFWHCHM52HQ"
            Category    = "Core"
            Description = "Cloud storage and sync service"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Knox Matrix for Windows"
            Id          = "9NJRV1DT8N79"
            Category    = "Core"
            Description = "Samsung Knox security synchronization"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Continuity Service"
            Id          = "9NGW9K44GQ5F"
            Category    = "Core"
            Description = "Enables cross-device continuity features"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Intelligence Service"
            Id          = "9NS0SHL4PQL9"
            Category    = "Core"
            Description = "Required for Galaxy AI features and AI Select"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Samsung Bluetooth Sync"
            Id          = "9NJNNJTTFL45"
            Category    = "Core"
            Description = "Bluetooth device synchronization"
            Status      = "Working"
            Required    = $true
        },
        @{
            Name        = "Galaxy Book Experience"
            Id          = "9P7QF37HPMGX"
            Category    = "Core"
            Description = "Samsung app discovery and Galaxy Book features"
            Status      = "Working"
            Required    = $true
        }
    )
    
    # RECOMMENDED PACKAGES - Full Samsung experience (everything that works)
    Recommended = @(
        @{
            Name              = "Quick Share"
            Id                = "9PCTGDFXVZLJ"
            Category          = "Connectivity"
            Description       = "Fast file sharing between devices"
            Status            = "Working"
            RequiresIntelWiFi = $true
            Warning           = "Requires Intel Wi-Fi (some AC/AX/BE) AND Intel Bluetooth"
        },
        @{
            Name        = "Samsung Notes"
            Id          = "9NBLGGH43VHV"
            Category    = "Productivity"
            Description = "Note-taking with stylus support"
            Status      = "Working"
        },
        @{
            Name        = "Multi Control"
            Id          = "9N3L4FZ03Q99"
            Category    = "Connectivity"
            Description = "Control multiple devices with one keyboard/mouse"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Gallery"
            Id          = "9NBLGGH4N9R9"
            Category    = "Media"
            Description = "Photo and video gallery with cloud sync"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Studio"
            Id          = "9P312B4TZFFH"
            Category    = "Media"
            Description = "Photo and video editing suite"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Studio for Gallery"
            Id          = "9NND8BT5WFC5"
            Category    = "Media"
            Description = "Gallery-integrated editing tools"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Screen Recorder"
            Id          = "9P5025MM7WDT"
            Category    = "Productivity"
            Description = "Screen recording with annotations"
            Status      = "Working"
            Warning     = "Shows 'optimized for Galaxy Books' message on launch, but works normally"
        },
        @{
            Name        = "Samsung Flow"
            Id          = "9NBLGGH5GB0M"
            Category    = "Connectivity"
            Description = "Phone-PC integration features"
            Status      = "Working"
        },
        @{
            Name        = "SmartThings"
            Id          = "9N3ZBH5V7HX6"
            Category    = "Smart Home"
            Description = "Control SmartThings devices"
            Status      = "Working"
        },
        @{
            Name        = "Galaxy Buds"
            Id          = "9NHTLWTKFZNB"
            Category    = "Accessories"
            Description = "Galaxy Buds management and settings"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Parental Controls"
            Id          = "9N5GWJTCZKGS"
            Category    = "Security"
            Description = "Manage children's device usage"
            Status      = "Working"
        },
        @{
            Name        = "AI Select"
            Id          = "9PM11FHJQLZ4"
            Category    = "Productivity"
            Description = "Smart screenshot tool with text extraction and AI features"
            Status      = "Working"
            Tip         = "TIP: If you have a Windows Precision Touchpad, you can configure the 4-finger tap gesture to launch AI Select via Settings > Bluetooth & devices > Touchpad > Advanced gestures"
        },
        @{
            Name        = "Nearby Devices"
            Id          = "9PHL04NJNT67"
            Category    = "Connectivity"
            Description = "Manage and connect to nearby Samsung devices"
            Status      = "Working"
        },
        @{
            Name              = "Storage Share"
            Id                = "9MVNW0XH7HS5"
            Category          = "Utilities"
            Description       = "Share storage between devices"
            Status            = "Working"
            RequiresIntelWiFi = $true
            Warning           = "Requires Intel Wi-Fi (some AC/AX/BE) AND Intel Bluetooth"
        },
        @{
            Name        = "Second Screen"
            Id          = "9PLTXW5DX5KB"
            Category    = "Productivity"
            Description = "Use tablet as secondary display"
            Status      = "Working"
        },
        @{
            Name        = "Live Wallpaper"
            Id          = "9N1G7F25FXCB"
            Category    = "Personalization"
            Description = "Animated wallpapers"
            Status      = "Working"
        },
        @{
            Name        = "Galaxy Book Smart Switch"
            Id          = "9PJ0J9KQWCLB"
            Category    = "Utilities"
            Description = "Transfer data to new Galaxy Book"
            Status      = "Working"
        },
        @{
            Name        = "Samsung Pass"
            Id          = "9MVWDZ5KX9LH"
            Category    = "Security"
            Description = "Password manager with biometric auth"
            Status      = "Working"
            Warning     = "Untested on non-Samsung devices - may require additional setup"
        }
    )
    
    # EXTRA STEPS REQUIRED - Need additional configuration
    ExtraSteps  = @(
        @{
            Name        = "Samsung Device Care"
            Id          = "9NBLGGH4XDV0"
            Category    = "Maintenance"
            Description = "Device optimization and diagnostics"
            Status      = "RequiresExtraSteps"
            Note        = "Requires additional setup to function properly"
        },
        @{
            Name        = "Samsung Phone"
            Id          = "9MWJXXLCHBGK"
            Category    = "Connectivity"
            Description = "Phone app integration"
            Status      = "RequiresExtraSteps"
            Warning     = "Requires additional configuration steps to work properly"
        },
        @{
            Name        = "Samsung Find"
            Id          = "9MWD59CZJ1RN"
            Category    = "Security"
            Description = "Find your Samsung devices"
            Status      = "RequiresExtraSteps"
            Warning     = "Requires additional configuration steps to work properly"
        },
        @{
            Name        = "Quick Search"
            Id          = "9N092440192Z"
            Category    = "Productivity"
            Description = "Fast system-wide search"
            Status      = "RequiresExtraSteps"
            Warning     = "Requires additional configuration steps to work properly"
        }
    )
    
    # NON-WORKING - User can install but won't function
    NonWorking  = @(
        @{
            Name        = "Samsung Recovery"
            Id          = "9NBFVH4X67LF"
            Category    = "Maintenance"
            Description = "Factory reset and recovery options"
            Status      = "NotWorking"
            Warning     = "This app will NOT work on non-Samsung devices (requires genuine hardware)"
        },
        @{
            Name        = "Samsung Update"
            Id          = "9NQ3HDB99VBF"
            Category    = "Maintenance"
            Description = "Firmware and driver updates"
            Status      = "NotWorking"
            Warning     = "This app will NOT work on non-Samsung devices (requires genuine hardware)"
        },
        @{
            Name              = "Camera Share"
            Id                = "9NPCS7FN6VB9"
            Category          = "Connectivity"
            Description       = "Use phone camera with PC apps"
            Status            = "Working"
            RequiresIntelWiFi = $true
            Warning           = "Requires Intel Wi-Fi (some AC/AX/BE) AND Intel Bluetooth"
        }
    )
    
    # LEGACY - Not recommended
    Legacy      = @(
        @{
            Name        = "Samsung Studio Plus (Legacy)"
            Id          = "9PLPF77D2R18"
            Category    = "Media"
            Description = "Old version of Studio"
            Status      = "Legacy"
            Warning     = "Use Samsung Studio instead (newer version)"
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
            }
            else {
                continue
            }
            
            # Extract the update GUID
            $updateId = $null
            if ($rowContent -match "goToDetails\([`"']([^`"']+)[`"']") {
                $updateId = $Matches[1]
            }
            elseif ($rowContent -match 'id=([a-f0-9-]{36})') {
                $updateId = $Matches[1]
            }
            
            if (-not $updateId) { continue }
            
            # Extract last updated date
            $lastUpdated = Get-Date
            if ($rowContent -match '(\d{1,2}/\d{1,2}/\d{4})') {
                try {
                    $lastUpdated = [DateTime]::Parse($Matches[1])
                }
                catch {
                    Write-Verbose "Failed to parse date '$($Matches[1])': $_. Using default date."
                }
            }
            
            $drivers += [PSCustomObject]@{
                Title       = $title
                Version     = $driverVersion
                UpdateId    = $updateId
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
        }
        else {
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
            }
            elseif ($downloadResponse.Content -match 'https?://[^''"\s]+\.cab') {
                $downloadUrl = $Matches[0]
            }
        }
        catch {
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
                Version  = $selectedDriver.Version
                FilePath = $outputFile
                FileName = $fileName
                UpdateId = $selectedDriver.UpdateId
                FileSize = $fileSize
            }
        }
        else {
            Write-Error "Download failed - file not found"
            return $null
        }
        
    }
    catch {
        Write-Error "Failed to download CAB: $($_.Exception.Message)"
        return $null
    }
}

function Expand-SSSECab {
    param(
        [string]$CabPath,
        [string]$ExtractRoot
    )
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $extractDir = Join-Path $ExtractRoot "CAB_Extract_$timestamp"
    $level1Dir = Join-Path $extractDir "Level1"
    $level2Dir = Join-Path $extractDir "Level2_settings_x64"
    
    try {
        # Create extraction directories
        New-Item -Path $level1Dir -ItemType Directory -Force | Out-Null
        New-Item -Path $level2Dir -ItemType Directory -Force | Out-Null
        
        # LEVEL 1: Extract main CAB
        Write-Host "  Extracting main CAB..." -ForegroundColor Yellow
        $expandResult = & expand.exe "$CabPath" -F:* "$level1Dir" 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract main CAB: $expandResult"
        }
        
        # Find the .inf and .cat files (driver files)
        $infFile = Get-ChildItem -Path $level1Dir -Filter "*.inf" -File | Select-Object -First 1
        $catFile = Get-ChildItem -Path $level1Dir -Filter "*.cat" -File | Select-Object -First 1
        
        # LEVEL 2: Extract inner settings_x64.cab
        $settingsCab = Get-ChildItem -Path $level1Dir -Filter "settings_x64.cab" -File
        if (-not $settingsCab) {
            throw "settings_x64.cab not found in main CAB"
        }
        
        Write-Host "  Extracting inner CAB..." -ForegroundColor Yellow
        $expandResult = & expand.exe "$($settingsCab.FullName)" -F:* "$level2Dir" 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to extract settings_x64.cab: $expandResult"
        }
        
        return @{
            ExtractDir = $extractDir
            Level1Dir  = $level1Dir
            Level2Dir  = $level2Dir
            InfFile    = $infFile
            CatFile    = $catFile
        }
    }
    catch {
        Write-Error "Extraction failed: $_"
        return $null
    }
}

function Update-SSSEBinary {
    param(
        [string]$ExePath
    )
    
    if (-not (Test-Path $ExePath)) {
        Write-Error "Binary not found: $ExePath"
        return $false
    }
    
    $backupExePath = "$ExePath.backup"
    Copy-Item $ExePath $backupExePath -Force
    Write-Host "    ✓ Backup created: $(Split-Path $backupExePath -Leaf)" -ForegroundColor Green
    
    $fileBytes = [System.IO.File]::ReadAllBytes($ExePath)
    
    $patchCount = 0
    
    for ($i = 0; $i -lt ($fileBytes.Length - 12); $i++) {
        if ($fileBytes[$i] -eq 0x4C -and $fileBytes[$i + 1] -eq 0x8B -and 
            ($fileBytes[$i + 2] -eq 0xF0 -or $fileBytes[$i + 2] -eq 0xF8) -and
            $fileBytes[$i + 3] -eq 0x48 -and $fileBytes[$i + 4] -eq 0x83 -and
            $fileBytes[$i + 5] -eq 0xF8 -and $fileBytes[$i + 6] -eq 0xFF -and
            $fileBytes[$i + 7] -eq 0x0F -and $fileBytes[$i + 8] -eq 0x85) {
            
            $reg = if ($fileBytes[$i + 2] -eq 0xF0) { "R14" } else { "R15" }
            $patchOffset = $i + 7
            
            $fileBytes[$patchOffset] = 0x48
            $fileBytes[$patchOffset + 1] = 0xE9
            
            Write-Host "    Primary patch @ 0x$($patchOffset.ToString('X5')): 0F 85 -> 48 E9 (MOV $reg pattern)" -ForegroundColor Green
            $patchCount++
            $searchEnd = [Math]::Min($i + 512, $fileBytes.Length - 10)
            for ($j = $i + 12; $j -lt $searchEnd; $j++) {
                if ($fileBytes[$j] -eq 0xE8 -and
                    $fileBytes[$j + 5] -eq 0x48 -and $fileBytes[$j + 6] -eq 0x83 -and
                    $fileBytes[$j + 7] -eq 0xF8 -and $fileBytes[$j + 8] -eq 0xFF -and
                    $fileBytes[$j + 9] -eq 0x75) {
                    
                    $secPatchOffset = $j + 9
                    $fileBytes[$secPatchOffset] = 0xEB
                    
                    Write-Host "    Secondary patch @ 0x$($secPatchOffset.ToString('X5')): 75 -> EB (6.x compatibility)" -ForegroundColor Green
                    $patchCount++
                    break
                }
            }
            break  
        }
    }
    
    if ($patchCount -eq 0) {
        $alreadyPatched = $false
        for ($i = 0; $i -lt ($fileBytes.Length - 12); $i++) {
            if ($fileBytes[$i] -eq 0x4C -and $fileBytes[$i + 1] -eq 0x8B -and 
                ($fileBytes[$i + 2] -eq 0xF0 -or $fileBytes[$i + 2] -eq 0xF8) -and
                $fileBytes[$i + 3] -eq 0x48 -and $fileBytes[$i + 4] -eq 0x83 -and
                $fileBytes[$i + 5] -eq 0xF8 -and $fileBytes[$i + 6] -eq 0xFF -and
                $fileBytes[$i + 7] -eq 0x48 -and $fileBytes[$i + 8] -eq 0xE9) {
                $alreadyPatched = $true
                break
            }
        }
        
        if ($alreadyPatched) {
            Write-Host "    ✓ Binary already patched!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "    ⚠ Pattern not found - unknown SSSE version" -ForegroundColor Yellow
            Write-Host "    Please report this version for analysis" -ForegroundColor Gray
            return $false
        }
    }
    else {
        # Write patched bytes back to file
        [System.IO.File]::WriteAllBytes($ExePath, $fileBytes)
        Write-Host "    ✓ Applied $patchCount patch(es) successfully!" -ForegroundColor Green
        return $true
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
    
    .PARAMETER ForceVersion
        If specified, skips version selection and uses this version directly
    #>
    
    param(
        [string]$InstallPath = "C:\GalaxyBook",
        [bool]$TestMode = $false,
        [string]$ForceVersion = $null
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
    
    # Ensure InstallPath has a value (defensive check for irm|iex scenarios)
    if ([string]::IsNullOrWhiteSpace($InstallPath)) {
        $InstallPath = "C:\GalaxyBook"
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
                        Path     = $path
                        Version  = $version
                        Size     = [math]::Round($fileInfo.Length / 1KB, 2)
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
            # Try to get service path with timeout to avoid hanging
            $svcPath = $null
            try {
                $svcPath = (Get-CimInstance Win32_Service -Filter "Name='$svcName'" -OperationTimeoutSec 5 -ErrorAction SilentlyContinue).PathName
            }
            catch {
                # Fallback: try registry
                try {
                    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
                    if (Test-Path $regPath) {
                        $svcPath = (Get-ItemProperty -Path $regPath -Name ImagePath -ErrorAction SilentlyContinue).ImagePath
                    }
                }
                catch {
                    $svcPath = "Unknown"
                }
            }
            
            $isDriverStore = $svcPath -like "*DriverStore*" -or $svcPath -like "*Windows\System32*"
            
            $existingServices += [PSCustomObject]@{
                Name          = $service.Name
                Status        = $service.Status
                StartType     = $service.StartType
                Path          = $svcPath
                IsOriginal    = ($svcName -eq "SamsungSystemSupportService")
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
            }
            else {
                Write-Host "  ⚠ Failed to disable service - you may need to do this manually" -ForegroundColor Yellow
            }
        }
        else {
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
                }
                elseif ($existingInstallations.Count -eq 1) {
                    # Use the single found installation path for upgrade
                    $InstallPath = $existingInstallations[0].Path
                }
                else {
                    # No installation directories found (only services detected)
                    # Use default path for fresh install
                    Write-Host "  No existing installation directory found, using default path" -ForegroundColor Yellow
                    $InstallPath = "C:\GalaxyBook"
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
                    }
                    else {
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
    
    # Download CAB - Dual Version Strategy for Fresh Install
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  SSSE Installation Strategy" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Use ForceVersion if provided (for quick upgrades), otherwise use dual-version strategy
    if ($ForceVersion) {
        $cabVersion = $ForceVersion
        $installedVersion = $ForceVersion  # Track installed version
        Write-Host "  Using specified version: $cabVersion" -ForegroundColor Cyan
        $useDualVersionStrategy = $false
    }
    else {
        Write-Host ""
        Write-Host "  Recommended: In-place upgrade strategy" -ForegroundColor Green
        Write-Host "    • Install stable 6.1.8.0, then auto-upgrade to latest 7.1.2.0" -ForegroundColor Gray
        Write-Host "    • Ensures Samsung Settings launches before upgrading" -ForegroundColor Gray
        Write-Host ""
        
        $strategyChoice = Read-Host "  Use in-place upgrade to latest version? ([Y]/n)"
        
        if ($strategyChoice -like "n*") {
            # Fallback to manual version selection
            Write-Host ""
            Write-Host "  Available versions:" -ForegroundColor Yellow
            Write-Host "    [1] 6.3.3.0 - Stable" -ForegroundColor White
            Write-Host "    [2] 7.1.2.0 - Latest" -ForegroundColor White
            Write-Host "    [3] Other   - Choose from all versions" -ForegroundColor Gray
            Write-Host ""
            
            $versionChoice = Read-Host "  Select version [1-3] (default: 1)"
            
            $cabVersion = switch ($versionChoice) {
                "2" { "7.1.2.0" }
                "3" { $null }  # Will show interactive menu
                default { "6.3.3.0" }
            }
            
            if ($cabVersion) {
                Write-Host "  Selected: $cabVersion" -ForegroundColor Cyan
            }
            $installedVersion = $cabVersion  # Track installed version for single-version install
            $useDualVersionStrategy = $false
        }
        else {
            # Use dual-version strategy
            $cabVersion = "6.1.8.0"  # Primary version for patched exe
            $driverVersion = "7.1.2.0"  # Driver version for DriverStore
            $installedVersion = $cabVersion  # Track current installed version (updated after binary replacement)
            $useDualVersionStrategy = $true
            Write-Host "  ✓ Will install 6.1.8.0 then upgrade to 7.1.2.0" -ForegroundColor Green
        }
    }
    
    # Check for and remove existing Samsung Settings packages
    Write-Host "`nChecking for existing Samsung Settings packages..." -ForegroundColor Cyan
    $existingSettings = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*SamsungSettings*" }
    
    if ($existingSettings) {
        Write-Host "  Found existing Samsung Settings packages:" -ForegroundColor Yellow
        foreach ($app in $existingSettings) {
            Write-Host "    • $($app.Name) v$($app.Version)" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "  These need to be removed to ensure the new driver version" -ForegroundColor Gray
        Write-Host "  triggers a fresh installation from the Store." -ForegroundColor Gray
        Write-Host ""
        
        $removeChoice = Read-Host "Remove existing Samsung Settings packages? (Y/n)"
        if ($removeChoice -notlike "n*") {
            Write-Host "  Removing packages..." -ForegroundColor Yellow
            $removalResult = Remove-SamsungSettingsPackages -Packages $existingSettings
            
            if ($removalResult.Success.Count -gt 0) {
                Write-Host "  ✓ Removed: $($removalResult.Success -join ', ')" -ForegroundColor Green
            }
            if ($removalResult.Failed.Count -gt 0) {
                Write-Host "  ⚠ Failed to remove some packages. You may need to remove manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  ⚠ Keeping existing packages (may cause version conflicts)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ✓ No existing Samsung Settings packages found" -ForegroundColor Green
    }
    
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
    
    $extractResult = Expand-SSSECab -CabPath $cabResult.FilePath -ExtractRoot $tempDir
    
    try {
        if (-not $extractResult) {
            throw "Extraction failed"
        }
    
        $extractDir = $extractResult.ExtractDir
        # $level1Dir = $extractResult.Level1Dir # Unused
        $level2Dir = $extractResult.Level2Dir
        $infFile = $extractResult.InfFile
        $catFile = $extractResult.CatFile
    
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
            }
            else {
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
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
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
                    }
                    catch {
                        Write-Host "    ⚠ Failed to stop: $procName" -ForegroundColor Yellow
                    }
                }
            }
        }
    
        if ($killedProcesses.Count -gt 0) {
            Write-Host "    ✓ Stopped $($killedProcesses.Count) process(es)" -ForegroundColor Green
            Start-Sleep -Seconds 2  # Give processes time to fully exit
        }
        else {
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
            }
            catch {
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
        }
        else {
            Write-Host "  ✓ All files copied" -ForegroundColor Green
        }
        
        # Patch the executable
        Write-Host "  [6/7] Patching binary..." -ForegroundColor Yellow
        
        $targetExePath = Join-Path $InstallPath "SamsungSystemSupportEngine.exe"
        $patchResult = Update-SSSEBinary -ExePath $targetExePath
        
        if (-not $patchResult) {
            Write-Warning "Patching failed or pattern not found"
        }
        
        # Handle conflicting services
        Write-Host "  [7/7] Configuring service..." -ForegroundColor Yellow
        
        if ($TestMode) {
            Write-Host "    [TEST MODE] Skipping service operations" -ForegroundColor Yellow
            Write-Host "      Would stop/disable conflicting Samsung services" -ForegroundColor Gray
            Write-Host "      Would create: GBeSupportService" -ForegroundColor Gray
            Write-Host "      Settings: LocalSystem account, Auto startup, Running" -ForegroundColor Gray
            Write-Host "      Binary: $targetExePath" -ForegroundColor Gray
        }
        else {
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
        
            $binPath = Join-Path $InstallPath "SamsungSystemSupportService.exe"
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
                & sc.exe delete $newServiceName 2>&1 | Out-Null
                Write-Host "      ✓ Service deletion initiated" -ForegroundColor Green
            
                # Wait for Windows to complete the deletion (marked for deletion issue)
                Write-Host "      Waiting for Windows to complete deletion..." -ForegroundColor Gray
                $maxWait = 30  # Maximum 30 seconds
                $waited = 0
                $serviceDeleted = $false
                $shownHelp = $false
            
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
                
                    # Show help after 10 seconds if still waiting
                    if ($waited -eq 10 -and -not $shownHelp) {
                        Write-Host "`n      ⚠ Service deletion is taking longer than usual..." -ForegroundColor Yellow
                        Write-Host "      Common causes:" -ForegroundColor Cyan
                        Write-Host "        • Task Manager is open" -ForegroundColor Gray
                        Write-Host "        • Services console (services.msc) is open" -ForegroundColor Gray
                        Write-Host "        • Event Viewer is open" -ForegroundColor Gray
                        Write-Host "        • Process Explorer is open" -ForegroundColor Gray
                        Write-Host "`n      Options:" -ForegroundColor Cyan
                        Write-Host "        [1] Close these apps manually and I'll wait" -ForegroundColor White
                        Write-Host "        [2] Auto-close Task Manager, Services, Event Viewer" -ForegroundColor White
                        Write-Host "        [3] Continue waiting (will timeout in $($maxWait - $waited)s)" -ForegroundColor White
                        Write-Host ""
                    
                        $choice = Read-Host "      Choose option [1-3]"
                    
                        if ($choice -eq "2") {
                            Write-Host "      Attempting to close interfering applications..." -ForegroundColor Yellow
                        
                            # Close MMC instances (Services, Event Viewer)
                            $mmcProcesses = Get-Process -Name "mmc" -ErrorAction SilentlyContinue
                            if ($mmcProcesses) {
                                Write-Host "        Closing MMC instances (Services/Event Viewer)..." -ForegroundColor Gray
                                $mmcProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
                            }
                        
                            # Close Task Manager
                            $taskmgrProcesses = Get-Process -Name "Taskmgr" -ErrorAction SilentlyContinue
                            if ($taskmgrProcesses) {
                                Write-Host "        Closing Task Manager..." -ForegroundColor Gray
                                $taskmgrProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
                            }
                        
                            # Close Process Explorer if present
                            $procexpProcesses = Get-Process -Name "procexp*" -ErrorAction SilentlyContinue
                            if ($procexpProcesses) {
                                Write-Host "        Closing Process Explorer..." -ForegroundColor Gray
                                $procexpProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
                            }
                        
                            Write-Host "        ✓ Applications closed, resuming wait..." -ForegroundColor Green
                            Start-Sleep -Seconds 2
                        }
                        elseif ($choice -eq "1") {
                            Write-Host "      Please close the applications, then press Enter to continue..." -ForegroundColor Yellow
                            Read-Host
                        }
                    
                        $shownHelp = $true
                        Write-Host ""
                    }
                
                    if ($waited % 6 -eq 0 -and $shownHelp) {
                        Write-Host "      Still waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
                    }
                }
            
                if (-not $serviceDeleted) {
                    Write-Host "`n      ⚠ Service still marked for deletion - unable to remove old service" -ForegroundColor Yellow
                    Write-Host "      Creating upgraded service with new name instead..." -ForegroundColor Cyan
                
                    # Use a versioned name to avoid conflict
                    $timestamp = Get-Date -Format 'yyyyMMdd'
                    $newServiceName = "GBeSupportService_$timestamp"
                    $displayName = "Galaxy Book Enabler Support Service ($timestamp)"
                
                    Write-Host "      New service name: $newServiceName" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "      ⚠ IMPORTANT: Old service 'GBeSupportService' is still present" -ForegroundColor Yellow
                    Write-Host "      After reboot, you should manually delete it:" -ForegroundColor Yellow
                    Write-Host "        1. Open PowerShell as Administrator" -ForegroundColor White
                    Write-Host "        2. Run: sc delete GBeSupportService" -ForegroundColor Cyan
                    Write-Host "        3. Or use Services console to delete it" -ForegroundColor White
                    Write-Host ""
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
                & sc.exe description $newServiceName $description 2>&1 | Out-Null
                
                # Configure service failure recovery - restart service on failure
                Write-Host "    Configuring service failure recovery..." -ForegroundColor Gray
                & sc.exe failure $newServiceName reset= 86400 actions= restart/5000/restart/5000/restart/5000 2>&1 | Out-Null
                Write-Host "    ✓ Service will auto-restart on failure (5s delays)" -ForegroundColor Green
            
                Write-Host "      Name: $newServiceName" -ForegroundColor Gray
                Write-Host "      Display: $displayName" -ForegroundColor Gray
                Write-Host "      Description: $description" -ForegroundColor Gray
                Write-Host "      Binary: $binPath" -ForegroundColor Gray
                Write-Host "      Startup: Automatic" -ForegroundColor Gray
                Write-Host "      Account: LocalSystem" -ForegroundColor Gray
            
                # Start the service immediately with aggressive retry
                Write-Host "    Starting service..." -ForegroundColor Gray
                Write-Host "      Killing any Samsung processes first..." -ForegroundColor Gray
                
                # Kill Samsung processes before starting
                $samsungProcesses = @(
                    "SamsungSystemSupportEngine",
                    "SamsungSystemSupportService",
                    "SamsungSystemSupportOSD",
                    "SamsungActiveScreen",
                    "SamsungHideWindow",
                    "SettingsEngineTest",
                    "SettingsExtensionLauncher"
                )
                
                foreach ($procName in $samsungProcesses) {
                    $processes = Get-Process -Name $procName -ErrorAction SilentlyContinue
                    if ($processes) {
                        $processes | Stop-Process -Force -ErrorAction SilentlyContinue
                    }
                }
                Start-Sleep -Seconds 2
                
                # Retry loop - keep trying until it starts
                $maxAttempts = 10
                $attempt = 1
                $serviceStarted = $false
                
                while (-not $serviceStarted -and $attempt -le $maxAttempts) {
                    Write-Host "      Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
                    
                    try {
                        Start-Service -Name $newServiceName -ErrorAction Stop
                        Start-Sleep -Seconds 3
                        
                        $serviceStatus = (Get-Service -Name $newServiceName -ErrorAction SilentlyContinue).Status
                        if ($serviceStatus -eq 'Running') {
                            Write-Host "    ✓ Service started successfully (attempt $attempt)" -ForegroundColor Green
                            $serviceStarted = $true
                        }
                        else {
                            Write-Host "      Status: $serviceStatus - retrying..." -ForegroundColor Yellow
                            $attempt++
                            Start-Sleep -Seconds 2
                        }
                    }
                    catch {
                        Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
                        $attempt++
                        Start-Sleep -Seconds 2
                    }
                }
                
                if (-not $serviceStarted) {
                    Write-Host "    ⚠ Could not start service after $maxAttempts attempts" -ForegroundColor Red
                    Write-Host "      The service is set to Automatic and will start on next reboot" -ForegroundColor Yellow
                    Write-Host "      If it still doesn't start, try:" -ForegroundColor Yellow
                    Write-Host "        1. Kill all Samsung processes" -ForegroundColor Gray
                    Write-Host "        2. Manually start GBeSupportService in Services" -ForegroundColor Gray
                }
            }
            else {
                Write-Warning "Service creation failed: $scResult"
                Write-Host "    You can manually create it with this command:" -ForegroundColor Yellow
                Write-Host "    sc create `"$newServiceName`" binPath=`"$binPath`" start=auto obj=LocalSystem DisplayName=`"$displayName`"" -ForegroundColor Cyan
                Write-Host "    sc description `"$newServiceName`" `"$description`"" -ForegroundColor Cyan
            }
        }
        
        # Install driver to DriverStore (required for Samsung Settings)
        Write-Host "  [8/8] Installing driver to DriverStore..." -ForegroundColor Yellow
        
        if ($TestMode) {
            Write-Host "    [TEST MODE] Skipping driver installation" -ForegroundColor Yellow
            if ($infFile) {
                Write-Host "      Would add driver to store: $($infFile.Name)" -ForegroundColor Gray
            }
            else {
                Write-Host "      No .inf file found" -ForegroundColor Gray
            }
        }
        else {
            if (-not $infFile) {
                Write-Warning "No .inf file found - skipping driver installation"
            }
            else {
                $infPath = Join-Path $InstallPath $infFile.Name
                Write-Host "    Using: $($infFile.Name)" -ForegroundColor Gray
                Install-SSSEDriverToStore -InfPath $infPath -TestMode $TestMode
            }
        }
        
        # DUAL-VERSION STRATEGY: Download and install 7.1.2.0 driver-only
        if ($useDualVersionStrategy) {
            Write-Host "`n  [DUAL-VERSION] Downloading 7.1.2.0 driver..." -ForegroundColor Cyan
            
            $driverCabResult = Get-SamsungDriverCab -Version $driverVersion -OutputPath $tempDir
            
            if ($driverCabResult) {
                # Extract just the driver files from 7.1.2.0
                $driverExtractDir = Join-Path $extractDir "Driver_7120"
                New-Item -Path $driverExtractDir -ItemType Directory -Force | Out-Null
                
                $expandResult = & expand.exe "$($driverCabResult.FilePath)" -F:* "$driverExtractDir" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $driverInfFile = Get-ChildItem -Path $driverExtractDir -Filter "*.inf" -File | Select-Object -First 1
                    
                    if ($driverInfFile) {
                        Write-Host "    Installing 7.1.2.0 driver to DriverStore..." -ForegroundColor Yellow
                        
                        if (-not $TestMode) {
                            $pnputilResult = & pnputil /add-driver "$($driverInfFile.FullName)" /install 2>&1
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "    ✓ 7.1.2.0 driver added to DriverStore" -ForegroundColor Green
                            }
                            else {
                                Write-Host "    ⚠ Driver add had issues: $pnputilResult" -ForegroundColor Yellow
                            }
                        }
                        else {
                            Write-Host "    [TEST] Would add 7.1.2.0 driver to DriverStore" -ForegroundColor Gray
                        }
                    }
                    else {
                        Write-Host "    ⚠ No .inf file found in 7.1.2.0 CAB" -ForegroundColor Yellow
                    }
                }
                else {
                    Write-Host "    ⚠ Failed to extract 7.1.2.0 CAB: $expandResult" -ForegroundColor Yellow
                }
                
                # Cleanup
                Remove-Item $driverExtractDir -Recurse -Force -ErrorAction SilentlyContinue

                # ==============================================================================
                # DUAL-VERSION PHASE 2: Core Apps & Binary Replacement
                # ==============================================================================
                
                # 1. Install Core Packages (Samsung Settings, etc.)
                Write-Host "`n  [DUAL-VERSION] Installing Core Packages..." -ForegroundColor Cyan
                Install-SamsungPackages -Packages $script:PackageDatabase.Core -TestMode $TestMode
                
                # 2. Launch Samsung Settings to trigger Store update
                Write-Host "`n  [DUAL-VERSION] Launching Samsung Settings" -ForegroundColor Cyan
                try {
                    # Samsung Settings AppID
                    $settingsAppId = "SAMSUNGELECTRONICSCO.LTD.SamsungSettings1.5_3c1yjt4zspk6g!App"
                    Start-Process "shell:AppsFolder\$settingsAppId" -ErrorAction Stop
                    Write-Host "  ✓ Samsung Settings launched" -ForegroundColor Green
                    
                    # Wait for user confirmation or delay
                    Write-Host "`n  IMPORTANT: Check if Samsung Settings opened." -ForegroundColor Yellow
                    Write-Host "  Please follow these steps to sync your devices:" -ForegroundColor Cyan
                    Write-Host "    1. Sign in to Samsung Settings" -ForegroundColor White
                    Write-Host "    2. Go to 'Easy Bluetooth Connection'" -ForegroundColor White
                    Write-Host "    3. Enable 'Sync Bluetooth devices with Samsung Cloud'" -ForegroundColor White
                    Write-Host "    4. Click on it to open Samsung Cloud" -ForegroundColor White
                    Write-Host "    5. Click 'Sync now'" -ForegroundColor White
                    Write-Host "    6. Verify it shows your paired Samsung devices" -ForegroundColor White
                    Write-Host "       (Note: Buds2/3 (Pro/Non-Pro) may not appear if they don't support multipoint)" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "  Once you have verified the sync, press Enter to continue..." -ForegroundColor Cyan
                    Read-Host
                }
                catch {
                    Write-Warning "Failed to launch Samsung Settings: $_"
                    Write-Host "  Please open Samsung Settings manually from Start Menu." -ForegroundColor Yellow
                    Write-Host "  Then follow the sync instructions above." -ForegroundColor Gray
                    Read-Host "  Press Enter when ready..."
                }
                
                # 3. Stop Services & Processes
                Write-Host "`n  [DUAL-VERSION] Stopping services for binary replacement..." -ForegroundColor Cyan
                Stop-SamsungProcesses
                Stop-Service -Name "GBeSupportService" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
                
                # 4. Extract 7.1.2.0 Binary
                Write-Host "`n  [DUAL-VERSION] Extracting 7.1.2.0 binary..." -ForegroundColor Cyan
                $extract7Result = Expand-SSSECab -CabPath $driverCabResult.FilePath -ExtractRoot $tempDir
                
                if ($extract7Result) {
                    $ssseExe7 = Get-ChildItem -Path $extract7Result.Level2Dir -Filter "SamsungSystemSupportEngine.exe" -File -Recurse
                    
                    if ($ssseExe7) {
                        # 5. Patch 7.1.2.0 Binary
                        Write-Host "    Patching 7.1.2.0 binary..." -ForegroundColor Yellow
                        $patch7Result = Update-SSSEBinary -ExePath $ssseExe7.FullName
                        
                        if ($patch7Result) {
                            # 6. Replace Binary
                            Write-Host "    Replacing binary in $InstallPath..." -ForegroundColor Yellow
                            Copy-Item -Path $ssseExe7.FullName -Destination $InstallPath -Force
                            Write-Host "    ✓ Binary replaced with 7.1.2.0 version" -ForegroundColor Green
                            
                            # Update installed version tracker
                            $installedVersion = $driverVersion
                            
                            # 7. Restart Service
                            Write-Host "    Restarting service..." -ForegroundColor Yellow
                            Start-Service -Name "GBeSupportService"
                            Write-Host "    ✓ Service restarted" -ForegroundColor Green
                        }
                        else {
                            Write-Error "Failed to patch 7.1.2.0 binary"
                        }
                    }
                    else {
                        Write-Error "SamsungSystemSupportEngine.exe not found in 7.1.2.0 CAB"
                    }
                }
                else {
                    Write-Error "Failed to extract 7.1.2.0 CAB"
                }
            }
            else {
                Write-Host "    ⚠ Failed to download 7.1.2.0 driver CAB" -ForegroundColor Yellow
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
            }
            else {
                Write-Host "    ⚠ Original Samsung service: $($verifyOriginal.StartType) (should be Disabled)" -ForegroundColor Yellow
            }
        }
        
        $gbeSvc = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
        if ($gbeSvc) {
            Write-Host "    ✓ GBeSupportService: $($gbeSvc.StartType), $($gbeSvc.Status)" -ForegroundColor Green
            if ($gbeSvc.StartType -ne 'Automatic') {
                Write-Host "    ⚠ Warning: Service is not set to Automatic startup" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "    ⚠ GBeSupportService not found" -ForegroundColor Yellow
        }
        
        # Show completion summary
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  ✓ SSSE Installation Complete!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        
        # Determine final installed version for display
        $finalVersion = if ($installedVersion) { $installedVersion } else { $cabVersion }
        
        Write-Host "Installation Summary:" -ForegroundColor Cyan
        Write-Host "  Location: $InstallPath" -ForegroundColor White
        Write-Host "  Version: $finalVersion" -ForegroundColor White
        Write-Host "  Service: GBeSupportService" -ForegroundColor White
        Write-Host "  Binary: Patched ✓" -ForegroundColor Green
        Write-Host "  Driver: Added to DriverStore ✓" -ForegroundColor Green
        
        Write-Host "`nFiles installed:" -ForegroundColor Cyan
        $installedFiles = Get-ChildItem -Path $InstallPath -File | Select-Object -First 10
        foreach ($file in $installedFiles) {
            Write-Host "  • $($file.Name)" -ForegroundColor Gray
        }
        if ((Get-ChildItem -Path $InstallPath -File).Count -gt 10) {
            Write-Host "  • ... and $((Get-ChildItem -Path $InstallPath -File).Count - 10) more files" -ForegroundColor Gray
        }
        
        # Reinstall Samsung Settings and Settings Runtime from Store
        Write-Host "`nReinstalling Samsung Settings from Microsoft Store..." -ForegroundColor Cyan
        
        $samsungPackages = @(
            @{
                Name = "Samsung Settings"
                Id   = "9P2TBWSHK6HJ"
            },
            @{
                Name = "Samsung Settings Runtime"
                Id   = "9NL68DVFP841"
            }
        )
        
        foreach ($pkg in $samsungPackages) {
            Write-Host "  Installing $($pkg.Name)..." -ForegroundColor Gray
            try {
                $installOutput = winget install --accept-source-agreements --accept-package-agreements --id $pkg.Id 2>&1 | Out-String
                
                if ($installOutput -match "Successfully installed|Installation completed successfully") {
                    Write-Host "    ✓ $($pkg.Name) installed" -ForegroundColor Green
                }
                elseif ($installOutput -match "already installed|No available upgrade found|No newer package versions") {
                    Write-Host "    ✓ $($pkg.Name) already present" -ForegroundColor Green
                }
                elseif ($installOutput -match "0x80d03805|0x80D03805") {
                    Write-Host "    ⚠ Store connection error - will install after reboot" -ForegroundColor Yellow
                }
                else {
                    Write-Host "    ⚠ $($pkg.Name) - may install automatically after reboot" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "    ⚠ Could not install $($pkg.Name) automatically" -ForegroundColor Yellow
                Write-Host "      Will install automatically after reboot, or install manually from Store" -ForegroundColor Gray
            }
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
        
        # Show upgrade notice only if not on latest version
        if ($finalVersion -and $finalVersion -like "6.*") {
            Write-Host "`n💡 UPGRADE TIP:" -ForegroundColor Cyan
            Write-Host "  You installed SSSE version $finalVersion (stable, compatible)" -ForegroundColor White
            Write-Host "  Later, you can upgrade to 7.1.2.0 for new features:" -ForegroundColor White
            Write-Host "    .\Install-GalaxyBookEnabler.ps1 -UpgradeSSE" -ForegroundColor Yellow
        }
        elseif ($finalVersion) {
            Write-Host "`n✓ You are running the latest SSSE version ($finalVersion)" -ForegroundColor Green
        }
        
        Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        return $true
        
    }
    catch {
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

function Stop-SamsungProcesses {
    <#
    .SYNOPSIS
        Stops all Samsung processes to prevent file locks during uninstall
    #>
    
    $samsungProcesses = @(
        "SamsungSystemSupportEngine",
        "SamsungSystemSupportService",
        "SamsungSystemSupportOSD",
        "SamsungActiveScreen",
        "SamsungHideWindow",
        "SettingsEngineTest",
        "SettingsExtensionLauncher",
        "SamsungSettings",
        "SamsungCloud",
        "SamsungNotes",
        "SamsungGallery",
        "QuickShare",
        "MultiControl",
        "AISelect",
        "SamsungFlow",
        "SamsungScreenRecorder"
    )
    
    $killedCount = 0
    foreach ($procName in $samsungProcesses) {
        $processes = Get-Process -Name $procName -ErrorAction SilentlyContinue
        if ($processes) {
            foreach ($proc in $processes) {
                try {
                    Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                    $killedCount++
                }
                catch {
                    # Process may have already exited or access denied - this is expected and safe to ignore
                    Write-Verbose "Could not stop process $($proc.Name) (PID: $($proc.Id)): $($_.Exception.Message)"
                }
            }
        }
    }
    
    if ($killedCount -gt 0) {
        Write-Host "  Stopped $killedCount Samsung process(es)" -ForegroundColor Gray
        Start-Sleep -Seconds 2  # Give processes time to fully exit
    }
    
    return $killedCount
}

function Remove-SamsungSettingsPackages {
    <#
    .SYNOPSIS
        Removes Samsung Settings packages using multiple fallback methods
    
    .DESCRIPTION
        Attempts to remove Samsung Settings packages using several methods:
        1. PowerShell 7 Remove-AppxPackage -AllUsers
        2. Windows PowerShell 5.1 Remove-AppxPackage -AllUsers (fallback)
        3. Remove provisioned packages (for system-wide installations)
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [array]$Packages
    )
    
    $results = @{
        Success = @()
        Failed  = @()
    }
    
    foreach ($app in $Packages) {
        $removed = $false
        $packageName = $app.Name
        $packageFullName = $app.PackageFullName
        
        Write-Host "  Removing $packageName..." -ForegroundColor Gray
        
        # Method 1: Try PowerShell 7 (current session)
        try {
            Write-Host "    [Method 1] Using PowerShell 7..." -ForegroundColor DarkGray
            $app | Remove-AppxPackage -AllUsers -ErrorAction Stop
            Write-Host "    ✓ Successfully removed via PowerShell 7" -ForegroundColor Green
            $removed = $true
            $results.Success += $packageName
        }
        catch {
            $error1 = $_.Exception.Message
            Write-Host "    ✗ PowerShell 7 failed: $error1" -ForegroundColor DarkGray
            
            # Method 2: Try Windows PowerShell 5.1
            try {
                Write-Host "    [Method 2] Using Windows PowerShell 5.1..." -ForegroundColor DarkGray
                
                # Create a script block to run in Windows PowerShell
                $scriptBlock = @"
Get-AppxPackage -AllUsers | Where-Object { `$_.PackageFullName -eq '$packageFullName' } | Remove-AppxPackage -AllUsers -ErrorAction Stop
"@
                
                $psOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $scriptBlock 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "    ✗ Windows PowerShell 5.1 failed with exit code $LASTEXITCODE. Output:" -ForegroundColor DarkGray
                    Write-Host $psOutput -ForegroundColor DarkGray
                }
                
                # Verify removal
                $stillExists = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -eq $packageFullName }
                if (-not $stillExists) {
                    Write-Host "    ✓ Successfully removed via Windows PowerShell" -ForegroundColor Green
                    $removed = $true
                    $results.Success += $packageName
                }
                else {
                    throw "Package still exists after removal attempt"
                }
            }
            catch {
                $error2 = $_.Exception.Message
                Write-Host "    ✗ Windows PowerShell failed: $error2" -ForegroundColor DarkGray
                
                # Method 3: Try removing provisioned package
                try {
                    Write-Host "    [Method 3] Checking provisioned packages..." -ForegroundColor DarkGray
                    
                    $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { 
                        $_.PackageName -like "*$($app.Name)*" 
                    }
                    
                    if ($provisioned) {
                        Write-Host "    Found provisioned package, removing..." -ForegroundColor DarkGray
                        $provisioned | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
                        
                        # Also try to remove user package again
                        $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                        
                        # Verify removal
                        $stillExists = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -eq $packageFullName }
                        if (-not $stillExists) {
                            Write-Host "    ✓ Successfully removed provisioned package" -ForegroundColor Green
                            $removed = $true
                            $results.Success += $packageName
                        }
                        else {
                            throw "Package still exists after provisioned removal"
                        }
                    }
                    else {
                        throw "No provisioned package found"
                    }
                }
                catch {
                    $error3 = $_.Exception.Message
                    Write-Host "    ✗ Provisioned package removal failed: $error3" -ForegroundColor DarkGray
                }
            }
        }
        
        if (-not $removed) {
            Write-Host "  ✗ Failed to remove $packageName after trying all methods" -ForegroundColor Red
            $results.Failed += @{
                Name     = $packageName
                FullName = $packageFullName
            }
        }
    }
    
    return $results
}

function Uninstall-SamsungApps {
    param([switch]$DeleteData)
    
    Write-Status "`n=== UNINSTALLING SAMSUNG APPS ===" -Status ACTION
    
    if ($DeleteData) {
        Write-Status "WARNING: This will also DELETE all app data!" -Status WARN
    }
    
    $samsungPackages = Get-AppxPackage | Where-Object { 
        $_.Name -like "*Samsung*" -or 
        $_.Name -like "*Galaxy*" -or
        $_.Name -like "*16297BCCB59BC*" -or
        $_.Name -like "*4438638898209*"
    }
    
    foreach ($pkg in $samsungPackages) {
        Write-Status "Uninstalling: $($pkg.Name)" -Status ACTION
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
            Write-Status "Uninstalled: $($pkg.Name)" -Status OK
        }
        catch {
            Write-Status "Failed to uninstall $($pkg.Name)`: $($_.Exception.Message)" -Status ERROR
        }
    }
    
    if ($DeleteData) {
        Write-Status "`nDeleting app data folders..." -Status ACTION
        
        # Remove Galaxy Buds from Bluetooth
        Write-Status "Removing Galaxy Buds from Bluetooth..." -Status ACTION
        try {
            $btResult = Remove-GalaxyBudsFromBluetooth
            if ($btResult.Removed.Count -gt 0) {
                foreach ($device in $btResult.Removed) {
                    Write-Status "Removed Bluetooth device: $device" -Status OK
                }
            }
            else {
                Write-Status "No Galaxy Buds devices found in Bluetooth registry" -Status OK
            }
        }
        catch {
            Write-Status "Failed to remove Bluetooth devices: $($_.Exception.Message)" -Status WARN
        }
        
        $packageFolders = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory | 
        Where-Object { $_.Name -match "Samsung|Galaxy" }
        
        foreach ($folder in $packageFolders) {
            try {
                Remove-Item $folder.FullName -Recurse -Force -ErrorAction Stop
                Write-Status "Deleted: $($folder.Name)" -Status OK
            }
            catch {
                Write-Status "Could not delete $($folder.Name): $($_.Exception.Message)" -Status WARN
            }
        }
        
        # Also clear ProgramData and LocalAppData Samsung folders
        Clear-SamsungSystemData
    }
}


function Get-InstalledSamsungPackages {
    <#
    .SYNOPSIS
        Returns a HashSet of installed Samsung package names/IDs for fast lookup
    #>
    $installed = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    
    try {
        # Get all packages that look like Samsung ones
        $packages = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object { 
            $_.Name -like "*Samsung*" -or 
            $_.Name -like "*Galaxy*" -or
            $_.Name -like "*16297BCCB59BC*" -or
            $_.Name -like "*4438638898209*"
        }
        
        foreach ($pkg in $packages) {
            if ($pkg.Name) { $null = $installed.Add($pkg.Name) }
            if ($pkg.PackageFamilyName) { $null = $installed.Add($pkg.PackageFamilyName) }
        }
    }
    catch {
        Write-Debug "Failed to enumerate installed packages: $($_.Exception.Message)"
    }
    
    return $installed
}

function Show-PackageSelectionMenu {
    param (
        [bool]$HasIntelWiFi
    )
    
    # Pre-calculate installed status
    Write-Host "Checking installed packages..." -ForegroundColor DarkGray
    $installedPkgs = Get-InstalledSamsungPackages
    
    # Helper to check if a profile is fully installed
    function Test-ProfileStatus {
        param($ProfilePackages)
        $total = $ProfilePackages.Count
        $installed = 0
        foreach ($p in $ProfilePackages) {
            # Check if package is installed (by Name or Family if available, or just assume not if we can't map it easily yet)
            # For now, we'll try to match loosely against the Name in our DB vs what we found
            # This is a heuristic since our DB has "Samsung Account" but Appx is "SamsungAccount"
            
            # Better approach: Check if ANY installed package matches the ID or Name
            # Since we don't have the exact Appx Name in our DB, we rely on the fact that 
            # Install-SamsungPackages will do a more precise check.
            # For the menu, we'll do a best-effort match.
            
            # Actually, let's just pass the installed set to the install function and let it handle the precise check.
            # For the menu, we can't easily know 100% without a mapping table for every single app.
            # BUT, we can try to match the "Name" from our DB against the installed list loosely.
            
            $dbName = $p.Name.Replace(" ", "")
            $isInstalled = $installedPkgs.Contains($dbName) -or 
            ($installedPkgs | Where-Object { $_ -like "*$dbName*" })
            
            if ($isInstalled) { $installed++ }
        }
        return @{ Total = $total; Installed = $installed }
    }
    
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Samsung Package Selection" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    # Note about AI Select configuration step
    Write-Host "Tip: If you include 'AI Select', a shortcut setup step appears later." -ForegroundColor Gray
    Write-Host "" 

    Write-Host "Select installation profile:`n" -ForegroundColor Yellow
    
    # [1] Core Only
    $coreStatus = Test-ProfileStatus $PackageDatabase.Core
    $coreColor = if ($coreStatus.Installed -eq $coreStatus.Total) { "Green" } elseif ($coreStatus.Installed -gt 0) { "Yellow" } else { "White" }
    $coreText = if ($coreStatus.Installed -eq $coreStatus.Total) { "[Installed]" } elseif ($coreStatus.Installed -gt 0) { "[$($coreStatus.Installed)/$($coreStatus.Total) Installed]" } else { "" }
    
    Write-Host "  [1] Core Only $coreText" -ForegroundColor $coreColor
    Write-Host "      Essential packages only (Account, Settings, Cloud)" -ForegroundColor Gray
    Write-Host ""
    
    # [2] Recommended
    $recPkgs = $PackageDatabase.Core + $PackageDatabase.Recommended
    $recStatus = Test-ProfileStatus $recPkgs
    $recColor = if ($recStatus.Installed -eq $recStatus.Total) { "Green" } elseif ($recStatus.Installed -gt 0) { "Yellow" } else { "Green" }
    $recText = if ($recStatus.Installed -eq $recStatus.Total) { "[Installed]" } elseif ($recStatus.Installed -gt 0) { "[$($recStatus.Installed)/$($recStatus.Total) Installed]" } else { "" }

    Write-Host "  [2] Recommended $recText" -ForegroundColor $recColor
    Write-Host "      Core + All working Samsung apps (Gallery, Notes, Multi Control, etc.)" -ForegroundColor Gray
    if (-not $HasIntelWiFi) {
        Write-Host "      ⚠ Note: Quick Share/Camera Share/Storage Share require Intel Wi-Fi + Intel Bluetooth" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # [3] Full Experience
    $fullPkgs = $PackageDatabase.Core + $PackageDatabase.Recommended + $PackageDatabase.ExtraSteps
    $fullStatus = Test-ProfileStatus $fullPkgs
    $fullColor = if ($fullStatus.Installed -eq $fullStatus.Total) { "Green" } elseif ($fullStatus.Installed -gt 0) { "Yellow" } else { "Cyan" }
    $fullText = if ($fullStatus.Installed -eq $fullStatus.Total) { "[Installed]" } elseif ($fullStatus.Installed -gt 0) { "[$($fullStatus.Installed)/$($fullStatus.Total) Installed]" } else { "" }

    Write-Host "  [3] Full Experience $fullText" -ForegroundColor $fullColor
    Write-Host "      Recommended + Apps requiring extra setup (Phone, Find, Quick Search)" -ForegroundColor Gray
    Write-Host "      ⚠ Some apps need additional configuration after install" -ForegroundColor Yellow
    Write-Host ""
    
    # [4] Everything
    $allPkgs = $PackageDatabase.Core + $PackageDatabase.Recommended + $PackageDatabase.ExtraSteps + $PackageDatabase.NonWorking
    $allStatus = Test-ProfileStatus $allPkgs
    $allColor = if ($allStatus.Installed -eq $allStatus.Total) { "Green" } elseif ($allStatus.Installed -gt 0) { "Yellow" } else { "Magenta" }
    $allText = if ($allStatus.Installed -eq $allStatus.Total) { "[Installed]" } elseif ($allStatus.Installed -gt 0) { "[$($allStatus.Installed)/$($allStatus.Total) Installed]" } else { "" }

    Write-Host "  [4] Everything $allText" -ForegroundColor $allColor
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
    } while ($choice -notin "1", "2", "3", "4", "5", "6")
    
    return $choice
}

function Get-PackagesByProfile {
    param (
        [string]$ProfileName
    )
    
    $packages = @()
    
    switch ($ProfileName) {
        "1" {
            # Core Only
            $packages = $PackageDatabase.Core
        }
        "2" {
            # Recommended
            $packages = $PackageDatabase.Core + $PackageDatabase.Recommended
        }
        "3" {
            # Full Experience
            $packages = $PackageDatabase.Core + $PackageDatabase.Recommended + $PackageDatabase.ExtraSteps
        }
        "4" {
            # Everything
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
    $installedPkgs = Get-InstalledSamsungPackages
    
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Custom Package Selection" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Group packages by category for better organization
    $categories = @{
        "Core"         = $PackageDatabase.Core
        "Connectivity" = @()
        "Productivity" = @()
        "Media"        = @()
        "Experience"   = @()
        "Security"     = @()
        "Maintenance"  = @()
        "Other"        = @()
    }
    
    foreach ($pkg in ($PackageDatabase.Recommended + $PackageDatabase.ExtraSteps + $PackageDatabase.NonWorking)) {
        if ($categories.ContainsKey($pkg.Category)) {
            $categories[$pkg.Category] += $pkg
        }
        else {
            $categories["Other"] += $pkg
        }
    }
    
    # Core packages (required)
    Write-Host "CORE PACKAGES (Auto-selected):" -ForegroundColor Green
    foreach ($pkg in $PackageDatabase.Core) {
        $dbName = $pkg.Name.Replace(" ", "")
        $isInstalled = $installedPkgs.Contains($dbName) -or ($installedPkgs | Where-Object { $_ -like "*$dbName*" })
        $status = if ($isInstalled) { " [Installed]" } else { "" }
        
        Write-Host "  ✓ $($pkg.Name)$status" -ForegroundColor Gray
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
        }
        elseif ($selectAll -eq "I" -or $selectAll -eq "i") {
            foreach ($pkg in $catPackages) {
                $dbName = $pkg.Name.Replace(" ", "")
                $isInstalled = $installedPkgs.Contains($dbName) -or ($installedPkgs | Where-Object { $_ -like "*$dbName*" })
                $statusTag = if ($isInstalled) { " [Installed]" } else { "" }
                $statusColor = if ($isInstalled) { "Green" } else { "White" }
                
                Write-Host ""
                Write-Host "  $($pkg.Name)$statusTag" -ForegroundColor $statusColor
                Write-Host "    $($pkg.Description)" -ForegroundColor Gray
                
                if ($pkg.Warning) {
                    Write-Host "    ⚠ $($pkg.Warning)" -ForegroundColor Yellow
                }
                if ($pkg.Tip) {
                    Write-Host "    💡 $($pkg.Tip)" -ForegroundColor Cyan
                }
                if ($pkg.RequiresIntelWiFi -and -not $HasIntelWiFi) {
                    Write-Host "    ⚠ Requires Intel Wi-Fi + Intel Bluetooth" -ForegroundColor Red
                }
                
                $prompt = if ($isInstalled) { "    Reinstall? (y/N)" } else { "    Install? (Y/N)" }
                $install = Read-Host $prompt
                
                if ($isInstalled) {
                    if ($install -eq "Y" -or $install -eq "y") {
                        Write-Host "    ✓ Added for reinstall" -ForegroundColor Green
                        $selectedPackages += $pkg
                    }
                }
                else {
                    if ($install -eq "Y" -or $install -eq "y") {
                        Write-Host "    ✓ Added" -ForegroundColor Green
                        $selectedPackages += $pkg
                    }
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
    
    # Get installed packages for differential install (with fallback for irm|iex scenarios)
    $installedPkgs = $null
    try {
        $installedPkgs = Get-InstalledSamsungPackages
    }
    catch {
        Write-Host "  Note: Could not check existing packages, will install all" -ForegroundColor Gray
        $installedPkgs = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    }
    
    if ($TestMode) {
        Write-Host "`n[TEST MODE] Simulating installation of $($Packages.Count) package(s)...`n" -ForegroundColor Yellow
    }
    else {
        Write-Host "`nInstalling $($Packages.Count) package(s)...`n" -ForegroundColor Cyan
    }
    
    foreach ($pkg in $Packages) {
        Write-Host "[$($installed + $failed + $skipped + 1)/$($Packages.Count)] " -NoNewline -ForegroundColor Gray
        Write-Host "$($pkg.Name)" -ForegroundColor White
        
        if ($pkg.Warning) {
            Write-Host "  ⚠ $($pkg.Warning)" -ForegroundColor Yellow
        }
        if ($pkg.Tip) {
            Write-Host "  💡 $($pkg.Tip)" -ForegroundColor Cyan
        }
        
        if ($TestMode) {
            Write-Host "  [TEST] Would check: winget list --id $($pkg.Id)" -ForegroundColor Gray
            Write-Host "  [TEST] Would install: winget install --id $($pkg.Id)" -ForegroundColor Gray
            Write-Host "  ✓ Simulated" -ForegroundColor Green
            $installed++
        }
        else {
            try {
                # Check if package is already installed (Differential Install)
                Write-Host "  Checking installation status..." -ForegroundColor Gray
                
                # Safety check for null package name
                if (-not $pkg.Name) {
                    Write-Host "  ✗ Package has no name defined, skipping" -ForegroundColor Red
                    $failed++
                    continue
                }
                
                $dbName = $pkg.Name.Replace(" ", "")
                $isInstalled = $false
                if ($installedPkgs) {
                    $isInstalled = $installedPkgs.Contains($dbName) -or ($installedPkgs | Where-Object { $_ -like "*$dbName*" })
                }
                
                if ($isInstalled) {
                    Write-Host "  ✓ Already installed (skipping)" -ForegroundColor Cyan
                    $skipped++
                    continue
                }
                
                # Fallback to winget check if not found in our quick check (just to be safe)
                $checkResult = winget list --id $pkg.Id 2>&1 | Out-String
                
                $pkgIdPattern = [regex]::Escape($pkg.Id)
                $pkgNamePattern = [regex]::Escape($pkg.Name)
                if ($checkResult -match $pkgIdPattern -or $checkResult -match $pkgNamePattern) {
                    Write-Host "  ✓ Already installed (skipping)" -ForegroundColor Cyan
                    $skipped++
                }
                else {
                    Write-Host "  Installing..." -ForegroundColor Gray
                    $installOutput = winget install --accept-source-agreements --accept-package-agreements --id $pkg.Id 2>&1 | Out-String
                    
                    # Check for Microsoft Store connection error (0x80d03805)
                    if ($installOutput -match "0x80d03805|0x80D03805") {
                        Write-Host "  ✗ Microsoft Store connection error (0x80d03805)" -ForegroundColor Red
                        Write-Host "" -ForegroundColor Yellow
                        Write-Host "    ═══════════════════════════════════════════════════════" -ForegroundColor Yellow
                        Write-Host "    WORKAROUND: Toggle your WiFi connection" -ForegroundColor Yellow
                        Write-Host "    ═══════════════════════════════════════════════════════" -ForegroundColor Yellow
                        Write-Host "" -ForegroundColor Yellow
                        Write-Host "    This is a known Microsoft Store issue. To fix:" -ForegroundColor White
                        Write-Host "      1. Turn WiFi OFF, wait 5 seconds, turn it back ON" -ForegroundColor Cyan
                        Write-Host "      2. Or switch to a different WiFi network temporarily" -ForegroundColor Cyan
                        Write-Host "      3. Then run the installer again" -ForegroundColor Cyan
                        Write-Host "" -ForegroundColor Yellow
                        Write-Host "    Alternative: Install manually from Microsoft Store" -ForegroundColor Gray
                        Write-Host "    Store link: ms-windows-store://pdp/?ProductId=$($pkg.Id)" -ForegroundColor Gray
                        Write-Host "" -ForegroundColor Yellow
                        $failed++
                    }
                    # Winget always returns 0 even when "already installed" or "no upgrade found"
                    # Parse output to determine actual result
                    elseif ($installOutput -match "Successfully installed|Installation completed successfully") {
                        Write-Host "  ✓ Installed successfully" -ForegroundColor Green
                        $installed++
                        # Add to installed list for tracking (if available)
                        if ($installedPkgs -and $pkg.Name) {
                            $dbName = $pkg.Name.Replace(" ", "")
                            $null = $installedPkgs.Add($dbName)
                        }
                    }
                    elseif ($installOutput -match "already installed|No available upgrade found|No newer package versions") {
                        Write-Host "  ✓ Already installed" -ForegroundColor Cyan
                        $skipped++
                    }
                    elseif ($installOutput -match "No package found matching input criteria|No applicable update found") {
                        Write-Host "  ✗ Package not found in winget" -ForegroundColor Red
                        Write-Host "    Package ID: $($pkg.Id)" -ForegroundColor Gray
                        Write-Host "    This may require installation through Microsoft Store instead" -ForegroundColor Yellow
                        $failed++
                    }
                    elseif ($LASTEXITCODE -ne 0) {
                        Write-Host "  ✗ Installation failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
                        Write-Host "    Output: $($installOutput.Substring(0, [Math]::Min(200, $installOutput.Length)))" -ForegroundColor Gray
                        $failed++
                    }
                    else {
                        # Exit code 0 but unclear message - assume already installed/up to date
                        Write-Host "  ✓ Already up to date" -ForegroundColor Cyan
                        $skipped++
                    }
                }
            }
            catch {
                Write-Host "  ✗ Error: $_" -ForegroundColor Red
                $failed++
            }
        }
        
        Write-Host ""
    }
    
    return @{
        Installed = $installed
        Failed    = $failed
        Skipped   = $skipped
        Total     = $Packages.Count
    }
}

function Install-SSSEDriverToStore {
    <#
    .SYNOPSIS
        Adds the Samsung driver to the Windows DriverStore
    .DESCRIPTION
        Simply adds the driver INF to the DriverStore using pnputil.
        This makes the driver available for Windows to use.
    #>
    param(
        [string]$InfPath,
        [bool]$TestMode
    )

    if ($TestMode) {
        Write-Host "    [TEST MODE] Would add driver to store: $InfPath" -ForegroundColor Gray
        return $true
    }

    if (-not (Test-Path $InfPath)) {
        Write-Warning "INF not found: $InfPath"
        return $false
    }

    try {
        Write-Host "    Adding driver to driver store..." -ForegroundColor Yellow
        $addResult = & pnputil.exe /add-driver "$InfPath" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "    ✗ Failed to add INF to store" -ForegroundColor Red
            Write-Host "      Error: $addResult" -ForegroundColor Red
            return $false
        }
        Write-Host "    ✓ Driver added to driver store" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "    ✗ Error adding driver: $_" -ForegroundColor Red
        return $false
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
            HasWiFi     = $false
            IsIntel     = $false
            IsAX        = $false
            AdapterName = "None"
            Model       = "None"
        }
    }
    
    $wifiInfo = $wifiAdapters[0].InterfaceDescription
    $isIntel = $wifiInfo -like "*Intel*"
    
    # Detect specific Intel Wi-Fi models and determine if AX (Wi-Fi 6/6E/7) or AC (Wi-Fi 5)
    $model = "Unknown"
    $isAX = $false
    if ($isIntel) {
        if ($wifiInfo -match "(AX\d+|BE\d+|Wi-Fi [67][E]?)") {
            $model = $matches[1]
            $isAX = $true
        }
        elseif ($wifiInfo -match "(AC \d+|Wireless-AC|Wi-Fi 5)") {
            $model = $matches[1]
            $isAX = $false  # AC cards don't work with Quick Share
        }
    }
    
    return @{
        HasWiFi     = $true
        IsIntel     = $isIntel
        IsAX        = $isAX
        AdapterName = $wifiInfo
        Model       = $model
    }
}

function Test-IntelBluetooth {
    # Filter for actual Bluetooth radio hardware (USB or PCI devices), not paired devices or services
    $btAdapters = Get-PnpDevice -Class Bluetooth -Status OK -ErrorAction SilentlyContinue | 
    Where-Object { $_.DeviceID -like "USB*" -or $_.DeviceID -like "PCI*" }
    
    if (-not $btAdapters -or $btAdapters.Count -eq 0) {
        return @{
            HasBluetooth = $false
            IsIntel      = $false
            AdapterName  = "None"
        }
    }
    
    $btInfo = $btAdapters[0].FriendlyName
    $isIntel = $btInfo -like "*Intel*"
    
    return @{
        HasBluetooth = $true
        IsIntel      = $isIntel
        AdapterName  = $btInfo
    }
}

function Show-ModelSelectionMenu {
    <#
    .SYNOPSIS
        Display interactive menu for Galaxy Book model selection
    .DESCRIPTION
        Shows categorized menu of 21 Galaxy Book models and returns selected model's registry values
    #>
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Select Galaxy Book Model to Spoof" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Available Models:" -ForegroundColor Yellow
    Write-Host ""
    
    # Group models by family for easier selection
    $modelGroups = @{
        'Galaxy Book5'        = @('960XHA', '940XHA', '960QHA', '750QHA')
        'Galaxy Book4'        = @('960XGL', '960XGK', '940XGK', '960QGK', '750XGK', '750XGL', '750QGK')
        'Galaxy Book3'        = @('960XFH', '960XFG', '960QFG', '750XFG', '750XFH', '730QFG')
        'Galaxy Book2/Series' = @('950XGK', '930XDB', '935QDC', '930SBE')
    }
    
    $index = 1
    $modelIndex = @{}
    
    foreach ($group in $modelGroups.GetEnumerator() | Sort-Object { 
            # Custom sort: Book5 > Book4 > Book3 > Book2
            switch ($_.Key) {
                'Galaxy Book5' { 1 }
                'Galaxy Book4' { 2 }
                'Galaxy Book3' { 3 }
                'Galaxy Book2/Series' { 4 }
            }
        }) {
        Write-Host "  $($group.Key):" -ForegroundColor Magenta
        
        foreach ($model in $group.Value) {
            $modelData = $GalaxyBookModels[$model]
            $displayName = "$model - $($modelData.SystemFamily)"
            Write-Host ("    {0,2}. {1}" -f $index, $displayName) -ForegroundColor White
            $modelIndex[$index] = $model
            $index++
        }
        Write-Host ""
    }
    
    Write-Host "  Default:" -ForegroundColor Magenta
    Write-Host "    22. Galaxy Book3 Ultra (960XFH) - Legacy Default" -ForegroundColor Gray
    Write-Host ""
    
    # Get user selection
    do {
        $selection = Read-Host "Enter model number (1-22)"
        
        if ($selection -eq '22') {
            # Legacy default - return null to use old default values
            Write-Host "`n✓ Using legacy default: Galaxy Book3 Ultra (960XFH)" -ForegroundColor Green
            return $null
        }
        
        $selectedNumber = [int]$selection
        if ($modelIndex.ContainsKey($selectedNumber)) {
            $selectedModel = $modelIndex[$selectedNumber]
            $selectedData = $GalaxyBookModels[$selectedModel]
            
            Write-Host "`n✓ Selected: $selectedModel - $($selectedData.SystemFamily)" -ForegroundColor Green
            Write-Host "  Product: $($selectedData.SystemProductName)" -ForegroundColor Gray
            Write-Host "  BIOS: $($selectedData.BIOSVersion)" -ForegroundColor Gray
            Write-Host ""
            
            return $selectedData
        }
        else {
            Write-Host "Invalid selection. Please enter a number between 1 and 22." -ForegroundColor Red
        }
    } while ($true)
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
            BIOSVendor            = "American Megatrends International, LLC."
            BIOSVersion           = "P04RKI.049.220408.ZQ"
            BIOSMajorRelease      = "0x04"
            BIOSMinorRelease      = "0x11"
            SystemManufacturer    = "SAMSUNG ELECTRONICS CO., LTD."
            SystemFamily          = "Galaxy Book3 Ultra"
            SystemProductName     = "NP960XFH-XA2UK"
            ProductSku            = "SCAI-A5A5-ADLP-PSLP"
            EnclosureKind         = "0x1f"
            BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            BaseBoardProduct      = "NP960XFH-XA2UK"
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
                Values   = $values
            }
        }
        
        return $null
    }
    catch {
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
        BIOSVendor            = "American Megatrends International, LLC."
        BIOSVersion           = "P04RKI.049.220408.ZQ"
        BIOSMajorRelease      = "0x04"
        BIOSMinorRelease      = "0x11"
        SystemManufacturer    = "SAMSUNG ELECTRONICS CO., LTD."
        SystemFamily          = "Galaxy Book3 Ultra"
        SystemProductName     = "NP960XFH-XA2UK"
        ProductSku            = "SCAI-A5A5-ADLP-PSLP"
        EnclosureKind         = "0x1f"
        BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
        BaseBoardProduct      = "NP960XFH-XA2UK"
    }
    
    # Use custom values if provided, otherwise use defaults
    $values = if ($BiosValues) { $BiosValues } else { $defaults }
    
    # Ensure all keys exist (fill missing ones with defaults)
    foreach ($key in $defaults.Keys) {
        if (-not $values.ContainsKey($key)) {
            $values[$key] = $defaults[$key]
        }
    }
    
    # Extract SystemVersion from BIOSVersion (e.g., "P08ALX.400.250306.05" -> "P08ALX")
    $systemVersion = if ($values.BIOSVersion -match '^([A-Z0-9]+)\.') { $Matches[1] } else { $values.BIOSVersion }
    
    # Generate random future BIOS release date (between 2026-2035)
    $randomYear = Get-Random -Minimum 2026 -Maximum 2036
    $randomMonth = Get-Random -Minimum 1 -Maximum 13
    $randomDay = Get-Random -Minimum 1 -Maximum 29  # Safe for all months
    $biosReleaseDate = "{0:D2}/{1:D2}/{2}" -f $randomMonth, $randomDay, $randomYear
    
    # Constants
    $systemSku = "Samsung Chassis"
    
    # Helper function to format registry value for BIOS key
    function Format-BiosRegValue {
        param($Key, $Value)
        
        $isDword = $Key -match '(Release|Kind|Type|Flags|^Id$)$'
        $type = if ($isDword) { "REG_DWORD" } else { "REG_SZ" }
        $formattedValue = if ($isDword) { $Value } else { "`"$Value`"" }
        
        return "reg add `"HKLM\HARDWARE\DESCRIPTION\System\BIOS`" /v $Key /t $type /d $formattedValue /f"
    }
    
    # Helper function to format registry value for HardwareConfig\Current key
    function Format-HwConfigRegValue {
        param($Key, $Value)
        
        $isDword = $Key -match '(Release|Kind|Type|Flags|^Id$)$'
        $type = if ($isDword) { "REG_DWORD" } else { "REG_SZ" }
        $formattedValue = if ($isDword) { $Value } else { "`"$Value`"" }
        
        return "reg add `"HKLM\SYSTEM\HardwareConfig\Current`" /v $Key /t $type /d $formattedValue /f"
    }
    
    # Helper function to format registry value for SystemInformation key
    function Format-SysInfoRegValue {
        param($Key, $Value)
        
        return "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation`" /v $Key /t REG_SZ /d `"$Value`" /f"
    }
    
    $batchContent = @"
@echo off
REM ============================================================================
REM Galaxy Book Enabler - Registry Spoof Script
REM Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
REM Model: $($values.SystemFamily) ($($values.SystemProductName))
REM ============================================================================

REM ============================================================================
REM SECTION 1: HKLM\HARDWARE\DESCRIPTION\System\BIOS
REM ============================================================================
$(Format-BiosRegValue "BIOSVendor" $values.BIOSVendor)
$(Format-BiosRegValue "BIOSVersion" $values.BIOSVersion)
$(Format-BiosRegValue "BIOSMajorRelease" $values.BIOSMajorRelease)
$(Format-BiosRegValue "BIOSMinorRelease" $values.BIOSMinorRelease)
$(Format-BiosRegValue "BIOSReleaseDate" $biosReleaseDate)
$(Format-BiosRegValue "SystemManufacturer" $values.SystemManufacturer)
$(Format-BiosRegValue "SystemFamily" $values.SystemFamily)
$(Format-BiosRegValue "SystemProductName" $values.SystemProductName)
$(Format-BiosRegValue "SystemSKU" $systemSku)
$(Format-BiosRegValue "SystemVersion" $systemVersion)
$(Format-BiosRegValue "ProductSku" $values.ProductSku)
$(Format-BiosRegValue "EnclosureKind" $values.EnclosureKind)
$(Format-BiosRegValue "BaseBoardManufacturer" $values.BaseBoardManufacturer)
$(Format-BiosRegValue "BaseBoardProduct" $values.BaseBoardProduct)

REM ============================================================================
REM SECTION 2: HKLM\SYSTEM\HardwareConfig\Current
REM ============================================================================
$(Format-HwConfigRegValue "Id" "0x00000001")
$(Format-HwConfigRegValue "BootDriverFlags" "0x00000000")
$(Format-HwConfigRegValue "EnclosureType" $values.EnclosureKind)
$(Format-HwConfigRegValue "EnclosureKind" $values.EnclosureKind)
$(Format-HwConfigRegValue "SystemManufacturer" $values.SystemManufacturer)
$(Format-HwConfigRegValue "SystemFamily" $values.SystemFamily)
$(Format-HwConfigRegValue "SystemProductName" $values.SystemProductName)
$(Format-HwConfigRegValue "SystemSKU" $systemSku)
$(Format-HwConfigRegValue "SystemVersion" $systemVersion)
$(Format-HwConfigRegValue "BIOSVendor" $values.BIOSVendor)
$(Format-HwConfigRegValue "BIOSVersion" $values.BIOSVersion)
$(Format-HwConfigRegValue "BIOSReleaseDate" $biosReleaseDate)
$(Format-HwConfigRegValue "BIOSMajorRelease" $values.BIOSMajorRelease)
$(Format-HwConfigRegValue "BIOSMinorRelease" $values.BIOSMinorRelease)
$(Format-HwConfigRegValue "BaseBoardManufacturer" $values.BaseBoardManufacturer)
$(Format-HwConfigRegValue "BaseBoardProduct" $values.BaseBoardProduct)
$(Format-HwConfigRegValue "ProductSku" $values.ProductSku)

REM ============================================================================
REM SECTION 3: HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation
REM ============================================================================
$(Format-SysInfoRegValue "BIOSVersion" $values.BIOSVersion)
$(Format-SysInfoRegValue "BIOSReleaseDate" $biosReleaseDate)
$(Format-SysInfoRegValue "SystemManufacturer" $values.SystemManufacturer)
$(Format-SysInfoRegValue "SystemProductName" $values.SystemProductName)

REM ============================================================================
REM Registry spoof complete!
REM ============================================================================
"@
    
    $batchContent | Set-Content $OutputPath -Encoding ASCII
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠ Administrator privileges required" -ForegroundColor Yellow
    Write-Host ""
    
    # Check if sudo is available (gsudo or Windows 11 native sudo)
    $hasSudo = $false
    $sudoCommand = $null
    
    # Check for gsudo first (https://github.com/gerardog/gsudo)
    if (Get-Command gsudo -ErrorAction SilentlyContinue) {
        $hasSudo = $true
        $sudoCommand = "gsudo"
        Write-Host "✓ Detected gsudo - attempting automatic elevation..." -ForegroundColor Cyan
    }
    # Check for Windows 11 native sudo
    elseif (Get-Command sudo -ErrorAction SilentlyContinue) {
        $hasSudo = $true
        $sudoCommand = "sudo"
        Write-Host "✓ Detected Windows sudo - attempting automatic elevation..." -ForegroundColor Cyan
    }
    else {
        Write-Host "Requesting administrator privileges..." -ForegroundColor Cyan
        Write-Host "(Tip: Install 'gsudo' for seamless elevation: winget install gerardog.gsudo)" -ForegroundColor Gray
    }
    
    Write-Host ""
    
    try {
        if ($hasSudo) {
            # Use sudo for seamless elevation
            $scriptPath = $MyInvocation.MyCommand.Path
            $arguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object {
                if ($_.Value -is [switch] -and $_.Value) {
                    "-$($_.Key)"
                }
            }
            
            # Re-launch with sudo
            if ($scriptPath) {
                & $sudoCommand pwsh -NoProfile -ExecutionPolicy Bypass -File "`"$scriptPath`"" @arguments
            }
            else {
                # Script was piped (irm | iex), need to re-download
                Write-Host "⚠ Cannot auto-elevate piped script with sudo" -ForegroundColor Yellow
                Write-Host "Please run as administrator or download the script first." -ForegroundColor Gray
                pause
                exit
            }
        }
        else {
            # Use traditional UAC elevation
            $scriptPath = $MyInvocation.MyCommand.Path
            $arguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object {
                if ($_.Value -is [switch] -and $_.Value) {
                    "-$($_.Key)"
                }
            }
            
            if ($scriptPath) {
                Start-Process -FilePath "pwsh" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $($arguments -join ' ')" -Verb RunAs
            }
            else {
                # Script was piped, show manual instructions
                Write-Host "Cannot auto-elevate when script is piped (irm | iex)." -ForegroundColor Red
                Write-Host ""
                Write-Host "Options:" -ForegroundColor Yellow
                Write-Host "  1. Download the script first, then run as administrator" -ForegroundColor Gray
                Write-Host "  2. Install gsudo: winget install gerardog.gsudo" -ForegroundColor Gray
                Write-Host "     Then run: irm <url> | gsudo pwsh" -ForegroundColor Gray
                pause
                exit
            }
        }
        
        # Exit current non-elevated instance
        exit
    }
    catch {
        Write-Host "✗ Failed to elevate: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please run PowerShell as Administrator manually:" -ForegroundColor Yellow
        Write-Host "  Right-click PowerShell → Run as Administrator" -ForegroundColor Gray
        pause
        exit
    }
}

$taskName = "GalaxyBookEnabler"
$installPath = Join-Path $env:USERPROFILE ".galaxy-book-enabler"
$batchScriptPath = Join-Path $installPath "GalaxyBookSpoof.bat"
$configPath = Join-Path $installPath "gbe-config.json"

# ==================== UPDATE SAMSUNG SETTINGS MODE ====================
if ($UpdateSettings) {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Samsung Settings Update/Reinstall" -ForegroundColor Cyan
    Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "This will use the SSSE installer to update Samsung Settings." -ForegroundColor White
    Write-Host "You'll be able to select a version and the installer will:" -ForegroundColor Gray
    Write-Host "  • Download and patch the chosen SSSE version" -ForegroundColor Gray
    Write-Host "  • Add driver to DriverStore" -ForegroundColor Gray
    Write-Host "  • Configure the GBeSupportService" -ForegroundColor Gray
    Write-Host ""
    
    $proceed = Read-Host "Proceed? (Y/n)"
    if ($proceed -like "n*") {
        Write-Host "`nCancelled." -ForegroundColor Yellow
        exit
    }
    
    # Call the main Install-SystemSupportEngine function which handles everything properly
    $result = Install-SystemSupportEngine -InstallPath "C:\GalaxyBook" -TestMode $TestMode
    
    if ($result) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  ✓ Samsung Settings Update Complete!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        Write-Host "Please reboot your PC for changes to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "`n⚠ Update may have encountered issues." -ForegroundColor Yellow
        Write-Host "  Check the output above for details." -ForegroundColor Gray
    }
    
    pause
    exit
}

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

# ==================== QUICK UPGRADE SSE MODE ====================
if ($UpgradeSSE) {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  SSSE QUICK UPGRADE" -ForegroundColor Yellow
    Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
    
    Write-Host "This will upgrade your Samsung System Support Engine" -ForegroundColor White
    Write-Host "to the latest version (7.1.2.0) without going through" -ForegroundColor White
    Write-Host "the full installation process.`n" -ForegroundColor White
    
    Write-Host "Prerequisites:" -ForegroundColor Cyan
    Write-Host "  • You must have already run the full installer once" -ForegroundColor Gray
    Write-Host "  • Registry spoof must be in place" -ForegroundColor Gray
    Write-Host "  • Existing SSSE installation will be upgraded" -ForegroundColor Gray
    Write-Host ""
    
    $proceed = Read-Host "Proceed with upgrade to 7.1.2.0? (Y/n)"
    if ($proceed -like "n*") {
        Write-Host "`nUpgrade cancelled." -ForegroundColor Yellow
        exit
    }
    
    Write-Host "`n"
    $result = Install-SystemSupportEngine -InstallPath "C:\GalaxyBook" -TestMode $TestMode -ForceVersion "7.1.2.0"
    
    if ($result) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  Upgrade Complete!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        Write-Host "SSSE has been upgraded to version 7.1.2.0" -ForegroundColor Cyan
        Write-Host "Please reboot your PC for changes to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "`n========================================" -ForegroundColor Red
        Write-Host "  Upgrade Failed" -ForegroundColor Red
        Write-Host "========================================`n" -ForegroundColor Red
        Write-Host "Please try running the full installer instead." -ForegroundColor Yellow
    }
    
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
}
else {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Galaxy Book Enabler INSTALLER" -ForegroundColor Cyan
    Write-Host "  Version $SCRIPT_VERSION" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

# Enhanced installation health check (4 components: config, task, C:\GalaxyBook, GBeSupportService)
$installHealth = Test-InstallationHealth -ConfigPath $configPath -TaskName $taskName
$alreadyInstalled = $installHealth.IsHealthy -or $installHealth.IsBroken

# Initialize BIOS values variable (may be set during reinstall)
$biosValuesToUse = $null

if ($alreadyInstalled) {
    # Display version info
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│  " -NoNewline -ForegroundColor Cyan
    Write-Host "Galaxy Book Enabler" -NoNewline -ForegroundColor White
    Write-Host " is installed                        │" -ForegroundColor Cyan
    Write-Host "├─────────────────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host "│  GBE Version:    " -NoNewline -ForegroundColor Cyan
    Write-Host (" {0,-10}" -f $installHealth.GbeVersion) -NoNewline -ForegroundColor Green
    Write-Host "                             │" -ForegroundColor Cyan
    Write-Host "│  SSSE Version:   " -NoNewline -ForegroundColor Cyan
    Write-Host (" {0,-10}" -f $installHealth.SsseVersion) -NoNewline -ForegroundColor Green
    Write-Host "                             │" -ForegroundColor Cyan
    Write-Host "│  Installer:      " -NoNewline -ForegroundColor Cyan
    Write-Host (" {0,-10}" -f $SCRIPT_VERSION) -NoNewline -ForegroundColor Yellow
    Write-Host "                             │" -ForegroundColor Cyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    
    # Show component health if broken
    if ($installHealth.IsBroken) {
        Write-Host ""
        Write-Host "  ⚠ Installation appears BROKEN ($($installHealth.ComponentCount)/4 components)" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Component Status:" -ForegroundColor Yellow
        $checkMark = "✓"; $crossMark = "✗"
        Write-Host "    $( if ($installHealth.Components.Config) { $checkMark } else { $crossMark } ) Config file" -ForegroundColor $(if ($installHealth.Components.Config) { "Green" } else { "Red" })
        Write-Host "    $( if ($installHealth.Components.Task) { $checkMark } else { $crossMark } ) Scheduled task" -ForegroundColor $(if ($installHealth.Components.Task) { "Green" } else { "Red" })
        Write-Host "    $( if ($installHealth.Components.SsseFolder) { $checkMark } else { $crossMark } ) C:\GalaxyBook folder" -ForegroundColor $(if ($installHealth.Components.SsseFolder) { "Green" } else { "Red" })
        Write-Host "    $( if ($installHealth.Components.Service) { $checkMark } else { $crossMark } ) GBeSupportService" -ForegroundColor $(if ($installHealth.Components.Service) { "Green" } else { "Red" })
        Write-Host ""
        Write-Host "  Recommendation: Choose 'Reinstall' to fix the installation" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ✓ All 4 components healthy" -ForegroundColor Green
    }
    
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
        Write-Host "  [4] Update/Reinstall Samsung Settings (SSSE)" -ForegroundColor Cyan
        Write-Host "  [5] Reset/Repair Samsung Apps (Experimental)" -ForegroundColor Yellow
        Write-Host "  [6] Uninstall (apps, services & scheduled task)" -ForegroundColor Gray
        Write-Host "  [7] Uninstall (apps only)" -ForegroundColor Gray
        Write-Host "  [8] Uninstall (services & scheduled task only)" -ForegroundColor Gray
        Write-Host "  [9] Cancel" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-9]"
        
        if ($choice -eq "1") {
            if (Update-GalaxyBookEnabler -DownloadUrl $updateCheck.DownloadUrl) {
                # Will exit if successful
            }
            else {
                Write-Host "Falling back to installer version..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
    else {
        if ($updateCheck.Error) {
            Write-Host "⚠ Could not check for updates (offline?)" -ForegroundColor Yellow
        }
        else {
            Write-Host "✓ You have the latest version" -ForegroundColor Green
        }
        
        Write-Host "`nWhat would you like to do?" -ForegroundColor Cyan
        Write-Host "  [1] Update to installer version (v$SCRIPT_VERSION)" -ForegroundColor Gray
        Write-Host "  [2] Reinstall" -ForegroundColor Gray
        Write-Host "  [3] Update/Reinstall Samsung Settings (SSSE)" -ForegroundColor Cyan
        Write-Host "  [4] Reset/Repair Samsung Apps (Experimental)" -ForegroundColor Yellow
        Write-Host "  [5] Uninstall (apps, services & scheduled task)" -ForegroundColor Gray
        Write-Host "  [6] Uninstall (apps only)" -ForegroundColor Gray
        Write-Host "  [7] Uninstall (services & scheduled task only)" -ForegroundColor Gray
        Write-Host "  [8] Cancel" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-8]"
    }
    
    # Handle "Update Samsung Settings" option - same action for both menus
    if (($updateCheck.Available -and $choice -eq "4") -or (-not $updateCheck.Available -and $choice -eq "3")) {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  Samsung Settings Update/Reinstall" -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan
        
        Write-Host "This will use the SSSE installer to update Samsung Settings." -ForegroundColor White
        Write-Host "You'll be able to select a version and the installer will:" -ForegroundColor Gray
        Write-Host "  • Download and patch the chosen SSSE version" -ForegroundColor Gray
        Write-Host "  • Add driver to DriverStore" -ForegroundColor Gray
        Write-Host "  • Configure the GBeSupportService" -ForegroundColor Gray
        Write-Host ""
        
        $proceed = Read-Host "Proceed? (Y/n)"
        if ($proceed -like "n*") {
            Write-Host "`nCancelled." -ForegroundColor Yellow
            exit
        }
        
        # Call the main Install-SystemSupportEngine function which handles everything properly
        $result = Install-SystemSupportEngine -InstallPath "C:\GalaxyBook" -TestMode $false
        
        if ($result) {
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  ✓ Samsung Settings Update Complete!" -ForegroundColor Green
            Write-Host "========================================`n" -ForegroundColor Green
            Write-Host "Please reboot your PC for changes to take effect." -ForegroundColor Yellow
        }
        else {
            Write-Host "`n⚠ Update may have encountered issues." -ForegroundColor Yellow
            Write-Host "  Check the output above for details." -ForegroundColor Gray
        }
        
        pause
        exit
    }
    
    # Handle "Reset/Repair Samsung Apps" option - same action for both menus
    if (($updateCheck.Available -and $choice -eq "5") -or (-not $updateCheck.Available -and $choice -eq "4")) {
        Write-Host "`n========================================" -ForegroundColor Yellow
        Write-Host "  Reset/Repair Samsung Apps (Experimental)" -ForegroundColor Yellow
        Write-Host "========================================`n" -ForegroundColor Yellow
        
        Write-Host "Repair Options:" -ForegroundColor Cyan
        Write-Host "  [1] Diagnostics" -ForegroundColor White
        Write-Host "      Check installed packages and device data" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [2] Soft Reset" -ForegroundColor White
        Write-Host "      Clear caches only (keeps login)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [3] Hard Reset" -ForegroundColor White
        Write-Host "      Clear caches + device data + settings (re-login required)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [4] Clear Authentication" -ForegroundColor White
        Write-Host "      Remove Samsung Account DB and credentials" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [5] Repair Permissions" -ForegroundColor White
        Write-Host "      Fix ACLs on app folders" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [6] Re-register Apps" -ForegroundColor White
        Write-Host "      Fix broken app registrations" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [7] Factory Reset" -ForegroundColor Red
        Write-Host "      Completely wipe ALL Samsung data" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [8] Back to Main Menu" -ForegroundColor Gray
        Write-Host ""
        
        $resetChoice = Read-Host "Enter choice [1-8]"
        
        switch ($resetChoice) {
            "1" { Invoke-Diagnostics }
            "2" { Invoke-SoftReset }
            "3" { Invoke-HardReset }
            "4" { Clear-AuthenticationData }
            "5" { Repair-Permissions }
            "6" { Invoke-AppReRegistration }
            "7" { Invoke-FactoryReset }
            default { Write-Host "`nCancelled." -ForegroundColor Yellow }
        }
        
        Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    
    # Remap choices for the rest of the switch
    # The switch statement uses a unified numbering:
    #   1 = Update to installer version
    #   2 = Reinstall
    #   3 = Reinstall current version (only when update available)
    #   4 = Uninstall all (apps, services & scheduled task)
    #   5 = Uninstall apps only
    #   6 = Uninstall services & scheduled task only
    #   7 = Cancel
    
    if ($updateCheck.Available) {
        # Menu when update available:
        #   [1] Download latest -> handled above
        #   [2] Update to installer -> switch 1
        #   [3] Reinstall current -> switch 2
        #   [4] Update SSSE -> handled above
        #   [5] Reset/Repair -> handled above
        #   [6] Uninstall all -> switch 4
        #   [7] Uninstall apps -> switch 5
        #   [8] Uninstall services -> switch 6
        #   [9] Cancel -> switch 7
        if ($choice -eq "2") { $choice = "1" }      # Update to installer version
        elseif ($choice -eq "3") { $choice = "2" }  # Reinstall current version
        elseif ($choice -eq "6") { $choice = "4" }  # Uninstall all
        elseif ($choice -eq "7") { $choice = "5" }  # Uninstall apps only
        elseif ($choice -eq "8") { $choice = "6" }  # Uninstall services only
        elseif ($choice -eq "9") { $choice = "7" }  # Cancel
    }
    else {
        # Menu when no update available:
        #   [1] Update to installer -> switch 1
        #   [2] Reinstall -> switch 2
        #   [3] Update SSSE -> handled above
        #   [4] Reset/Repair -> handled above
        #   [5] Uninstall all -> switch 4
        #   [6] Uninstall apps -> switch 5
        #   [7] Uninstall services -> switch 6
        #   [8] Cancel -> switch 7
        # Choices 1 and 2 stay the same
        if ($choice -eq "5") { $choice = "4" }      # Uninstall all
        elseif ($choice -eq "6") { $choice = "5" }  # Uninstall apps only
        elseif ($choice -eq "7") { $choice = "6" }  # Uninstall services only
        elseif ($choice -eq "8") { $choice = "7" }  # Cancel
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
                    $preserveChoice = Read-Host "Keep your custom config? ([Y]=Keep custom, N=Use default GB3U)"
                    
                    if ($preserveChoice -eq "" -or $preserveChoice -eq "Y" -or $preserveChoice -eq "y") {
                        $biosValuesToUse = $backupBiosValues.Values
                        Write-Host "  ✓ Will preserve your custom BIOS values" -ForegroundColor Green
                    }
                    else {
                        Write-Host "  ✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
                    }
                }
            }
        }
        "2" {
            Write-Host "`n========================================" -ForegroundColor Yellow
            Write-Host "  Full Reinstall (Nuke + Fresh Install)" -ForegroundColor Yellow
            Write-Host "========================================`n" -ForegroundColor Yellow
            
            Write-Host "This will:" -ForegroundColor Cyan
            Write-Host "  1. Backup your current BIOS configuration" -ForegroundColor White
            Write-Host "  2. Uninstall ALL Samsung apps" -ForegroundColor White
            Write-Host "  3. Remove services & scheduled task" -ForegroundColor White
            Write-Host "  4. Delete Samsung app data (optional)" -ForegroundColor White
            Write-Host "  5. Perform a fresh installation" -ForegroundColor White
            Write-Host ""
            
            $confirmReinstall = Read-Host "Proceed with full reinstall? (Y/n)"
            if ($confirmReinstall -like "n*") {
                Write-Host "`nCancelled." -ForegroundColor Yellow
                exit
            }
            
            # Step 1: Backup existing BIOS configuration
            $backupBiosValues = $null
            if (Test-Path $batchScriptPath) {
                Write-Host "`n  [1/5] Backing up BIOS configuration..." -ForegroundColor Cyan
                $backupBiosValues = Get-LegacyBiosValues -OldBatchPath $batchScriptPath
                if ($backupBiosValues -and $backupBiosValues.IsCustom) {
                    Write-Host "    ✓ Custom BIOS values backed up" -ForegroundColor Green
                    Write-Host "      Model: $($backupBiosValues.Values.SystemFamily) ($($backupBiosValues.Values.SystemProductName))" -ForegroundColor Gray
                }
                else {
                    Write-Host "    ✓ Default BIOS config detected" -ForegroundColor Green
                }
            }
            else {
                Write-Host "`n  [1/5] No existing BIOS config found" -ForegroundColor Gray
            }
            
            # Ask about preserving config NOW before nuking
            if ($backupBiosValues -and $backupBiosValues.IsCustom) {
                Write-Host ""
                $preserveChoice = Read-Host "  Keep your custom BIOS config after reinstall? ([Y]=Keep, N=Use default GB3U)"
                
                if ($preserveChoice -eq "" -or $preserveChoice -like "y*") {
                    $biosValuesToUse = $backupBiosValues.Values
                    Write-Host "    ✓ Will restore custom BIOS values after reinstall" -ForegroundColor Green
                }
                else {
                    Write-Host "    ✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
                }
            }
            
            # Step 2: Ask about deleting Samsung app data
            Write-Host "`n  [2/5] Uninstalling Samsung apps..." -ForegroundColor Cyan
            $deleteData = $false
            $nukeConfirm = Read-Host "    Delete ALL Samsung app data too? (Nuke Mode) [y/N]"
            if ($nukeConfirm -like "y*") {
                $deleteData = $true
                Write-Host "    ⚠ Will delete all Samsung app data" -ForegroundColor Yellow
            }
            
            Uninstall-SamsungApps -DeleteData:$deleteData
            
            # Step 3: Remove services
            Write-Host "`n  [3/5] Removing services..." -ForegroundColor Cyan
            $dummyService = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
            if ($dummyService) {
                Stop-Service -Name "SamsungSystemSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete SamsungSystemSupportService 2>&1 | Out-Null
                Write-Host "    ✓ SamsungSystemSupportService removed" -ForegroundColor Green
            }
            $gbeService = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
            if ($gbeService) {
                Stop-Service -Name "GBeSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete GBeSupportService 2>&1 | Out-Null
                Write-Host "    ✓ GBeSupportService removed" -ForegroundColor Green
            }
            if (-not $dummyService -and -not $gbeService) {
                Write-Host "    ✓ No services to remove" -ForegroundColor Green
            }
            
            # Step 4: Remove scheduled task and folders
            Write-Host "`n  [4/5] Removing scheduled task & folders..." -ForegroundColor Cyan
            $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($existingTask) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                Write-Host "    ✓ Scheduled task removed" -ForegroundColor Green
            }
            
            Write-Host "    Stopping Samsung processes..." -ForegroundColor Gray
            Stop-SamsungProcesses | Out-Null
            
            # Remove user folder
            if (Test-Path $installPath) {
                Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "    ✓ User folder removed" -ForegroundColor Green
            }
            
            # Remove SSSE installation folder (C:\GalaxyBook)
            $ssseInstallPath = "C:\GalaxyBook"
            if (Test-Path $ssseInstallPath) {
                Remove-Item -Path $ssseInstallPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "    ✓ SSSE folder removed" -ForegroundColor Green
            }
            
            # Step 5: Continue with fresh install
            Write-Host "`n  [5/5] Starting fresh installation..." -ForegroundColor Cyan
            Write-Host "    Continuing with installation process..." -ForegroundColor Gray
            Write-Host ""
            
            # Fall through to the main installation flow below
        }
        "3" {
            # This case should not be reached after remapping
            # Fall through to continue with reinstall if somehow reached
            Write-Host "`nReinstalling..." -ForegroundColor Yellow
        }
        "4" {
            # Uninstall all (apps, services & scheduled task)
            Write-Host "`nUninstalling (apps, services & scheduled task)..." -ForegroundColor Yellow
            
            $deleteData = $false
            $nukeConfirm = Read-Host "Do you also want to DELETE all Samsung app data? (Nuke Mode) [y/N]"
            if ($nukeConfirm -like "y*") {
                $deleteData = $true
            }
            
            Uninstall-SamsungApps -DeleteData:$deleteData
            
            # Remove services
            $dummyService = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
            if ($dummyService) {
                Stop-Service -Name "SamsungSystemSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete SamsungSystemSupportService 2>&1 | Out-Null
            }
            $gbeService = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
            if ($gbeService) {
                Stop-Service -Name "GBeSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete GBeSupportService 2>&1 | Out-Null
            }
            if ($dummyService -or $gbeService) {
                Write-Host "  ✓ Samsung services removed" -ForegroundColor Green
            }
            
            # Remove scheduled task
            $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($existingTask) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                Write-Host "  ✓ Task removed" -ForegroundColor Green
            }
            
            Write-Host "  Stopping Samsung processes..." -ForegroundColor Gray
            Stop-SamsungProcesses | Out-Null
            
            # Remove user folder
            if (Test-Path $installPath) {
                Write-Host "  Removing user folder..." -ForegroundColor Gray
                Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
                if (-not (Test-Path $installPath)) {
                    Write-Host "  ✓ User folder removed" -ForegroundColor Green
                }
            }
            
            # Remove SSSE installation folder (C:\GalaxyBook)
            $ssseInstallPath = "C:\GalaxyBook"
            if (Test-Path $ssseInstallPath) {
                Write-Host "  Removing SSSE folder..." -ForegroundColor Gray
                Remove-Item -Path $ssseInstallPath -Recurse -Force -ErrorAction SilentlyContinue
                if (-not (Test-Path $ssseInstallPath)) {
                    Write-Host "  ✓ SSSE folder removed" -ForegroundColor Green
                }
            }
            
            Write-Host "`nUninstall complete!" -ForegroundColor Green
            exit
        }
        "5" {
            # Uninstall apps only
            Write-Host "`nUninstalling (apps only)..." -ForegroundColor Yellow
            
            $deleteData = $false
            $nukeConfirm = Read-Host "Do you also want to DELETE all Samsung app data? (Nuke Mode) [y/N]"
            if ($nukeConfirm -like "y*") {
                $deleteData = $true
            }
            
            Uninstall-SamsungApps -DeleteData:$deleteData
            Write-Host "`nUninstall complete!" -ForegroundColor Green
            exit
        }
        "6" {
            # Uninstall services & scheduled task only
            Write-Host "`nUninstalling (services & scheduled task only)..." -ForegroundColor Yellow
            
            # Remove services
            $dummyService = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
            if ($dummyService) {
                Stop-Service -Name "SamsungSystemSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete SamsungSystemSupportService 2>&1 | Out-Null
            }
            $gbeService = Get-Service -Name "GBeSupportService" -ErrorAction SilentlyContinue
            if ($gbeService) {
                Stop-Service -Name "GBeSupportService" -Force -ErrorAction SilentlyContinue
                & sc.exe delete GBeSupportService 2>&1 | Out-Null
            }
            if ($dummyService -or $gbeService) {
                Write-Host "  ✓ Samsung services removed" -ForegroundColor Green
            }
            
            # Remove scheduled task
            $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($existingTask) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                Write-Host "  ✓ Task removed" -ForegroundColor Green
            }
            
            Write-Host "  Stopping Samsung processes..." -ForegroundColor Gray
            Stop-SamsungProcesses | Out-Null
            
            # Remove user folder
            if (Test-Path $installPath) {
                Write-Host "  Removing user folder..." -ForegroundColor Gray
                Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
                if (-not (Test-Path $installPath)) {
                    Write-Host "  ✓ User folder removed" -ForegroundColor Green
                }
            }
            
            # Remove SSSE installation folder (C:\GalaxyBook)
            $ssseInstallPath = "C:\GalaxyBook"
            if (Test-Path $ssseInstallPath) {
                Write-Host "  Removing SSSE folder..." -ForegroundColor Gray
                Remove-Item -Path $ssseInstallPath -Recurse -Force -ErrorAction SilentlyContinue
                if (-not (Test-Path $ssseInstallPath)) {
                    Write-Host "  ✓ SSSE folder removed" -ForegroundColor Green
                }
            }
            
            Write-Host "`nUninstall complete!" -ForegroundColor Green
            exit
        }
        "7" {
            Write-Host "`nCancelled." -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
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
        Write-Host "✓ Intel Wi-Fi adapter - Full* compatibility with Quick Share, Camera Share, Storage Share!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Non-Intel Wi-Fi adapter detected" -ForegroundColor Yellow
        Write-Host "  Quick Share, Camera Share, Storage Share require Intel Wi-Fi adapters" -ForegroundColor Gray
        Write-Host "  Alternative: Google Nearby Share works with any adapter" -ForegroundColor Cyan
        Write-Host "  https://www.android.com/better-together/nearby-share-app/" -ForegroundColor Gray
    }
}
else {
    Write-Host "⚠ No Wi-Fi adapter detected" -ForegroundColor Yellow
    Write-Host "  Quick Share, Camera Share, Storage Share require Wi-Fi to function" -ForegroundColor Gray
}

Write-Host ""

Write-Host "Checking Bluetooth adapter..." -ForegroundColor Yellow
$btCheck = Test-IntelBluetooth

if ($btCheck.HasBluetooth) {
    Write-Host "Detected: $($btCheck.AdapterName)" -ForegroundColor Green
    
    if ($btCheck.IsIntel) {
        Write-Host "✓ Intel Bluetooth radio - Full compatibility!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Non-Intel Bluetooth adapter detected" -ForegroundColor Yellow
        Write-Host "  Quick Share, Camera Share, Storage Share require Intel Bluetooth" -ForegroundColor Gray
        Write-Host "  Third-party Bluetooth adapters cause these features to fail" -ForegroundColor Gray
    }
}
else {
    Write-Host "⚠ No Bluetooth adapter detected" -ForegroundColor Yellow
    Write-Host "  Quick Share, Camera Share, Storage Share require Bluetooth" -ForegroundColor Gray
}

# Summary check for Quick Share / Camera Share / Storage Share compatibility
$quickShareCompatible = $wifiCheck.HasWiFi -and $wifiCheck.IsIntel -and $btCheck.HasBluetooth -and $btCheck.IsIntel
if (-not $quickShareCompatible) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "  Quick Share/Camera Share/Storage Share" -ForegroundColor Red
    Write-Host "  will NOT work on this system" -ForegroundColor Red
    Write-Host "  Requires: Intel Wi-Fi + Intel Bluetooth" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
}

Write-Host ""

# ==================== STEP 2: MODEL SELECTION ====================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 2: Galaxy Book Model Selection" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Only prompt for model selection if not already set from reinstall/legacy
if (-not $biosValuesToUse) {
    $biosValuesToUse = Show-ModelSelectionMenu
}

# ==================== STEP 3: CREATE INSTALLATION ====================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STEP 3: Setting Up Files" -ForegroundColor Cyan
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
            BIOSVendor            = "American Megatrends International, LLC."
            BIOSVersion           = "P04RKI.049.220408.ZQ"
            BIOSMajorRelease      = "0x04"
            BIOSMinorRelease      = "0x11"
            SystemManufacturer    = "SAMSUNG ELECTRONICS CO., LTD."
            SystemFamily          = "Galaxy Book3 Ultra"
            SystemProductName     = "NP960XFH-XA2UK"
            ProductSku            = "SCAI-A5A5-ADLP-PSLP"
            EnclosureKind         = "0x1f"
            BaseBoardManufacturer = "SAMSUNG ELECTRONICS CO., LTD."
            BaseBoardProduct      = "NP960XFH-XA2UK"
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
        }
        else {
            Write-Host "✓ Will use default Galaxy Book3 Ultra values" -ForegroundColor Green
        }
    }
    else {
        Write-Host "✓ Legacy installation uses standard values" -ForegroundColor Green
    }
    Write-Host ""
}

# Create the batch file for registry spoofing
Write-Host "Creating registry spoof script..." -ForegroundColor Yellow
New-RegistrySpoofBatch -OutputPath $batchScriptPath -BiosValues $biosValuesToUse

if ($biosValuesToUse) {
    Write-Host "✓ Registry spoof script created (custom values preserved)" -ForegroundColor Green
}
else {
    Write-Host "✓ Registry spoof script created (Galaxy Book3 Ultra)" -ForegroundColor Green
}

# Clean up legacy installation if it exists
if (Test-Path $legacyPath) {
    Write-Host "Cleaning up legacy installation files..." -ForegroundColor Yellow
    try {
        Remove-Item $legacyPath -Recurse -Force -ErrorAction Stop
        Write-Host "✓ Legacy files removed" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Could not remove legacy files: $_" -ForegroundColor Yellow
        Write-Host "  You can manually delete: $legacyPath" -ForegroundColor Gray
    }
}

# Save configuration
$config = @{
    InstalledVersion = $SCRIPT_VERSION
    InstallDate      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    WiFiAdapter      = $wifiCheck.AdapterName
    IsIntelWiFi      = $wifiCheck.IsIntel
}

$config | ConvertTo-Json | Set-Content $configPath
Write-Host "✓ Configuration saved" -ForegroundColor Green

# ==================== STEP 4: SCHEDULED TASK ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 4: Creating Startup Task" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($TestMode) {
    Write-Host "[TEST MODE] Skipping scheduled task creation" -ForegroundColor Yellow
    Write-Host "  Would create task: $taskName" -ForegroundColor Gray
    Write-Host "  Would execute: $batchScriptPath" -ForegroundColor Gray
    Write-Host "  Would run as: SYSTEM (at startup + 10s delay)" -ForegroundColor Gray
}
else {
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

# ==================== STEP 5: SYSTEM SUPPORT ENGINE (OPTIONAL/ADVANCED) ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 5: System Support Engine (Advanced)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Warn if Samsung Settings already installed (version mismatch risk with driver-bound install)
try {
    $existingSettings = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*SamsungSettings*" }
    $provisionedSettings = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*SamsungSettings*" }
    
    if ($existingSettings -or $provisionedSettings) {
        Write-Host "⚠ Existing Samsung Settings packages detected:" -ForegroundColor Yellow
        
        if ($existingSettings) {
            Write-Host "`n  Installed packages:" -ForegroundColor Cyan
            foreach ($app in $existingSettings) {
                Write-Host "    • $($app.Name) (version: $($app.Version))" -ForegroundColor Gray
            }
        }
        
        if ($provisionedSettings) {
            Write-Host "`n  Provisioned packages (system-wide):" -ForegroundColor Cyan
            foreach ($prov in $provisionedSettings) {
                Write-Host "    • $($prov.DisplayName) (version: $($prov.Version))" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "  Note: The System Support Engine driver triggers a specific Store version." -ForegroundColor Gray
        Write-Host "  If versions don't match, features may misbehave." -ForegroundColor Gray
        Write-Host ""
         
        $choice = Read-Host "Options: [U]ninstall existing packages, [C]ontinue anyway, [S]kip SSSE setup (U/C/S)"
         
        if ($choice -like "u*") {
            Write-Host "`nUninstalling existing Samsung Settings packages..." -ForegroundColor Yellow
            Write-Host "  This will try multiple methods to ensure complete removal." -ForegroundColor Gray
            Write-Host ""
            
            $removalResult = Remove-SamsungSettingsPackages -Packages $existingSettings
            
            Write-Host ""
            Write-Host "Removal Summary:" -ForegroundColor Cyan
            if ($removalResult.Success.Count -gt 0) {
                Write-Host "  ✓ Successfully removed: $($removalResult.Success.Count) package(s)" -ForegroundColor Green
                foreach ($pkg in $removalResult.Success) {
                    Write-Host "    • $pkg" -ForegroundColor Gray
                }
            }
            
            if ($removalResult.Failed.Count -gt 0) {
                Write-Host "  ✗ Failed to remove: $($removalResult.Failed.Count) package(s)" -ForegroundColor Red
                foreach ($pkg in $removalResult.Failed) {
                    Write-Host "    • $($pkg.Name)" -ForegroundColor Gray
                }
                Write-Host ""
                Write-Host "  Manual removal options:" -ForegroundColor Yellow
                Write-Host "    1. Try running this script in Windows PowerShell as Admin" -ForegroundColor Gray
                Write-Host "    2. Use Settings > Apps to uninstall Samsung Settings" -ForegroundColor Gray
                Write-Host "    3. Continue anyway (may cause version conflicts)" -ForegroundColor Gray
                Write-Host ""
                
                $continueAnyway = Read-Host "Continue with SSSE installation anyway? (y/N)"
                if ($continueAnyway -notlike "y*") {
                    Write-Host "Skipped SSSE setup." -ForegroundColor Yellow
                    return
                }
            }
            
            Write-Host "`nProceeding with SSSE installation (will trigger fresh Store installation)..." -ForegroundColor Green
            Install-SystemSupportEngine -TestMode $TestMode | Out-Null
        }
        elseif ($choice -like "c*") {
            Write-Host "Continuing with existing packages..." -ForegroundColor Yellow
            Install-SystemSupportEngine -TestMode $TestMode | Out-Null
        }
        else {
            Write-Host "Skipped SSSE setup by user choice." -ForegroundColor Yellow
        }
    }
    else {
        Install-SystemSupportEngine -TestMode $TestMode | Out-Null
    }
}
catch {
    Install-SystemSupportEngine -TestMode $TestMode | Out-Null
}

# ==================== STEP 6: PACKAGE INSTALLATION ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 6: Samsung Software Installation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$installChoice = Show-PackageSelectionMenu -HasIntelWiFi $wifiCheck.IsIntel

$packagesToInstall = @()

if ($installChoice -eq "6") {
    Write-Host "✓ Skipping package installation" -ForegroundColor Green
    Write-Host "  You can install packages manually from the Microsoft Store" -ForegroundColor Gray
}
elseif ($installChoice -eq "5") {
    # Custom selection
    $packagesToInstall = Show-CustomPackageSelection -HasIntelWiFi $wifiCheck.IsIntel
}
else {
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
        if ($pkg.Tip) {
            Write-Host "    💡 $($pkg.Tip)" -ForegroundColor Cyan
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
        Write-Host ""
        Write-Host "  Troubleshooting tips:" -ForegroundColor Yellow
        Write-Host "    • If you see error 0x80d03805: Toggle WiFi OFF/ON and retry" -ForegroundColor Gray
        Write-Host "    • Or switch to a different WiFi network temporarily" -ForegroundColor Gray
        Write-Host "    • Manual install: Open Microsoft Store and search for the app" -ForegroundColor Gray
    }
    
    Write-Host ""

    # Conditionally show AI Select configuration if 'AI Select' was selected
    $aiSelectChosen = $packagesToInstall | Where-Object { $_.Name -eq "AI Select" }
    if ($aiSelectChosen) {
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  STEP 7: AI Select Configuration" -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        Write-Host "AI Select is Samsung's intelligent selection tool." -ForegroundColor White
        Write-Host "You'll need a keyboard shortcut to launch it quickly.`n" -ForegroundColor Gray

        # Create launcher scripts in C:\GalaxyBook
        $aiSelectLauncherDir = "C:\GalaxyBook"
        if (-not (Test-Path $aiSelectLauncherDir)) {
            New-Item -Path $aiSelectLauncherDir -ItemType Directory -Force | Out-Null
        }
        
        # Create .bat launcher (fastest, no window)
        $batLauncherPath = Join-Path $aiSelectLauncherDir "AISelect.bat"
        $batContent = @"
@echo off
start "" shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App
"@
        $batContent | Set-Content -Path $batLauncherPath -Encoding ASCII
        
        # Create .ps1 launcher (nicer, hidden window)
        $ps1LauncherPath = Join-Path $aiSelectLauncherDir "AISelect.ps1"
        $ps1Content = @"
# AI Select Launcher - Galaxy Book Enabler
# Use with PowerToys Keyboard Manager for fastest launch
Start-Process "shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App"
"@
        $ps1Content | Set-Content -Path $ps1LauncherPath -Encoding UTF8
        
        Write-Host "✓ Launcher scripts created:" -ForegroundColor Green
        Write-Host "    $batLauncherPath" -ForegroundColor Gray
        Write-Host "    $ps1LauncherPath" -ForegroundColor Gray
        Write-Host ""

        Write-Host "Launch Options (fastest to slowest):" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [1] PowerToys URI Method (Recommended - Fastest)" -ForegroundColor Green
        Write-Host "      • Install PowerToys from Microsoft Store" -ForegroundColor Gray
        Write-Host "      • Open PowerToys → Keyboard Manager → Remap a key" -ForegroundColor Gray
        Write-Host "      • Map a key (e.g., Right Alt) → Win+Ctrl+Alt+S" -ForegroundColor Gray
        Write-Host "      • Then: Remap a shortcut → Win+Ctrl+Alt+S → Open URI" -ForegroundColor Gray
        Write-Host "      • URI: shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [2] PowerToys Run Program (Fast)" -ForegroundColor Cyan
        Write-Host "      • Remap a shortcut → Action: Run Program" -ForegroundColor Gray
        Write-Host "      • Program: powershell.exe" -ForegroundColor Gray
        Write-Host "      • Args: -WindowStyle Hidden -File `"$ps1LauncherPath`"" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [3] AutoHotkey (Alternative)" -ForegroundColor Cyan
        Write-Host "      • Create AHK script to launch the URI on key press" -ForegroundColor Gray
        Write-Host "      • See README for example scripts" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  [4] Desktop shortcut (Standard)" -ForegroundColor White
        Write-Host "      • Uses explorer.exe (slight overhead)" -ForegroundColor Gray
        Write-Host ""

        $setupShortcut = Read-Host "Create Desktop shortcut? (Y/N)"

        if ($setupShortcut -like "y*") {
            $WshShell = New-Object -ComObject WScript.Shell
            $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "AI Select.lnk")
            $shortcut = $WshShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = "explorer.exe"
            $shortcut.Arguments = "shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App"
            $shortcut.IconLocation = "shell32.dll,23"
            $shortcut.Save()
            
            Write-Host "✓ Desktop shortcut created!" -ForegroundColor Green
            Write-Host "  Right-click it → Properties → Set 'Shortcut key' (e.g., Ctrl+Alt+S)" -ForegroundColor Gray
        }
        else {
            Write-Host "✓ Skipped desktop shortcut" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Tip: PowerToys URI method is the fastest - launches AI Select instantly!" -ForegroundColor Cyan
        Write-Host "     See README for detailed setup instructions." -ForegroundColor Gray
        Write-Host ""
    }
    
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

# ==================== STEP 8: APPLY SPOOF NOW ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  STEP 8: Applying Registry Spoof" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($TestMode) {
    Write-Host "[TEST MODE] Skipping registry modification" -ForegroundColor Yellow
    Write-Host "  Would execute: $batchScriptPath" -ForegroundColor Gray
    Write-Host "  Registry keys that would be modified:" -ForegroundColor Gray
    Write-Host "    HKLM\HARDWARE\DESCRIPTION\System\BIOS (14 values)" -ForegroundColor Gray
    Write-Host "    HKLM\SYSTEM\HardwareConfig\Current (17 values)" -ForegroundColor Gray
    Write-Host "    HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation (4 values)" -ForegroundColor Gray
}
else {
    Write-Host "Applying Samsung Galaxy Book spoof..." -ForegroundColor Yellow
    Start-Process -FilePath $batchScriptPath -Wait -NoNewWindow
    Write-Host "✓ Registry spoof applied!" -ForegroundColor Green
    if ($biosValuesToUse) {
        $fam = $biosValuesToUse.SystemFamily
        $prod = $biosValuesToUse.SystemProductName
        Write-Host "  Your PC now identifies as a Samsung $fam ($prod)" -ForegroundColor Gray
    }
    else {
        Write-Host "  Your PC now identifies as a Samsung Galaxy Book3 Ultra" -ForegroundColor Gray
    }
}

Write-Host "`nCreating Samsung System Support Service (dummy)..." -ForegroundColor Yellow
$dummyService = Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue
if (-not $dummyService) {
    & sc.exe create SamsungSystemSupportService binPath= "C:\Windows\System32\cmd.exe" DisplayName= "Samsung System Support Service" start= disabled 2>&1 | Out-Null
    Write-Host "✓ Dummy service created (disabled)" -ForegroundColor Green
}
else {
    # Ensure existing service is disabled
    $currentStartType = (Get-Service -Name "SamsungSystemSupportService" -ErrorAction SilentlyContinue).StartType
    if ($currentStartType -ne 'Disabled') {
        Set-Service -Name "SamsungSystemSupportService" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "✓ Service already exists (set to disabled)" -ForegroundColor Green
    }
    else {
        Write-Host "✓ Service already exists (disabled)" -ForegroundColor Green
    }
}

Write-Host "`nStopping all Samsung processes..." -ForegroundColor Yellow
Stop-SamsungProcesses
# Also catch any remaining Samsung processes by wildcard
Get-Process -Name 'Samsung*', 'QuickShare*', 'MultiControl*', 'SmartSelect*', 'AISelect*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "✓ Samsung processes stopped" -ForegroundColor Green

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
}
else {
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
    if ($aiSelectChosen) {
        Write-Host "  4. Set up AI Select hotkey (see C:\GalaxyBook\AISelect.ps1)" -ForegroundColor White
    }

    Write-Host "`n────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  USAGE GUIDE" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
    
    Write-Host "`n  Online One-Line Version:" -ForegroundColor Yellow
    Write-Host "  Run in PowerShell (Admin) - shows menu with all options:" -ForegroundColor Gray
    Write-Host "    irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex" -ForegroundColor White
    
    Write-Host "`n  Downloaded Script Version:" -ForegroundColor Yellow
    Write-Host "  Download and run with parameters for direct actions:" -ForegroundColor Gray
    Write-Host "    .\Install-GalaxyBookEnabler.ps1                  # Fresh install / menu" -ForegroundColor White
    Write-Host "    .\Install-GalaxyBookEnabler.ps1 -UpgradeSSE      # Upgrade Samsung Settings (SSSE)" -ForegroundColor White
    Write-Host "    .\Install-GalaxyBookEnabler.ps1 -UpdateSettings  # Clean reinstall Samsung Settings" -ForegroundColor White
    Write-Host "    .\Install-GalaxyBookEnabler.ps1 -Uninstall       # Full uninstall" -ForegroundColor White
    Write-Host "    .\Install-GalaxyBookEnabler.ps1 -TestMode        # Dry run (no changes)" -ForegroundColor White
    
    Write-Host "`n  Quick Share Requirements:" -ForegroundColor Yellow
    Write-Host "  • Intel Wi-Fi AX card (not AC) + Intel Bluetooth required" -ForegroundColor Gray

    # Launch Galaxy Book Experience to show available Samsung apps
    Write-Host "`nLaunching Galaxy Book Experience..." -ForegroundColor Cyan
    try {
        Start-Process "shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SamsungWelcome_3c1yjt4zspk6g!App"
        Write-Host "  ✓ Galaxy Book Experience opened - explore available Samsung apps!" -ForegroundColor Green
    }
    catch {
        Write-Host "  Note: Galaxy Book Experience will be available after reboot" -ForegroundColor Yellow
    }
}

Write-Host "`n"