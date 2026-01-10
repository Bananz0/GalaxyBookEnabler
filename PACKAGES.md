# Samsung Package Reference

Complete list of Samsung apps available through Galaxy Book Enabler.

## Package Categories

### Core Packages (Required)

These packages are essential for Samsung ecosystem functionality and are auto-installed in all profiles.

| Package | Store ID | Description |
|---------|----------|-------------|
| Samsung Account | 9P98T77876KZ | Authentication for Samsung ecosystem |
| Samsung Settings | 9P2TBWSHK6HJ | Central configuration hub |
| Samsung Settings Runtime | 9NL68DVFP841 | Required runtime for Settings |
| Samsung Cloud | 9NFWHCHM52HQ | Cloud storage and sync |
| Knox Matrix for Windows | 9NJRV1DT8N79 | Samsung Knox security synchronization |
| Samsung Continuity Service | 9NGW9K44GQ5F | Cross-device continuity |
| Samsung Intelligence Service | 9NS0SHL4PQL9 | Galaxy AI features and AI Select support |
| Samsung Bluetooth Sync | 9NJNNJTTFL45 | Bluetooth device synchronization |
| Galaxy Book Experience | 9P7QF37HPMGX | Enhanced Galaxy Book features (shows available Samsung apps) |

---

## Recommended Packages (Most Working)

### Connectivity

| Package | Store ID | Intel Wi-Fi Required | Description |
|---------|----------|---------------------|-------------|
| Quick Share | 9PCTGDFXVZLJ | ✅ Yes | Fast file sharing between devices |
| Camera Share | 9NPCS7FN6VB9 | ✅ Yes | Use phone camera with PC apps |
| Storage Share | 9MVNW0XH7HS5 | ✅ Yes | Share storage between devices |
| Multi Control | 9N3L4FZ03Q99 | ✅ Yes | Control devices with one keyboard/mouse. **⚠️ Under Investigation** - works intermittently on all Intel Wi-Fi, not working reliably |
| Samsung Flow | 9NBLGGH5GB0M | ❌ No | Phone-PC integration |
| Nearby Devices | 9PHL04NJNT67 | ❌ No | Manage and connect to nearby Samsung devices |
| Second Screen | 9PLTXW5DX5KB | ✅ Yes | Use tablet as secondary display. Works on Wi-Fi 6/6E/7, not on Wi-Fi 5 |

> **Wi-Fi Compatibility Note:**
>
> **Supported Intel Products:**
> - **Wi-Fi 7 (BE200, BE201, BE202)**: Full compatibility
> - **Wi-Fi 6E (AX210, AX211, AX411)**: Full compatibility
> - **Wi-Fi 6 (AX200, AX201)**: Full compatibility
> - **Wi-Fi 5 / Wireless-AC 9000 Series (9260, 9560)**: Quick Share, Camera Share, Storage Share work. Multi Control and Second Screen do not work.
> - **Wi-Fi 5 / Wireless-AC 8000 Series (8265, 8260)**: Same as 9000 series
>
> **Not Tested / May Not Work:**
> - **Wireless-AC 7000 Series (7265, 7260)**: Legacy adapters, untested
> - **Wireless-AC 3000 Series (3168, 3165)**: Legacy adapters, untested
> - These older adapters may not work with outdated drivers (e.g., Windows 8.1 drivers from 2020)
>
> **Multi Control Status**: Currently under investigation. Works intermittently on all Intel Wi-Fi generations but not reliably.
>
> All wireless features also require **Intel Bluetooth**

### Productivity
| Package | Store ID | Description | Notes |
|---------|----------|-------------|-------|
| Samsung Notes | 9NBLGGH43VHV | Note-taking with stylus support | |
| AI Select | 9PM11FHJQLZ4 | Smart screenshot tool with text extraction and AI features | |
| Second Screen | 9PLTXW5DX5KB | Use tablet as secondary display | |

### Media
| Package | Store ID | Description |
|---------|----------|-------------|
| Samsung Gallery | 9NBLGGH4N9R9 | Photo/video gallery with cloud sync |

### Accessories
| Package | Store ID | Description |
|---------|----------|-------------|
| Galaxy Buds | 9NHTLWTKFZNB | Galaxy Buds management and settings |

### Security
| Package | Store ID | Description | Notes |
|---------|----------|-------------|-------|
| Samsung Pass | 9MVWDZ5KX9LH | Password manager with biometric auth | ⚠️ Untested on non-Samsung devices |

---

## Recommended Plus Packages (Additional Working Apps)

### Media
| Package | Store ID | Description |
|---------|----------|-------------|
| Samsung Studio | 9P312B4TZFFH | Photo and video editing suite |
| Samsung Studio for Gallery | 9NND8BT5WFC5 | Gallery-integrated editing tools |
| Live Wallpaper | 9N1G7F25FXCB | Animated wallpapers |

