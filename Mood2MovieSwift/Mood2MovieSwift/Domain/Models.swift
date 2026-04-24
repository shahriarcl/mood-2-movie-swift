import Foundation

public enum MoodAudience: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case solo
    case couple
    case family
    case friends

    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .solo: "Solo"
        case .couple: "Couple"
        case .family: "Family"
        case .friends: "Friends"
        }
    }
}

public enum MoodVibe: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case feelGood = "feel-good"
    case thrilling = "thrilling"
    case mindBending = "mind-bending"
    case laughOutLoud = "laugh-out-loud"
    case cryItOut = "cry-it-out"
    case epicAdventure = "epic-adventure"

    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .feelGood: "Feel-good"
        case .thrilling: "Thrilling"
        case .mindBending: "Mind-bending"
        case .laughOutLoud: "Laugh-out-loud"
        case .cryItOut: "Cry it out"
        case .epicAdventure: "Epic adventure"
        }
    }
}

public enum MoodGenre: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case sciFi = "sci-fi"
    case romance
    case comedy
    case action
    case mystery
    case horror
    case fantasy
    case documentary
    case classic

    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .sciFi: "Sci-Fi"
        case .romance: "Romance"
        case .comedy: "Comedy"
        case .action: "Action"
        case .mystery: "Mystery"
        case .horror: "Horror"
        case .fantasy: "Fantasy"
        case .documentary: "Documentary"
        case .classic: "Classic"
        }
    }
}

public enum MoodDecade: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case forties = "40s"
    case fifties = "50s"
    case sixties = "60s"
    case seventies = "70s"
    case eighties = "80s"
    case nineties = "90s"

    public var id: String { rawValue }
    public var label: String { rawValue }
}

public struct MoodSelection: Codable, Hashable, Identifiable, Sendable {
    public var id: String {
        [audience.rawValue, vibe?.rawValue ?? "", genre.rawValue, decade?.rawValue ?? ""]
            .joined(separator: "|")
    }

    public var audience: MoodAudience
    public var vibe: MoodVibe?
    public var genre: MoodGenre
    public var decade: MoodDecade?

    public init(audience: MoodAudience, vibe: MoodVibe? = nil, genre: MoodGenre, decade: MoodDecade? = nil) {
        self.audience = audience
        self.vibe = vibe
        self.genre = genre
        self.decade = decade
    }
}

public struct MoodSelectionDraft: Hashable, Sendable {
    public var audience: MoodAudience?
    public var vibe: MoodVibe?
    public var genre: MoodGenre?
    public var decade: MoodDecade?

    public init(
        audience: MoodAudience? = nil,
        vibe: MoodVibe? = nil,
        genre: MoodGenre? = nil,
        decade: MoodDecade? = nil
    ) {
        self.audience = audience
        self.vibe = vibe
        self.genre = genre
        self.decade = decade
    }

    public var isComplete: Bool {
        guard let genre else { return false }
        if genre == .classic {
            return audience != nil && decade != nil
        }
        return audience != nil
    }

    public var resolved: MoodSelection? {
        guard let audience, let genre else { return nil }
        if genre == .classic {
            guard let decade else { return nil }
            return MoodSelection(audience: audience, vibe: vibe, genre: genre, decade: decade)
        }
        return MoodSelection(audience: audience, vibe: vibe, genre: genre, decade: nil)
    }
}

public enum AvailabilityType: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {
    case subscription
    case rent
    case buy

    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .subscription: "Streaming"
        case .rent: "Rent"
        case .buy: "Buy"
        }
    }
}

public struct Availability: Codable, Hashable, Identifiable, Sendable {
    public var id: String { [platformKey, type.rawValue].joined(separator: "|") }
    public let type: AvailabilityType
    public let platformName: String
    public let platformKey: String
}

public struct ProviderResult: Codable, Hashable, Sendable {
    public let providerId: Int
    public let type: AvailabilityType

    public init(providerId: Int, type: AvailabilityType) {
        self.providerId = providerId
        self.type = type
    }
}

public struct MovieResult: Codable, Hashable, Identifiable, Sendable {
    public var id: Int { tmdbId }
    public let tmdbId: Int
    public let title: String
    public let year: Int
    public let posterPath: String?
    public let reason: String
    public let availability: [Availability]
    public let primaryAvailability: Availability
    public let genre: MoodGenre
}

public enum MovieStatus: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {
    case watchlist
    case watched

    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .watchlist: "Watchlist"
        case .watched: "Watched"
        }
    }
}

public struct UserMovie: Codable, Hashable, Identifiable, Sendable {
    public var id: Int { tmdbId }
    public let tmdbId: Int
    public let title: String
    public let year: Int
    public let posterPath: String?
    public let genre: MoodGenre
    public var status: MovieStatus
    public var createdAt: Date
}

public struct CloudUserMovie: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var tmdbId: Int
    public var title: String
    public var year: Int
    public var posterPath: String?
    public var status: MovieStatus
    public var createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case tmdbId = "tmdb_id"
        case title
        case year
        case posterPath = "poster_path"
        case status
        case createdAt = "created_at"
    }
}

public struct CloudSession: Codable, Hashable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date?
    public let userId: String
    public let email: String?

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
        case user
    }

    private enum UserKeys: String, CodingKey {
        case id
        case email
    }

    public init(accessToken: String, refreshToken: String, expiresAt: Date?, userId: String, email: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.userId = userId
        self.email = email
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        if let expiresRaw = try? container.decode(Double.self, forKey: .expiresAt) {
            expiresAt = Date(timeIntervalSince1970: expiresRaw)
        } else if let expiresInt = try? container.decode(Int.self, forKey: .expiresAt) {
            expiresAt = Date(timeIntervalSince1970: TimeInterval(expiresInt))
        } else if let expiresIn = try? container.decode(Int.self, forKey: .expiresIn) {
            expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        } else {
            expiresAt = nil
        }

        let user = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        userId = try user.decode(String.self, forKey: .id)
        email = try? user.decode(String.self, forKey: .email)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        if let expiresAt {
            try container.encode(Int(expiresAt.timeIntervalSince1970), forKey: .expiresAt)
        }
        var user = container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        try user.encode(userId, forKey: .id)
        try user.encodeIfPresent(email, forKey: .email)
    }
}

public struct CloudAuthPayload: Codable {
    public let email: String
    public let password: String
}

public struct CloudMovieUpsert: Codable {
    public let userId: String
    public let tmdbId: Int
    public let title: String
    public let year: Int
    public let posterPath: String?
    public let status: MovieStatus
    public let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case tmdbId = "tmdb_id"
        case title
        case year
        case posterPath = "poster_path"
        case status
        case createdAt = "created_at"
    }
}

public struct Platform: Codable, Hashable, Identifiable, Sendable {
    public var id: String { key }
    public let key: String
    public let name: String
    public let tmdbId: Int
    public let symbolName: String
}

public struct CountryOption: Codable, Hashable, Identifiable, Sendable {
    public var id: String { code }
    public let code: String
    public let name: String
}

public struct UserPreferences: Codable, Hashable, Sendable {
    public var platforms: [String]
    public var country: String
    public var familySafe: Bool

    public init(platforms: [String] = [], country: String = "US", familySafe: Bool = false) {
        self.platforms = platforms
        self.country = country
        self.familySafe = familySafe
    }
}
