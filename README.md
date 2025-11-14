# Galaxy Book Enabler

> Enable Samsung Galaxy Book features on any Windows PC

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/Bananz0/GalaxyBookEnabler)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![CodeFactor](https://www.codefactor.io/repository/github/bananz0/galaxybookenabler/badge)](https://www.codefactor.io/repository/github/bananz0/galaxybookenabler)

## Overview

Galaxy Book Enabler spoofs your Windows PC as a Samsung Galaxy Book, unlocking access to Samsung's ecosystem apps like Quick Share, Multi Control, Samsung Notes, and more. The tool provides an intelligent installer with package filtering, Wi-Fi compatibility detection, and automated startup configuration.

## Feature
- **Smart Package Selection** - Choose from Core, Recommended, Full Experience, or custom package combinations
- **Wi-Fi Compatibility Check** - Automatically detects Intel Wi-Fi adapters and warns about Quick Share limitations
- **Automated Startup** - Registry spoof runs automatically on every boot
- **Professional Installer** - Clean, color-coded UI with progress tracking
- **Version Management** - Update detection and migration support
- **Easy Uninstall** - One-command removal with cleanu
## Quick Start

### One-Line Install (from GitHub)
```powershell
irm https://raw.githubusercontent.com/Bananz0/GalaxyBookEnabler/main/Install-GalaxyBookEnabler.ps1 | iex
```

### Manual Install
1. Download `Install-GalaxyBookEnabler.ps1`
2. Right-click PowerShell → Run as Administrator
3. Run: `.\Install-GalaxyBookEnabler.ps1`
4. Follow the interactive installer

### Uninstall
```powershell
.\Install-GalaxyBookEnabler.ps1 -Uninstall
```

## Package Profiles

### Core Only
Essential packages for basic Samsung ecosystem functionality:
- Samsung Account
- Samsung Settings + Runtime
- Samsung Cloud + Cloud Assistant
- Samsung Continuity Service
- Samsung Intelligence Service

### Recommended ⭐
Core packages + all fully working Samsung apps:
- Quick Share (requires Intel Wi-Fi for best results)
- Galaxy Book Experience
- Samsung Notes
- Multi Control
- Samsung Gallery
- Samsung Studio + Studio for Gallery
- Samsung Screen Recorder
- Samsung Flow
- SmartThings
- Galaxy Buds Manager
- Samsung Device Care
- Samsung Parental Controls
- AI Select
- Nearby Devices
- Storage Share
- Second Screen
- Live Wallpaper
- Galaxy Book Smart Switch

### Full Experience
Recommended + apps requiring extra configuration:
- Samsung Phone (needs additional setup)
- Samsung Find (needs additional setup)
- Quick Search (needs additional setup)
- Samsung Pass (needs additional setup)

### Everything
All packages including non-functional ones:
- ⚠️ Samsung Recovery (won't work)
- ⚠️ Samsung Update (won't work)

### Custom Selection
Pick individual packages by category with detailed descriptions and warnings.

## 📋 Package Compatibility Matrix

| Package | Status | Intel Wi-Fi Required | Notes |
|---------|--------|---------------------|-------|
| Samsung Account | ✅ Working | No | Required |
| Samsung Settings | ✅ Working | No | Required |
| Samsung Settings Runtime | ✅ Working | No | Required |
| Samsung Cloud | ✅ Working | No | Required |
| Samsung Cloud Assistant | ✅ Working | No | Required |
| Samsung Continuity Service | ✅ Working | No | Required |
| Samsung Intelligence Service | ✅ Working | No | Required (AI features) |
| Quick Share | ✅ Working | **Yes** | Limited on non-Intel |
| Galaxy Book Experience | ✅ Working | No | Recommended |
| Samsung Notes | ✅ Working | No | - |
| Multi Control | ✅ Working | No | - |
| Samsung Gallery | ✅ Working | No | - |
| Samsung Studio | ✅ Working | No | - |
| Samsung Studio for Gallery | ✅ Working | No | - |
| Samsung Screen Recorder | ✅ Working | No | - |
| Samsung Flow | ✅ Working | No | - |
| SmartThings | ✅ Working | No | - |
| Galaxy Buds | ✅ Working | No | - |
| Samsung Device Care | ✅ Working | No | - |
| Samsung Parental Controls | ✅ Working | No | - |
| AI Select | ✅ Working | No | - |
| Nearby Devices | ✅ Working | No | - |
| Storage Share | ✅ Working | No | - |
| Second Screen | ✅ Working | No | - |
| Live Wallpaper | ✅ Working | No | - |
| Galaxy Book Smart Switch | ✅ Working | No | - |
| Samsung Phone | ⚠️ Extra Steps | No | Configuration required |
| Samsung Find | ⚠️ Extra Steps | No | Configuration required |
| Quick Search | ⚠️ Extra Steps | No | Configuration required |
| Samsung Pass | ⚠️ Extra Steps | No | Configuration required |
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

## ⚠️ Wi-Fi Compatibility

**Quick Share** is designed to work with Intel Wi-Fi adapters. While the app may install on systems with other Wi-Fi adapters, functionality may be limited or non-existent.

### Intel Wi-Fi (Full Compatibility)
- Intel Wi-Fi 6/6E adapters
- Intel Wi-Fi 5 adapters
- Intel Wireless-AC adapters

### Non-Intel Wi-Fi (Limited/No Support) 
- Realtek adapters
- MediaTek adapters
- Qualcomm adapters
- Broadcom adapters

### Alternative for Non-Intel Users
If you don't have an Intel Wi-Fi adapter, consider **Google Nearby Share** as an alternative:
- Works with any Wi-Fi adapter
- Similar file-sharing functionality
- Cross-platform support (Windows, Android, ChromeOS)
- Download: [Google Nearby Share](https://www.android.com/better-together/nearby-share-app/)

## AI Select (Smart Select)

AI Select is Samsung's intelligent selection tool. The installer can create a Desktop shortcut for easy access.

### Keyboard Shortcut Setup
1. Find the "AI Select.lnk" on your Desktop
2. Right-click → Properties
3. Click in the "Shortcut key" field
4. Press your desired key combination (e.g., Ctrl+Alt+S)
5. Click OK

### Manual Launch Command
```powershell
explorer.exe shell:AppsFolder\SAMSUNGELECTRONICSCO.LTD.SmartSelect_3c1yjt4zspk6g!App
```

## 🔧 How It Works

1. **Registry Spoof**: Modifies system registry to identify as "Samsung Galaxy Book3 Ultra"
2. **Startup Task**: Creates a scheduled task that runs the spoof on every boot
3. **Package Installation**: Installs selected Samsung apps from Microsoft Store
4. **Configuration**: Sets up shortcuts and configuration files

### Modified Registry Keys
```
HKLM\HARDWARE\DESCRIPTION\System\BIOS\BaseBoardManufacturer
HKLM\HARDWARE\DESCRIPTION\System\BIOS\BaseBoardProduct  
HKLM\HARDWARE\DESCRIPTION\System\BIOS\SystemProductName
HKLM\HARDWARE\DESCRIPTION\System\BIOS\SystemFamily
HKLM\HARDWARE\DESCRIPTION\System\BIOS\SystemManufacturer
```

## 📖 Installation Guide

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
   - Generates registry spoof script
   - Saves configuration file

4. **Startup Task Creation**
   - Creates scheduled task "GalaxyBookEnabler"
   - Runs automatically on system startup
   - Uses SYSTEM privileges for registry access

5. **AI Select Configuration (Optional)**
   - Create desktop shortcut
   - Set up keyboard shortcut manually

6. **Package Selection**
   - Choose installation profile
   - Review package list
   - Confirm installation

7. **Apply Registry Spoof**
   - Immediate spoof application
   - No reboot required for testing

8. **Reboot**
   - Restart your PC for full activation
   - Sign into Samsung Account
   - Configure Samsung apps

## Troubleshooting

### Quick Share Not Working
- **Check Wi-Fi adapter**: Quick Share requires Intel Wi-Fi
- **Verify installation**: Check if app is properly installed
- **Sign in**: Ensure you're signed into Samsung Account
- **Alternative**: Use Google Nearby Share for non-Intel adapters

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
A: Samsung designed Quick Share to work specifically with Intel's Wi-Fi Direct implementation.

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

- **Quick Share**: Requires Intel Wi-Fi adapter for full functionality
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

<p align="center">Made with ❤️ for the Samsung ecosystem enthusiasts</p>


