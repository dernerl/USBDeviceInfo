import SwiftUI

struct ConnectedDevicesSection: View {
    let devices: [USBDevice]
    let isFalconActive: Bool
    let copyFeedbackDeviceID: UUID?
    let onCopy: (USBDevice) -> Void

    /// Sorted devices: Mass Storage first, then by connection time
    private var sortedDevices: [USBDevice] {
        devices.sorted { a, b in
            if a.deviceType == .massStorage && b.deviceType != .massStorage {
                return true
            } else if a.deviceType != .massStorage && b.deviceType == .massStorage {
                return false
            }
            return a.connectedAt > b.connectedAt
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Connected Devices", systemImage: "cable.connector.horizontal")
                .font(.title2)
                .fontWeight(.semibold)

            if devices.isEmpty {
                emptyState
            } else {
                ForEach(sortedDevices) { device in
                    DeviceCardView(
                        device: device,
                        isFalconActive: isFalconActive,
                        showCopied: copyFeedbackDeviceID == device.id,
                        onCopy: { onCopy(device) }
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No USB Devices Connected", systemImage: "cable.connector.horizontal")
        } description: {
            Text("Connect a USB device to see its details and CrowdStrike Combined ID.")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}
