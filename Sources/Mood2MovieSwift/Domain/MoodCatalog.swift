import Foundation

public enum MoodCatalog {
    public static let genreMap: [Int: MoodGenre] = [
        878: .sciFi,
        10749: .romance,
        35: .comedy,
        28: .action,
        9648: .mystery,
        27: .horror,
        14: .fantasy,
        99: .documentary
    ]

    public static let platforms: [Platform] = [
        Platform(key: "netflix", name: "Netflix", tmdbId: 8, symbolName: "play.rectangle.fill"),
        Platform(key: "prime", name: "Prime Video", tmdbId: 9, symbolName: "shippingbox.fill"),
        Platform(key: "disney", name: "Disney+", tmdbId: 337, symbolName: "sparkles.tv.fill"),
        Platform(key: "hulu", name: "Hulu", tmdbId: 15, symbolName: "film.stack.fill"),
        Platform(key: "max", name: "Max", tmdbId: 1899, symbolName: "h.circle.fill"),
        Platform(key: "apple-tv", name: "Apple TV+", tmdbId: 350, symbolName: "apple.logo"),
        Platform(key: "peacock", name: "Peacock", tmdbId: 386, symbolName: "feather.fill"),
        Platform(key: "paramount", name: "Paramount+", tmdbId: 531, symbolName: "mountain.2.fill")
    ]

    public static let countries: [CountryOption] = [
        CountryOption(code: "US", name: "United States"),
        CountryOption(code: "GB", name: "United Kingdom"),
        CountryOption(code: "CA", name: "Canada"),
        CountryOption(code: "AU", name: "Australia"),
        CountryOption(code: "DE", name: "Germany"),
        CountryOption(code: "FR", name: "France"),
        CountryOption(code: "IN", name: "India"),
        CountryOption(code: "BR", name: "Brazil"),
        CountryOption(code: "MX", name: "Mexico"),
        CountryOption(code: "JP", name: "Japan")
    ]

    public static let defaultPlatforms = ["netflix", "prime", "disney"]

