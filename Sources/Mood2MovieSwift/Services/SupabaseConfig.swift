import Foundation

public struct SupabaseConfig {
    public let url: URL?
    public let anonKey: String?

    public init(url: URL? = nil, anonKey: String? = nil) {
        self.url = url
        self.anonKey = anonKey
    }

    public static var live: SupabaseConfig {
        let env = ProcessInfo.processInfo.environment
        return SupabaseConfig(
            url: env["SUPABASE_URL"].flatMap(URL.init(string:)),
            anonKey: env["SUPABASE_ANON_KEY"]
        )
    }

    public var isConfigured: Bool {
        url != nil && !(anonKey?.isEmpty ?? true)
    }
}
