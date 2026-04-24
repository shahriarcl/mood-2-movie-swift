import Foundation

public final class RemoteRecommendationService: RecommendationService {
    private let fallback: LocalRecommendationService

    public init(fallback: LocalRecommendationService = LocalRecommendationService()) {
        self.fallback = fallback
    }

    public func suggestions(
        for selection: MoodSelection,
        preferences: UserPreferences,
        excludingTitles: Set<String>,
        page: Int
    ) async -> [MovieResult] {
        let config = APIConfiguration.live
        guard let tmdb = config.hasTMDB ? TMDBClient(apiKey: config.tmdbAPIKey ?? "") : nil else {
            return await fallback.suggestions(for: selection, preferences: preferences, excludingTitles: excludingTitles, page: page)
        }
        let anthropic = (config.hasTMDB && config.hasAnthropic)
            ? AnthropicClient(apiKey: config.anthropicAPIKey ?? "", model: config.anthropicModel)
            : nil

        do {
            let nominations: [Nomination]
            if let anthropic {
                nominations = try await anthropic.nominate(
                    mood: selection,
                    familySafe: preferences.familySafe,
                    page: page,
                    excludeTitles: Array(excludingTitles)
                )
            } else {
                nominations = []
            }

            let rawMovies: [MovieResult]
            if nominations.isEmpty {
                rawMovies = try await discoverFallback(selection: selection, preferences: preferences, excludingTitles: excludingTitles, page: page)
            } else {
                rawMovies = try await resolveNominations(
                    nominations,
                    tmdb: tmdb,
                    platforms: preferences.platforms,
                    country: preferences.country,
                    allowFallbackAvailability: true
                )
            }

            if rawMovies.isEmpty {
                return await fallback.suggestions(for: selection, preferences: preferences, excludingTitles: excludingTitles, page: page)
            }
            return rawMovies
        } catch {
            return await fallback.suggestions(for: selection, preferences: preferences, excludingTitles: excludingTitles, page: page)
        }
    }

    public func search(query: String, excludingTitles: Set<String>) async -> [MovieResult] {
        let config = APIConfiguration.live
        guard let tmdb = config.hasTMDB ? TMDBClient(apiKey: config.tmdbAPIKey ?? "") : nil else {
            return await fallback.search(query: query, excludingTitles: excludingTitles)
        }

        do {
            let results = try await tmdb.searchMovies(query: query, page: 1)
            return await resolveSearchResults(results, tmdb: tmdb, excludingTitles: excludingTitles, country: "US", platformKeys: [])
        } catch {
            return await fallback.search(query: query, excludingTitles: excludingTitles)
        }
    }

    public func forYou(
        preferences: UserPreferences,
        favoriteGenres: [MoodGenre]
    ) async -> [MovieResult] {
        let config = APIConfiguration.live
        guard config.hasTMDB else {
            return await fallback.forYou(preferences: preferences, favoriteGenres: favoriteGenres)
        }
        let genre = favoriteGenres.first ?? .comedy
        let selection = MoodSelection(audience: .solo, vibe: nil, genre: genre, decade: nil)
        return await suggestions(for: selection, preferences: preferences, excludingTitles: [], page: 1)
    }

    private func discoverFallback(
        selection: MoodSelection,
        preferences: UserPreferences,
        excludingTitles: Set<String>,
        page: Int
    ) async throws -> [MovieResult] {
        let config = APIConfiguration.live
        guard let tmdb = config.hasTMDB ? TMDBClient(apiKey: config.tmdbAPIKey ?? "") : nil else { return [] }
        let discovered = try await tmdb.discoverMovies(selection: selection, familySafe: preferences.familySafe, page: page)
        return await resolveSearchResults(
            discovered,
            tmdb: tmdb,
            excludingTitles: excludingTitles,
            country: preferences.country,
            platformKeys: preferences.platforms
        )
    }

    private func resolveSearchResults(
        _ results: [TMDBSearchResult],
        tmdb: TMDBClient,
        excludingTitles: Set<String>,
        country: String,
        platformKeys: [String]
    ) async -> [MovieResult] {
        let filtered = results.filter { !excludingTitles.contains($0.title) }
        let candidates = Array(filtered.prefix(8))
        return await withTaskGroup(of: MovieResult?.self) { group in
            for result in candidates {
                group.addTask {
                    await self.resolveMovie(result, tmdb: tmdb, platformKeys: platformKeys, country: country, allowFallbackAvailability: true)
                }
            }

            var resolved: [MovieResult] = []
            for await item in group {
                if let item {
                    resolved.append(item)
                }
            }
            return resolved.sorted { $0.year > $1.year }
        }
    }