    public static let sampleMovies: [MovieBlueprint] = [
        .init(id: 201, title: "Arrival", year: 2016, genre: .sciFi, vibes: [.mindBending, .cryItOut], audiences: [.solo, .couple], decades: [.nineties], availability: [.subscription("Apple TV+"), .rent("Prime Video")], reason: "A thoughtful first-contact story with a human heart."),
        .init(id: 202, title: "Interstellar", year: 2014, genre: .sciFi, vibes: [.epicAdventure, .mindBending], audiences: [.solo, .couple, .family], decades: [.nineties], availability: [.subscription("Netflix"), .rent("Prime Video")], reason: "Big ideas, emotional stakes, and a genuinely cosmic scale."),
        .init(id: 203, title: "Ex Machina", year: 2014, genre: .sciFi, vibes: [.thrilling, .mindBending], audiences: [.solo, .couple], decades: [.nineties], availability: [.subscription("Max"), .rent("Apple TV+")], reason: "Tense, sleek, and perfect when you want your sci-fi unsettling."),
        .init(id: 204, title: "Before Sunrise", year: 1995, genre: .romance, vibes: [.feelGood, .cryItOut], audiences: [.couple, .solo], decades: [.nineties], availability: [.subscription("Max"), .buy("Apple TV+")], reason: "A conversation-first romance that feels beautifully intimate."),
        .init(id: 205, title: "La La Land", year: 2016, genre: .romance, vibes: [.feelGood, .cryItOut], audiences: [.couple, .friends], decades: [.nineties], availability: [.subscription("Disney+"), .rent("Prime Video")], reason: "Bright, romantic, and a little wistful in the best way."),
        .init(id: 206, title: "Palm Springs", year: 2020, genre: .comedy, vibes: [.laughOutLoud, .mindBending], audiences: [.couple, .friends], decades: [.nineties], availability: [.subscription("Hulu"), .buy("Prime Video")], reason: "A playful loop comedy that lands perfectly for a low-pressure night."),
        .init(id: 207, title: "Paddington 2", year: 2017, genre: .comedy, vibes: [.feelGood], audiences: [.family, .friends], decades: [.nineties], availability: [.subscription("Netflix"), .buy("Apple TV+")], reason: "Warm, charming, and basically the gold standard for feel-good movies."),
        .init(id: 208, title: "Mad Max: Fury Road", year: 2015, genre: .action, vibes: [.epicAdventure, .thrilling], audiences: [.solo, .friends], decades: [.nineties], availability: [.subscription("Max"), .rent("Prime Video")], reason: "Pure kinetic energy with relentless momentum."),
        .init(id: 209, title: "Top Gun: Maverick", year: 2022, genre: .action, vibes: [.epicAdventure, .feelGood], audiences: [.friends, .family], decades: [.nineties], availability: [.subscription("Paramount+")], reason: "A crowd-pleaser that absolutely understands spectacle."),
        .init(id: 210, title: "Knives Out", year: 2019, genre: .mystery, vibes: [.thrilling, .laughOutLoud], audiences: [.family, .friends, .couple], decades: [.nineties], availability: [.subscription("Netflix"), .rent("Prime Video")], reason: "A sharp, playful whodunit that keeps the whole room engaged."),
        .init(id: 211, title: "Zodiac", year: 2007, genre: .mystery, vibes: [.thrilling, .mindBending], audiences: [.solo, .couple], decades: [.nineties], availability: [.rent("Apple TV+"), .buy("Prime Video")], reason: "A slow-burn mystery that gets under your skin."),
        .init(id: 212, title: "Get Out", year: 2017, genre: .horror, vibes: [.thrilling, .mindBending], audiences: [.solo, .friends], decades: [.nineties], availability: [.subscription("Peacock"), .rent("Prime Video")], reason: "A sharp, elevated horror pick that keeps you glued to the screen."),
        .init(id: 213, title: "A Quiet Place", year: 2018, genre: .horror, vibes: [.thrilling], audiences: [.family, .couple], decades: [.nineties], availability: [.subscription("Paramount+")], reason: "Tension, silence, and smart emotional beats."),
        .init(id: 214, title: "The Princess Bride", year: 1987, genre: .fantasy, vibes: [.feelGood, .laughOutLoud], audiences: [.family, .couple], decades: [.eighties], availability: [.subscription("Disney+"), .buy("Prime Video")], reason: "A timeless adventure with endless charm."),
        .init(id: 215, title: "Spirited Away", year: 2001, genre: .fantasy, vibes: [.mindBending, .feelGood], audiences: [.family, .solo], decades: [.nineties], availability: [.rent("Apple TV+"), .buy("Prime Video")], reason: "Magical, immersive, and unlike anything else on the shelf."),
        .init(id: 216, title: "Free Solo", year: 2018, genre: .documentary, vibes: [.thrilling, .epicAdventure], audiences: [.solo, .family], decades: [.nineties], availability: [.subscription("Disney+")], reason: "A documentary that plays like a real-life edge-of-your-seat thriller."),
        .init(id: 217, title: "Apollo 11", year: 2019, genre: .documentary, vibes: [.epicAdventure, .feelGood], audiences: [.family, .solo], decades: [.nineties], availability: [.subscription("Max"), .rent("Prime Video")], reason: "A gorgeous time capsule of one of humanity's biggest wins."),
        .init(id: 218, title: "Casablanca", year: 1942, genre: .classic, vibes: [.cryItOut, .feelGood], audiences: [.couple, .solo], decades: [.forties], availability: [.subscription("Max"), .buy("Apple TV+")], reason: "A classic for a reason: romance, longing, and unforgettable lines."),
        .init(id: 219, title: "Back to the Future", year: 1985, genre: .classic, vibes: [.feelGood, .laughOutLoud], audiences: [.family, .friends], decades: [.eighties], availability: [.subscription("Netflix"), .buy("Prime Video")], reason: "Nostalgic, playful, and still a blast every time."),
        .init(id: 220, title: "Rear Window", year: 1954, genre: .classic, vibes: [.thrilling, .mindBending], audiences: [.solo, .couple], decades: [.fifties], availability: [.subscription("Paramount+")], reason: "A masterclass in tension and observation."),
        .init(id: 221, title: "The Grand Budapest Hotel", year: 2014, genre: .comedy, vibes: [.feelGood, .mindBending], audiences: [.friends, .solo], decades: [.nineties], availability: [.subscription("Disney+"), .buy("Prime Video")], reason: "Stylish, whimsical, and wonderfully offbeat."),
        .init(id: 222, title: "Hereditary", year: 2018, genre: .horror, vibes: [.thrilling, .cryItOut], audiences: [.solo], decades: [.nineties], availability: [.subscription("Max"), .rent("Prime Video")], reason: "A brutal, unforgettable horror pick for true believers."),
        .init(id: 223, title: "Dune", year: 2021, genre: .sciFi, vibes: [.epicAdventure, .mindBending], audiences: [.family, .friends], decades: [.nineties], availability: [.subscription("Max")], reason: "A modern epic with giant scale and a serious sense of world-building."),
        .init(id: 224, title: "Eternal Sunshine of the Spotless Mind", year: 2004, genre: .romance, vibes: [.cryItOut, .mindBending], audiences: [.couple, .solo], decades: [.nineties], availability: [.subscription("Netflix"), .buy("Apple TV+")], reason: "Tender, strange, and emotionally resonant.")
    ]

