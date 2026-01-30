# Falcon Host Information Feature

## Summary

Add a new section to USBDeviceInfo that displays CrowdStrike Falcon sensor information read locally from the Mac. This provides users with their Falcon Agent ID for reference alongside USB device information.

## Scope

- **Data source**: Local Falcon sensor via `falconctl stats` command
- **Permissions**: Graceful fallback if command fails (no sudo/privilege elevation)
- **Phase alignment**: Phase 1 MVP - simple informational display only

## Tasks

### Task 1: Save Spec Documentation

Create `agent-os/specs/2026-01-28-1530-falcon-host-info/` with:
- `plan.md` — This full plan
- `shape.md` — Shaping notes (scope, decisions, context)
- `standards.md` — SwiftUI standards that apply
- `references.md` — Pointers to existing USB code patterns

### Task 2: Create FalconInfo Model

**File**: `USBDeviceInfo/USBDeviceInfo/Models/FalconInfo.swift`

Create model struct:
```swift
struct FalconInfo {
    let agentID: String?          // AID from falconctl
    let isOperational: Bool       // Sensor operational status
    let version: String?          // Falcon sensor version
    let customerID: String?       // CID (optional)
}
```

### Task 3: Create FalconInfoProvider Service

**File**: `USBDeviceInfo/USBDeviceInfo/Services/FalconInfoProvider.swift`

Service responsibilities:
- Execute `/Applications/Falcon.app/Contents/Resources/falconctl stats agent_info`
- Parse output to extract Agent ID, version, operational status
- Return `nil` gracefully if:
  - Falcon not installed
  - Command fails (permission denied)
  - Output cannot be parsed

Pattern: Follow `HostInfoProvider.swift` structure.

### Task 4: Create FalconInfoSection View

**File**: `USBDeviceInfo/USBDeviceInfo/Views/FalconInfoSection.swift`

Section component displaying:
- Falcon Agent ID (with copy button)
- Sensor operational status (icon/badge)
- Sensor version
- Empty/unavailable state if Falcon not detected

Standards to apply:
- `swiftui/section-components` — Section header with Label
- `swiftui/card-style` — Card styling (16pt padding, 12pt radius, .regularMaterial)

### Task 5: Integrate into ContentView and ViewModel

**Files to modify**:
- `USBDeviceInfo/USBDeviceInfo/ViewModels/DeviceListViewModel.swift`
- `USBDeviceInfo/USBDeviceInfo/ContentView.swift`

Changes:
- Add `falconInfo: FalconInfo?` property to ViewModel
- Add `fetchFalconInfo()` method
- Call on init alongside `loadHostInfo()`
- Add `FalconInfoSection` to ContentView between HostInfoSection and ConnectedDevicesSection

## Critical Files

| File | Action |
|------|--------|
| `USBDeviceInfo/Models/FalconInfo.swift` | Create |
| `USBDeviceInfo/Services/FalconInfoProvider.swift` | Create |
| `USBDeviceInfo/Views/FalconInfoSection.swift` | Create |
| `USBDeviceInfo/ViewModels/DeviceListViewModel.swift` | Modify |
| `USBDeviceInfo/ContentView.swift` | Modify |

## Reference Code

- `USBDeviceInfo/Services/HostInfoProvider.swift` — Pattern for async system info provider
- `USBDeviceInfo/Views/HostInfoSection.swift` — Pattern for section component with copy button
- `USBDeviceInfo/Models/HostInfo.swift` — Pattern for info model struct

## Verification

1. Build and run the app
2. If Falcon is installed: Verify Agent ID, status, and version display correctly
3. If Falcon is not installed: Verify graceful "unavailable" state shows
4. Test copy button for Agent ID
5. Verify no crashes or hangs when falconctl permission is denied

## Notes

- User requested this feature be tracked as a GitHub issue for future sessions
- No Hostgroup or Device Control Policy info (would require Falcon API, out of scope for Phase 1)
- Only Agent ID and basic sensor info available locally via falconctl
