# Section Components

Break complex views into `*Section` components that receive data and callbacks.

```swift
struct ItemsSection: View {
    let items: [Item]
    let selectedID: UUID?
    let onSelect: (Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Items", systemImage: "list.bullet")
                .font(.title2)
                .fontWeight(.semibold)

            ForEach(items) { item in
                ItemCard(item: item, isSelected: selectedID == item.id)
                    .onTapGesture { onSelect(item) }
            }
        }
    }
}
```

## Usage in Parent

```swift
var body: some View {
    ScrollView {
        VStack(spacing: 24) {
            HeaderSection(info: viewModel.info)
            ItemsSection(
                items: viewModel.items,
                selectedID: viewModel.selectedID,
                onSelect: { viewModel.select($0) }
            )
        }
        .padding(20)
    }
}
```

## Key Points

- Section = header label + content list
- Pass data as `let` props, actions as closures
- Parent owns state, sections are stateless
