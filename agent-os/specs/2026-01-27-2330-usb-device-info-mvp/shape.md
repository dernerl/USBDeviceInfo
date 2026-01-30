# USB Device Info — Shape

## Scope

Standalone SwiftUI macOS app (Phase 1 MVP) that reads USB device information via IOKit and presents it in a format compatible with CrowdStrike Falcon Device Control.

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| UI Framework | SwiftUI with `@Observable` | Modern, declarative; targets macOS 15+ |
| USB Enumeration | IOKit (`IOUSBHostDevice`) | Direct, fast, supports real-time notifications |
| Persistence | UserDefaults (JSON) | Sufficient for 5 device entries; no CoreData overhead |
| Sandbox | Disabled | IOKit USB registry access requires it; internal enterprise tool |
| Window Style | Single `Window` scene | Not a menu bar app; launched from SupportApp |
| Combined ID Format | `{VendorID}_{ProductID}_{SerialNumber}` | Matches CrowdStrike Falcon Device Control exactly (decimal integers) |

## Context

- Launched from SupportApp (Root3) via custom action button
- Fields must match CrowdStrike Falcon "Add device exception" dialog: Serial number, Vendor ID, Vendor name, Product ID, Product name
- USB hubs produce Combined IDs with serial `000000001` — filtered out via `bDeviceClass == 9`
- Devices without serial numbers show "N/A" with a warning about Falcon compatibility

## Out of Scope (Phase 1)

- SupportApp Extension integration (Phase 2)
- CrowdStrike Falcon API automation (Phase 3)
- Azure backend / approval workflow (Phase 3)
