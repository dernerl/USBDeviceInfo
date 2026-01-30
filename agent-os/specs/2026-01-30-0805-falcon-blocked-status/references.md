# References

## Existing Patterns

### DeviceCardView Badge Pattern (line 32-37)
```swift
Text(device.deviceType.label)
    .font(.caption)
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(.quaternary)
    .clipShape(Capsule())
```

### HostInfo Falcon Status
```swift
struct HostInfo {
    // ...
    var falconSensorLoaded: Bool?  // nil = not installed, true/false = status
}
```

### Volume Name Display (line 40-49)
```swift
if let volumeName = device.volumeName {
    HStack(spacing: 4) {
        Image(systemName: "internaldrive")
            .font(.caption)
        Text(volumeName)
            .fontWeight(.medium)
    }
    .font(.callout)
    .foregroundStyle(.blue)
}
```

## Related Files

- `USBDeviceInfo/Models/USBDevice.swift` - Device model
- `USBDeviceInfo/Views/DeviceCardView.swift` - Card component
- `USBDeviceInfo/ViewModels/DeviceListViewModel.swift` - ViewModel with Falcon status
- `USBDeviceInfo/Services/FalconInfoProvider.swift` - Falcon detection service
