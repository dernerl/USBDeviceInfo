# Shape: Device Identification + Host Identification

## Context

The USB Device Info app was built for enterprise admins using CrowdStrike Falcon Device Control. Two user feedback items drove this feature request:

### Problem 1: Device Identification
> "Mit Anschluss einer Dockingstation kann es in der Liste sehr unübersichtlich sein. Kann man irgendwie kenntlich machen was eine Dockingstation ist und was ein USB Stick? Ich habe es jetzt identifiziert in dem ich den Stick mehrmals rein und wieder raus gesteckt habe und dann gesehen habe welcher Eintrag verschwindet und wieder kommt."
>
> "Ist es auch möglich dass der Name des USB Sticks angezeigt wird?"

When a docking station is connected, it exposes multiple USB devices (HID, audio, video). The current app shows all of them with identical generic icons. Users can't tell which entry is the USB stick they need to create a Falcon exception for — they have to plug/unplug repeatedly.

### Problem 2: Host Identification
> "Wie im Screenshot zu sehen, kommt man mit dem Host name nicht weiter. Hier steht oft nur Mac.fritz.box (Bug?). Die MAC Adresse, IP (intern oder extern) als zusätzliche Info wären für den Admin hilfreich."

Admins need to match the machine in CrowdStrike Falcon. The hostname alone is unreliable (often shows a generic Fritz!Box name). MAC address, local IP, and external IP provide the additional identifiers needed.

## Shaping Decisions

### Device Type Detection
- **Approach:** Read `bInterfaceClass` from child `IOUSBHostInterface` nodes, not `bDeviceClass` on the device itself
- **Rationale:** Most USB devices (including mass storage) report `bDeviceClass=0` (composite). The actual device class lives at the interface level. The current code only reads `bDeviceClass` to filter hubs.
- **Mapping:** Standard USB interface class codes (0x08=mass storage, 0x03=HID, 0x01=audio, 0x0E=video, etc.)

### Volume Name Resolution
- **Approach:** DiskArbitration framework — find BSD name in IORegistry child hierarchy, then use `DADiskCopyDescription` to get volume name
- **Timing:** Volume may not be mounted immediately. Accept nil initially, re-resolve after 1.5s delay.
- **Scope:** Only resolve for mass storage devices (avoid unnecessary work for HID/audio)

### Host Info Gathering
- **Computer Name:** `SCDynamicStoreCopyComputerName` — user-friendly name set in System Settings
- **Local Hostname:** `SCDynamicStoreCopyLocalHostName` — Bonjour hostname (the `.local` name)
- **Local IP:** `getifaddrs()` filtering for `AF_INET` on `en*` interfaces
- **External IP:** Async fetch from `https://api.ipify.org` — simple, reliable, no API key
- **MAC Address:** IOKit `IOEthernetInterface` with `IOPrimaryInterface: true` property, read `IOMACAddress` data

### UI Placement
- Host info section goes at the **top** of the window, above connected devices — it's contextual info about the machine
- Device type shown as icon + small badge on each device card
- Volume name shown prominently on mass storage device cards

## Boundaries

### In scope
- Device type labels and icons for USB interface classes
- Volume name for mass storage devices
- Host info section with computer name, hostname, local IP, external IP, MAC address
- Copy button for MAC address

### Out of scope
- Multiple volume names per device (just show the first)
- Automatic CrowdStrike API integration
- Network change monitoring (refresh manually)
- IPv6 display (IPv4 sufficient for admin identification)
