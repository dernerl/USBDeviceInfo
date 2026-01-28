import SwiftUI

struct ConnectedDevicesSection: View {
    let devices: [USBDevice]
    let copyFeedbackDeviceID: UUID?
    let onCopy: (USBDevice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Connected Devices", systemImage: "cable.connector.horizontal")
                .font(.title2)
                .fontWeight(.semibold)

            if devices.isEmpty {
                emptyState
            } else {
                ForEach(devices) { device in
                    DeviceCardView(
                        device: device,
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
