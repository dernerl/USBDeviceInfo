# Falcon Device Control Blocked Status Indicator

**Issue:** #5 - Feature: Falcon Device Control View
**Status:** Implementing

## Summary

Add a visual indicator on USB device cards showing when a device is likely blocked by CrowdStrike Falcon Device Control. Uses inferred detection: if a mass storage device exists in IOKit but has no volume after retries AND Falcon sensor is loaded, display "Blocked by Falcon" badge.

## Files to Modify

- `USBDeviceInfo/Models/USBDevice.swift` - Add `isLikelyBlocked` computed property
- `USBDeviceInfo/Views/DeviceCardView.swift` - Add blocked status badge in header
- `USBDeviceInfo/Views/ConnectedDevicesSection.swift` - Pass Falcon status to DeviceCardView
- `USBDeviceInfo/Views/RecentDevicesSection.swift` - Pass Falcon status to DeviceCardView
- `USBDeviceInfo/ContentView.swift` - Pass Falcon status from ViewModel

## Implementation Tasks

### Task 1: Add Blocked Detection Logic to USBDevice Model

Add computed property to `USBDevice.swift`:
```swift
var isLikelyBlocked: Bool {
    deviceType == .massStorage && volumeName == nil
}
```

### Task 2: Add Blocked Badge to DeviceCardView

Modify to accept `isFalconActive: Bool` parameter and show badge when:
- `device.isLikelyBlocked == true` AND `isFalconActive == true`

Badge design:
- Red/orange capsule badge next to device type badge
- Icon: `exclamationmark.shield`
- Text: "Blocked"
- Tooltip: "This device may be blocked by Falcon Device Control"

### Task 3: Pass Falcon Status Through View Hierarchy

Update ContentView, ConnectedDevicesSection, and RecentDevicesSection to pass `falconSensorLoaded` to DeviceCardView.

## Verification

1. Build: `xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo build`
2. Test with allowed USB device - should show normal card with volume name
3. Test with blocked USB device - should show "Blocked" badge
4. Verify badge only appears when Falcon sensor is active

## Standards Applied

- **swiftui/card-style** - Badge follows capsule style like existing device type badge
- **swiftui/observable-viewmodel** - Falcon status flows from ViewModel through props
