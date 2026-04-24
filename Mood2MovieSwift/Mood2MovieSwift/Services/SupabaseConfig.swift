import Foundation

public struct SupabaseConfig {
    public let url: URL?
    public let anonKey: String?

    public init(url: URL? = nil, anonKey: String? = nil) {
        self.url = url
        self.anonKey = anonKey
    }

    public static var live: SupabaseConfig {
        let values = AppConfigurationStore.shared.values
        return SupabaseConfig(
            url: values.supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: values.supabaseURL),
            anonKey: values.supabaseAnonKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : values.supabaseAnonKey
        )
    }

    public var isConfigured: Bool {
        url != nil && !(anonKey?.isEmpty ?? true)
    }
}
