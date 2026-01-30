import Foundation

struct FalconInfoProvider {

    private let falconctlPath = "/Applications/Falcon.app/Contents/Resources/falconctl"

    func isSensorLoaded() async -> Bool? {
        guard FileManager.default.fileExists(atPath: falconctlPath) else {
            return nil  // Falcon nicht installiert
        }

        guard let output = await runFalconctl() else {
            return false
        }

        return parseSensorLoaded(from: output)
    }

    // MARK: - Private

    private func runFalconctl() async -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: falconctlPath)
        process.arguments = ["info"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                return nil
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    private func parseSensorLoaded(from xmlString: String) -> Bool {
        // Parse XML plist output for sensor_loaded key
        guard let data = xmlString.data(using: .utf8) else {
            return false
        }

        do {
            guard let plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: Any] else {
                return false
            }

            return plist["sensor_loaded"] as? Bool ?? false
        } catch {
            // Fallback: simple string search
            return xmlString.contains("<key>sensor_loaded</key>") &&
                   xmlString.contains("<true/>")
        }
    }
}
