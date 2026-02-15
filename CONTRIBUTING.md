# Contributing to Galaxy Book Enabler

First off, thank you for considering contributing to Galaxy Book Enabler! It's people like you that make this tool better for everyone.

## Development Environment
- Windows 10/11
- PowerShell 7.0+ (`pwsh`)
- `Pester` module (v3.4.0) for running tests

## Pull Request Process

1. **Fork the repository** and create your branch from `main`.
2. If you've added code that should be tested, **add tests**.
3. Ensure the test suite passes locally.
4. Update the documentation if you've changed functionality.
5. Create a Pull Request with a clear description of the problem and solution.

## CI/CD and Branch Protection Policy

This repository implements strict branch protection. The following checks are **REQUIRED** to pass before a pull request can be merged:

### 1. Autonomous Action Checks (`Autonomous Action Checks`)
- **Workflow**: `.github/workflows/autonomous-actions-check.yml`
- **Purpose**: Verifies that the installer works correctly in non-interactive mode.
- **Key Regressions Covered**:
  - Unconditional pauses (blocking CI).
  - Array argument "comma-collapsing" during elevation.
  - Fully autonomous install/uninstall/update-settings actions.

### 2. Installer Smoke Tests (`installer-smoke`)
- **Workflow**: `.github/workflows/installer-smoke.yml`
- **Purpose**: Basic verification of installer logic and environment setup on a clean Windows runner.

### 3. Identity Generator Tests (`generator-tests`)
- **Workflow**: `.github/workflows/generator-tests.yml`
- **Purpose**: Runs Pester unit tests for the `Generate-SamsungIdentity.ps1` script to ensure valid DMI string generation.

## Coding Standards
- Use PowerShell 7 idiomatic code (avoid PS 5.1 specificisms).
- Implement `Invoke-InteractivePause` for any user interaction to ensure CI compatibility.
- Use strict `ErrorActionPreference = 'Stop'` in scripts intended for automation.
- For elevation logic, ensure array parameters are correctly itemized (preserve `[string[]]` types).
