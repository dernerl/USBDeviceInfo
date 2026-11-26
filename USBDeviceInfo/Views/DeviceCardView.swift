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
                        badge(
                            "Blocked",
                            icon: "exclamationmark.shield",
                            tint: .orange,
                            help: "This device may be blocked by Falcon Device Control"
                        )
                    }

                    if isAccessAllowed {
                        badge(
                            "Zugriff erlaubt",
                            icon: "checkmark.shield",
                            tint: .green,
                            help: "Falcon lässt diesen Stick zu, z. B. durch eine Freigabe. Ob sie befristet ist, siehst du im Ticket."
                        )
                    } else if device.deviceType == .massStorage {
                        badge(
                            eligibility.label,
                            icon: eligibility.isEligible ? "checkmark.seal" : "xmark.seal",
                            tint: eligibility.isEligible ? .green : .orange,
                            help: eligibility.reason
                        )
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

    /// Mounted while Falcon is active: Device Control lets the stick through.
    /// Whether that is an exception (and when it expires) is not readable locally:
    /// the policy is only in root-only, encrypted Falcon channel files.
    private var isAccessAllowed: Bool {
        device.deviceType == .massStorage && device.volumeName != nil && isFalconActive
    }

    private func badge(_ label: String, icon: String, tint: Color, help: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(tint.opacity(0.2))
        .foregroundStyle(tint)
        .clipShape(Capsule())
        .help(help)
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
