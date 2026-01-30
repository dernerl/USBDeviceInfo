# USB Device Info — Implementation Plan

## Summary

Build a standalone native macOS SwiftUI app that lists connected USB devices with their CrowdStrike Falcon Combined ID (`VendorID_ProductID_SerialNumber`), shows the last 5 recently connected devices, and provides a one-click copy button. The app can be launched from the SupportApp via a custom action button.

## Architecture

```
USBDeviceInfoApp (SwiftUI @main)
    └── ContentView
         ├── @State DeviceListViewModel (@Observable, @MainActor)
         │       ├── USBDeviceMonitor (IOKit enumeration + notifications)
         │       ├── DeviceHistoryStore (UserDefaults persistence)
         │       ├── connectedDevices: [USBDevice]
         │       └── recentDevices: [USBDevice]
         ├── ConnectedDevicesSection
         │       └── DeviceCardView (per device, with copy button)
         └── RecentDevicesSection
                 └── DeviceCardView (per device, dimmed, with copy button)
```

## Tasks

### Task 1: Save spec documentation
Create `agent-os/specs/2026-01-27-2330-usb-device-info-mvp/` with plan, shape, references, and visuals.

### Task 2: Create Xcode project
SwiftUI macOS app project with sandbox disabled, macOS 15+ deployment target.

### Task 3: Implement USB device model
`USBDevice` struct — Identifiable, Codable, Hashable with combinedID computed property.

### Task 4: Implement IOKit USB monitor
Enumerate USB devices via `IOServiceMatching("IOUSBHostDevice")`, filter hubs, extract properties.

### Task 5: Implement device history store
UserDefaults persistence for last 5 devices, deduplicated by Combined ID.

### Task 6: Implement ViewModel
`@Observable @MainActor` class connecting monitor, history, and UI state.

### Task 7: Build the UI
SwiftUI views: ContentView, DeviceCardView, ConnectedDevicesSection, RecentDevicesSection.

### Task 8: Add real-time USB monitoring
IOKit notifications for plug/unplug with debounced refresh.

### Task 9: Polish and test
Build verification, edge cases, dark/light mode.

## Verification

1. Build compiles without errors
2. Window appears with empty state when no devices connected
3. USB device appears in real-time when plugged in
4. Copy button copies Combined ID to clipboard
5. Unplugged device moves to Recent section
6. Recent devices persist across app relaunch
7. Max 5 devices in history
