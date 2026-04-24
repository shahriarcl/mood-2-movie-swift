import SwiftUI

struct ResultsView: View {
    @Environment(AppStore.self) private var store
    @Environment(CloudSyncService.self) private var cloud
    @Binding var path: [AppRoute]
    let selection: MoodSelection

    @State private var didAppear = false
    @State private var movies: [MovieResult] = []
    @State private var message: String?
    @State private var loading = true
    @State private var page = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                heroSummary

                if loading && movies.isEmpty {
                    LoadingStateView(text: "Finding the right vibe...")
                } else if movies.isEmpty {
                    EmptyStateView(message: message ?? "Something went wrong. Please try again.")
                } else {
                    VStack(spacing: 12) {
                        ForEach(movies) { movie in
                            MovieCardView(
                                movie: movie,
                                status: store.status(for: movie.tmdbId),
                                onOpenDetail: {
                                    path.append(.movieDetail(movie))
                                },
                                onSave: { status in
                                    store.saveMovie(movie, status: status)
                                    Task { await cloud.syncLocalLibrary(store.movies) }
                                },
                                onRemove: {
                                    store.removeMovie(movie.tmdbId)
                                    Task { await cloud.syncDelete(movie.tmdbId) }
                                }
                            )
                        }
                    }

                    if loading {
                        LoadingStateView(text: "Loading more...")
                    }

                    Button("Load more") {
                        page += 1
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: 400, alignment: .leading)
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 12)
        }
        .background(AppScreenBackground())
        .navigationTitle("Tonight's Picks")
        .task(id: fetchKey) {
            await loadMovies()
        }
        .onChange(of: selection) { _, _ in
            movies = []
            message = nil
            page = 1
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                didAppear = true
            }
        }
    }

    private var fetchKey: String {
        "\(selection.id)-\(page)"
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                if !path.isEmpty {
                    path.removeLast()
                }
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(PlainBackButtonStyle())

            ScreenHeader(
                eyebrow: "Mood selection",
                title: "Tonight's Picks",
                subtitle: selectionSummary,
                badge: "\(movies.count) matches"
            )
        }
    }

    private var heroSummary: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("RESULTS")
                            .font(.caption2.weight(.bold))
                            .tracking(3)
                            .foregroundStyle(Color(hex: "F5A623"))
                        Text("Mobile stack")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color(hex: "F5A623"))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected vibe")
                            .font(.caption2.weight(.bold))
                            .tracking(3)
                            .foregroundStyle(Color(hex: "F5A623"))
                        Text("One stack of movies tuned to this mood.")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(selectionSummary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("The engine is matching this mood to titles, providers, and watch status.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        SelectionStat(label: "Matches", value: "\(movies.count)")
                        SelectionStat(label: "Page", value: "\(page)")
                        SelectionStat(label: "Genre", value: selection.genre.label)
                    }
                }

                HStack(spacing: 8) {
                    SummaryChip(text: selection.audience.label)
                    if let vibe = selection.vibe { SummaryChip(text: vibe.label) }
                    SummaryChip(text: selection.genre.label)
                    if let decade = selection.decade { SummaryChip(text: decade.label) }
                }
            }
        }
    }

    private struct SelectionStat: View {
        let label: String
        let value: String

        var body: some View {
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                Text(label.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var selectionSummary: String {
        var parts: [String] = [selection.audience.label]
        if let vibe = selection.vibe {
            parts.append(vibe.label)
        }
        parts.append(selection.genre.label)
        if let decade = selection.decade {
            parts.append(decade.label)
        }
        return parts.joined(separator: " • ")
    }

    private func loadMovies() async {
        loading = true
        let excluded = Set(store.movies.map(\.title)).union(Set(movies.map(\.title)))
        let incoming = await store.recommendationService.suggestions(
            for: selection,
            preferences: store.preferences,
            excludingTitles: excluded,
            page: page
        )

        if page == 1 {
            movies = incoming
        } else {
            movies.append(contentsOf: incoming)
        }

        if incoming.isEmpty && page == 1 {
            message = "No picks matched that combo yet."
        }
        loading = false
    }
}

private struct MovieCardView: View {
    let movie: MovieResult
    let status: MovieStatus?
    let onOpenDetail: () -> Void
    let onSave: (MovieStatus) -> Void
    let onRemove: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Button(action: onOpenDetail) {
                        PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(movie.year) • \(movie.primaryAvailability.platformName)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        AvailabilityPill(availability: movie.primaryAvailability)

                        Text(movie.reason)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !movie.availability.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(movie.availability) { availability in
                            AvailabilityPill(availability: availability)
                        }
                    }
                }

                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Button {
                            onOpenDetail()
                        } label: {
                            Label("Details", systemImage: "info.circle")
                        }
                        .buttonStyle(InlineActionButtonStyle(isActive: false))

                        Button {
                            onSave(.watchlist)
                        } label: {
                            Label("Watchlist", systemImage: "bookmark")
                        }
                        .buttonStyle(InlineActionButtonStyle(isActive: status == .watchlist))
                    }

                    HStack(spacing: 8) {
                        Button {
                            onSave(.watched)
                        } label: {
                            Label("Watched", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(InlineActionButtonStyle(isActive: status == .watched))

                        if status != nil {
                            Button(role: .destructive) {
                                onRemove()
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .buttonStyle(InlineActionButtonStyle(isActive: false))
                        }
                    }
                }
            }
        }
    }
}

private struct SummaryChip: View {
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
