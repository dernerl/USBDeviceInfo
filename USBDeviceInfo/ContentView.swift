import SwiftUI

struct ContentView: View {
    @State private var viewModel = DeviceListViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HostInfoSection(
                    hostInfo: viewModel.hostInfo,
                    macCopied: viewModel.macCopied,
                    onCopyMAC: { viewModel.copyMACAddress() }
                )

                ConnectedDevicesSection(
                    devices: viewModel.connectedDevices,
                    copyFeedbackDeviceID: viewModel.copyFeedbackDeviceID,
                    onCopy: { viewModel.copyCombinedID(for: $0) }
                )

                if !viewModel.recentDevices.isEmpty {
                    RecentDevicesSection(
                        devices: viewModel.recentDevices,
                        copyFeedbackDeviceID: viewModel.copyFeedbackDeviceID,
                        onCopy: { viewModel.copyCombinedID(for: $0) }
                    )
                }
            }
            .padding(20)
        }
        .frame(minWidth: 460, minHeight: 300)
        .toolbar {
            ToolbarItem {
                Button {
                    viewModel.refreshConnectedDevices()
                    viewModel.refreshHostInfo()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh USB devices and host info")
            }
        }
    }
}
