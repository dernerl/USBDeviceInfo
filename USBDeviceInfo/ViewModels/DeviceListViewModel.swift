import Foundation
import AppKit
import Observation

@Observable
@MainActor
final class DeviceListViewModel {

    private(set) var connectedDevices: [USBDevice] = []
    private(set) var recentDevices: [USBDevice] = []
    private(set) var hostInfo: HostInfo?
    var copyFeedbackDeviceID: UUID?
    var macCopied = false

    private let monitor = USBDeviceMonitor()
    private let historyStore = DeviceHistoryStore()
    private let hostInfoProvider = HostInfoProvider()
    private var debounceTask: Task<Void, Never>?
    private var volumeRetryTask: Task<Void, Never>?

    init() {
        refreshConnectedDevices()

        monitor.onDevicesChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.scheduleRefresh()
            }
        }
        monitor.startMonitoring()

        Task {
            await loadHostInfo()
        }
    }

    func refreshConnectedDevices() {
        let devices = monitor.getConnectedDevices()
        connectedDevices = devices

        for device in devices {
            historyStore.addToHistory(device)
        }

        reloadHistory()

        // Schedule volume name retry for mass storage devices with nil volumeName
        scheduleVolumeNameRetry()
    }

    func refreshHostInfo() {
        Task {
            await loadHostInfo()
        }
    }

    func copyCombinedID(for device: USBDevice) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(device.combinedID, forType: .string)

        copyFeedbackDeviceID = device.id

        Task { [weak self, deviceID = device.id] in
            try? await Task.sleep(for: .seconds(1.5))
            if self?.copyFeedbackDeviceID == deviceID {
                self?.copyFeedbackDeviceID = nil
            }
        }
    }

    func copyMACAddress() {
        guard let mac = hostInfo?.macAddress else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(mac, forType: .string)

        macCopied = true

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            self?.macCopied = false
        }
    }

    // MARK: - Private

    private func loadHostInfo() async {
        let info = await hostInfoProvider.getHostInfo()
        hostInfo = info
    }

    private func reloadHistory() {
        let history = historyStore.loadHistory()
        let connectedFingerprints = Set(connectedDevices.map(\.fingerprint))
        recentDevices = history.filter { !connectedFingerprints.contains($0.fingerprint) }
    }

    private func scheduleRefresh() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self?.refreshConnectedDevices()
        }
    }

    private func scheduleVolumeNameRetry() {
        let hasMissingVolumes = connectedDevices.contains {
            $0.deviceType == .massStorage && $0.volumeName == nil
        }
        guard hasMissingVolumes else { return }

        volumeRetryTask?.cancel()
        volumeRetryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled, let self else { return }

            let resolved = self.monitor.resolveVolumeNames(for: self.connectedDevices)
            self.connectedDevices = resolved

            // Update history with resolved volume names
            for device in resolved where device.volumeName != nil {
                self.historyStore.addToHistory(device)
            }
            self.reloadHistory()
        }
    }
}
