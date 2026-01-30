# SwiftUI Standards Applied

## Section Components

Section headers use `Label` with system image:
```swift
Label("Falcon Sensor", systemImage: "shield.checkerboard")
    .font(.title2)
    .fontWeight(.semibold)
```

## Card Styling

Cards use consistent styling:
- Padding: 16pt
- Corner radius: 12pt
- Background: `.regularMaterial`

```swift
.padding(16)
.background(.regularMaterial)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

## Copy Button Pattern

Copy buttons with feedback animation:
```swift
Button(action: onCopy) {
    HStack(spacing: 4) {
        Image(systemName: copied ? "checkmark" : "doc.on.doc")
        Text(copied ? "Copied!" : "Copy")
    }
    .font(.caption)
    .contentTransition(.symbolEffect(.replace))
}
.buttonStyle(.bordered)
.tint(copied ? .green : nil)
```

## Grid Layout

Info grids use:
```swift
Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
    GridRow {
        Text("Label")
            .foregroundStyle(.secondary)
        Text("Value")
    }
}
.font(.callout)
```

## Async Data Loading

Services follow async pattern:
```swift
struct FalconInfoProvider {
    func getFalconInfo() async -> FalconInfo? {
        // ...
    }
}
```
