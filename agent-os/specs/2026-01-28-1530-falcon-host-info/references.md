# Reference Code Pointers

## Model Pattern

**File**: `USBDeviceInfo/Models/HostInfo.swift`

Simple struct with optional properties for nullable data.

## Service Pattern

**File**: `USBDeviceInfo/Services/HostInfoProvider.swift`

- Struct-based service
- Async function returning model
- Private helper methods for individual data points
- Graceful nil returns on failure

## View Pattern

**File**: `USBDeviceInfo/Views/HostInfoSection.swift`

- Section header with Label
- Card-styled container
- Grid layout for key-value pairs
- Copy button with animation feedback
- Loading state handling

## ViewModel Integration

**File**: `USBDeviceInfo/ViewModels/DeviceListViewModel.swift`

- `@Observable` class with `@MainActor`
- Private provider instance
- Public read-only property for data
- Async loading in init Task
- Refresh method for toolbar button
