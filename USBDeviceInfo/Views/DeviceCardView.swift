import SwiftUI

struct DeviceCardView: View {
    let device: USBDevice
    let isFalconActive: Bool
    let showCopied: Bool
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            Divider()
            detailsGrid
        }
        .padding(16)
        .background {
            if device.deviceType == .massStorage {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            }
        }
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

                    if device.isLikelyBlocked && isFalconActive {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.shield")
                            Text("Blocked")
                        }
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                        .help("This device may be blocked by Falcon Device Control")
                    }

                    if device.deviceType == .massStorage {
                        eligibilityBadge
                    }
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
            .disabled(!canCopyID)
            .help(canCopyID ? "Copy Combined ID" : eligibility.reason)
        }
    }

    private var eligibility: ExceptionEligibility { device.exceptionEligibility }

    /// Copying the ID of a mass storage device that cannot be released would
    /// only lead to a rejected self-service request.
    private var canCopyID: Bool {
        device.deviceType != .massStorage || eligibility.isEligible
    }

    private var eligibilityBadge: some View {
        let tint: Color = eligibility.isEligible ? .green : .orange
        return HStack(spacing: 3) {
            Image(systemName: eligibility.isEligible ? "checkmark.seal" : "xmark.seal")
            Text(eligibility.label)
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(tint.opacity(0.2))
        .foregroundStyle(tint)
        .clipShape(Capsule())
        .help(eligibility.reason)
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

    /// IDs in hex like system_profiler / System Information (0x1050).
    /// The Combined ID stays decimal: that is what Falcon Device Control expects.
    private func formatField(_ name: String, id: Int) -> String {
        let hexID = String(format: "0x%04x", id)
        return "\(name.isEmpty ? "Unknown" : name) (\(hexID))"
    }
}