    private func resolveNominations(
        _ nominations: [Nomination],
        tmdb: TMDBClient,
        platforms: [String],
        country: String,
        allowFallbackAvailability: Bool
    ) async throws -> [MovieResult] {
        let chunks = Array(nominations.prefix(30))
        return await withTaskGroup(of: MovieResult?.self) { group in
            for nomination in chunks {
                group.addTask {
                    await self.resolveNomination(nomination, tmdb: tmdb, platformKeys: platforms, country: country, allowFallbackAvailability: allowFallbackAvailability)
                }
            }

            var results: [MovieResult] = []
            for await item in group {
                if let item {
                    results.append(item)
                }
            }
            return results.sorted { $0.year > $1.year }.prefix(6).map { $0 }
        }
    }

    private func resolveNomination(
        _ nomination: Nomination,
        tmdb: TMDBClient,
        platformKeys: [String],
        country: String,
        allowFallbackAvailability: Bool
    ) async -> MovieResult? {
        guard let movie = try? await tmdb.searchMovieByTitle(title: nomination.title, year: nomination.year) else {
            return nil
        }
        return await resolveMovie(movie, tmdb: tmdb, platformKeys: platformKeys, country: country, allowFallbackAvailability: allowFallbackAvailability, reason: nomination.reason)
    }

    private func resolveMovie(
        _ movie: TMDBSearchResult,
        tmdb: TMDBClient,
        platformKeys: [String],
        country: String,
        allowFallbackAvailability: Bool,
        reason: String? = nil
    ) async -> MovieResult? {
        let providers = (try? await tmdb.watchProviders(tmdbId: movie.id, country: country)) ?? []
        var availability = buildAvailability(providers: providers, platforms: platformKeys)
        if availability.isEmpty, allowFallbackAvailability {
            availability = buildAnyAvailability(providers: providers)
        }
        guard !availability.isEmpty else { return nil }
        guard let genre = MoodCatalog.genre(for: movie.genreIds.first ?? -1) ?? MoodGenre.allCases.first else { return nil }

        return MovieResult(
            tmdbId: movie.id,
            title: movie.title,
            year: movie.year,
            posterPath: movie.posterPath,
            reason: reason ?? (movie.overview ?? "A strong fit for this mood."),
            availability: availability,
            primaryAvailability: availability[0],
            genre: genre
        )
    }

    private func buildAvailability(providers: [ProviderResult], platforms: [String]) -> [Availability] {
        let order: [AvailabilityType: Int] = [.subscription: 0, .rent: 1, .buy: 2]
        let platformMap = Dictionary(uniqueKeysWithValues: MoodCatalog.platforms.map { ($0.tmdbId, $0) })
        let allowedPlatformIds = Set(platforms.compactMap { key in
            MoodCatalog.platforms.first(where: { $0.key == key })?.tmdbId
        })

        let filteredProviders = platforms.isEmpty
            ? providers
            : providers.filter { allowedPlatformIds.contains($0.providerId) }

        let mapped = filteredProviders.compactMap { provider -> Availability? in
            guard let platform = platformMap[provider.providerId] else { return nil }
            return Availability(type: provider.type, platformName: platform.name, platformKey: platform.key)
        }

        let sorted = mapped.sorted { lhs, rhs in
            (order[lhs.type] ?? 99) < (order[rhs.type] ?? 99)
        }

        if !sorted.isEmpty {
            return sorted
        }

        return []
    }

    private func buildAnyAvailability(providers: [ProviderResult]) -> [Availability] {
        let order: [AvailabilityType: Int] = [.subscription: 0, .rent: 1, .buy: 2]
        let platformMap = Dictionary(uniqueKeysWithValues: MoodCatalog.platforms.map { ($0.tmdbId, $0) })

        return providers.compactMap { provider -> Availability? in
            guard let platform = platformMap[provider.providerId] else { return nil }
            return Availability(type: provider.type, platformName: platform.name, platformKey: platform.key)
        }
        .sorted { (order[$0.type] ?? 99) < (order[$1.type] ?? 99) }
    }
}
