# Shape: Make USBDeviceInfo Installable via GitHub

## Problem

The USBDeviceInfo app is built locally but needs to be distributable to end users via Microsoft Intune. Currently:
- The app builds successfully with `make pkg`
- Version is hardcoded in `build-pkg.sh`
- No version control or release pipeline exists

## Appetite

Small batch - straightforward automation work.

## Solution

### GitHub + GitHub Actions Approach

Use GitHub as the distribution platform:
1. Public repository hosts the source code
2. GitHub Actions builds .pkg on every version tag
3. GitHub Releases hosts the downloadable .pkg files
4. Intune can download .pkg from GitHub Releases URL

### Version Management

Extract version from `project.yml` MARKETING_VERSION field:
- Single source of truth for version
- Build script reads it dynamically
- Tags match the version (`v1.0.0` for version `1.0.0`)

### Signing Strategy

Ad-hoc signing (CODE_SIGN_IDENTITY="-"):
- Works without Apple Developer account
- Intune with full MDM control can deploy unsigned/ad-hoc apps
- No notarization required for MDM-deployed apps

## Rabbit Holes

- **Notarization**: Not needed for MDM deployment, skip it
- **Code signing certificate**: Ad-hoc works for our use case
- **App Store**: Not applicable, enterprise distribution only

## No-Gos

- Apple Developer Program enrollment (not needed for MDM)
- Complex CI/CD beyond simple tag-triggered builds
- Private repository (public is fine for this utility)
