# Pull Request Template

## Description
Please describe the changes in this PR.

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🧪 Test addition/improvement

## PR Checklist for Maintainers / Required Checks
This project uses GitHub Actions for automated quality gates. Before merging, please ensure the following status checks are green:

- [ ] **Autonomous Action Checks** (`autonomous-actions-check.yml`) - *Added for regression testing of autonomous paths and array-forwarding bugs*
- [ ] **Installer Smoke Tests** (`installer-smoke.yml`) - *Verifies core installer health on Windows runners*
- [ ] **Identity Generator Tests** (`generator-tests.yml`) - *Verifies Samsung identity randomization logic*

## How Has This Been Tested?
Please describe the tests that you ran to verify your changes.

- [ ] Manually tested in PowerShell 7 (pwsh)
- [ ] Verified non-interactive/autonomous execution
- [ ] Verified UAC elevation paths
- [ ] Added/Updated Pester tests
