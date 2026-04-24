import Foundation
import Observation

@MainActor
@Observable
public final class AppStore {
    public var preferences: UserPreferences
    public var movies: [UserMovie]
    public let recommendationService: RecommendationService

    private let preferencesStore: PreferencesStore
    private let libraryStore: LibraryStore

    public init(
        preferencesStore: PreferencesStore = PreferencesStore(),
        libraryStore: LibraryStore = LibraryStore(),
        recommendationService: RecommendationService = RemoteRecommendationService()
    ) {
        self.preferencesStore = preferencesStore
        self.libraryStore = libraryStore
        self.recommendationService = recommendationService
        self.preferences = preferencesStore.load()
        self.movies = libraryStore.load()
    }

    public var watchlist: [UserMovie] {
        movies.filter { $0.status == .watchlist }.sorted { $0.createdAt > $1.createdAt }
    }

    public var watched: [UserMovie] {
        movies.filter { $0.status == .watched }.sorted { $0.createdAt > $1.createdAt }
    }

    public var favoriteGenres: [MoodGenre] {
        let counts = Dictionary(grouping: movies, by: { $0.genre }).mapValues { $0.count }
        return counts.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key.rawValue < rhs.key.rawValue }
            return lhs.value > rhs.value
        }.map(\.key)
    }

    public func updatePreferences(_ mutate: (inout UserPreferences) -> Void) {
        mutate(&preferences)
        preferencesStore.save(preferences)
    }

    public func setPlatforms(_ platforms: [String]) {
        updatePreferences { $0.platforms = platforms }
    }

    public func setCountry(_ country: String) {
        updatePreferences { $0.country = country }
    }

    public func setFamilySafe(_ familySafe: Bool) {
        updatePreferences { $0.familySafe = familySafe }
    }

    public func saveMovie(_ movie: MovieResult, status: MovieStatus) {
        let now = Date()
        if let index = movies.firstIndex(where: { $0.tmdbId == movie.tmdbId }) {
            movies[index].status = status
        } else {
            movies.append(
                UserMovie(
                    tmdbId: movie.tmdbId,
                    title: movie.title,
                    year: movie.year,
                    posterPath: movie.posterPath,
                    genre: movie.genre,
                    status: status,
                    createdAt: now
                )
            )
        }
        libraryStore.save(movies)
    }

    public func removeMovie(_ tmdbId: Int) {
        movies.removeAll { $0.tmdbId == tmdbId }
        libraryStore.save(movies)
    }

    public func status(for tmdbId: Int) -> MovieStatus? {
        movies.first(where: { $0.tmdbId == tmdbId })?.status
    }

    public func randomSelection() -> MoodSelection {
        MoodCatalog.surpriseSelection(tasteGenres: favoriteGenres)
    }
}
