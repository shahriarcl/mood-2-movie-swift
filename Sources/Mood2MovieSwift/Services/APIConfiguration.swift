import Foundation

public struct APIConfiguration {
    public let tmdbAPIKey: String?
    public let anthropicAPIKey: String?
    public let anthropicModel: String

    public init(
        tmdbAPIKey: String? = nil,
        anthropicAPIKey: String? = nil,
        anthropicModel: String = "claude-3-5-haiku-latest"
    ) {
        self.tmdbAPIKey = tmdbAPIKey
        self.anthropicAPIKey = anthropicAPIKey
        self.anthropicModel = anthropicModel
    }

    public static var live: APIConfiguration {
        let env = ProcessInfo.processInfo.environment
        return APIConfiguration(
            tmdbAPIKey: env["TMDB_API_KEY"],
            anthropicAPIKey: env["ANTHROPIC_API_KEY"],
            anthropicModel: env["ANTHROPIC_MODEL"] ?? "claude-3-5-haiku-latest"
        )
    }

    public var hasTMDB: Bool {
        !(tmdbAPIKey?.isEmpty ?? true)
    }

    public var hasAnthropic: Bool {
        !(anthropicAPIKey?.isEmpty ?? true)
    }
}
