import SwiftUI

struct HostInfoSection: View {
    let hostInfo: HostInfo?
    let copiedMAC: String?
    let onCopyMAC: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Host Information", systemImage: "desktopcomputer")
                .font(.title2)
                .fontWeight(.semibold)

            if let info = hostInfo {
                hostCard(info)
            } else {
                loadingCard
            }
        }
    }

    // MARK: - Subviews

    private func hostCard(_ info: HostInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with computer name
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.computerName)
                        .font(.headline)
                    Text(info.hostName + ".local")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // Details grid
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    Text("Local IP")
                        .foregroundStyle(.secondary)
                    Text(info.localIP ?? "N/A")
                }

                GridRow {
                    Text("External IP")
                        .foregroundStyle(.secondary)
                    if let externalIP = info.externalIP {
                        Text(externalIP)
                    } else {
                        HStack(spacing: 4) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Loading...")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                GridRow {
                    Text("MAC Address")
                        .foregroundStyle(.secondary)
                    macValue(info.macAddress)
                }

                // Docking stations / USB LAN adapters (issue #8)
                ForEach(info.externalAdapters, id: \.self) { adapter in
                    GridRow {
                        Text("Dock MAC")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            macValue(adapter.macAddress)
                            Text("\(adapter.name) (\(adapter.bsdName))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let falconLoaded = info.falconSensorLoaded {
                    GridRow {
                        Text("Falcon Sensor")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Circle()
                                .fill(falconLoaded ? .green : .orange)
                                .frame(width: 8, height: 8)
                            Text(falconLoaded ? "Active" : "Inactive")
                        }
                    }
                }
            }
            .font(.callout)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func macValue(_ mac: String?) -> some View {
        HStack(spacing: 8) {
            Text(mac ?? "N/A")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)

            if let mac {
                let copied = copiedMAC == mac
                Button { onCopyMAC(mac) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy")
                    }
                    .font(.caption)
                    .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.bordered)
                .tint(copied ? .green : nil)
            }
        }
    }

    private var loadingCard: some View {
        HStack {
            ProgressView()
                .controlSize(.small)
            Text("Loading host information...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
