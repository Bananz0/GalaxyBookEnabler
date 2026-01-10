# Issue Templates

This directory contains GitHub issue templates to help users report problems effectively.

## Available Templates

### 🐛 Bug Report (`bug_report.yml`)
For reporting installation problems, features not working, or errors.

**Key fields:**
- What happened (required)
- What you expected (required)
- Which feature is affected (required)
- Installation log file (recommended - saved to %TEMP%)
- Hardware information (WiFi/Bluetooth adapter models)
- Version and Windows build

### 📊 Hardware Compatibility Report (`hardware_compatibility.yml`)
For sharing your hardware compatibility results to help improve documentation.

**Key fields:**
- Intel Wi-Fi generation (required)
- Exact Wi-Fi model (required)
- Bluetooth model
- Feature status (Quick Share, Camera Share, Storage Share, Multi Control, Second Screen)
- Additional details about performance

### ✨ Feature Request (`feature_request.yml`)
For suggesting new features or improvements.

**Key fields:**
- Feature description
- Use case (how would it be used?)
- Alternatives considered
- Additional context

## Configuration (`config.yml`)

Disables blank issues and provides helpful links:
- 📖 Documentation (README.md)
- 📦 Package Reference (PACKAGES.md)
- 💬 Discussions

## For Maintainers

### Log File Information

The script automatically generates diagnostic logs at:
```
%TEMP%\GalaxyBookEnabler_YYYYMMDD_HHMMSS.log
```

**Log Contents:**
- System information (OS, CPU, RAM, PowerShell version)
- Hardware detection results (WiFi/Bluetooth adapters with hardware IDs)
- Step-by-step execution flow
- Package installation results (success/failure/skipped)
- Error messages with full output
- SSSE installation status

**Key Features:**
- Works even with `irm | iex` one-line install (uses %TEMP%)
- Non-intrusive silent fallback if logging fails
- Timestamped entries for debugging timing issues
- Debug-level output for verbose error details

### Common Issues to Look For in Logs

1. **Hardware Detection**
   - Look for "Wi-Fi (Intel)" vs "Wi-Fi: Not Intel"
   - Check Hardware IDs (VEN_8086 = Intel WiFi, VID_8087 = Intel BT)

2. **Package Installation**
   - Microsoft Store errors (0x80d03805)
   - Winget failures (exit codes, package not found)
   - Already installed vs new installs

3. **SSSE Issues**
   - User skipped vs installation attempted
   - Existing Samsung Settings conflicts

### Template Maintenance

- Keep hardware dropdown options in sync with PACKAGES.md WiFi compatibility section
- Update feature dropdowns when new Samsung apps are added
- Ensure log file instructions match actual script behavior
