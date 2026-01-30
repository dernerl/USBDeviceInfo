import SwiftUI

struct RecentDevicesSection: View {
    let devices: [USBDevice]
    let isFalconActive: Bool
    let copyFeedbackDeviceID: UUID?
    let onCopy: (USBDevice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent Devices", systemImage: "clock")
                .font(.title2)
                .fontWeight(.semibold)

            ForEach(devices) { device in
                DeviceCardView(
                    device: device,
                    isFalconActive: isFalconActive,
                    showCopied: copyFeedbackDeviceID == device.id,
                    onCopy: { onCopy(device) }
                )
                .opacity(0.75)
            }
        }
    }
}
