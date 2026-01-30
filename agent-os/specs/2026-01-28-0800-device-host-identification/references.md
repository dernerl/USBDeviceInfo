# References: Device Identification + Host Identification

## USB Interface Classes (bInterfaceClass)

Standard USB interface class codes from USB-IF:

| Code | Class | USBDeviceType |
|------|-------|---------------|
| 0x01 | Audio | `.audio` |
| 0x02 | Communications (CDC) | `.communication` |
| 0x03 | Human Interface Device (HID) | `.hid` |
| 0x07 | Printer | `.printer` |
| 0x08 | Mass Storage | `.massStorage` |
| 0x0B | Smart Card | `.smartCard` |
| 0x0E | Video | `.video` |
| 0xE0 | Wireless Controller | `.wireless` |

**Note:** `bDeviceClass=0` means "defined at interface level" — most USB devices use this. The actual class is on child `IOUSBHostInterface` nodes.

## IOKit APIs

### Enumerating Child Interfaces
```swift
// Get child iterator for IOUSBHostInterface nodes
IORegistryEntryGetChildIterator(device, kIOServicePlane, &childIterator)

// Read bInterfaceClass from each child
IORegistryEntryCreateCFProperty(child, "bInterfaceClass" as CFString, ...)
```

### Finding BSD Name (for volume resolution)
```swift
// Search recursively in device's child hierarchy
IORegistryEntrySearchCFProperty(
    device,
    kIOServicePlane,
    "BSD Name" as CFString,
    kCFAllocatorDefault,
    IOOptionBits(kIORegistryIterateRecursively)
)
```

## DiskArbitration Framework

Used to resolve BSD name → volume name:

```swift
import DiskArbitration

let session = DASessionCreate(kCFAllocatorDefault)
let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, bsdName)
let desc = DADiskCopyDescription(disk) as? [String: Any]
let volumeName = desc[kDADiskDescriptionVolumeNameKey as String] as? String
```

**Timing:** Volume mount is asynchronous after USB connect. May need 1-2s retry.

## SystemConfiguration Framework

### Computer Name
```swift
import SystemConfiguration

let name = SCDynamicStoreCopyComputerName(nil, nil) as String?
```

### Local Hostname (Bonjour)
```swift
let hostname = SCDynamicStoreCopyLocalHostName(nil) as String?
```

## Network APIs

### Local IP Address
```swift
import Darwin

var ifaddr: UnsafeMutablePointer<ifaddrs>?
getifaddrs(&ifaddr)
// Walk linked list, filter AF_INET + en* interface name
// Convert sockaddr_in to string with inet_ntop
freeifaddrs(ifaddr)
```

### External IP
```
GET https://api.ipify.org
→ Returns plain text IP address (e.g. "203.0.113.42")
```

### MAC Address via IOKit
```swift
let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
// Find service with IOPrimaryInterface = true in parent
// Read IOMACAddress property (6-byte Data)
// Format as xx:xx:xx:xx:xx:xx
```

## SF Symbols for Device Types

| Device Type | SF Symbol |
|------------|-----------|
| Mass Storage | `externaldrive.fill` |
| HID | `keyboard` |
| Audio | `speaker.wave.2` |
| Video | `video` |
| Printer | `printer` |
| Wireless | `wifi` |
| Smart Card | `creditcard` |
| Communication | `antenna.radiowaves.left.and.right` |
| Other/Unknown | `cable.connector.horizontal` |
