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
            macAddress: macAddress
        )

        // Fetch external IP asynchronously
        info.externalIP = await fetchExternalIP()

        return info
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
        // Find the primary Ethernet interface via IOKit
        let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary

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

            // Check if this is the primary interface by looking at parent's IOPrimaryInterface
            var parentService: io_object_t = IO_OBJECT_NULL
            let parentResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService)
            guard parentResult == KERN_SUCCESS else { continue }
            defer { IOObjectRelease(parentService) }

            if let primaryRef = IORegistryEntryCreateCFProperty(
                parentService,
                "IOPrimaryInterface" as CFString,
                kCFAllocatorDefault,
                0
            ) {
                let isPrimary = primaryRef.takeRetainedValue() as? Bool ?? false
                guard isPrimary else { continue }
            } else {
                continue
            }

            // Read IOMACAddress
            if let macRef = IORegistryEntryCreateCFProperty(
                service,
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

        return nil
    }
}
