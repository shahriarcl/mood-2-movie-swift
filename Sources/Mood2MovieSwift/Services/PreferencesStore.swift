import Foundation

public final class PreferencesStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = baseURL.appendingPathComponent("Mood2MovieSwift", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        self.fileURL = directory.appendingPathComponent("preferences.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        self.decoder = decoder
    }

    public func load() -> UserPreferences {
        guard let data = try? Data(contentsOf: fileURL),
              let prefs = try? decoder.decode(UserPreferences.self, from: data) else {
            return UserPreferences(platforms: MoodCatalog.defaultPlatforms, country: "US", familySafe: false)
        }
        return prefs
    }

    public func save(_ preferences: UserPreferences) {
        guard let data = try? encoder.encode(preferences) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
