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
            VStack(alignment: .leading, spacing: 28) {
                heroHeader
                searchSection
                forYouSection
                moodSection
                actionSection
                footerSection
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: 820, alignment: .leading)
        }
        .background(backgroundView)
        .task(id: store.favoriteGenres) {
            await loadForYou()
        }
        .task(id: searchText) {
            await runSearch()
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(hex: "09090B"),
                Color(hex: "111114"),
                Color(hex: "0D0D10")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            RadialGradient(
                colors: [Color(hex: "F5A623").opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()
        )
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("◆ AI-Curated")
                .font(.caption2.weight(.semibold))
                .tracking(2.4)
                .foregroundStyle(Color(hex: "F5A623"))
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 4) {
                Text("Mood")
                    .foregroundStyle(.primary)
                Text("2")
                    .foregroundStyle(Color(hex: "F5A623"))
                Text("Movie")
                    .foregroundStyle(.primary)
            }
            .font(.system(size: 62, weight: .black, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.65)

            Text("You don't know what you want to watch - we do.")
                .font(.system(.body, design: .serif).italic())
                .foregroundStyle(.secondary)

            Divider()
                .overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Search")
            TextField("Search a movie title", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .scrollContentBackground(.hidden)
                .padding(.vertical, 2)

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
                                path.append(.results(MoodSelection(audience: .solo, genre: movie.genre)))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "For You")

            if forYouMovies.isEmpty {
                Text("Save a few movies and the app will start shaping recommendations around your taste.")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else {
                VStack(spacing: 10) {
                    ForEach(forYouMovies) { movie in
                        SearchResultRow(movie: movie) {
                            path.append(.results(MoodSelection(audience: .solo, genre: movie.genre)))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Build Your Mood")

            MoodSelectorView(draft: $draft)
                .opacity(searchText.isEmpty ? 1 : 0.35)
                .allowsHitTesting(searchText.isEmpty)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var actionSection: some View {
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

    private var footerSection: some View {
        HStack {
            Button {
                path.append(.settings)
            } label: {
                let count = store.preferences.platforms.count
                Text(count > 0 ? "\(count) platform\(count == 1 ? "" : "s") selected" : "Set up your streaming platforms")
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

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.045))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
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
