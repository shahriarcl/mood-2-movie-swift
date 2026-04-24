import Foundation
import Observation

public struct AppConfigurationValues: Codable, Hashable {
    public var tmdbAPIKey: String
    public var anthropicAPIKey: String
    public var anthropicModel: String
    public var supabaseURL: String
    public var supabaseAnonKey: String

    public init(
        tmdbAPIKey: String = "",
        anthropicAPIKey: String = "",
        anthropicModel: String = "claude-3-5-haiku-latest",
        supabaseURL: String = "",
        supabaseAnonKey: String = ""
    ) {
        self.tmdbAPIKey = tmdbAPIKey
        self.anthropicAPIKey = anthropicAPIKey
        self.anthropicModel = anthropicModel
        self.supabaseURL = supabaseURL
        self.supabaseAnonKey = supabaseAnonKey
    }
}

@Observable
public final class AppConfigurationStore {
    public static let shared = AppConfigurationStore()

    public static func liveValues() -> AppConfigurationValues {
        ConfigurationPersistence().load()
    }

    public var values: AppConfigurationValues {
        didSet {
            save(values)
        }
    }

    private let store = ConfigurationPersistence()

    public init() {
        values = store.load()
    }

    public func resetToEnvironmentDefaults() {
        values = store.environmentDefaults()
    }

    private func save(_ values: AppConfigurationValues) {
        store.save(values)
    }
}

extension AppConfigurationStore: @unchecked Sendable {}

private final class ConfigurationPersistence {
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directory = baseURL.appendingPathComponent("Mood2MovieSwift", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        fileURL = directory.appendingPathComponent("configuration.json")

        decoder = JSONDecoder()
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() -> AppConfigurationValues {
        if let data = try? Data(contentsOf: fileURL),
           let values = try? decoder.decode(AppConfigurationValues.self, from: data) {
            return values
        }
        return environmentDefaults()
    }

    func save(_ values: AppConfigurationValues) {
        guard let data = try? encoder.encode(values) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    func environmentDefaults() -> AppConfigurationValues {
        let env = ProcessInfo.processInfo.environment
        return AppConfigurationValues(
            tmdbAPIKey: env["TMDB_API_KEY"] ?? "",
            anthropicAPIKey: env["ANTHROPIC_API_KEY"] ?? "",
            anthropicModel: env["ANTHROPIC_MODEL"] ?? "claude-3-5-haiku-latest",
            supabaseURL: env["SUPABASE_URL"] ?? "",
            supabaseAnonKey: env["SUPABASE_ANON_KEY"] ?? ""
        )
    }
}
