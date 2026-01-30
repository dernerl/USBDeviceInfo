# Card Style

Consistent card styling for list items.

```swift
struct ItemCard: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            Divider()
            content
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

## Style Tokens

| Element | Value |
|---------|-------|
| Padding | 16pt |
| Corner radius | 12pt |
| Background | `.regularMaterial` |
| Internal spacing | 10pt |
| Section spacing | 24pt |

## Grid Layout

```swift
Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
    GridRow {
        Text("Label").foregroundStyle(.secondary)
        Text(value)
    }
}
.font(.callout)
```
