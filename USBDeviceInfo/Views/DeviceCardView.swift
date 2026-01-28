import SwiftUI

struct DeviceCardView: View {
    let device: USBDevice
    let showCopied: Bool
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            Divider()
            detailsGrid
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Image(systemName: device.deviceType.iconName)
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(device.displayName)
                        .font(.headline)

                    Text(device.deviceType.label)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(Capsule())
                }

                if let volumeName = device.volumeName {
                    HStack(spacing: 4) {
                        Image(systemName: "internaldrive")
                            .font(.caption)
                        Text(volumeName)
                            .fontWeight(.medium)
                    }
                    .font(.callout)
                    .foregroundStyle(.blue)
                }
            }

            Spacer()

            Button(action: onCopy) {
                HStack(spacing: 4) {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    Text(showCopied ? "Copied!" : "Copy ID")
                }
                .font(.caption)
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .tint(showCopied ? .green : nil)
        }
    }

    private var detailsGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
            detailRow("Vendor", value: formatField(device.vendorName, id: device.vendorID))
            detailRow("Product", value: formatField(device.productName, id: device.productID))

            GridRow {
                Text("Serial")
                    .foregroundStyle(.secondary)
                if device.serialNumber.isEmpty {
                    HStack(spacing: 4) {
                        Text("N/A")
                            .foregroundStyle(.secondary)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                            .help("No serial number — may not work with Falcon Device Control")
                    }
                } else {
                    Text(device.serialNumber)
                }
            }

            GridRow {
                Text("Combined ID")
                    .foregroundStyle(.secondary)
                Text(device.combinedID)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
                    .textSelection(.enabled)
            }
        }
        .font(.callout)
    }

    // MARK: - Helpers

    private func detailRow(_ label: String, value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }

    private func formatField(_ name: String, id: Int) -> String {
        if name.isEmpty {
            return "Unknown (\(id))"
        }
        return "\(name) (\(id))"
    }
}
