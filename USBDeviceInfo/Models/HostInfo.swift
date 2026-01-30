import Foundation

struct HostInfo {
    let computerName: String
    let hostName: String
    var localIP: String?
    var externalIP: String?
    var macAddress: String?
    var falconSensorLoaded: Bool?  // nil = nicht installiert, true/false = Status
}
