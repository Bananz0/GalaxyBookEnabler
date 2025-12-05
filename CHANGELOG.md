# Changelog

All notable changes to Galaxy Book Enabler will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Configuration guides for "Extra Steps" apps (Phone, Find) *(planned)*

## [3.0.0] - 2025-12-04

### Added

- **Package Manager** - New menu option for managing Samsung apps
  - View installation status of all profiles at a glance
  - Install any profile (Core, Recommended, Recommended Plus, Full, Everything)
  - Uninstall any profile with confirmation
  - Uninstall all Samsung apps with optional data deletion
  - Accessible from existing installation menu via "Manage Packages"

- **Smart Package Detection** - Accurate installed package counting
  - Name mapping for packages with mismatched AppX names
  - Handles Camera Share, Storage Share, AI Select, Live Wallpaper, Device Care, etc.
  - Fast HashSet-based lookup instead of slow winget queries
  - Fallback detection for all package variants

- **Improved Installation Flow**
  - Differential install skips already-installed packages
  - Shows [Installed] or [X/Y Installed] status for each profile
  - Suppressed verbose AppX deployment output during uninstall

- **Enhanced Installation Detection** - Comprehensive health check at startup
  - Displays both GBE version and SSSE version
  - Checks 4 components: config file, scheduled task, C:\GalaxyBook, GBeSupportService
  - Shows "installation appears BROKEN" warning if partial install detected
  - Offers repair/reinstall option automatically

- **Standalone SSSE Upgrade Option** - New menu to upgrade Samsung System Support Engine
  - Auto mode: Downloads latest version automatically
  - Manual mode: Choose from all SSSE versions
  - Service stop/restart handled during upgrade

- **Dual-Version SSSE Installation Strategy** - Improved reliability
  - After Samsung Settings launches, auto-upgrades binary to latest
  - Full service lifecycle (stop, kill, replace, restart)
  - Simplified strategy prompt with recommended in-place upgrade option

- **Merged Reset-Samsung Tools** - Comprehensive repair suite
  - **New Submenu**: "Reset/Repair Samsung Apps (VERY Experimental)"
  - **Tools**: Diagnostics, Soft/Hard Reset, Clear Authentication, Repair Permissions, Re-register Apps, Factory Reset

- **"Nuke" Uninstall Mode** - Optional destructive uninstall
  - Prompts to delete ALL app data during uninstall
  - Wipes ProgramData, AppData, and package LocalState folders if left behind
  - Triggers Galaxy Buds Bluetooth device cleanup

- **Nuke + Fresh Install Reinstall** - Complete reinstall option
  - Option 2 now performs full uninstall (preserving BIOS config) then fresh install
  - Ensures clean state without manual uninstall/reinstall cycle

- **Galaxy Buds Bluetooth Cleanup** - Remove from Windows BT registry (using methods inspired by @m-a-x-s-e-e-l-i-g and @RS-DU34) (thanks to @felipecrs)
  - All variants: Buds 2/3/4, Pro, Live, FE

- **Touchpad AI Select Tip** - 4-finger tap customization guidance

### Changed

- Version 3.0.0 - Major revision
- Uninstall menu redesigned with Reset sub-menu
- SSSE version selection replaced with dual-version strategy
- Reinstall option (menu choice 2) now performs full nuke + fresh install
- Simplified SSSE strategy prompt (removed verbose box UI)
- `$installedVersion` now consistently tracks actual installed SSSE version throughout installation

### Fixed

- **Security: Self-elevation no longer downloads from GitHub** - Uses temp file approach to prevent RCE
- **Binary patching failure now triggers full cleanup** - Stops services, removes folders on patch failure
- **Suppressed verbose uninstall output** - No more "Deployment operation progress" spam
- **Fixed HashSet collection error** - Proper handling with Write-Output -NoEnumerate
- **Fixed package counter accuracy** - All 34 packages now detected correctly with name mappings
- **Fixed menu choice [5] Everything** - Was incorrectly showing Custom Selection
- Bluetooth detection now correctly identifies physical Bluetooth adapters (filters by DeviceID pattern)
- Fixed null-valued expression errors during package installation with proper scope handling
- Fixed uninstall menu option 5 not properly mapping to "Uninstall all" action
- Script-scoped `$PackageDatabase` for consistent access across all functions

### Documentation

- Updated Multi Control/Second Screen Wi-Fi compatibility (Wi-Fi 5: ❌, Wi-Fi 6/6E: ⚠️ Jittery, Wi-Fi 7: ❓ Unknown)

