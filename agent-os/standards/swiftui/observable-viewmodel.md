# @Observable ViewModel Pattern

Use Swift 5.9+ `@Observable` macro instead of `ObservableObject`.

```swift
import Observation

@Observable
@MainActor
final class FeatureViewModel {
    private(set) var items: [Item] = []
    var selectedID: UUID?

    private let service: SomeService

    init(service: SomeService = SomeService()) {
        self.service = service
    }

    func refresh() {
        items = service.fetchItems()
    }
}
```

## In the View

```swift
struct FeatureView: View {
    @State private var viewModel = FeatureViewModel()

    var body: some View {
        List(viewModel.items) { item in
            // ...
        }
    }
}
```

## Key Points

- `@Observable` + `@State` replaces `ObservableObject` + `@StateObject`
- `@MainActor` ensures UI updates on main thread
- `private(set)` for read-only published state
- Services as private dependencies injected via init
