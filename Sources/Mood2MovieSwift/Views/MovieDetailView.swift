import SwiftUI

struct MovieDetailView: View {
    let movie: MovieResult

    @State private var detail: TMDBMovieDetail?
    @State private var providers: [Availability] = []
    @State private var loading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if loading && detail == nil {
                    LoadingStateView(text: "Loading movie details...")
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        poster
                        VStack(alignment: .leading, spacing: 10) {
                            Text(movie.title)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            Text(summaryLine)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(detail?.overview ?? movie.reason)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)

                            if let runtime = detail?.runtime {
                                Text("Runtime: \(runtime) min")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            if let rating = detail?.voteAverage {
                                Text(String(format: "TMDB rating: %.1f", rating))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !providers.isEmpty {
                        section(title: "Where to watch") {
                            FlowLayout(spacing: 8) {
                                ForEach(providers) { availability in
                                    AvailabilityPill(availability: availability)
                                }
                            }
                        }
                    }

                    if let detail {
                        if !detail.genres.isEmpty {
                            section(title: "Genres") {
                                FlowLayout(spacing: 8) {
                                    ForEach(detail.genres, id: \.id) { genre in
                                        Text(genreLabel(genre.id))
                                            .font(.footnote.weight(.semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Capsule().fill(Color.white.opacity(0.06)))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: 820, alignment: .leading)
        }
        .background(backgroundView)
        .task(id: movie.tmdbId) {
            await load()
        }
    }

    private var summaryLine: String {
        var parts: [String] = ["\(movie.year)", movie.genre.label]
        if let detail, let runtime = detail.runtime {
            parts.append("\(runtime) min")
        }
        return parts.joined(separator: " • ")
    }

    private var poster: some View {
        AsyncImage(url: posterURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)
            case .empty:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            @unknown default:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            }
        }
        .frame(width: 160, height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var posterURL: URL? {
        detail?.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") } ??
        movie.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Movie Details")
                .font(.caption2.weight(.semibold))
                .tracking(2.2)
                .foregroundStyle(Color(hex: "F5A623"))
            Divider().overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func load() async {
        loading = true
        defer { loading = false }
        let config = APIConfiguration.live
        guard let key = config.tmdbAPIKey, !key.isEmpty else {
            return
        }

        let client = TMDBClient(apiKey: key)
        let movieID = movie.tmdbId
        async let details = client.movieDetails(tmdbId: movieID)
        async let providerResults = client.watchProviders(tmdbId: movieID, country: "US")

        let fetchedDetails = try? await details
        let fetchedProviders = (try? await providerResults) ?? []

        detail = fetchedDetails
        providers = fetchedProviders.compactMap { provider in
            guard let platform = MoodCatalog.platforms.first(where: { $0.tmdbId == provider.providerId }) else { return nil }
            return Availability(type: provider.type, platformName: platform.name, platformKey: platform.key)
        }
        .sorted { lhs, rhs in
            let order: [AvailabilityType: Int] = [.subscription: 0, .rent: 1, .buy: 2]
            return (order[lhs.type] ?? 99) < (order[rhs.type] ?? 99)
        }
        loading = false
    }

    private func genreLabel(_ id: Int) -> String {
        switch id {
        case 878: return "Sci-Fi"
        case 10749: return "Romance"
        case 35: return "Comedy"
        case 28: return "Action"
        case 9648: return "Mystery"
        case 27: return "Horror"
        case 14: return "Fantasy"
        case 99: return "Documentary"
        default: return "Genre \(id)"
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(hex: "09090B"), Color(hex: "111114"), Color(hex: "0D0D10")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
