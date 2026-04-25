import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: [AppRoute]

    @State private var draft = MoodSelectionDraft()
    @State private var searchText = ""
    @State private var searchResults: [MovieResult] = []
    @State private var searching = false
    @State private var forYouMovies: [MovieResult] = []
    @State private var didAppear = false
    @FocusState private var searchFocused: Bool
    private let topAnchor = "home-top"

    var body: some View {
        scrollBody
            .toolbar(.hidden, for: .navigationBar)
    }

    private var scrollBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Color.clear.frame(height: 0).id(topAnchor)
                    motion(topBar, delay: 0.0)
                    motion(heroSection, delay: 0.05)
                    motion(searchSection, delay: 0.10)
                    motion(statsSection, delay: 0.16)
                    motion(forYouSection, delay: 0.22)
                    motion(moodSection, delay: 0.28)
                    motion(actionSection, delay: 0.34)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollIndicators(.hidden)
            .onAppear {
                didAppear = true
                DispatchQueue.main.async { proxy.scrollTo(topAnchor, anchor: .top) }
            }
            .onChange(of: path) { _, _ in
                if path.isEmpty {
                    DispatchQueue.main.async { proxy.scrollTo(topAnchor, anchor: .top) }
                }
            }
            .task(id: store.favoriteGenres) { await loadForYou() }
            .task(id: searchText) { await runSearch() }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            wordmark
            Spacer(minLength: 12)
            Button { path.append(.settings) } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var wordmark: some View {
        HStack(spacing: 6) {
            Text("MOOD")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(4.8)
            Text("2")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "F5A623"))
            Text("MOVIE")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(4.8)
        }
        .foregroundStyle(.white)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                CinematicHeroArt()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.80)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                heroTitle
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.30), radius: 16, x: 0, y: 8)

            Text("Search a title or let the mood cards below steer you.")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var heroTitle: Text {
        var copy = AttributedString("Mood picks for\ntonight.")
        copy.foregroundColor = .white
        if let range = copy.range(of: "Mood") {
            copy[range].foregroundColor = Color(hex: "F5A623")
        }
        return Text(copy)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.45))
                TextField("Search a movie", text: $searchText)
                    .focused($searchFocused)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                Button { searchFocused = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "F5A623"))
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: "F5A623").opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            )

            if searching {
                HStack(spacing: 10) {
                    ProgressView().tint(Color(hex: "F5A623"))
                    Text("Searching…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
            } else if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if searchResults.isEmpty {
                    Text("No local matches.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                } else {
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(searchResults.count) matches")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(hex: "F5A623"))
                            Spacer()
                            Text("Tap to open")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(searchResults) { movie in
                            SearchResultRow(movie: movie) { path.append(.movieDetail(movie)) }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 10) {
            MetricCard(icon: "bookmark.fill", title: "Saved", value: "\(store.movies.count)", note: "in your library")
            MetricCard(icon: "sparkles", title: "For you", value: "\(forYouMovies.count)", note: "recommendations")
            MetricCard(icon: "tv", title: "Platforms", value: "\(store.preferences.platforms.count)", note: "connected")
        }
    }

    // MARK: - For you

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Top for you")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Button("See all") { path.append(.myMovies) }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
            }
            if forYouMovies.isEmpty {
                Text("Save a few movies to start seeing personal recommendations here.")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
            } else if let spotlight = forYouMovies.first {
                SpotlightCard(movie: spotlight)
            }
        }
    }

    // MARK: - Mood

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("How are you feeling?")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Pick the vibe, the crowd, and the genre.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Clear") { draft = MoodSelectionDraft() }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
            }
            MoodSelectorView(draft: $draft)
        }
    }

    // MARK: - Action

    private var actionSection: some View {
        Button {
            guard let selection = draft.resolved else { return }
            path.append(.results(selection))
        } label: {
            Label("Get Recommendations", systemImage: "sparkles")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryActionButtonStyle(isEnabled: draft.isComplete))
        .disabled(!draft.isComplete)
    }

    // MARK: - Helpers

    private func motion<Content: View>(_ content: Content, delay: Double) -> some View {
        content
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.82).delay(delay), value: didAppear)
    }

    private func loadForYou() async {
        forYouMovies = await store.recommendationService.forYou(
            preferences: store.preferences,
            favoriteGenres: store.favoriteGenres
        )
    }

    private func runSearch() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            searching = false
            return
        }
        searching = true
        searchResults = await store.recommendationService.search(
            query: trimmed,
            excludingTitles: Set(store.movies.map(\.title))
        )
        searching = false
    }
}

// MARK: - Search result row

private struct SearchResultRow: View {
    let movie: MovieResult
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .small)
                VStack(alignment: .leading, spacing: 3) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(movie.year) • \(movie.genre.label)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.footnote.weight(.semibold))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metric card

private struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "F5A623"))
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

// MARK: - Spotlight card

private struct SpotlightCard: View {
    let movie: MovieResult

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(movie.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text("\(movie.year) • \(movie.genre.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(movie.reason)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.65))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    SummaryPill(text: movie.primaryAvailability.platformName)
                    SummaryPill(text: movie.primaryAvailability.type.label)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

