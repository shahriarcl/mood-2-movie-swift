import Foundation

public struct TMDBSearchResult: Decodable, Hashable {
    public let id: Int
    public let title: String
    public let releaseDate: String?
    public let overview: String?
    public let posterPath: String?
    public let genreIds: [Int]
    public let voteAverage: Double

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case overview
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
    }

    public var year: Int {
        return parseYear(releaseDate)
    }
}

public struct TMDBMovieDetail: Decodable, Hashable {
    public let id: Int
    public let title: String
    public let releaseDate: String?
    public let overview: String?
    public let runtime: Int?
    public let voteAverage: Double
    public let posterPath: String?
    public let genres: [TMDBGenre]

    public struct TMDBGenre: Decodable, Hashable {
        public let id: Int
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case overview
        case runtime
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case genres
    }
}

public struct TMDBProviderResponse: Decodable, Hashable {
    public struct CountryProviders: Decodable, Hashable {
        public let flatrate: [ProviderEntry]?
        public let rent: [ProviderEntry]?
        public let buy: [ProviderEntry]?
    }

    public struct ProviderEntry: Decodable, Hashable {
        public let providerId: Int

        private enum CodingKeys: String, CodingKey {
            case providerId = "provider_id"
        }
    }

    public let results: [String: CountryProviders]
}

public struct TMDBPeopleResponse: Decodable, Hashable {
    public struct Person: Decodable, Hashable {
        public let id: Int
        public let name: String
    }

    public let results: [Person]
}

