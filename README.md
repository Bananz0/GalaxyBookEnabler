# Galaxy Book Enabler

> Enable Samsung Galaxy Book features on any Windows PC

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/Bananz0/GalaxyBookEnabler)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D4.svg?logo=windows11)](https://www.microsoft.com/windows/windows-11)
[![SSSE Support](https://img.shields.io/badge/SSSE-Integrated-purple.svg)](https://github.com/Bananz0/GalaxyBookEnabler)
[![CodeFactor](https://www.codefactor.io/repository/github/bananz0/galaxybookenabler/badge)](https://www.codefactor.io/repository/github/bananz0/galaxybookenabler)
![View Count](https://komarev.com/ghpvc/?username=Bananz0&repo=GalaxyBookEnabler&color=brightgreen)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/bananz0/GalaxyBookEnabler/total)

> 🎉 A big thank you to [@Hydro3ia](https://github.com/Hydro3ia), [@systemsrethinking](https://github.com/systemsrethinking) and [@intini](https://github.com/intini) for sponsoring us! ❤️

## Overview

Galaxy Book Enabler spoofs your Windows PC as a Samsung Galaxy Book, unlocking access to Samsung's ecosystem apps like Quick Share, Multi Control, Samsung Notes, and more. The tool provides an intelligent installer with package filtering, Wi-Fi compatibility detection, and automated startup configuration.

> 📋 **See what's new:** [Changelog](CHANGELOG.md) | [Releases](https://github.com/Bananz0/GalaxyBookEnabler/releases)

## Features

- **21 Galaxy Book Models** - Choose from authentic hardware profiles (Galaxy Book3/4/5, Pro, Ultra, 360)
- **Samsung MultiPoint Support** - Connect Galaxy Buds to multiple devices seamlessly via Samsung Settings app
- **Auto-Elevation** - Automatically requests admin rights (supports gsudo and Windows 11 native sudo)
- **Smart Package Selection** - Choose from Core, Recommended, Full Experience, or custom package combinations
- **Wi-Fi Compatibility Check** - Automatically detects Intel Wi-Fi adapters and warns about Quick Share limitations
- **System Support Engine (Advanced)** - Optional experimental feature for enhanced Samsung integration (Windows 11 only)
- **Automated Startup** - Registry spoof runs automatically on every boot
- **Professional Installer** - Clean, color-coded UI with progress tracking
- **Test Mode** - Simulate installation without making changes to your system
- **Version Management** - Update detection and migration support
- **Easy Uninstall** - One-command removal with cleanup
- **Advanced Reset & Repair** - Built-in tools to fix app issues, clear caches, and repair permissions
- **Nuke Mode** - Optional destructive uninstall to wipe all Samsung app data

## 📋 Requirements

### ⚠️ IMPORTANT: This script requires PowerShell 7.0 or later

Windows comes with PowerShell 5.1 by default, which is **NOT compatible**. You must install PowerShell 7:

```powershell
# Install PowerShell 7 (one-time setup)
winget install Microsoft.PowerShell
```

**Note:** If this is your first time using `winget`, you may need to run `winget list` first to accept the source agreements. The command may appear to stall without this step.

Or download from: <https://aka.ms/powershell>

After installing, use `pwsh` (PowerShell 7) instead of `powershell` (Windows PowerShell 5.1).

## Quick Start

### One-Line Install (from GitHub)

```powershell
# Run in PowerShell 7 (pwsh)
irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
```

*The installer will automatically request administrator privileges if needed.*

### Uninstall Options

When running the installer on an existing installation, you have granular uninstall options:

- **Reinstall (nuke + fresh install)**: Completely removes everything (preserving BIOS config), then performs a clean installation
- **Uninstall everything**: Removes all Samsung apps, services, scheduled task, and configuration
  - **Nuke Mode**: Optionally delete ALL Samsung app data (caches, settings, databases) during uninstall
- **Uninstall apps only**: Removes all installed Samsung apps while keeping services and scheduled task
- **Uninstall services only**: Removes scheduled task and Samsung services while keeping apps installed

**With gsudo (recommended for seamless elevation):**

```powershell
# Install gsudo first (one-time)
winget install gerardog.gsudo

# Then install Galaxy Book Enabler with automatic elevation
irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | gsudo pwsh
```

### Manual Install

1. Download `Install-GalaxyBookEnabler.ps1`
2. Run: `.\Install-GalaxyBookEnabler.ps1`
3. Accept UAC prompt when requested
4. Follow the interactive installer

*No need to manually "Run as Administrator" - the script handles elevation automatically!*

### Uninstall

```powershell
.\Install-GalaxyBookEnabler.ps1 -Uninstall
```

### Test Mode (No Changes Applied)

```powershell
.\Install-GalaxyBookEnabler.ps1 -TestMode
```

Test mode simulates the entire installation without making any actual changes. Perfect for testing or reviewing what the installer will do before committing.

## 🛠️ Reset & Repair Tools

The installer includes a comprehensive suite of tools to fix common issues with Samsung apps. Select **"Reset/Repair Samsung Apps"** from the main menu (or uninstall menu) to access:

- **Diagnostics**: Checks installed packages, device data files, and databases
- **Soft Reset**: Clears app caches and temporary files (preserves login)
- **Hard Reset**: Clears caches, device data, and settings (requires re-login)
- **Clear Authentication**: Removes Samsung Account database and credentials
- **Repair Permissions**: Fixes ACLs on app folders
- **Re-register Apps**: Re-registers AppX manifests to fix launch issues
- **Factory Reset**: Completely wipes ALL Samsung data (credentials, devices, DBs, settings)

## Package Profiles

### Core Only

Essential packages for basic Samsung ecosystem functionality:

- Samsung Account
- Samsung Settings + Runtime
- Samsung Cloud
- Knox Matrix for Windows
- Samsung Continuity Service
- Samsung Intelligence Service
- Samsung Bluetooth Sync
- Galaxy Book Experience

### Recommended ⭐

Core packages + all fully working Samsung apps:

- Quick Share (requires Intel Wi-Fi for best results)
- Samsung Notes
- Multi Control
- Samsung Gallery
- Samsung Studio + Studio for Gallery
- Samsung Screen Recorder
- Samsung Flow
- SmartThings
- Galaxy Buds Manager
- Samsung Parental Controls
- AI Select
- Nearby Devices
- Storage Share
- Second Screen
- Live Wallpaper
- Galaxy Book Smart Switch
- Samsung Pass

### Full Experience

Recommended + apps requiring extra configuration:

- Samsung Phone (needs additional setup)
- Samsung Find (needs additional setup)
- Quick Search (needs additional setup)

### Everything

All packages including non-functional ones:

- ⚠️ Samsung Recovery (won't work)
- ⚠️ Samsung Update (won't work)

### Custom Selection

Pick individual packages by category with detailed descriptions and warnings.

## 📋 Package Compatibility Matrix

| Package | Status | Intel Wi-Fi AX + BT Required | Notes |
|---------|--------|------------------------------|-------|
| Samsung Account | ✅ Working | No | Required |
| Samsung Settings | ✅ Working | No | Required |
| Samsung Settings Runtime | ✅ Working | No | Required |
| Samsung Cloud Assistant | ✅ Working | No | Required |
| Samsung Continuity Service | ✅ Working | No | Required |
| Samsung Intelligence Service | ✅ Working | No | Required (AI features) |
| Samsung Bluetooth Sync | ✅ Working | No | Required |
| Galaxy Book Experience | ✅ Working | No | Core (app catalog) |
| Quick Share | ✅ Working | **Yes** | Requires Intel Wi-Fi AX + Intel Bluetooth |
| Camera Share | ✅ Working |**Yes**| Requires Intel Wi-Fi AX + Intel Bluetooth |
| Samsung Notes | ✅ Working | No | - |
| Multi Control | ⚠️ Limited | **Yes** | Jittery on Wi-Fi 6/6E, not working on Wi-Fi 5 |
| Samsung Gallery | ✅ Working | No | - |
| Samsung Studio | ✅ Working | No | - |
| Samsung Studio for Gallery | ✅ Working | No | - |
| Samsung Screen Recorder | ⚠️ Working | No | Shows "optimized for Galaxy Books" |
| Samsung Flow | ✅ Working | No | - |
| SmartThings | ✅ Working | No | - |
| Galaxy Buds | ✅ Working | No | - |
| Samsung Parental Controls | ✅ Working | No | - |
| AI Select | ✅ Working | No | - |
| Nearby Devices | ✅ Working | No | - |
| Storage Share | ✅ Working | No | - |
| Second Screen | ⚠️ Limited | **Yes** | Works on Wi-Fi 6/6E/7 (AX/BE), not on Wi-Fi 5 (AC) |
| Live Wallpaper | ✅ Working | No | - |
| Galaxy Book Smart Switch | ✅ Working | No | - |
| Samsung Pass | ✅ Working | No | - |
| Samsung Device Care | ⚠️ Extra Steps | No | May not function properly |
| Samsung Phone | ⚠️ Extra Steps | No | Configuration required |
| Samsung Find | ⚠️ Extra Steps | No | Configuration required |
| Quick Search | ⚠️ Extra Steps | No | Configuration required |
| Samsung Recovery | ❌ Not Working | No | Requires genuine hardware |
| Samsung Update | ❌ Not Working | No | Requires genuine hardware |

## 💻 System Requirements

### Required

- Windows 10/11 (64-bit)
- PowerShell 7.0 or later
- Administrator privileges
- Active Internet connection

### Recommended for Full Experience

- Intel Wi-Fi adapter (for Quick Share)
- 8GB RAM or more
- Samsung account

### System Support Engine (Optional Advanced Feature)

- **Windows 11 (Build 22000+)** - Required
- **x64 architecture** - ARM not supported
- **Advanced users only** - Involves binary patching and service creation
- **Experimental** - May cause system instability or trigger antivirus warnings

## ⚠️ Wi-Fi & Bluetooth Compatibility

Samsung apps require **Intel Wi-Fi** and **Intel Bluetooth** adapters for full wireless features. Compatibility varies by Wi-Fi generation:

### Wi-Fi Compatibility by Generation

| Generation | Adapters | Quick Share | Multi Control | Second Screen | Camera Share | Storage Share |
|------------|----------|-------------|---------------|---------------|--------------|---------------|
| **Wi-Fi 7 (BE)** | BE200, BE201, BE202 | ✅ Full | ❓ Unknown | ✅ Full | ✅ Full | ✅ Full |
| **Wi-Fi 6/6E (AX)** | AX210, AX211, AX201, AX200 | ✅ Full | ⚠️ Jittery | ✅ Full | ✅ Full | ✅ Full |
| **Wi-Fi 5 (AC)** | AC 9260, AC 9560, AC 8265, AC 8260 | ✅ Works | ❌ Not Working | ❌ Not Working | ✅ Works | ✅ Works |
| **Non-Intel** | Realtek, MediaTek, Qualcomm, Broadcom | ❌ | ❌ | ❌ | ❌ | ❌ |

### Wi-Fi 7 (BE) - Full Compatibility ✅

- Intel Wi-Fi 7 BE200
- Intel Wi-Fi 7 BE201  
- Intel Wi-Fi 7 BE202

### Wi-Fi 6/6E (AX) - Full Compatibility ✅

- Intel Wi-Fi 6E AX210/AX211
- Intel Wi-Fi 6 AX201/AX200

### Wi-Fi 5 (AC) - Limited Compatibility ⚠️

- Intel Wireless-AC 9260/9560
- Intel Wireless-AC 8265/8260

**AC Limitations:**

- Multi Control does not work
- Second Screen does not work (WiFi Direct uses 802.11n - Samsung limitation)
- May show "A software or driver update is required" error in Quick Share

### Non-Intel Wi-Fi (Not Working) ❌

- Realtek adapters
- MediaTek adapters
- Qualcomm adapters
- Broadcom adapters

### Intel Bluetooth (Required) ✅

All wireless features also require an **Intel Bluetooth radio** (not just Wi-Fi). Third-party Bluetooth adapters (USB dongles, etc.) will cause features to fail with unhelpful errors.

### Alternative for Non-Intel Users

If you don't have Intel Wi-Fi **and** Intel Bluetooth, consider **Google Nearby Share** as an alternative:

- Works with any Wi-Fi adapter
- Similar file-sharing functionality
- Cross-platform support (Windows, Android, ChromeOS)
- Download: [Google Nearby Share](https://www.android.com/better-together/nearby-share-app/)

## AI Select (Smart Select)

AI Select is Samsung's intelligent selection tool. The installer creates launcher scripts in `C:\GalaxyBook\` for easy hotkey binding.

### Launch URI

```shell
shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App
```

### Method 1: PowerToys URI (Recommended - Fastest)

This method launches AI Select instantly with a single key press:

1. Install [PowerToys](https://aka.ms/getPowerToys) from Microsoft Store
2. Open PowerToys → Keyboard Manager
3. **Remap a key** (e.g., `Right Alt` → `Win+Ctrl+Alt+S`)
   - This creates an unused intermediate shortcut
4. **Remap a shortcut** → `Win+Ctrl+Alt+S` → **Open URI**
   - URI: `shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App`
5. Press Right Alt to instantly launch AI Select!

### Method 2: PowerToys Run Program

1. Install PowerToys
2. Keyboard Manager → Remap a shortcut
3. Set shortcut (e.g., `Ctrl+Shift+S`) → Action: **Run Program**
4. Program: `powershell.exe`
5. Args: `-WindowStyle Hidden -File "C:\GalaxyBook\AISelect.ps1"`

### Method 3: AutoHotkey (AHK)

For advanced users who prefer AutoHotkey:

```autohotkey
; AI Select launcher - save as AISelect.ahk
#Requires AutoHotkey v2.0

; Press Right Alt to launch AI Select
RAlt::Run "shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App"
```

### Method 4: Desktop Shortcut (Standard)

1. Find the "AI Select.lnk" on your Desktop (created by installer)
2. Right-click → Properties
3. Click in the "Shortcut key" field
4. Press your desired key combination (e.g., Ctrl+Alt+S)
5. Click OK

> **Note:** Desktop shortcuts use explorer.exe which adds slight overhead. PowerToys URI or AHK methods are faster.

## 🔧 How It Works

1. **Registry Spoof**: Modifies system registry to identify as "Samsung Galaxy Book3 Ultra"
2. **Startup Task**: Creates a scheduled task that runs the spoof on every boot
3. **Package Installation**: Installs selected Samsung apps from Microsoft Store
4. **Configuration**: Sets up shortcuts and configuration files

**Available Models** (21 authentic hardware profiles):

| Model   | Family                              | Gen  |
|---------|-------------------------------------|------|
| 960XHA  | Galaxy Book5 Pro                    | 2025 |
| 940XHA  | Galaxy Book5 Pro                    | 2025 |
| 960QHA  | Galaxy Book5 Pro 360                | 2025 |
| 750QHA  | Galaxy Book5 360                    | 2025 |
| 960XGL  | Galaxy Book4 Ultra                  | 2024 |
| 960XGK  | Galaxy Book4 Pro                    | 2024 |
| 940XGK  | Galaxy Book4 Pro                    | 2024 |
| 960QGK  | Galaxy Book4 Pro 360                | 2024 |
| 750XGK  | Galaxy Book4                        | 2024 |
| 750XGL  | Galaxy Book4                        | 2024 |
| 750QGK  | Galaxy Book4 360                    | 2024 |
| 960XFH  | Galaxy Book3 Ultra                  | 2023 |
| 960XFG  | Galaxy Book3 Pro                    | 2023 |
| 960QFG  | Galaxy Book3 Pro 360                | 2023 |
| 750XFG  | Galaxy Book3                        | 2023 |
| 750XFH  | Galaxy Book3                        | 2023 |
| 730QFG  | Galaxy Book3 360                    | 2023 |
| 950XGK  | Galaxy Book2 Pro Special Edition    | 2022 |
| 930XDB  | Galaxy Book Series                  | 2021 |
| 935QDC  | Galaxy Book Series                  | 2021 |
| 930SBE  | Notebook 9 Series                   | 2020 |

**How Model Selection Works:**

1. During installation, you'll see a categorized menu of all 21 models
2. Models are grouped by generation (Book5 > Book4 > Book3 > Book2)
3. Each model has authentic BIOS/DMI values extracted from real hardware
4. Select your preferred model to spoof
5. All 11 registry values are automatically configured

**Example Selection:**

```preview
========================================
  Select Galaxy Book Model to Spoof
========================================

Available Models:

  Galaxy Book5:
     1. 960XHA - Galaxy Book5 Pro
     2. 940XHA - Galaxy Book5 Pro
     3. 960QHA - Galaxy Book5 Pro 360
     4. 750QHA - Galaxy Book5 360

  Galaxy Book4:
     5. 960XGL - Galaxy Book4 Ultra
     6. 960XGK - Galaxy Book4 Pro
     7. 940XGK - Galaxy Book4 Pro
     [... more models ...]

Enter model number (1-22): 5

✓ Selected: 960XGL - Galaxy Book4 Ultra
  Product: 960XGL
  BIOS: P08ALX.400.250306.05
```

## 📖 Installation Guide

### Step-by-Step

1. **Run Installer as Administrator**

   ```powershell
   .\Install-GalaxyBookEnabler.ps1
   ```

2. **System Compatibility Check**
   - Installer detects your Wi-Fi adapter
   - Shows compatibility status for Quick Share

3. **File Setup**
   - Creates installation directory: `%USERPROFILE%\.galaxy-book-enabler`
   - Detects legacy v1.x installation (if present)
   - **Preserves custom BIOS values** from old QS.bat (Galaxy Book4 Ultra, GB4 Pro, etc.)
   - Generates registry spoof script with preserved or default values
   - Cleans up old installation files
   - Saves configuration file

4. **Startup Task Creation**
   - Creates scheduled task "GalaxyBookEnabler"
   - Runs automatically on system startup
   - Uses SYSTEM privileges for registry access

5. **AI Select Configuration (Optional)**
   - Create desktop shortcut
   - Set up keyboard shortcut manually

6. **System Support Engine (Optional/Advanced)**
   - **Windows 11 only** - Experimental feature
   - Downloads Samsung System Support Service CAB from Microsoft Update Catalog
   - Extracts and patches binary executable
   - Installs to `C:\GalaxyBook`
   - Creates `GBeSupportService` Windows service (LocalSystem, Auto startup)
   - Installs driver automatically via pnputil
   - **Use with caution** - May trigger antivirus, requires advanced troubleshooting

7. **Package Selection**
   - Choose installation profile
   - Review package list
   - Confirm installation

8. **Apply Registry Spoof**
   - Immediate spoof application
   - No reboot required for testing

9. **Launch Galaxy Book Experience**
   - Automatically opens after installation
   - Explore available Samsung apps
   - Access app catalog at any time

10. **Reboot**

- Restart your PC for full activation
- Sign into Samsung Account
- Configure Samsung apps

## Troubleshooting

### System Support Engine Issues

- **Service not starting**: Check Event Viewer for errors
- **Antivirus blocking**: Add `C:\GalaxyBook` to exclusions
- **Driver not installing**: Manually install via Device Manager
- **Samsung Settings not appearing**: Wait 5-10 minutes after reboot for background installation
- **Service verification**: Run `Get-Service 'GBeSupportService'` in PowerShell
- **Only for Windows 11**: Feature requires Windows 11 Build 22000 or higher

### Quick Share Not Working

- **Check Wi-Fi adapter type**: Quick Share requires **Intel Wi-Fi AX** (not AC)
- **Check Bluetooth adapter**: Quick Share requires **Intel Bluetooth** radio
- **AC card error**: If you see "A software or driver update is required", your Intel AC card is not supported
- **AC9560 confirmed working**: Intel AC9560 has been tested and works with Quick Share
- **Third-party Bluetooth**: USB Bluetooth dongles or non-Intel Bluetooth will cause failures
- **Verify installation**: Check if app is properly installed
- **Sign in**: Ensure you're signed into Samsung Account
- **Alternative**: Use Google Nearby Share for non-Intel hardware

### Apps Not Appearing

- **Reboot required**: Some apps need a system restart
- **Registry spoof**: Verify scheduled task is running
- **Manual install**: Try installing apps individually from Microsoft Store

### Scheduled Task Not Running

- **Check Task Scheduler**: Look for "GalaxyBookEnabler" task
- **Permissions**: Task must run as SYSTEM with highest privileges
- **Reinstall**: Run installer again to recreate task

### Registry Spoof Not Persistent

- **Verify startup task**: Check if task is enabled in Task Scheduler
- **Run manually**: Execute `%USERPROFILE%\.galaxy-book-enabler\GalaxyBookSpoof.bat`
- **Check logs**: Review Task Scheduler history

### Installation Fails

- **Admin rights**: Must run PowerShell as Administrator
- **Winget issues**: Update winget: `winget upgrade --all`
- **Network**: Verify internet connection for package downloads
- **Antivirus**: Temporarily disable if blocking installation

## FAQ

**Q: Is this safe to use?**
A: Yes, it only modifies volatile registry keys that reset on reboot. The scheduled task ensures the spoof runs automatically.

**Q: Will this void my warranty?**
A: This doesn't modify hardware or firmware. It only changes registry values.

**Q: Can I use this on a real Samsung Galaxy Book?**
A: There's no need - these features already work on genuine Galaxy Books.

**Q: Why does Quick Share need Intel Wi-Fi?**
A: Samsung designed Quick Share to work specifically with Intel's Wi-Fi Direct implementation. You need both **Intel Wi-Fi AX** (not AC) and **Intel Bluetooth** radios. Third-party Bluetooth adapters or Intel AC cards won't work.

**Q: Can I uninstall specific packages later?**
A: Yes, uninstall Samsung apps through Windows Settings → Apps like any other app.

**Q: Do I need to keep the installer after installation?**
A: No, but keep it if you want to update or uninstall later.

**Q: Will this work on ARM Windows devices?**
A: Not tested. The script is designed for x64 Windows systems.

**Q: Can I customize the spoofed device model?**
A: Advanced users can edit the batch file in the installation directory.

## Updating

### Check for Updates

The installer detects if you have an older version installed and offers to update.

### Manual Update

```powershell
# Download latest version
irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
```

### What Gets Updated

- Registry spoof script
- Scheduled task configuration
- Package definitions
- Helper functions

## Uninstallation

### Complete Removal

```powershell
.\Install-GalaxyBookEnabler.ps1 -Uninstall
```

### What Gets Removed

- Scheduled task
- Installation directory (`%USERPROFILE%\.galaxy-book-enabler`)
- Desktop shortcuts (if created)

### What Stays

- Installed Samsung apps (uninstall manually if desired)
- Registry spoof (clears after reboot)

### Manual Cleanup (if needed)

```powershell
# Remove scheduled task
Unregister-ScheduledTask -TaskName "GalaxyBookEnabler" -Confirm:$false

# Remove installation folder
Remove-Item "$env:USERPROFILE\.galaxy-book-enabler" -Recurse -Force

# Reboot to clear registry spoof
Restart-Computer
```

## Privacy & Security

- **No telemetry**: Script doesn't send any data
- **Local only**: All operations are local to your PC
- **Open source**: Full code is available for review
- **No network access**: Script doesn't make outbound connections (except winget for packages)
- **Reversible**: Complete uninstall available

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## Known Limitations

- **Quick Share**: Requires Intel Wi-Fi AX adapter **AND** Intel Bluetooth radio (Some AC cards don't work)
- **System Support Engine**: Windows 11 only, experimental, may cause instability
- **Samsung Recovery**: Will never work (requires genuine Samsung hardware)
- **Samsung Update**: Will never work (requires genuine Samsung hardware)
- **Some features**: May require additional Samsung account setup
- **Registry reset**: Spoof clears on reboot (handled by scheduled task)

## Reporting Issues

When reporting issues, please include:

- Windows version
- PowerShell version (`$PSVersionTable`)
- Wi-Fi adapter model
- Error messages or screenshots
- Steps to reproduce

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Original script by [@obrobrio2000](https://github.com/obrobrio2000)
- Enhanced and maintained by [@Bananz0](https://github.com/Bananz0)
- Inspired by [eGPUae](https://github.com/bananz0/eGPUae) architecture

## Supporters

A huge thanks to the following people for supporting this project ❤️ :

- **@Hydro3ia**
- **@systemsrethinking**
- **@intini**

### Bluetooth Device Removal

- [@m-a-x-s-e-e-l-i-g](https://github.com/m-a-x-s-e-e-l-i-g) - [powerBTremover (fork)](https://github.com/m-a-x-s-e-e-l-i-g/powerBTremover)
- [@RS-DU34](https://github.com/RS-DU34) - [powerBTremover (original)](https://github.com/RS-DU34/powerBTremover)

## Disclaimer

**IMPORTANT**:

- This tool is for educational and personal use only
- Not affiliated with or endorsed by Samsung Electronics
- Use at your own risk
- Author is not responsible for any issues or damages
- Samsung may update their apps to detect or block this method
- Features may break with future Samsung app updates

## Links

- [GitHub Repository](https://github.com/Bananz0/GalaxyBookEnabler)
- [Issues & Bug Reports](https://github.com/Bananz0/GalaxyBookEnabler/issues)
- [Changelog](CHANGELOG.md)
- [Google Nearby Share Alternative](https://www.android.com/better-together/nearby-share-app/)

---

> Made with ❤️ for the Samsung ecosystem enthusiasts