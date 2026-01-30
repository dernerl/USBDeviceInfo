# Plan: Device Identification + Host Identification

## Summary

Two features for the existing USB Device Info app:

1. **Device Identification** — Show USB device type labels (Mass Storage, HID, etc.) and volume names (e.g. "DATENGRAB") so users can distinguish USB sticks from docking station components without plugging/unplugging.
2. **Host Identification** — New section at the top of the window showing hostname, MAC address, local IP, and external IP so admins can match the machine in CrowdStrike Falcon.

## Files to Modify

| File | Changes |
|------|---------|
| `USBDeviceInfo/Models/USBDevice.swift` | Add `deviceType`, `volumeName` fields |
| `USBDeviceInfo/Services/USBDeviceMonitor.swift` | Read `bInterfaceClass` from child IOUSBHostInterface, resolve volume name via DiskArbitration |
| `USBDeviceInfo/Services/HostInfoProvider.swift` | **New** — hostname, local IP, external IP, MAC address |
| `USBDeviceInfo/ViewModels/DeviceListViewModel.swift` | Integrate HostInfoProvider, async volume name resolution |
| `USBDeviceInfo/Models/HostInfo.swift` | **New** — model for host identification data |
| `USBDeviceInfo/Views/DeviceCardView.swift` | Show device type icon/label + volume name |
| `USBDeviceInfo/Views/HostInfoSection.swift` | **New** — host info card at top of window |
| `USBDeviceInfo/ContentView.swift` | Add HostInfoSection at top |

## Tasks

### Task 1: Save spec documentation

Create `agent-os/specs/2026-01-28-0800-device-host-identification/` with:
- `plan.md` — this plan
- `shape.md` — shaping decisions and context
- `references.md` — IOKit interface classes, DiskArbitration, network APIs
- `visuals/` — copy Feature-DeviceIdentification.png and Feature-HostIdentifikation.png

### Task 2: Add device type to model and monitor

**Modify:** `USBDevice.swift`, `USBDeviceMonitor.swift`

Add a `USBDeviceType` enum and `deviceType` property to the model:
```
enum USBDeviceType: String, Codable {
    case massStorage, hid, audio, video, printer,
         wireless, smartCard, communication, other
}
```

In `USBDeviceMonitor.extractDeviceInfo()`:
- After getting the `io_object_t` for the device, enumerate its child nodes in `kIOServicePlane`
- Find children of class `IOUSBHostInterface` and read their `bInterfaceClass` property
- Map `bInterfaceClass` to `USBDeviceType` (0x08=massStorage, 0x03=hid, 0x01=audio, 0x0E=video, 0x07=printer, 0xE0=wireless, 0x0B=smartCard, 0x02=communication)
- Most USB sticks report `bDeviceClass=0` with the actual class at the interface level — this is why the current hub-only filtering misses device types

### Task 3: Add volume name resolution

**Modify:** `USBDeviceMonitor.swift`, `USBDevice.swift`

Add `volumeName: String?` to `USBDevice`.

In `USBDeviceMonitor`:
- For mass storage devices, use `IORegistryEntrySearchCFProperty` with `kIORegistryIterateRecursively` to find `"BSD Name"` in the device's child hierarchy
- Use `DiskArbitration` framework: `DASessionCreate` → `DADiskCreateFromBSDName` → `DADiskCopyDescription` → read `kDADiskDescriptionVolumeNameKey`
- Volume may not be mounted immediately after USB connect — add a retry mechanism (re-resolve after 1-2s delay) or accept nil on first pass and resolve on next refresh

**Note:** Need to add `DiskArbitration.framework` to project.yml dependencies.

### Task 4: Create HostInfoProvider service

**New file:** `USBDeviceInfo/Services/HostInfoProvider.swift`
**New file:** `USBDeviceInfo/Models/HostInfo.swift`

`HostInfo` struct with:
- `computerName: String` — via `SCDynamicStoreCopyComputerName` (non-blocking, user-friendly name)
- `hostName: String` — via `SCDynamicStoreCopyLocalHostName` (Bonjour local hostname)
- `localIP: String?` — via `getifaddrs()`, filter for `AF_INET` on `en*` interfaces
- `externalIP: String?` — async fetch from `https://api.ipify.org`
- `macAddress: String?` — via IOKit `IOEthernetInterface` with `IOPrimaryInterface: true`, read `IOMACAddress`

`HostInfoProvider`:
- `func getHostInfo() async -> HostInfo` — gathers all info, external IP fetched async
- Uses `SystemConfiguration` framework for hostname
- Formats MAC as `xx:xx:xx:xx:xx:xx`

**Note:** Need to add `SystemConfiguration.framework` to project.yml dependencies.

### Task 5: Integrate into ViewModel

**Modify:** `DeviceListViewModel.swift`

- Add `hostInfo: HostInfo?` published property
- On init, call `loadHostInfo()` which runs `HostInfoProvider.getHostInfo()` async
- Add `refreshHostInfo()` method
- For volume name timing: after `refreshConnectedDevices()`, schedule a delayed re-resolve (1.5s) for any mass storage devices with nil volumeName

### Task 6: Build Host Info UI section

**New file:** `USBDeviceInfo/Views/HostInfoSection.swift`
**Modify:** `ContentView.swift`

`HostInfoSection`:
- Section header: "Host Information" with `desktopcomputer` SF Symbol
- Card (same `.regularMaterial` style as device cards) showing:
  - Computer Name (headline)
  - Hostname (callout, secondary)
  - Grid: Local IP, External IP, MAC Address
  - Copy button for MAC address (useful for CrowdStrike matching)
- Loading state while external IP is being fetched

Add `HostInfoSection` at the **top** of `ContentView`, above `ConnectedDevicesSection`.

### Task 7: Update DeviceCardView for device type + volume name

**Modify:** `DeviceCardView.swift`

- Replace the generic `externaldrive.connected.to.line.below` icon with type-specific SF Symbols:
  - massStorage → `externaldrive.fill`
  - hid → `keyboard`
  - audio → `speaker.wave.2`
  - video → `video`
  - printer → `printer`
  - wireless → `wifi`
  - other → `cable.connector.horizontal`
- Show device type label as a small badge/tag next to the device name
- If `volumeName` is present, show it prominently (e.g. `"DATENGRAB"` above or next to the product name)

### Task 8: Update project.yml and build

**Modify:** `project.yml`

- Add `DiskArbitration.framework` and `SystemConfiguration.framework` as SDK dependencies
- Regenerate project with `xcodegen generate`
- Build and verify zero errors/warnings

## Verification

1. `xcodebuild` compiles without errors
2. App launches with Host Info section at top showing computer name, hostname, local IP, external IP (after brief load), MAC address
3. USB stick plugged in → shows device type "Mass Storage" with correct icon, volume name (e.g. "DATENGRAB") appears
4. Docking station devices show different type labels (HID, Audio, etc.) — clearly distinguishable from USB sticks
5. Copy buttons work for both Combined ID and MAC address
6. Dark/Light mode renders correctly
7. Recent devices section still works (device type and volume name persisted in history)
