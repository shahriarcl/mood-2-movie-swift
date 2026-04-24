import Foundation

public enum MoodAudience: String, CaseIterable, Codable, Hashable, Identifiable {
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

public enum MoodVibe: String, CaseIterable, Codable, Hashable, Identifiable {
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

public enum MoodGenre: String, CaseIterable, Codable, Hashable, Identifiable {
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

public enum MoodDecade: String, CaseIterable, Codable, Hashable, Identifiable {
    case forties = "40s"
    case fifties = "50s"
    case sixties = "60s"
    case seventies = "70s"
    case eighties = "80s"
    case nineties = "90s"

    public var id: String { rawValue }
    public var label: String { rawValue }
}

public struct MoodSelection: Codable, Hashable, Identifiable {
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

public struct MoodSelectionDraft: Hashable {
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

public enum AvailabilityType: String, Codable, Hashable, CaseIterable, Identifiable {
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

public struct Availability: Codable, Hashable, Identifiable {
    public var id: String { [platformKey, type.rawValue].joined(separator: "|") }
    public let type: AvailabilityType
    public let platformName: String
    public let platformKey: String
}

public struct MovieResult: Codable, Hashable, Identifiable {
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

public enum MovieStatus: String, Codable, Hashable, CaseIterable, Identifiable {
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

public struct UserMovie: Codable, Hashable, Identifiable {
    public var id: Int { tmdbId }
    public let tmdbId: Int
    public let title: String
    public let year: Int
    public let posterPath: String?
    public let genre: MoodGenre
    public var status: MovieStatus
    public let createdAt: Date
}

public struct Platform: Codable, Hashable, Identifiable {
    public var id: String { key }
    public let key: String
    public let name: String
    public let tmdbId: Int
    public let symbolName: String
}

public struct CountryOption: Codable, Hashable, Identifiable {
    public var id: String { code }
    public let code: String
    public let name: String
}

public struct UserPreferences: Codable, Hashable {
    public var platforms: [String]
    public var country: String
    public var familySafe: Bool

    public init(platforms: [String] = [], country: String = "US", familySafe: Bool = false) {
        self.platforms = platforms
        self.country = country
        self.familySafe = familySafe
    }
}
