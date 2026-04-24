import Foundation

public protocol RecommendationService {
    func suggestions(
        for selection: MoodSelection,
        preferences: UserPreferences,
        excludingTitles: Set<String>,
        page: Int
    ) async -> [MovieResult]

    func search(query: String, excludingTitles: Set<String>) async -> [MovieResult]

    func forYou(
        preferences: UserPreferences,
        favoriteGenres: [MoodGenre]
    ) async -> [MovieResult]
}

public final class LocalRecommendationService: RecommendationService {
    public init() {}

    public func suggestions(
        for selection: MoodSelection,
        preferences: UserPreferences,
        excludingTitles: Set<String>,
        page: Int
    ) async -> [MovieResult] {
        await simulatedLatency()
        let scored = MoodCatalog.sampleMovies
            .filter { !excludingTitles.contains($0.title) }
            .map { blueprint in
                (blueprint: blueprint, score: score(blueprint, for: selection, preferences: preferences))
            }
            .filter { $0.score > 0 }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score { return lhs.blueprint.year > rhs.blueprint.year }
                return lhs.score > rhs.score
            }

        let pageSize = 3
        let start = max(0, (page - 1) * pageSize)
        let slice = scored.dropFirst(start).prefix(pageSize)
        return slice.map { makeMovieResult(from: $0.blueprint) }
    }

    public func search(query: String, excludingTitles: Set<String>) async -> [MovieResult] {
        await simulatedLatency()
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return [] }
        return MoodCatalog.sampleMovies
            .filter { $0.title.lowercased().contains(normalized) && !excludingTitles.contains($0.title) }
            .sorted { $0.title < $1.title }
            .prefix(8)
            .map(makeMovieResult)
    }

    public func forYou(
        preferences: UserPreferences,
        favoriteGenres: [MoodGenre]
    ) async -> [MovieResult] {
        await simulatedLatency()
        let excluded = Set<String>()
        let selection = MoodSelection(
            audience: .solo,
            vibe: nil,
            genre: favoriteGenres.first ?? .comedy,
            decade: nil
        )
        return await suggestions(for: selection, preferences: preferences, excludingTitles: excluded, page: 1)
    }

    private func simulatedLatency() async {
        try? await Task.sleep(nanoseconds: 120_000_000)
    }

    private func score(_ blueprint: MoodCatalog.MovieBlueprint, for selection: MoodSelection, preferences: UserPreferences) -> Int {
        var score = 0
        if blueprint.genre == selection.genre { score += 50 }
        if let vibe = selection.vibe, blueprint.vibes.contains(vibe) { score += 20 }
        if blueprint.audiences.contains(selection.audience) { score += 10 }
        if let decade = selection.decade, blueprint.decades.contains(decade) { score += 12 }
        if preferences.familySafe, selection.audience == .family {
            if blueprint.genre == .horror || blueprint.genre == .mystery { score -= 100 }
            if blueprint.genre == .documentary || blueprint.genre == .classic { score += 6 }
        }
        return score
    }

    private func makeMovieResult(from blueprint: MoodCatalog.MovieBlueprint) -> MovieResult {
        let availability = blueprint.availability.map(makeAvailability)
        let primary = availability.sorted(by: availabilitySort).first
            ?? Availability(type: .subscription, platformName: "TBD", platformKey: "tbd")

        return MovieResult(
            tmdbId: blueprint.id,
            title: blueprint.title,
            year: blueprint.year,
            posterPath: nil,
            reason: blueprint.reason,
            availability: availability.sorted(by: availabilitySort),
            primaryAvailability: primary,
            genre: blueprint.genre
        )
    }

    private func availabilitySort(_ lhs: Availability, _ rhs: Availability) -> Bool {
        let order: [AvailabilityType: Int] = [.subscription: 0, .rent: 1, .buy: 2]
        return (order[lhs.type] ?? 99) < (order[rhs.type] ?? 99)
    }

    private func makeAvailability(from blueprintAvailability: MoodCatalog.MovieBlueprint.BlueprintAvailability) -> Availability {
        let platformName = blueprintAvailability.platformName
        let platformKey = MoodCatalog.platforms.first(where: { $0.name == platformName })?.key
            ?? platformName.lowercased().replacingOccurrences(of: " ", with: "-")
        return Availability(type: blueprintAvailability.type, platformName: platformName, platformKey: platformKey)
    }
}
