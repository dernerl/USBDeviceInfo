# References

## Existing Implementation

### Build Script
- `USBDeviceInfo/scripts/build-pkg.sh` — Creates .pkg installer
- `USBDeviceInfo/Makefile` — Build targets (build, pkg, clean)
- `USBDeviceInfo/project.yml` — XcodeGen project definition with MARKETING_VERSION

### Previous Specs
- `agent-os/specs/2026-01-27-2330-usb-device-info-mvp/` — Original MVP specification
- `agent-os/specs/2026-01-28-0800-device-host-identification/` — Device/host ID feature

## External References

### GitHub Actions
- [macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) — Pre-installed Xcode
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release) — Release action

### Intune
- [Add macOS LOB apps](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos) — .pkg deployment
- MDM can install apps without notarization when device is supervised