### Productivity
| Package | Store ID | Description | Notes |
|---------|----------|-------------|-------|
| Samsung Screen Recorder | 9P5025MM7WDT | Screen recording with annotations | Shows "optimized for Galaxy Books" message but works normally |

### Connectivity
| Package | Store ID | Description |
|---------|----------|-------------|
| Samsung Flow | 9NBLGGH5GB0M | Phone-PC integration features |

### Smart Home
| Package | Store ID | Description |
|---------|----------|-------------|
| SmartThings | 9N3ZBH5V7HX6 | Control SmartThings devices |

### Security
| Package | Store ID | Description |
|---------|----------|-------------|
| Samsung Parental Controls | 9N5GWJTCZKGS | Manage children's device usage |

### Utilities
| Package | Store ID | Description |
|---------|----------|-------------|
| Galaxy Book Smart Switch | 9PJ0J9KQWCLB | Transfer data to new Galaxy Book |

---

## Extra Steps Required

These packages install successfully but require additional configuration to function properly.

| Package | Store ID | Description | Notes |
|---------|----------|-------------|-------|
| Samsung Device Care | 9NBLGGH4XDV0 | Device optimization and diagnostics | Requires additional setup to function |
| Samsung Phone | 9MWJXXLCHBGK | Phone app integration | Additional setup required |
| Samsung Find | 9MWD59CZJ1RN | Find your devices | Additional setup required |
| Quick Search | 9N092440192Z | System-wide search | Additional setup required |

> **Note**: Configuration guides for these apps will be added in future updates.

---

## Non-Working Packages

These packages will NOT work on non-Samsung devices.

| Package | Store ID | Description | Why It Doesn't Work |
|---------|----------|-------------|---------------------|
| Samsung Recovery | 9NBFVH4X67LF | Factory reset and recovery | Requires genuine Samsung firmware |
| Samsung Update | 9NQ3HDB99VBF | Firmware and driver updates | Requires genuine Samsung hardware IDs |

> **Warning**: You can install these apps, but they will not function and may display errors.

---

## Legacy Packages

Deprecated versions - use newer alternatives instead.

| Package | Store ID | Description | Recommendation |
|---------|----------|-------------|----------------|
| Samsung Studio Plus (Legacy) | 9PLPF77D2R18 | Old photo editor | Use Samsung Studio (9P312B4TZFFH) instead |

---

## Installation Profiles

### Core Only (9 packages)
- Samsung Account
- Samsung Settings + Runtime
- Samsung Cloud
- Knox Matrix for Windows
- Samsung Continuity Service
- Samsung Intelligence Service
- Samsung Bluetooth Sync
- Galaxy Book Experience

### Recommended (20 packages)
Core + essential working Samsung apps:
- Quick Share, Camera Share, Storage Share
- Multi Control, Nearby Devices
- Notes, AI Select, Second Screen
- Gallery
- Galaxy Buds
- Samsung Pass

### Recommended Plus (27 packages)
Recommended + additional working apps:
- Samsung Studio, Studio for Gallery
- Screen Recorder
- Samsung Flow, SmartThings
- Parental Controls, Live Wallpaper
- Galaxy Book Smart Switch

### Full Experience (31 packages)
Recommended Plus + apps requiring extra setup:
- Samsung Device Care
- Samsung Phone
- Samsung Find
- Quick Search

### Everything (34 packages)
All packages including non-working ones:
- Samsung Recovery
- Samsung Update

### Custom Selection
Pick individual packages by category with full control over what gets installed.

---

## Quick Stats

- **Total Packages**: 35
- **Core (Required)**: 9
- **Recommended (Essential)**: 11
- **Recommended Plus (Additional)**: 8
- **Requires Extra Steps**: 4
- **Non-Working**: 2
- **Legacy**: 1

---

## Finding Package IDs

To find package IDs for new Samsung apps:

1. Open Microsoft Store
2. Navigate to the app page
3. Look at the URL: `https://apps.microsoft.com/detail/[PACKAGE_ID]`
4. The package ID is the alphanumeric code (e.g., 9PCTGDFXVZLJ)

### Alternative Method
```powershell
# Search for Samsung apps
winget search "Samsung" --source msstore
```

---

## Tips

- **Start with Recommended**: Best balance of features and compatibility
- **Check Wi-Fi for Quick Share/Camera Share/Storage Share**: Requires Intel Wi-Fi (AC/AX/BE) + Intel Bluetooth
- **Install Core First**: Test basic functionality before adding more
- **Skip Non-Working**: No point installing Recovery or Update
- **Custom for Power Users**: Pick exactly what you need

---

## Resources

- [Microsoft Store](https://apps.microsoft.com/)
- [Package Downloader](https://store.rg-adguard.net/) - Manual package downloads
- [Samsung Support](https://www.samsung.com/support/) - Official app documentation

---

**Last Updated**: January 10, 2026 (v3.1.0)
