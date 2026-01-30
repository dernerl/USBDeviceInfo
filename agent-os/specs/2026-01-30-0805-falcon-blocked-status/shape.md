# Shaping: Falcon Blocked Status Indicator

## Problem Statement

When CrowdStrike Falcon Device Control blocks a USB mass storage device, the device appears in IOKit but no volume is mounted. Users need visual feedback that a device is blocked vs. still mounting.

## Design Decisions

### Detection Strategy: Inference-Based

We use an inference approach rather than direct Falcon API integration:

1. **Why inference?** CrowdStrike Falcon doesn't expose a public API for checking blocked devices
2. **Heuristic:** If mass storage device + no volume after retry + Falcon active = likely blocked
3. **Trade-off:** May show false positives for slow-mounting devices, but provides valuable feedback

### Badge Design

- **Location:** In the header, next to the device type badge
- **Color:** Orange (`Color.orange`) - warning, not error
- **Icon:** `exclamationmark.shield` - indicates security-related blocking
- **Text:** "Blocked" - concise and clear
- **Tooltip:** Explains Falcon Device Control context

### Data Flow

```
ViewModel.hostInfo.falconSensorLoaded
    → ContentView
        → ConnectedDevicesSection(isFalconActive:)
            → DeviceCardView(isFalconActive:)
```

## Constraints

- Must not add new dependencies
- Must follow existing card-style patterns
- Badge should only show when Falcon is definitively active (not nil)

## Future Enhancement

Issue created for DiskArbitration-based detection using `DARegisterDiskMountApprovalCallback` which could provide precise blocking detection.
