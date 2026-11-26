import Foundation

enum USBDeviceType: String, Codable, CaseIterable {
    case massStorage
    case hid
    case audio
    case video
    case printer
    case wireless
    case smartCard
    case communication
    case other

    /// Human-readable label for display
    var label: String {
        switch self {
        case .massStorage: "Mass Storage"
        case .hid: "HID"
        case .audio: "Audio"
        case .video: "Video"
        case .printer: "Printer"
        case .wireless: "Wireless"
        case .smartCard: "Smart Card"
        case .communication: "Communication"
        case .other: "Other"
        }
    }

    /// SF Symbol name for this device type
    var iconName: String {
        switch self {
        case .massStorage: "externaldrive.fill"
        case .hid: "keyboard"
        case .audio: "speaker.wave.2"
        case .video: "video"
        case .printer: "printer"
        case .wireless: "wifi"
        case .smartCard: "creditcard"
        case .communication: "antenna.radiowaves.left.and.right"
        case .other: "cable.connector.horizontal"
        }
    }

    /// Map USB interface class code to device type
    static func from(interfaceClass: Int) -> USBDeviceType {
        switch interfaceClass {
        case 0x01: .audio
        case 0x02: .communication
        case 0x03: .hid
        case 0x07: .printer
        case 0x08: .massStorage
        case 0x0B: .smartCard
        case 0x0E: .video
        case 0xE0: .wireless
        default: .other
        }
    }
}

struct USBDevice: Identifiable, Codable, Hashable {
    let id: UUID
    let vendorID: Int
    let productID: Int
    let serialNumber: String
    let vendorName: String
    let productName: String
    let connectedAt: Date
    var deviceType: USBDeviceType
    var volumeName: String?

    /// CrowdStrike Falcon Combined ID: VendorID_ProductID_SerialNumber
    var combinedID: String {
        let serial = serialNumber.isEmpty ? "N/A" : serialNumber
        return "\(vendorID)_\(productID)_\(serial)"
    }

    /// Human-readable display name
    var displayName: String {
        if !productName.isEmpty {
            return productName
        } else if !vendorName.isEmpty {
            return "\(vendorName) Device"
        } else {
            return "Unknown USB Device"
        }
    }

    /// Stable identity for deduplication (same physical device)
    var fingerprint: String {
        "\(vendorID)_\(productID)_\(serialNumber)"
    }

    /// Returns true if this mass storage device has no mounted volume
    /// (may indicate blocking by Falcon Device Control when Falcon is active)
    var isLikelyBlocked: Bool {
        deviceType == .massStorage && volumeName == nil
    }

    /// Whether a Falcon Device Control exception can target exactly this device
    var exceptionEligibility: ExceptionEligibility {
        ExceptionEligibility(serialNumber: serialNumber)
    }
}

/// Whether a serial number identifies a device uniquely enough for a
/// Device Control exception. Falcon matches only VID, PID and serial — a
/// missing or placeholder serial would release every identical device.
/// Rules must match the server-side self-service release (see issue #10).
enum ExceptionEligibility: Equatable {
    case eligible
    case missingSerial
    case placeholderSerial

    /// Known controller placeholder serials (prefix match).
    /// Keep in sync with the self-service release.
    static let placeholderPattern = "^(CCYYMMDDHHmmSS|0123456789)"

    init(serialNumber: String) {
        let serial = serialNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let withoutLeadingZeros = serial.drop(while: { $0 == "0" })

        if serial.isEmpty {
            self = .missingSerial
        } else if withoutLeadingZeros.count < 3
                    || Set(serial).count == 1
                    || serial.range(of: Self.placeholderPattern, options: .regularExpression) != nil {
            self = .placeholderSerial
        } else {
            self = .eligible
        }
    }

    var isEligible: Bool { self == .eligible }

    var label: String {
        isEligible ? "Freigabe möglich" : "Keine Freigabe möglich"
    }

    var reason: String {
        switch self {
        case .eligible:
            "Die Seriennummer ist eindeutig genug für eine Freigabe."
        case .missingSerial:
            "Der Stick hat keine Seriennummer. Eine Freigabe würde alle baugleichen Sticks freigeben."
        case .placeholderSerial:
            "Die Seriennummer ist ein Platzhalter des Herstellers und nicht eindeutig."
        }
    }
}
