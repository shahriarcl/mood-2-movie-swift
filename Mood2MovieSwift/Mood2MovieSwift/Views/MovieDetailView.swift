import SwiftUI

struct MovieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let movie: MovieResult

    @State private var detail: TMDBMovieDetail?
    @State private var providers: [Availability] = []
    @State private var loading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                if loading && detail == nil {
                    LoadingStateView(text: "Loading movie details...")
                } else {
                    heroCard
                    statsRow

                    if !providers.isEmpty {
                        section(title: "Where to watch") {
                            providerGrid
                        }
                    }

                    if let detail, !detail.genres.isEmpty {
                        section(title: "Genres") {
                            FlowLayout(spacing: 8) {
                                ForEach(detail.genres, id: \.id) { genre in
                                    Text(genreLabel(genre.id))
                                        .font(.footnote.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(Color.white.opacity(0.07))
                                                .overlay(
                                                    Capsule(style: .continuous)
                                                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                    }

                    section(title: "About this pick") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(detail?.overview ?? movie.reason)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)

                            if let runtime = detail?.runtime {
                                DetailRow(label: "Runtime", value: "\(runtime) minutes")
                            }

                            if let rating = detail?.voteAverage {
                                DetailRow(label: "TMDB rating", value: String(format: "%.1f / 10", rating))
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: 430, alignment: .leading)
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
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var posterURL: URL? {
        detail?.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") } ??
        movie.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(PlainBackButtonStyle())

            Text("MOVIE DETAILS")
                .font(.caption2.weight(.bold))
                .tracking(3.0)
                .foregroundStyle(Color(hex: "F5A623"))
            Text(movie.title)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text("A closer look at the pick, the synopsis, and where to watch.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Divider().overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }

    private var heroCard: some View {
        GlassCard {
            ViewThatFits(in: .horizontal) {
                heroCardWide
                heroCardStacked
            }
        }
    }

    private var heroCardWide: some View {
        HStack(alignment: .top, spacing: 18) {
            poster
            detailCopy
            Spacer(minLength: 0)
        }
    }

    private var heroCardStacked: some View {
        VStack(alignment: .leading, spacing: 16) {
            poster
            detailCopy
        }
    }

    private var detailCopy: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(summaryLine)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                DetailChip(text: movie.genre.label)
                DetailChip(text: movie.primaryAvailability.platformName)
                DetailChip(text: movie.year.description)
            }

            HStack(spacing: 8) {
                DetailChip(text: movie.primaryAvailability.type.label)
                if let runtime = detail?.runtime {
                    DetailChip(text: "\(runtime) min")
                }
                if let rating = detail?.voteAverage {
                    DetailChip(text: String(format: "%.1f / 10", rating))
                }
            }

            Text(movie.reason)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(detail?.overview ?? "Fetching the full synopsis...")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var statsRow: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Year", value: "\(movie.year)", note: movie.genre.label)
                StatCard(title: "Primary", value: movie.primaryAvailability.platformName, note: movie.primaryAvailability.type.label)
            }
            StatCard(title: "Providers", value: "\(providers.count)", note: "available matches")
        }
    }

    private var providerGrid: some View {
        VStack(spacing: 12) {
            ForEach(providers) { availability in
                ProviderCard(availability: availability)
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

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 96, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.top, 4)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(note)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
    }
}

private struct ProviderCard: View {
    let availability: Availability

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(Color(hex: "F5A623"))
                Spacer()
                Text(availability.type.label.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(.secondary)
            }

            Text(availability.platformName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(availability.type == .subscription ? "Stream instantly" : "Alternative purchase option")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
    }

    private var iconName: String {
        switch availability.type {
        case .subscription: return "play.fill"
        case .rent: return "clock.arrow.circlepath"
        case .buy: return "cart.fill"
        }
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
