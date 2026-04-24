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
        let values = AppConfigurationStore.liveValues()
        return APIConfiguration(
            tmdbAPIKey: values.tmdbAPIKey.isEmpty ? nil : values.tmdbAPIKey,
            anthropicAPIKey: values.anthropicAPIKey.isEmpty ? nil : values.anthropicAPIKey,
            anthropicModel: values.anthropicModel.isEmpty ? "claude-3-5-haiku-latest" : values.anthropicModel
        )
    }

    public var hasTMDB: Bool {
        !(tmdbAPIKey?.isEmpty ?? true)
    }

    public var hasAnthropic: Bool {
        !(anthropicAPIKey?.isEmpty ?? true)
    }
}
