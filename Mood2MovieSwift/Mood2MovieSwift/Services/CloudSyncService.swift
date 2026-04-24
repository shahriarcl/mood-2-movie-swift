import Foundation

@MainActor
@Observable
public final class CloudSyncService {
    public var session: CloudSession? {
        didSet {
            saveSession()
        }
    }

    public var isConfigured: Bool { client.isConfigured }
    public var isSignedIn: Bool { session != nil }

    private let sessionStore = SessionStore()
    private var client: SupabaseHTTPClient {
        SupabaseHTTPClient(config: .live)
    }

    public init() {
        self.session = sessionStore.load()
    }

    public func restoreSessionIfNeeded() async {
        guard let session else { return }
        if let expiresAt = session.expiresAt, expiresAt < Date() {
            await refreshSession()
        }
    }

    public func signIn(email: String, password: String) async throws {
        let newSession = try await client.signIn(email: email, password: password)
        session = newSession
    }

    public func signUp(email: String, password: String) async throws {
        let newSession = try await client.signUp(email: email, password: password)
        session = newSession
    }

    public func signOut() async {
        guard let session else { return }
        await client.signOut(accessToken: session.accessToken)
        self.session = nil
    }

    public func refreshSession() async {
        guard let session else { return }
        do {
            self.session = try await client.refreshSession(refreshToken: session.refreshToken)
        } catch {
            self.session = nil
        }
    }

    public func fetchRemoteLibrary() async -> [UserMovie] {
        guard let session else { return [] }
        do {
            let cloudRows = try await client.fetchUserMovies(accessToken: session.accessToken)
            return await enrichCloudMovies(cloudRows)
        } catch {
            return []
        }
    }

    public func syncLocalLibrary(_ movies: [UserMovie]) async {
        guard let session else { return }
        for movie in movies {
            let cloudMovie = CloudMovieUpsert(
                userId: session.userId,
                tmdbId: movie.tmdbId,
                title: movie.title,
                year: movie.year,
                posterPath: movie.posterPath,
                status: movie.status,
                createdAt: movie.createdAt
            )
            try? await client.upsertUserMovie(accessToken: session.accessToken, movie: cloudMovie)
        }
    }

    public func syncDelete(_ tmdbId: Int) async {
        guard let session else { return }
        try? await client.deleteUserMovie(accessToken: session.accessToken, userId: session.userId, tmdbId: tmdbId)
    }

    private func enrichCloudMovies(_ cloudRows: [CloudUserMovie]) async -> [UserMovie] {
        await withTaskGroup(of: UserMovie?.self) { group in
            for row in cloudRows {
                group.addTask {
                    let genre: MoodGenre = await self.lookupGenre(title: row.title, year: row.year)
                    return UserMovie(
                        tmdbId: row.tmdbId,
                        title: row.title,
                        year: row.year,
                        posterPath: row.posterPath,
                        genre: genre,
                        status: row.status,
                        createdAt: row.createdAt
                    )
                }
            }

            var results: [UserMovie] = []
            for await item in group {
                if let item { results.append(item) }
            }
            return results.sorted { $0.createdAt > $1.createdAt }
        }
    }

    private func lookupGenre(title: String, year: Int) async -> MoodGenre {
        guard let tmdbClient = tmdbClient, let movie = try? await tmdbClient.searchMovieByTitle(title: title, year: year) else {
            return .comedy
        }
        return movie.genreIds.first.flatMap(MoodCatalog.genre(for:)) ?? .comedy
    }

    private var tmdbClient: TMDBClient? {
        let config = APIConfiguration.live
        guard config.hasTMDB, let key = config.tmdbAPIKey else { return nil }
        return TMDBClient(apiKey: key)
    }

    public static func merge(local: [UserMovie], remote: [UserMovie]) -> [UserMovie] {
        var byId: [Int: UserMovie] = [:]

        for movie in remote {
            byId[movie.tmdbId] = movie
        }

        for movie in local {
            if let existing = byId[movie.tmdbId] {
                if movie.createdAt >= existing.createdAt {
                    byId[movie.tmdbId] = movie
                }
            } else {
                byId[movie.tmdbId] = movie
            }
        }

        return byId.values.sorted { $0.createdAt > $1.createdAt }
    }

    private func saveSession() {
        sessionStore.save(session)
    }
}

private final class SessionStore {
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directory = baseURL.appendingPathComponent("Mood2MovieSwift", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        fileURL = directory.appendingPathComponent("session.json")
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    func load() -> CloudSession? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(CloudSession.self, from: data)
    }

    func save(_ session: CloudSession?) {
        guard let session, let data = try? encoder.encode(session) else {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
