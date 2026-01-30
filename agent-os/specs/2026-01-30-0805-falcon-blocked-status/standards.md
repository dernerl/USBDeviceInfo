# Standards Applied

## swiftui/card-style

Device cards use consistent styling:
- `VStack` with `.padding(16)`
- `.background(.regularMaterial)`
- `.clipShape(RoundedRectangle(cornerRadius: 12))`
- Capsule badges for status indicators

The blocked badge follows this pattern:
```swift
Text("Blocked")
    .font(.caption)
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(Color.orange.opacity(0.2))
    .foregroundStyle(.orange)
    .clipShape(Capsule())
```

## swiftui/observable-viewmodel

- `DeviceListViewModel` is `@Observable`
- State flows unidirectionally: ViewModel → View
- `hostInfo.falconSensorLoaded` is the source of truth for Falcon status
- Views receive status as props, not by observing ViewModel directly