public final class TMDBClient {
    private let apiKey: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!

    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    public func searchMovies(query: String, page: Int = 1, year: Int? = nil) async throws -> [TMDBSearchResult] {
        var items = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: String(page))
        ]
        if let year {
            items.append(URLQueryItem(name: "year", value: String(year)))
        }
        let response: TMDBSearchEnvelope = try await request(path: "search/movie", queryItems: items)
        return response.results
    }

    public func discoverMovies(selection: MoodSelection, familySafe: Bool, page: Int = 1) async throws -> [TMDBSearchResult] {
        let (startYear, endYear, cert) = discoveryBounds(for: selection, familySafe: familySafe)
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "sort_by", value: selection.vibe == .thrilling ? "popularity.desc" : "vote_average.desc"),
            URLQueryItem(name: "vote_average.gte", value: familySafe ? "6.0" : "5.8"),
            URLQueryItem(name: "vote_count.gte", value: "100")
        ]

        if let genreId = MoodCatalog.genreMap.first(where: { $0.value == selection.genre })?.key {
            items.append(URLQueryItem(name: "with_genres", value: String(genreId)))
        }
        if let startYear {
            items.append(URLQueryItem(name: "primary_release_date.gte", value: "\(startYear)-01-01"))
        }
        if let endYear {
            items.append(URLQueryItem(name: "primary_release_date.lte", value: "\(endYear)-12-31"))
        }
        if let cert {
            items.append(URLQueryItem(name: "certification_country", value: "US"))
            items.append(URLQueryItem(name: "certification", value: cert))
        }

        let response: TMDBSearchEnvelope = try await request(path: "discover/movie", queryItems: items)
        return response.results
    }

    public func searchMovieByTitle(title: String, year: Int? = nil) async throws -> TMDBSearchResult? {
        let first = try await searchMovies(query: title, year: year)
        if let best = pickBestMatch(requestedTitle: title, requestedYear: year, candidates: first) {
            return best
        }

        guard year != nil else { return nil }
        let fallback = try await searchMovies(query: title, year: nil)
        return pickBestMatch(requestedTitle: title, requestedYear: year, candidates: fallback)
    }

    public func watchProviders(tmdbId: Int, country: String = "US") async throws -> [ProviderResult] {
        let response: TMDBProviderResponse = try await request(path: "movie/\(tmdbId)/watch/providers", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey)
        ])

        guard let countryData = response.results[country] ?? response.results.values.first else {
            return []
        }

        var results: [ProviderResult] = []
        for entry in countryData.flatrate ?? [] {
            results.append(.init(providerId: entry.providerId, type: .subscription))
        }
        for entry in countryData.rent ?? [] {
            results.append(.init(providerId: entry.providerId, type: .rent))
        }
        for entry in countryData.buy ?? [] {
            results.append(.init(providerId: entry.providerId, type: .buy))
        }
        return results
    }

    public func movieDetails(tmdbId: Int) async throws -> TMDBMovieDetail? {
        let detail: TMDBMovieDetail = try await request(path: "movie/\(tmdbId)", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ])
        return detail
    }

    private func discoveryBounds(for selection: MoodSelection, familySafe: Bool) -> (Int?, Int?, String?) {
        switch selection.decade {
        case .forties: return (1940, 1949, familySafe ? "PG" : nil)
        case .fifties: return (1950, 1959, familySafe ? "PG" : nil)
        case .sixties: return (1960, 1969, familySafe ? "PG" : nil)
        case .seventies: return (1970, 1979, familySafe ? "PG" : nil)
        case .eighties: return (1980, 1989, familySafe ? "PG" : nil)
        case .nineties: return (1990, 1999, familySafe ? "PG-13" : nil)
        case nil:
            return (nil, nil, familySafe ? "PG-13" : nil)
        }
    }

    private func pickBestMatch(requestedTitle: String, requestedYear: Int?, candidates: [TMDBSearchResult]) -> TMDBSearchResult? {
        let requested = normalizeTitle(requestedTitle)
        let ranked: [(candidate: TMDBSearchResult, score: Double)] = candidates
            .map { candidate in
                (candidate: candidate, score: titleScore(requested: requested, candidate: normalizeTitle(candidate.title), requestedYear: requestedYear, candidateYear: candidate.year))
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.candidate.voteAverage > rhs.candidate.voteAverage
                }
                return lhs.score > rhs.score
            }

        guard let best = ranked.first, best.score >= 0.7 else {
            return nil
        }
        return best.candidate
    }

    private func normalizeTitle(_ title: String) -> String {
        title
            .lowercased()
            .applyingTransform(.stripDiacritics, reverse: false)?
            .replacingOccurrences(of: "&", with: " and ")
            .replacingOccurrences(of: "[\\'\".,:!?()\\[\\]{}]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[-_/]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? title.lowercased()
    }

    private func titleScore(requested: String, candidate: String, requestedYear: Int?, candidateYear: Int) -> Double {
        guard !requested.isEmpty, !candidate.isEmpty else { return 0 }
        if requested == candidate { return 1 }
        if requested.contains(candidate) || candidate.contains(requested) { return 0.88 }

        let requestedWords = requested.split(separator: " ")
        let candidateWords = candidate.split(separator: " ")
        let overlap = requestedWords.filter { candidateWords.contains($0) }.count
        let union = Set(requestedWords).union(candidateWords).count
        let nameScore = Double(overlap) / Double(max(union, 1))

        var yearScore = 0.0
        if let requestedYear {
            let diff = abs(requestedYear - candidateYear)
            switch diff {
            case 0: yearScore = 1
            case 1: yearScore = 0.92
            case 2: yearScore = 0.8
            case 3: yearScore = 0.65
            default: yearScore = 0
            }
        }

        if nameScore < 0.7 {
            return 0
        }
        return (nameScore * 0.75) + (yearScore * 0.25)
    }

    private func request<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T {
        var url = baseURL
        for segment in path.split(separator: "/") {
            url.appendPathComponent(String(segment))
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct TMDBSearchEnvelope: Decodable {
    let results: [TMDBSearchResult]
}

private func parseYear(_ releaseDate: String?) -> Int {
    guard let releaseDate, !releaseDate.isEmpty else { return 0 }
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: releaseDate) else { return 0 }
    return Calendar(identifier: .gregorian).component(.year, from: date)
}
