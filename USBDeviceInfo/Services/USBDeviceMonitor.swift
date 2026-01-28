import Foundation
import IOKit
import IOKit.usb
import DiskArbitration

final class USBDeviceMonitor {

    var onDevicesChanged: (@Sendable () -> Void)?

    private var notificationPort: IONotificationPortRef?
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0

    // MARK: - Enumeration

    /// Returns all currently connected USB devices, filtering out hubs and virtual devices.
    func getConnectedDevices() -> [USBDevice] {
        var devices: [USBDevice] = []

        guard let matchingDict = IOServiceMatching("IOUSBHostDevice") else { return devices }

        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
        guard result == KERN_SUCCESS else { return devices }
        defer { IOObjectRelease(iterator) }

        var service: io_object_t = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            if let device = extractDeviceInfo(from: service) {
                devices.append(device)
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        return devices
    }

    /// Re-resolve volume names for devices that have nil volumeName.
    /// Call after a short delay to allow mount to complete.
    func resolveVolumeNames(for devices: [USBDevice]) -> [USBDevice] {
        devices.map { device in
            guard device.deviceType == .massStorage, device.volumeName == nil else { return device }
            var updated = device
            updated.volumeName = resolveVolumeName(vendorID: device.vendorID, productID: device.productID)
            return updated
        }
    }

    // MARK: - Real-Time Monitoring

    func startMonitoring() {
        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        guard let port = notificationPort else { return }

        let runLoopSource = IONotificationPortGetRunLoopSource(port).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .defaultMode)

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        // Device connected notifications
        let matchAdd = IOServiceMatching("IOUSBHostDevice")
        IOServiceAddMatchingNotification(
            port,
            kIOFirstMatchNotification,
            matchAdd,
            Self.deviceNotificationCallback,
            selfPtr,
            &addedIterator
        )
        drainIterator(addedIterator)

        // Device disconnected notifications
        let matchRemove = IOServiceMatching("IOUSBHostDevice")
        IOServiceAddMatchingNotification(
            port,
            kIOTerminatedNotification,
            matchRemove,
            Self.deviceNotificationCallback,
            selfPtr,
            &removedIterator
        )
        drainIterator(removedIterator)
    }

