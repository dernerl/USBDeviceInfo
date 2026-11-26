import Foundation
import SystemConfiguration
import IOKit

struct HostInfoProvider {

    func getHostInfo() async -> HostInfo {
        let computerName = getComputerName()
        let hostName = getLocalHostName()
        let localIP = getLocalIPAddress()
        let macAddress = getMACAddress()

        var info = HostInfo(
            computerName: computerName,
            hostName: hostName,
            localIP: localIP,
            externalIP: nil,
            macAddress: macAddress,
            externalAdapters: getExternalAdapters()
        )

        // Fetch external IP asynchronously
        info.externalIP = await fetchExternalIP()

        return info
    }

    // MARK: - External Network Adapters (Docks)

    /// Ethernet interfaces that are not built in and sit on a USB or PCIe device
    /// (USB dongles, Thunderbolt docks). Skips the Mac's own USB-C gadget
    /// interfaces (AppleUSBDeviceNCM) and virtual VM interfaces.
    func getExternalAdapters() -> [NetworkAdapter] {
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(
            kIOMainPortDefault, IOServiceMatching("IOEthernetInterface"), &iterator
        ) == KERN_SUCCESS else { return [] }
        defer { IOObjectRelease(iterator) }

        var adapters: [NetworkAdapter] = []
        var interface = IOIteratorNext(iterator)
        while interface != IO_OBJECT_NULL {
            defer {
                IOObjectRelease(interface)
                interface = IOIteratorNext(iterator)
            }
            guard registryBool(interface, "IOBuiltin") == false,
                  let bsdName = registryString(interface, "BSD Name"),
                  hasHardwareAncestor(interface),
                  let mac = macAddress(ofInterface: interface)
            else { continue }

            adapters.append(NetworkAdapter(
                name: displayName(forBSDName: bsdName) ?? bsdName,
                bsdName: bsdName,
                macAddress: mac
            ))
        }
        return adapters.sorted { $0.bsdName.localizedStandardCompare($1.bsdName) == .orderedAscending }
    }

    private func hasHardwareAncestor(_ entry: io_object_t) -> Bool {
        var current = entry
        IOObjectRetain(current)
        defer { IOObjectRelease(current) }

        while true {
            var parent: io_registry_entry_t = IO_OBJECT_NULL
            guard IORegistryEntryGetParentEntry(current, kIOServicePlane, &parent) == KERN_SUCCESS else {
                return false
            }
            IOObjectRelease(current)
            current = parent
            if IOObjectConformsTo(current, "IOUSBHostDevice") != 0
                || IOObjectConformsTo(current, "IOPCIDevice") != 0 {
                return true
            }
        }
    }

    private func macAddress(ofInterface interface: io_object_t) -> String? {
        var controller: io_object_t = IO_OBJECT_NULL
        guard IORegistryEntryGetParentEntry(interface, kIOServicePlane, &controller) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(controller) }
        guard let data = IORegistryEntryCreateCFProperty(
            controller, "IOMACAddress" as CFString, kCFAllocatorDefault, 0
        )?.takeRetainedValue() as? Data, data.count == 6 else { return nil }
        return data.map { String(format: "%02x", $0) }.joined(separator: ":")
    }

    private func displayName(forBSDName bsdName: String) -> String? {
        guard let all = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else { return nil }
        return all.first { SCNetworkInterfaceGetBSDName($0) as String? == bsdName }
            .flatMap { SCNetworkInterfaceGetLocalizedDisplayName($0) as String? }
    }

    private func registryString(_ entry: io_object_t, _ key: String) -> String? {
        IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?
            .takeRetainedValue() as? String
    }

    private func registryBool(_ entry: io_object_t, _ key: String) -> Bool? {
        IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?
            .takeRetainedValue() as? Bool
    }

    // MARK: - Computer Name

    private func getComputerName() -> String {
        (SCDynamicStoreCopyComputerName(nil, nil) as String?) ?? "Unknown"
    }

    // MARK: - Local Hostname (Bonjour)

    private func getLocalHostName() -> String {
        (SCDynamicStoreCopyLocalHostName(nil) as String?) ?? "Unknown"
    }

    // MARK: - Local IP Address

    private func getLocalIPAddress() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        var current: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = current {
            let interface = addr.pointee
            let family = interface.ifa_addr.pointee.sa_family

            if family == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                if name.hasPrefix("en") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let result = getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil, 0,
                        NI_NUMERICHOST
                    )
                    if result == 0 {
                        return String(cString: hostname)
                    }
                }
            }
            current = interface.ifa_next
        }
        return nil
    }

    // MARK: - External IP Address

    private func fetchExternalIP() async -> String? {
        guard let url = URL(string: "https://api.ipify.org") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }

    // MARK: - MAC Address

    private func getMACAddress() -> String? {
        // Get the BSD name of the active network interface (typically en0)
        let bsdName = getActiveBSDInterface() ?? "en0"

        // Create matching dictionary for the specific interface
        let matchingDict = IOBSDNameMatching(kIOMainPortDefault, 0, bsdName)

        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
        guard result == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != IO_OBJECT_NULL {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            // Walk up the I/O Registry tree to find the IOEthernetController parent
            var controllerService: io_object_t = IO_OBJECT_NULL
            if IORegistryEntryGetParentEntry(service, kIOServicePlane, &controllerService) == KERN_SUCCESS {
                defer { IOObjectRelease(controllerService) }

                // Read IOMACAddress from the controller
                if let macRef = IORegistryEntryCreateCFProperty(
                    controllerService,
                    "IOMACAddress" as CFString,
                    kCFAllocatorDefault,
                    0
                ) {
                    let macData = macRef.takeRetainedValue() as? Data ?? Data()
                    if macData.count == 6 {
                        return macData.map { String(format: "%02x", $0) }.joined(separator: ":")
                    }
                }
            }
        }

        return nil
    }

    // MARK: - Active Network Interface

    private func getActiveBSDInterface() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        var current: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = current {
            let interface = addr.pointee
            let family = interface.ifa_addr.pointee.sa_family

            // Look for IPv4 interface that is up and has an address
            if family == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // Prefer en0-en9 interfaces (Ethernet/WiFi)
                if name.hasPrefix("en") {
                    return name
                }
            }
            current = interface.ifa_next
        }
        return nil
    }
}