    public static func surpriseSelection(tasteGenres: [MoodGenre]) -> MoodSelection {
        let audience = MoodAudience.allCases.randomElement() ?? .solo
        let vibe = MoodVibe.allCases.randomElement()

        let weightedGenres = tasteGenres.isEmpty || Double.random(in: 0...1) > 0.7
            ? MoodGenre.allCases
            : tasteGenres

        let genre = weightedGenres.randomElement() ?? .comedy
        let decade = genre == .classic ? MoodDecade.allCases.randomElement() : nil
        return MoodSelection(audience: audience, vibe: vibe, genre: genre, decade: decade)
    }

    public static func genre(for tmdbGenreId: Int) -> MoodGenre? {
        genreMap[tmdbGenreId]
    }

    public struct MovieBlueprint: Hashable {
        public enum BlueprintAvailability: Hashable {
            case subscription(String)
            case rent(String)
            case buy(String)

            var type: AvailabilityType {
                switch self {
                case .subscription: .subscription
                case .rent: .rent
                case .buy: .buy
                }
            }

            var platformName: String {
                switch self {
                case .subscription(let platform), .rent(let platform), .buy(let platform):
                    platform
                }
            }
        }

        public let id: Int
        public let title: String
        public let year: Int
        public let genre: MoodGenre
        public let vibes: [MoodVibe]
        public let audiences: [MoodAudience]
        public let decades: [MoodDecade]
        public let availability: [BlueprintAvailability]
        public let reason: String

        public init(
            id: Int,
            title: String,
            year: Int,
            genre: MoodGenre,
            vibes: [MoodVibe],
            audiences: [MoodAudience],
            decades: [MoodDecade],
            availability: [BlueprintAvailability],
            reason: String
        ) {
            self.id = id
            self.title = title
            self.year = year
            self.genre = genre
            self.vibes = vibes
            self.audiences = audiences
            self.decades = decades
            self.availability = availability
            self.reason = reason
        }
    }

    public static func makeAvailability(from blueprintAvailability: MovieBlueprint.BlueprintAvailability) -> Availability {
        let platformName = blueprintAvailability.platformName
        let platformKey = platforms.first(where: { $0.name == platformName })?.key ?? platformName.lowercased().replacingOccurrences(of: " ", with: "-")
        return Availability(type: blueprintAvailability.type, platformName: platformName, platformKey: platformKey)
    }
}
