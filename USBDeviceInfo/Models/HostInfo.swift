import Foundation

struct HostInfo {
    let computerName: String
    let hostName: String
    var localIP: String?
    var externalIP: String?
    var macAddress: String?
    var falconSensorLoaded: Bool?  // nil = nicht installiert, true/false = Status
    var externalAdapters: [NetworkAdapter] = []
}

/// Ethernet adapter attached via USB or Thunderbolt (docking station, dongle).
/// Its MAC is what NAC tools like macmon see when the Mac is docked.
struct NetworkAdapter: Hashable {
    let name: String        // e.g. "USB 10/100/1G/2.5G LAN"
    let bsdName: String     // e.g. "en5"
    let macAddress: String
}