**Credits:** [@Hydro3ia](https://github.com/Hydro3ia) ❤️, [@systemsrethinking](https://github.com/systemsrethinking) ❤️, [@intini](https://github.com/intini) ❤️, [@m-a-x-s-e-e-l-i-g](https://github.com/m-a-x-s-e-e-l-i-g), [@RS-DU34](https://github.com/RS-DU34), [@felipecrs](https://github.com/felipecrs)

## [2.5.0] - 2025-11-26

### Added

- **`-UpdateSettings` parameter** - One-command Samsung Settings reinstall
  - Stops all Samsung processes and services
  - Cleans C:\GalaxyBook installation folder
  - Uninstalls Samsung Settings & Settings Runtime packages
  - Downloads and patches chosen SSSE version
  - Adds driver to DriverStore automatically
  - Reinstalls apps from Microsoft Store via winget
- **"Update/Reinstall Samsung Settings" menu option** - Available from the reinstall menu
  - Allows `irm|iex` users to upgrade SSSE without needing to pass parameters
  - Full SSSE version selection including 6.3.3.0 (recommended) and 7.1.2.0 (latest)
- **Intel Bluetooth detection** - Now checks for Intel Bluetooth radio (required for Quick Share)
- **Intel Wi-Fi AX vs AC detection** - Distinguishes Wi-Fi 6 (AX) from Wi-Fi 5 (AC) cards
- **Comprehensive usage guide** - Displayed at installation completion
  - Online one-line version instructions
  - Downloaded script version with all available parameters
- **AI Select launcher scripts** - Created in `C:\GalaxyBook\` for easy hotkey binding
  - `AISelect.bat` - Batch launcher for shortcuts
  - `AISelect.ps1` - PowerShell launcher for PowerToys
  - Detailed setup guide for PowerToys URI method, Run Program.

### Changed

- **Simplified driver installation** - Driver now added to DriverStore automatically via `pnputil`
  - Removed manual Device Manager binding prompts
  - No more interactive driver installation steps
- **Enhanced Quick Share compatibility warnings**
  - AC cards explicitly noted as NOT working (shows "software update required" error)
  - Third-party Bluetooth adapters noted as causing Quick Share failures
- **Updated README** - Wi-Fi/Bluetooth requirements section rewritten for clarity

### Removed

- `Install-SSSEDriverInteractive` function - Replaced with simpler `Install-SSSEDriverToStore`
- Manual driver binding instructions during SSSE setup

## [2.4.0] - 2025-11-25 (unreleased)

### Added

- **Universal SSSE binary patching** - Supports all Samsung System Support Engine versions
  - Version 6.x series: 6.1.8.0, 6.3.3.0 (requires 2 patches)
  - Version 7.x series: 7.0.10.0, 7.0.14.0, 7.0.16.0, 7.1.2.0 (requires 1 patch)
- **`-UpgradeSSE` parameter** - Quick upgrade path for existing SSSE installations
- **Version selection menu** - Choose specific SSSE version during installation
  - 6.3.3.0 recommended for first install (most stable)
  - 7.1.2.0 for latest features (use for upgrades)
- **Secondary patch detection** - Automatically applies additional patch for 6.x versions

### Changed

- **SSSE version 6.3.3.0 now default** - More compatible than 7.x for fresh installs
- **Improved patching logic** - Pattern matching handles all known SSSE versions

## [2.2.0] - 2025-11-15

### Added

- Connect your Galaxy Buds to multiple devices simultaneously
- Seamless switching between PC and phone
- No additional configuration needed - automatic with proper BIOS spoofing
- **21 Authentic Galaxy Book Models** - Complete hardware profile database
  - Galaxy Book5 series (2025): 960XHA, 940XHA, 960QHA, 750QHA
  - Galaxy Book4 series (2024): 960XGL, 960XGK, 940XGK, 960QGK, 750XGK, 750XGL, 750QGK
  - Galaxy Book3 series (2023): 960XFH, 960XFG, 960QFG, 750XFG, 750XFH, 730QFG
  - Galaxy Book2/Earlier: 950XGK, 930XDB, 935QDC, 930SBE
  - All 11 BIOS/DMI registry values per model extracted from real hardware
  - Data sourced from linux-hardware.org DMI dumps
- **Interactive Model Selection Menu** - New Step 2 in installation flow
  - Categorized by generation (Book5/4/3/2)
  - Shows product family for each model
  - Option to use legacy default (960XFH - Galaxy Book3 Ultra)
  - Clear display of selected model details
- **Automatic Privilege Elevation** - No more manual "Run as Administrator"
  - Detects if running without admin rights
  - Supports gsudo for seamless elevation (no UAC popup)
  - Supports Windows 11 native sudo
  - Falls back to traditional UAC prompt if no sudo available
  - Preserves script parameters during re-launch
  - Smart handling of piped scripts (irm | iex)
- **Python Extraction Tools** - Developer tools for future model updates
  - `analyze-patterns.py` - DMI/BIOS pattern analysis
  - `extract-registry-db.py` - Model database generator
  - `GalaxyBookModels.ps1` - PowerShell hashtable reference
  - `galaxy-book-database.json` - Portable JSON database
- **MODELS.md Documentation** - Comprehensive model selection guide
  - Detailed specifications for all 21 models
  - Screen sizes, types (laptop/convertible), generations
  - Recommendations for different use cases
  - Technical details on naming patterns
  - Migration guidance for legacy users
- **Installation flow updated to 8 steps** (was 7)
  - Step 2 is now Model Selection (new)
  - All subsequent steps renumbered (3-8)
- **Core packages increased to 8** (was 7)
  - Added Galaxy Book Experience to Core
  - GBE now launches at end of installation
- **README.md updated**
  - Model selection feature highlighted
  - Auto-elevation instructions added
  - gsudo installation recommendation
  - Updated Quick Start section
- **FLOW_DIAGRAM.md updated**
  - Added Step 2: Model Selection
  - Updated Core package count
  - Renumbered all subsequent steps

### Changed

- Model database embedded directly in installer (no external files needed)
- Pattern analysis confirmed no algorithmic generation possible
- BIOS versions contain unpredictable build dates
- SKU codes use model-specific platform identifiers
- Lookup table required for accurate spoofing

## [2.0.0] - 2025-11-14

### Added

- Changelog extraction for release notes
- Release artifact creation
- One-line installer hosting
- **Auto-update checker** - Checks GitHub for latest version
  - Compares current version with latest release
  - Downloads and launches updated installer automatically
  - Shows release notes before updating
  - Fallback to manual update if download fails
- **Legacy configuration preservation** - Upgrading from v1.x
  - Detects custom BIOS values in old QS.bat
  - Prompts user to preserve custom values or use defaults
  - Automatically cleans up old installation files
  - Seamless migration from v1.x to v2.x
- **Comprehensive package database** - Defined all 33+ Samsung apps with metadata
  - Core packages (required): Account, Settings, Cloud, Continuity Service, Intelligence Service
  - Recommended packages (21 apps): All fully working Samsung apps
  - Extra steps packages: Phone, Find, Quick Search, Samsung Pass (require additional config)
  - Non-working packages: Recovery, Update (will never work on non-Samsung hardware)
  - Legacy packages: Studio Plus (old version)
- **New packages added**:
  - **Samsung Intelligence Service** (Core) - Required for Galaxy AI features and AI Select
  - **AI Select** (Recommended) - Smart screenshot tool with text extraction and AI features
  - **Nearby Devices** (Recommended) - Manage and connect to nearby Samsung devices
  - **Storage Share** (Recommended) - Share storage between devices
- **Advanced package selection system** with multiple profiles
  - **Core Only**: Essential packages for basic functionality
  - **Recommended**: Core + all fully working apps (25 packages)
  - **Full Experience**: Recommended + apps requiring extra setup
  - **Everything**: All packages including non-functional ones
  - **Custom Selection**: Pick individual packages by category
- **Smart package filtering** - Interactive category-based selection
  - Packages grouped by: Connectivity, Productivity, Media, Security, etc.
  - Bulk selection per category (All/None/Individual)
  - Package warnings and compatibility notes displayed inline
- **Intel Wi-Fi detection moved to conditional check**
  - Warning only appears if Quick Share is selected for installation
  - Other apps work without Intel Wi-Fi requirement
  - No longer blocks installation unnecessarily
- **Package status indicators** with color coding
  - ✅ Green: Fully working packages
  - ⚠️ Yellow: Requires extra steps
  - ❌ Red: Non-functional packages
  - 🔵 Gray: Legacy/deprecated packages
- **Installation progress tracking** - Real-time feedback during package installation
  - Shows current package number / total packages
  - Individual package status (success/failure)
  - Summary with statistics after installation
- **Post-installation warnings** for specific app types
  - Quick Share Wi-Fi adapter warning (only if non-Intel and Quick Share selected)
  - Extra configuration required warning (for Phone, Find, Quick Search)
  - Non-functional app notice (for Recovery, Update)
- **Package metadata system** - Each package includes
  - Name, Store ID, Category, Description
  - Working status, warnings, special requirements
  - Intel Wi-Fi requirement flag

### Changed

- **BREAKING:** Wi-Fi compatibility check no longer blocks installation
- **BREAKING:** Package installation completely redesigned with new UI
- **Samsung Pass moved to Extra Steps** - Requires additional configuration
- Installer version bumped to 2.0.0
- Package selection moved to Step 5 (after file setup and task creation)
- All package IDs updated to match Microsoft Store
- Removed simple "core/optional" split in favor of profile system

### Changed

- Installation summary shows detailed package list with status colors
- User confirms package list before installation begins
- Better error handling for individual package failures
- Clearer distinction between working and non-working apps
- Help text explains what each profile includes
- `Show-PackageSelectionMenu()` - Main selection interface with 6 options
- `Get-PackagesByProfile()` - Returns packages based on selected profile
- `Show-CustomPackageSelection()` - Interactive custom package picker
- `Install-SamsungPackages()` - Batch installer with progress tracking
- `Test-IntelWiFi()` - Returns structured Wi-Fi adapter information
- `Get-LegacyBiosValues()` - Extracts custom values from v1.x QS.bat
- `New-RegistrySpoofBatch()` - Generates batch file with custom or default values
- Package database structured as hashtable with arrays per category
- Package objects include all necessary metadata for smart filtering

### Fixed

- Quick Share no longer requires Intel Wi-Fi to proceed with installation
- Galaxy Book Experience properly marked as optional
- Package IDs corrected for Samsung Account and other core apps
- Installation no longer fails silently - shows clear success/failure status

---

## [1.1.5] - 2024-04-09 (Legacy)

### Added

- Basic registry spoof functionality
- Manual package installation support
- Scheduled task for startup execution

---

## [1.0.0] - 2023-11-05

### Added

- Initial release of Galaxy Book Enabler
- Basic registry spoofing to identify as Samsung Galaxy Book3 Ultra
- Batch file for BIOS registry modifications
- Scheduled task for startup execution
- Manual package installation prompts
- Support for:
  - Samsung Continuity Service
  - Samsung Account
  - Samsung Cloud Assistant
  - Quick Share
  - Samsung Notes
  - Multi Control

**Known Issues:** No version tracking, no Wi-Fi compatibility detection, manual keyboard shortcut setup for AI Select, no update mechanism, installation path in user folder root.

---

## Roadmap

Here's what's planned for future versions:

- **Automatic update notifications** (v2.1.0)
  - Daily update checks
  - Windows toast notifications when updates available
  - One-click update from notification

- **Enhanced AI Select integration** (v2.2.0)
  - PowerShell wrapper for easier launching
  - Auto-register global hotkey without manual shortcut setup
  - Integration with Windows PowerToys (if installed)

- **Package manager** (v2.3.0)
  - Check which Samsung apps are installed
  - One-command install/uninstall for individual packages
  - Update all Samsung packages at once

- **Compatibility profiles** (v2.1.0)
  - Support for different Galaxy Book models (Book2, Book3, Book4)
  - Custom registry profiles for specific features
  - Profile switching without reinstallation

---

## Migration Guide

### Upgrading from v1.x to v2.x

**What changes:**

- New installation directory: `.galaxy-book-enabler` in your user folder
- Configuration now in JSON format
- New scheduled task name (same: "GalaxyBookEnabler")

**How to upgrade:**

1. Run the new installer - it will detect your v1.x installation
2. If you customized BIOS values in QS.bat, you'll be asked to preserve them
3. Choose option [1] to update
4. Old files will be cleaned up automatically
5. Your registry spoof settings are preserved (if you chose to keep them)

**Custom BIOS values:**
If you modified QS.bat with custom device names (e.g., different Galaxy Book model), the installer will:

- Detect your custom values automatically
- Ask if you want to preserve them
- Apply your custom values to the new installation
- Or use the default Galaxy Book3 Ultra profile

**Note:** Standard Galaxy Book3 Ultra values are used by default if no customization is detected.

---

## Breaking Changes

### v2.0.0

- Installation path changed from `GalaxyBookEnablerScript` to `.galaxy-book-enabler`
- Configuration format changed from none to JSON
- Batch file renamed from `QS.bat` to `GalaxyBookSpoof.bat`

**Impact:** Low - Automatic migration during update

---

## Version History

| Version | Release Date | Major Changes |
|---------|--------------|---------------|
| 2.0.0   | 2025-11-14   | Complete rewrite, Wi-Fi detection, AI Select helper |
| 1.0.0   | 2023-11-XX   | Initial release, basic functionality |

---

**Last Updated:** 2025-12-04

[unreleased]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v2.5.0...v3.0.0
[2.5.0]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v2.2.0...v2.4.0
[2.2.0]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v2.0.0...v2.2.0
[2.0.0]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v1.1.5...v2.0.0
[1.1.5]: https://github.com/Bananz0/GalaxyBookEnabler/compare/v1.0.0...v1.1.5
[1.0.0]: https://github.com/Bananz0/GalaxyBookEnabler/releases/tag/v1.0.0
