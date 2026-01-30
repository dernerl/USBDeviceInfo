# Plan: Make USBDeviceInfo Installable with GitHub + Automated Releases

## Summary

Make the existing USBDeviceInfo macOS app distributable via Intune by:
1. Saving spec documentation
2. Creating a public GitHub repository
3. Adding GitHub Actions for automated .pkg releases on version tags
4. Updating version management from hardcoded to dynamic

## Context

- **App**: USBDeviceInfo - macOS SwiftUI utility for USB device identification (CrowdStrike Falcon Device Control)
- **Current state**: Working app with existing `scripts/build-pkg.sh` that creates .pkg installer
- **Distribution**: Microsoft Intune (full MDM control available)
- **Signing**: Ad-hoc (no Apple Developer account)
- **Standards**: `macos/intune-pkg` already implemented

---

## Tasks

### Task 1: Save Spec Documentation

Create `agent-os/specs/2026-01-28-make-installable-github/` with:
- `plan.md` — This plan
- `shape.md` — Shaping notes and decisions
- `standards.md` — Applied standards (macos/intune-pkg)
- `references.md` — Reference to existing build script

### Task 2: Update Version Management

**Files to modify:**
- `USBDeviceInfo/scripts/build-pkg.sh` — Read version from project.yml instead of hardcoded "1.0"
- `USBDeviceInfo/project.yml` — Ensure version is defined (MARKETING_VERSION)

**Approach:**
- Extract version from project.yml using grep/sed in build script

### Task 3: Create .gitignore

Create `USBDeviceInfo/.gitignore` with standard macOS/Xcode ignores.

### Task 4: Add GitHub Actions Workflow

Create `USBDeviceInfo/.github/workflows/release.yml`:
- Trigger: on tag push (`v*`)
- Build: Run `make pkg` on macOS runner
- Release: Upload .pkg to GitHub Releases

### Task 5: Initialize Git Repository

Initialize git repo and make initial commit.

### Task 6: Create GitHub Repository

Create public GitHub repository and push code.

### Task 7: Create First Release

Tag v1.0.0 and push to trigger automated release.

---

## Files Created/Modified

| File | Action |
|------|--------|
| `agent-os/specs/2026-01-28-make-installable-github/` | Created (spec docs) |
| `USBDeviceInfo/.gitignore` | Created |
| `USBDeviceInfo/.github/workflows/release.yml` | Created |
| `USBDeviceInfo/scripts/build-pkg.sh` | Modified (dynamic version) |

---

## Verification

1. **Build locally**: Run `make pkg` and verify .pkg is created
2. **GitHub push**: Confirm code is pushed to GitHub
3. **Release workflow**: Push a tag and verify GitHub Actions creates a release with .pkg
4. **Download test**: Download .pkg from GitHub Releases
5. **Install test**: Install .pkg on a Mac and verify app works
