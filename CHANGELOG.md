# Changelog

All notable changes to Galaxy Book Enabler will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Configuration guides for "Extra Steps" apps (Phone, Find, Quick Search, Pass and Camera Share)
- Advanced AI Select launcher with auto-hotkey registration
- Differential package updates (only install new packages)
- Silent installation mode
- Export/import package selections

## [2.2.0] - 2025-11-15

### Added
- **Samsung MultiPoint Support** - Galaxy Buds multipoint connectivity
  - Works through Samsung Settings app (included in Core packages)
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

### Changed
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

### Technical
- Model database embedded directly in installer (no external files needed)
- Pattern analysis confirmed no algorithmic generation possible
- BIOS versions contain unpredictable build dates
- SKU codes use model-specific platform identifiers
- Lookup table required for accurate spoofing

## [2.0.0] - 2025-11-14

### Added
- **GitHub Actions workflow** - Automated release system
  - Automatic version number updates on release
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

### Improved
- Installation summary shows detailed package list with status colors
- User confirms package list before installation begins
- Better error handling for individual package failures
- Clearer distinction between working and non-working apps
- Help text explains what each profile includes

### Technical Improvements
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

### Known Issues
- No version tracking
- No Wi-Fi compatibility detection
- Manual keyboard shortcut setup for AI Select
- No update mechanism
- Installation path in user folder root

---

## Planned Features (Roadmap)

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

**Last Updated:** 2025-11-14