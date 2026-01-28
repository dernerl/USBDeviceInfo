import Foundation

struct DeviceHistoryStore {
    private let key = "USBDeviceHistory"
    private let maxCount = 5
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadHistory() -> [USBDevice] {
        guard let data = defaults.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([USBDevice].self, from: data)) ?? []
    }

    func addToHistory(_ device: USBDevice) {
        var history = loadHistory()

        // Remove existing entry with same fingerprint to update timestamp
        history.removeAll { $0.fingerprint == device.fingerprint }

        // Insert at front (most recent first)
        history.insert(device, at: 0)

        // Trim to max
        if history.count > maxCount {
            history = Array(history.prefix(maxCount))
        }

        save(history)
    }

    private func save(_ history: [USBDevice]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(history) {
            defaults.set(data, forKey: key)
        }
    }
}
