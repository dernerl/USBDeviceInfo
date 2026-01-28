import SwiftUI

struct HostInfoSection: View {
    let hostInfo: HostInfo?
    let macCopied: Bool
    let onCopyMAC: () -> Void

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
                    HStack(spacing: 8) {
                        Text(info.macAddress ?? "N/A")
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)

                        if info.macAddress != nil {
                            Button(action: onCopyMAC) {
                                HStack(spacing: 4) {
                                    Image(systemName: macCopied ? "checkmark" : "doc.on.doc")
                                    Text(macCopied ? "Copied!" : "Copy")
                                }
                                .font(.caption)
                                .contentTransition(.symbolEffect(.replace))
                            }
                            .buttonStyle(.bordered)
                            .tint(macCopied ? .green : nil)
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
