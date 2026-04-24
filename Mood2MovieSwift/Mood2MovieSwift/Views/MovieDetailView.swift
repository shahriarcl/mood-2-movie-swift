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
                heroCard

                if loading && detail == nil {
                    LoadingStateView(text: "Loading movie details...")
                } else {
                    GlassCard {
                        HStack(alignment: .top, spacing: 18) {
                            poster
                            VStack(alignment: .leading, spacing: 12) {
                                Text(movie.title)
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                Text(summaryLine)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(detail?.overview ?? movie.reason)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack(spacing: 8) {
                                    if let runtime = detail?.runtime {
                                        DetailChip(text: "Runtime \(runtime) min")
                                    }

                                    if let rating = detail?.voteAverage {
                                        DetailChip(text: String(format: "TMDB %.1f", rating))
                                    }
                                }
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
            .frame(maxWidth: 980, alignment: .leading)
        }
        .background(AppScreenBackground())
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

    private var heroCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 18) {
                poster
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        Text(summaryLine)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        DetailChip(text: movie.genre.label)
                        DetailChip(text: movie.primaryAvailability.platformName)
                        DetailChip(text: movie.year.description)
                    }

                    Text(detail?.overview ?? movie.reason)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: title)
                content()
            }
        }
    }
}

private struct DetailChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.09), lineWidth: 1)
                    )
            )
            .foregroundStyle(.secondary)
    }
}

extension MovieDetailView {
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
}
