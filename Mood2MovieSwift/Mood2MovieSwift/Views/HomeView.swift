import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: [AppRoute]
    @Binding var focusSearch: Bool

    @State private var draft = MoodSelectionDraft()
    @State private var searchText = ""
    @State private var searchResults: [MovieResult] = []
    @State private var searching = false
    @State private var forYouMovies: [MovieResult] = []
    @State private var didAppear = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                motion(topBar, delay: 0.0)
                motion(heroSection, delay: 0.05)
                motion(searchSection, delay: 0.10)
                motion(statsSection, delay: 0.16)
                motion(forYouSection, delay: 0.22)
                motion(moodSection, delay: 0.28)
                motion(actionSection, delay: 0.34)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: 400, alignment: .leading)
        }
        .background(AppScreenBackground())
        .onAppear {
            didAppear = true
            if focusSearch {
                searchFocused = true
            }
        }
        .onChange(of: focusSearch) { _, newValue in
            if newValue {
                searchFocused = true
            }
        }
        .onChange(of: searchFocused) { _, newValue in
            if !newValue && focusSearch {
                focusSearch = false
            }
        }
        .task(id: store.favoriteGenres) {
            await loadForYou()
        }
        .task(id: searchText) {
            await runSearch()
        }
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            wordmark
            Spacer(minLength: 12)
            Button {
                path.append(.settings)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var wordmark: some View {
        HStack(spacing: 8) {
            Text("MOOD")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(5.4)
            Text("2")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "F5A623"))
            Text("MOVIE")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(5.4)
        }
        .foregroundStyle(.white)
    }

    private var heroSection: some View {
        GlassCard {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    heroCopy
                    CinematicHeroArt()
                        .frame(width: 154)
                }

                VStack(alignment: .leading, spacing: 14) {
                    heroCopy
                    CinematicHeroArt()
                }
            }
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                heroTitle
                Text("Search a title, or let the mood cards steer you toward a better match.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.system(size: 29, weight: .black, design: .rounded))
            .lineLimit(3)
            .minimumScaleFactor(0.82)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var heroTitle: Text {
        var copy = AttributedString("Mood picks for\nwhatever you feel\nlike tonight.")
        if let range = copy.range(of: "Mood") {
            copy[range].foregroundColor = Color(hex: "F5A623")
        }
        return Text(copy)
    }

    private var searchSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search a movie", text: $searchText)
                        .focused($searchFocused)
                        .textFieldStyle(.plain)
                    Button {
                        searchFocused = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color(hex: "F5A623"))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(hex: "F5A623").opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.09), lineWidth: 1)
                        )
                )

                if searching {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Searching...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if searchResults.isEmpty {
                        Text("No local matches yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack {
                            Text("\(searchResults.count) matches")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(hex: "F5A623"))
                            Spacer()
                            Text("Tap a title to open details")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        VStack(spacing: 10) {
                            ForEach(searchResults) { movie in
                                SearchResultRow(movie: movie) {
                                    path.append(.movieDetail(movie))
                                }
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("Search local titles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "F5A623"))
                        Spacer()
                        Text("Find a title fast")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 10) {
            MetricCard(title: "Saved", value: "\(store.movies.count)", note: "in your library")
            MetricCard(title: "For you", value: "\(forYouMovies.count)", note: "recommendations")
            MetricCard(title: "Platforms", value: "\(store.preferences.platforms.count)", note: "connected")
        }
    }

    private var forYouSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Top for you")
                        Text("Built from your saved library and platform preferences.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("See all") {
                        path.append(.myMovies)
                    }
                    .buttonStyle(InlineActionButtonStyle(isActive: false))
                }

                if forYouMovies.isEmpty {
                    EmptyStateView(message: "Save a few movies and the app will start shaping recommendations around your taste.")
                } else if let spotlight = forYouMovies.first {
                    SpotlightCard(movie: spotlight)
                }
            }
        }
    }

    private var moodSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "How are you feeling?")
                        Text("Choose the people, the vibe, and the genre lane.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Clear") {
                        draft = MoodSelectionDraft()
                    }
                    .buttonStyle(PlainBackButtonStyle())
                }

                MoodSelectorView(draft: $draft)
            }
        }
    }

    private var actionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Action")
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
        }
    }

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
                    .fill(Color.white.opacity(0.04))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(Color.white)
            Text(note)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

private struct SpotlightCard: View {
    let movie: MovieResult

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title)
                            .font(.headline.weight(.semibold))
                            .lineLimit(2)
                        Text("\(movie.year) • \(movie.genre.label)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(movie.reason)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    SummaryPill(text: movie.primaryAvailability.platformName)
                    SummaryPill(text: movie.primaryAvailability.type.label)
                    Spacer()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.11), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}
