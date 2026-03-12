# Galaxy Book Enabler Explainer

This file is the public command reference for:

```powershell
.\Install-GalaxyBookEnabler.ps1
```

Best practice: download the script first and run it locally from PowerShell 7. That gives you the most predictable behavior, makes reruns easier, and is the best way to use the install, autonomous, and manual generation paths.

## Recommended Setup

### Install PowerShell 7

```powershell
winget install Microsoft.PowerShell
```

### Download the script locally

Download `Install-GalaxyBookEnabler.ps1` from the Releases page:

`https://github.com/Bananz0/GalaxyBookEnabler/releases`

### Run the local script

```powershell
.\Install-GalaxyBookEnabler.ps1
```

## `irm` Use

Running with `irm` is supported, but local use is still preferred.

### Direct one-liner

```powershell
irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
```

After saving locally:

```powershell
.\Install-GalaxyBookEnabler.ps1
```

## Basic Use

### Interactive install

```powershell
.\Install-GalaxyBookEnabler.ps1
```

### Test mode

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode
```

### Full uninstall

```powershell
.\Install-GalaxyBookEnabler.ps1 -Uninstall
```

### Update Samsung Settings

```powershell
.\Install-GalaxyBookEnabler.ps1 -UpdateSettings
```

### Upgrade SSE path

```powershell
.\Install-GalaxyBookEnabler.ps1 -UpgradeSSE
```

## Autonomous Install

### Standard autonomous install

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Pro -AutonomousPackageProfile Recommended -AutonomousInstallSsse:$true -AutonomousSsseStrategy Dual -AutonomousConfirmPackages:$true
```

### Exact model code

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel 960XGL -AutonomousPackageProfile Skip -AutonomousInstallSsse:$false
```

### Family or profile input

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel "Galaxy Book4 Pro" -AutonomousPackageProfile Core -AutonomousInstallSsse:$false
```

### Region-aware autonomous install

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Ultra -AutonomousCountryCode US -AutonomousPackageProfile Recommended
```

### GeoIP-driven autonomous resolution

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Ultra -AutonomousRegionSource GeoIp -AutonomousPackageProfile Recommended
```

### Manual region override

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Ultra -AutonomousRegion DE -AutonomousPackageProfile Recommended
```

### Region preference fallback

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Ultra -AutonomousRegionPreference UK,DE -AutonomousPackageProfile Recommended
```

## Manual Identity / Configuration Generation

These commands resolve values directly through the installer.

### Basic manual generation

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra
```

### Full BIOS string

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -IncludeFullBiosVersion
```

### Country override

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -CountryCode US
```

### Region override

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -RegionCode DE
```

### Region preference

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -RegionPreference UK,DE
```

### GeoIP

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -UseGeoIp
```

### Friendly family name

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile "Galaxy Book4 Pro"
```

### Configuration-file update

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -CountryCode US -WriteConfigPlist -ConfigPath "D:\EFI\OC\config.plist"
```

### Configuration-file update with full BIOS string

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -CountryCode US -IncludeFullBiosVersion -WriteConfigPlist -ConfigPath "D:\EFI\OC\config.plist"
```

### Configuration-file update without backup

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -WriteConfigPlist -ConfigPath "D:\EFI\OC\config.plist" -SkipConfigBackup
```

### Configuration-file update with custom backup suffix

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -WriteConfigPlist -ConfigPath "D:\EFI\OC\config.plist" -ConfigBackupSuffix manual-test
```

## Explicit Configuration-Only Mode

This is the lower-level form of the same path.

### Basic configuration-only call

```powershell
.\Install-GalaxyBookEnabler.ps1 -ConfigurationOnly -FullyAutonomous -AutonomousModel Book4Pro -AutonomousCountryCode US
```

### Configuration-only file update

```powershell
.\Install-GalaxyBookEnabler.ps1 -ConfigurationOnly -FullyAutonomous -AutonomousModel Book4Pro -AutonomousCountryCode US -ConfigurationPath "D:\EFI\OC\config.plist"
```

## Autonomous Actions

### Install

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousAction Install -AutonomousModel Book4Pro -AutonomousPackageProfile Skip -AutonomousInstallSsse:$false
```

### UpdateSettings

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousAction UpdateSettings -AutonomousSsseStrategy Stable
```

### UpgradeSSE

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousAction UpgradeSSE
```

### UninstallAll

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousAction UninstallAll
```

## Package Profiles

Valid values for `-AutonomousPackageProfile`:

- `Core`
- `Recommended`
- `RecommendedPlus`
- `Full`
- `Everything`
- `Custom`
- `Skip`

### Custom package list

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousModel 960XGL -AutonomousPackageProfile Custom -AutonomousPackageNames "Samsung Account","Samsung Settings" -AutonomousInstallSsse:$false -AutonomousConfirmPackages:$false
```

## Model Input Rules

You can pass:

- exact model codes such as `960XGL`
- short family/profile values such as `Book4Pro`
- friendly family names such as `Galaxy Book4 Pro`

Examples:

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra
.\Install-GalaxyBookEnabler.ps1 -Profile "Galaxy Book4 Pro"
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel 960XGL -AutonomousPackageProfile Skip
```

## Region Input Rules

If you do not specify a country or region, the script uses your Windows locale.

`IE` maps to `UK`.

Examples:

```powershell
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -CountryCode IE
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -RegionCode UK
.\Install-GalaxyBookEnabler.ps1 -Profile Book4Ultra -UseGeoIp
```

## Logging

### Default autonomous logging

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Pro -AutonomousPackageProfile Skip -LogDirectory "C:\GalaxyBook\Logs"
```

### Explicit log file

```powershell
.\Install-GalaxyBookEnabler.ps1 -FullyAutonomous -AutonomousModel Book4Pro -AutonomousPackageProfile Skip -LogPath "C:\GalaxyBook\Logs\manual-run.log"
```

## Recommended Test Commands

### Installer dry run

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode
```

### Autonomous dry run

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode -FullyAutonomous -AutonomousModel Book4Pro -AutonomousPackageProfile Skip -AutonomousInstallSsse:$false
```

### Configuration generation test

```powershell
Copy-Item .\tests\fixtures\config.plist.sample $env:TEMP\gbe-config-test.plist -Force; .\Install-GalaxyBookEnabler.ps1 -Profile Book4Pro -CountryCode US -IncludeFullBiosVersion -WriteConfigPlist -ConfigPath "$env:TEMP\gbe-config-test.plist"
```

### Pester

```powershell
Invoke-Pester -Script .\tests\Install-Configuration.Tests.ps1 -EnableExit
```
