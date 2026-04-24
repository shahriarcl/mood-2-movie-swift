import Foundation

public final class SupabaseHTTPClient {
    private let config: SupabaseConfig
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    public init(config: SupabaseConfig = .live, session: URLSession = .shared) {
        self.config = config
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder = encoder
    }

    public var isConfigured: Bool { config.isConfigured }

    public func signIn(email: String, password: String) async throws -> CloudSession {
        try await authRequest(path: "token", queryItems: [URLQueryItem(name: "grant_type", value: "password")], body: CloudAuthPayload(email: email, password: password), decode: CloudSession.self)
    }

    public func signUp(email: String, password: String) async throws -> CloudSession {
        try await authRequest(path: "signup", body: CloudAuthPayload(email: email, password: password), decode: CloudSession.self)
    }

    public func refreshSession(refreshToken: String) async throws -> CloudSession {
        try await authRequest(path: "token", queryItems: [URLQueryItem(name: "grant_type", value: "refresh_token")], body: ["refresh_token": refreshToken], decode: CloudSession.self)
    }

    public func signOut(accessToken: String) async {
        guard let url = endpoint(path: "logout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addCommonHeaders(&request, bearer: accessToken)
        _ = try? await session.data(for: request)
    }

    public func fetchUserMovies(accessToken: String) async throws -> [CloudUserMovie] {
        guard let url = endpoint(path: "rest/v1/user_movies", queryItems: [
            URLQueryItem(name: "select", value: "id,tmdb_id,title,year,poster_path,status,created_at"),
            URLQueryItem(name: "order", value: "created_at.desc")
        ]) else {
            return []
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addCommonHeaders(&request, bearer: accessToken)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try jsonDecoder.decode([CloudUserMovie].self, from: data)
    }

    public func upsertUserMovie(accessToken: String, movie: CloudMovieUpsert) async throws {
        guard let url = endpoint(path: "rest/v1/user_movies", queryItems: [
            URLQueryItem(name: "on_conflict", value: "user_id,tmdb_id")
        ]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addCommonHeaders(&request, bearer: accessToken)
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try jsonEncoder.encode(CloudMovieUpsert(
            userId: movie.userId,
            tmdbId: movie.tmdbId,
            title: movie.title,
            year: movie.year,
            posterPath: movie.posterPath,
            status: movie.status,
            createdAt: movie.createdAt
        ))
        let (_, response) = try await session.data(for: request)
        try validate(response)
    }

    public func deleteUserMovie(accessToken: String, userId: String, tmdbId: Int) async throws {
        guard let url = endpoint(path: "rest/v1/user_movies", queryItems: [
            URLQueryItem(name: "user_id", value: "eq.\(userId)"),
            URLQueryItem(name: "tmdb_id", value: "eq.\(tmdbId)")
        ]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        addCommonHeaders(&request, bearer: accessToken)
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        let (_, response) = try await session.data(for: request)
        try validate(response)
    }

    public func fetchTasteProfile(accessToken: String) async throws -> Data? {
        guard let url = endpoint(path: "rest/v1/taste_profiles", queryItems: [
            URLQueryItem(name: "select", value: "user_id,structured_data,taste_summary,movie_count,updated_at"),
            URLQueryItem(name: "limit", value: "1")
        ]) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addCommonHeaders(&request, bearer: accessToken)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return data
    }

    private func authRequest<T: Decodable, Body: Encodable>(path: String, queryItems: [URLQueryItem] = [], body: Body, decode: T.Type) async throws -> T {
        guard let url = endpoint(path: "auth/v1/\(path)", queryItems: queryItems) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addCommonHeaders(&request)
        request.httpBody = try jsonEncoder.encode(body)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try jsonDecoder.decode(T.self, from: data)
    }

    private func authRequest<T: Decodable>(path: String, queryItems: [URLQueryItem] = [], body: [String: String], decode: T.Type) async throws -> T {
        guard let url = endpoint(path: "auth/v1/\(path)", queryItems: queryItems) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addCommonHeaders(&request)
        request.httpBody = try jsonEncoder.encode(body)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try jsonDecoder.decode(T.self, from: data)
    }

    private func endpoint(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard let base = config.url else { return nil }
        var url = base
        for segment in path.split(separator: "/") {
            url.appendPathComponent(String(segment))
        }
        if queryItems.isEmpty { return url }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        return components?.url
    }

    private func addCommonHeaders(_ request: inout URLRequest, bearer: String? = nil) {
        request.setValue(config.anonKey ?? "", forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        if let bearer {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "authorization")
        }
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
