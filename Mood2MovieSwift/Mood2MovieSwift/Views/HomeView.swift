import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: [AppRoute]

    @State private var draft = MoodSelectionDraft()
    @State private var searchText = ""
    @State private var searchResults: [MovieResult] = []
    @State private var searching = false
    @State private var forYouMovies: [MovieResult] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                topBar
                heroHeader
                heroMetrics
                searchSection
                forYouSection
                moodSection
                actionSection
                footerSection
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: 980, alignment: .leading)
        }
        .background(AppScreenBackground())
        .task(id: store.favoriteGenres) {
            await loadForYou()
        }
        .task(id: searchText) {
            await runSearch()
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F5A623"), Color(hex: "FF7A59")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "play.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(hex: "0D0D0F"))
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Mood2Movie")
                        .font(.headline.weight(.semibold))
                    Text("Pick a movie by how you feel")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                Button {
                    path.append(.settings)
                } label: {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(FooterLinkButtonStyle())

                Button {
                    path.append(.myMovies)
                } label: {
                    Label("Library", systemImage: "rectangle.stack.badge.person.crop")
                }
                .buttonStyle(FooterLinkButtonStyle())
            }
        }
    }

    private var heroHeader: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("◆ AI-Curated")
                        .font(.caption2.weight(.semibold))
                        .tracking(2.4)
                        .foregroundStyle(Color(hex: "F5A623"))
                        .textCase(.uppercase)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood")
                        Text("2")
                            .foregroundStyle(Color(hex: "F5A623"))
                        Text("Movie")
                    }
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                    Text("You do not need the perfect title. You just need the right feeling.")
                        .font(.system(.body, design: .serif).italic())
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        HeroTag(text: "\(store.movies.count) saved")
                        HeroTag(text: "\(store.favoriteGenres.count) favorite genres")
                        HeroTag(text: "\(store.preferences.platforms.count) platforms")
                    }
                }

                Spacer(minLength: 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Tonight's vibe")
                        .font(.caption2.weight(.semibold))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                    Text(store.movies.isEmpty ? "Start with a mood and we’ll build the lane." : "Your saved library is already shaping better picks.")
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Divider().opacity(0.4)
                    Text("Use search if you already know the title, or let the mood cards guide you.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 260, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
            }
        }
    }

    private var heroMetrics: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            MetricCard(title: "Saved", value: "\(store.movies.count)", note: "in your library")
            MetricCard(title: "For you", value: "\(forYouMovies.count)", note: "recommendations ready")
            MetricCard(title: "Platforms", value: "\(store.preferences.platforms.count)", note: "streaming services")
        }
    }

    private var searchSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Search")
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search a movie title", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                Text("Search the local catalog, then jump into the movie detail view.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if searching {
                    HStack {
                        ProgressView()
                        Text("Searching...")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                } else if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if searchResults.isEmpty {
                        Text("No local matches yet.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(searchResults) { movie in
                                SearchResultRow(movie: movie) {
                                    path.append(.movieDetail(movie))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var forYouSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "For You")
                        Text("Built from your saved library and platform preferences.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(forYouMovies.count) picks")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                }

                if forYouMovies.isEmpty {
                    Text("Save a few movies and the app will start shaping recommendations around your taste.")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                } else {
                    VStack(spacing: 10) {
                        ForEach(forYouMovies) { movie in
                            SearchResultRow(movie: movie) {
                                path.append(.movieDetail(movie))
                            }
                        }
                    }
                }
            }
        }
    }

    private var moodSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Build Your Mood")
                        Text("Choose the people, the vibe, and the genre lane.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(searchText.isEmpty ? "Ready" : "Search mode")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(searchText.isEmpty ? Color(hex: "F5A623").opacity(0.18) : Color.white.opacity(0.06))
                        )
                }

                MoodSelectorView(draft: $draft)
                    .opacity(searchText.isEmpty ? 1 : 0.35)
                    .allowsHitTesting(searchText.isEmpty)
            }
        }
    }

    private var actionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Action")
                HStack(spacing: 12) {
                    Button {
                        guard let selection = draft.resolved else { return }
                        path.append(.results(selection))
                    } label: {
                        Text("Find my movie")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryActionButtonStyle(isEnabled: draft.isComplete))
                    .disabled(!draft.isComplete)

                    Button {
                        path.append(.results(store.randomSelection()))
                    } label: {
                        Text("Surprise me")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
        }
    }

    private var footerSection: some View {
        GlassCard {
            HStack(spacing: 12) {
                Button {
                    path.append(.settings)
                } label: {
                    let count = store.preferences.platforms.count
                    Text(count > 0 ? "\(count) platform\(count == 1 ? "" : "s") selected" : "Set up streaming platforms")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FooterLinkButtonStyle())

                Button {
                    path.append(.myMovies)
                } label: {
                    Text("My Movies")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FooterLinkButtonStyle())
            }
        }
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

private struct HeroTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .foregroundStyle(.secondary)
    }
}
