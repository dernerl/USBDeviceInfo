# USB Device Info — References

## IOKit USB Enumeration

- IOKit matching: `IOServiceMatching("IOUSBHostDevice")` (macOS 13+; replaces `"IOUSBDevice"`)
- Main port: `kIOMainPortDefault` (replaces deprecated `kIOMasterPortDefault`)
- Property keys: `idVendor` (Int), `idProduct` (Int), `USB Serial Number` (String), `USB Vendor Name` (String), `USB Product Name` (String), `bDeviceClass` (Int)
- Notifications: `IOServiceAddMatchingNotification` with `kIOFirstMatchNotification` / `kIOTerminatedNotification`
- Iterator must be drained after registration to arm notifications

## CrowdStrike Falcon Device Control

- Combined ID format: `{VendorID}_{ProductID}_{SerialNumber}` using decimal integers
- Fields: Serial number, Vendor ID, Vendor name, Product ID, Product name, Device class
- USB hubs appear with serial `000000001`

## SupportApp (Root3) Integration

- Custom action button configuration via MDM profile
- Launch method: `open` URL or direct app path `/Applications/USBDeviceInfo.app`
- Phase 2: Extension writes to `nl.root3.support.plist` via `defaults write`

## Screenshots

- `visuals/crowdstrike-device-exception.png` — CrowdStrike Falcon "Add device exception" dialog
- `visuals/combined-id-format.png` — Combined ID format example
- `visuals/supportapp-ui.png` — SupportApp popover UI