    func stopMonitoring() {
        if addedIterator != IO_OBJECT_NULL {
            IOObjectRelease(addedIterator)
            addedIterator = 0
        }
        if removedIterator != IO_OBJECT_NULL {
            IOObjectRelease(removedIterator)
            removedIterator = 0
        }
        if let port = notificationPort {
            IONotificationPortDestroy(port)
            notificationPort = nil
        }
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Private

    private static let deviceNotificationCallback: IOServiceMatchingCallback = { refcon, iterator in
        guard let refcon else { return }
        let monitor = Unmanaged<USBDeviceMonitor>.fromOpaque(refcon).takeUnretainedValue()

        // Must drain the iterator to re-arm the notification
        var entry: io_object_t = IOIteratorNext(iterator)
        while entry != IO_OBJECT_NULL {
            IOObjectRelease(entry)
            entry = IOIteratorNext(iterator)
        }

        monitor.onDevicesChanged?()
    }

    private func drainIterator(_ iterator: io_iterator_t) {
        var entry = IOIteratorNext(iterator)
        while entry != IO_OBJECT_NULL {
            IOObjectRelease(entry)
            entry = IOIteratorNext(iterator)
        }
    }

    private func extractDeviceInfo(from service: io_object_t) -> USBDevice? {
        let vendorID = intProperty(service, key: "idVendor") ?? 0
        let productID = intProperty(service, key: "idProduct") ?? 0
        let deviceClass = intProperty(service, key: "bDeviceClass") ?? 0

        // Filter out hubs (class 9) and virtual/internal devices (vendorID 0)
        guard vendorID > 0, deviceClass != 9 else { return nil }

        let serialNumber = stringProperty(service, key: "USB Serial Number") ?? ""
        let vendorName = stringProperty(service, key: "USB Vendor Name") ?? ""
        let productName = stringProperty(service, key: "USB Product Name") ?? ""

        // Detect device type from interface class on child nodes
        let deviceType = detectDeviceType(from: service, deviceClass: deviceClass)

        // Resolve volume name for mass storage devices
        let volumeName: String? = if deviceType == .massStorage {
            resolveVolumeNameFromService(service)
        } else {
            nil
        }

        return USBDevice(
            id: UUID(),
            vendorID: vendorID,
            productID: productID,
            serialNumber: serialNumber,
            vendorName: vendorName,
            productName: productName,
            connectedAt: Date(),
            deviceType: deviceType,
            volumeName: volumeName
        )
    }

    // MARK: - Device Type Detection

    /// Detect device type by reading bInterfaceClass from child IOUSBHostInterface nodes.
    /// Falls back to bDeviceClass if no interfaces found.
    private func detectDeviceType(from service: io_object_t, deviceClass: Int) -> USBDeviceType {
        var childIterator: io_iterator_t = 0
        let result = IORegistryEntryGetChildIterator(service, kIOServicePlane, &childIterator)
        guard result == KERN_SUCCESS else {
            return deviceClass > 0 ? USBDeviceType.from(interfaceClass: deviceClass) : .other
        }
        defer { IOObjectRelease(childIterator) }

        var bestType: USBDeviceType = .other
        var foundInterface = false

        var child: io_object_t = IOIteratorNext(childIterator)
        while child != IO_OBJECT_NULL {
            defer {
                IOObjectRelease(child)
                child = IOIteratorNext(childIterator)
            }

            // Check if this child is an IOUSBHostInterface
            if let interfaceClass = intProperty(child, key: "bInterfaceClass") {
                foundInterface = true
                let type = USBDeviceType.from(interfaceClass: interfaceClass)
                // Prefer mass storage over other types (most useful for identification)
                if type == .massStorage {
                    return .massStorage
                }
                if bestType == .other {
                    bestType = type
                }
            }
        }

        if foundInterface {
            return bestType
        }

        // Fallback to device class if no interface children found
        return deviceClass > 0 ? USBDeviceType.from(interfaceClass: deviceClass) : .other
    }

    // MARK: - Volume Name Resolution

    /// Resolve volume name from an IORegistry service by finding BSD Name in child hierarchy.
    private func resolveVolumeNameFromService(_ service: io_object_t) -> String? {
        // Search recursively for BSD Name in child hierarchy
        guard let bsdNameRef = IORegistryEntrySearchCFProperty(
            service,
            kIOServicePlane,
            "BSD Name" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)
        ) else { return nil }

        guard let bsdName = bsdNameRef as? String else { return nil }
        return volumeNameFromBSDName(bsdName)
    }

    /// Resolve volume name by scanning IORegistry for a mass storage device matching vendor/product ID.
    private func resolveVolumeName(vendorID: Int, productID: Int) -> String? {
        guard let matchingDict = IOServiceMatching("IOUSBHostDevice") else { return nil }

        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
        guard result == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        var service: io_object_t = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            let vid = intProperty(service, key: "idVendor") ?? 0
            let pid = intProperty(service, key: "idProduct") ?? 0
            if vid == vendorID && pid == productID {
                if let name = resolveVolumeNameFromService(service) {
                    return name
                }
            }
        }

        return nil
    }

    /// Use DiskArbitration to get volume name from a BSD device name.
    private func volumeNameFromBSDName(_ bsdName: String) -> String? {
        guard let session = DASessionCreate(kCFAllocatorDefault) else { return nil }
        guard let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, bsdName) else { return nil }
        guard let desc = DADiskCopyDescription(disk) as? [String: Any] else { return nil }
        return desc[kDADiskDescriptionVolumeNameKey as String] as? String
    }

    // MARK: - Property Helpers

    private func stringProperty(_ service: io_object_t, key: String) -> String? {
        IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?
            .takeRetainedValue() as? String
    }

    private func intProperty(_ service: io_object_t, key: String) -> Int? {
        IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?
            .takeRetainedValue() as? Int
    }
}
