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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                motion(topBar, delay: 0.0)
                motion(heroShowcase, delay: 0.05)
                motion(searchSection, delay: 0.12)
                motion(forYouSection, delay: 0.18)
                motion(moodSection, delay: 0.24)
                motion(actionSection, delay: 0.30)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: 400, alignment: .leading)
        }
        .background(AppScreenBackground())
        .onAppear {
            didAppear = true
        }
        .task(id: store.favoriteGenres) {
            await loadForYou()
        }
        .task(id: searchText) {
            await runSearch()
        }
    }

    private var topBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 14) {
                brandHeader
                Spacer(minLength: 12)
                topBarActions
            }

            VStack(alignment: .leading, spacing: 14) {
                brandHeader
                topBarActions
            }
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 10) {
            BrandMark()

            VStack(alignment: .leading, spacing: 2) {
                Text("Mood2Movie")
                    .font(.title3.weight(.black))
                    .foregroundStyle(Color.white)
                Text("Pick a movie by how you feel")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var topBarActions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                settingsButton
                libraryButton
            }

            VStack(alignment: .leading, spacing: 10) {
                settingsButton
                libraryButton
            }
        }
    }

    private var settingsButton: some View {
        Button {
            path.append(.settings)
        } label: {
            Label("Settings", systemImage: "slider.horizontal.3")
        }
        .buttonStyle(FooterLinkButtonStyle())
    }

    private var libraryButton: some View {
        Button {
            path.append(.myMovies)
        } label: {
            Label("Library", systemImage: "rectangle.stack.badge.person.crop")
        }
        .buttonStyle(FooterLinkButtonStyle())
    }

    private func motion<Content: View>(_ content: Content, delay: Double) -> some View {
        content
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.82).delay(delay), value: didAppear)
    }

    private var heroShowcase: some View {
        GlassCard {
            heroShowcaseStacked
        }
    }

    private var heroShowcaseStacked: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text("TODAY")
                    .font(.caption2.weight(.bold))
                    .tracking(3)
                    .foregroundStyle(Color(hex: "F5A623"))
                Text("Phone-first vibe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(hex: "F5A623"))
            }

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("◆ MOOD-DRIVEN RECOMMENDATIONS")
                        .font(.caption2.weight(.bold))
                        .tracking(3.2)
                        .foregroundStyle(Color(hex: "F5A623"))
                        .textCase(.uppercase)

                    Text("Tonight’s movie starts with a feeling.")
                        .font(.system(size: 33, weight: .black, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Search a title, or let the mood cards steer you toward a better match.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                HeroTag(text: "Fast search")
                HeroTag(text: "Mobile-first")
                HeroTag(text: "Saved taste")
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                HeroTag(text: "\(store.movies.count) saved")
                HeroTag(text: "\(store.favoriteGenres.count) favorite genres")
                HeroTag(text: "\(store.preferences.platforms.count) platforms")
                HeroTag(text: "\(forYouMovies.count) picks")
            }

            VStack(spacing: 12) {
                Button {
                    guard let selection = draft.resolved else { return }
                    path.append(.results(selection))
                } label: {
                    Label("Start the vibe", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryActionButtonStyle(isEnabled: draft.isComplete))
                .disabled(!draft.isComplete)

                Button {
                    path.append(.settings)
                } label: {
                    Label("Tune app", systemImage: "slider.horizontal.3")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MiniStat(label: "Saved", value: "\(store.movies.count)")
                MiniStat(label: "For you", value: "\(forYouMovies.count)")
                MiniStat(label: "Platforms", value: "\(store.preferences.platforms.count)")
                MiniStat(label: "Genres", value: "\(store.favoriteGenres.count)")
            }

            if let spotlight = forYouMovies.first {
                SpotlightCard(movie: spotlight)
            } else {
                EmptySpotlightCard()
            }

            HStack(spacing: 10) {
                Label(store.movies.isEmpty ? "Build your taste" : "Taste is active", systemImage: "heart.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
                Spacer()
                Text(store.movies.isEmpty ? "Start saving movies to power better picks." : "Your library is already feeding the engine.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: "Search")
                        Text("Find a title fast")
                            .font(.headline.weight(.semibold))
                        Text("Search the local catalog, then jump into the movie detail view.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Text(searchText.isEmpty ? "Browse" : "Search mode")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(searchText.isEmpty ? Color.white.opacity(0.06) : Color(hex: "F5A623").opacity(0.18))
                        )
                }

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
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "For You")
                        Text("Built from your saved library and platform preferences.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
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
                    LazyVStack(spacing: 12) {
                        ForEach(forYouMovies.prefix(3)) { movie in
                            FeaturedMovieCard(movie: movie) {
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
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Build Your Mood")
                        Text("Choose the people, the vibe, and the genre lane.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
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
                VStack(spacing: 12) {
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
                Text("Pick a mood, then let the app do the sorting.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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

private struct MiniStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

private struct SpotlightCard: View {
    let movie: MovieResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top for you")
                    .font(.caption2.weight(.bold))
                    .tracking(3)
                    .foregroundStyle(Color(hex: "F5A623"))
                Spacer()
                AvailabilityPill(availability: movie.primaryAvailability)
            }

            PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)
                .frame(width: 92, height: 132, alignment: .leading)

            Text(movie.title)
                .font(.headline.weight(.semibold))
            Text(movie.reason)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.10), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

private struct EmptySpotlightCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top for you")
                .font(.caption2.weight(.bold))
                .tracking(3)
                .foregroundStyle(Color(hex: "F5A623"))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "6AA8FF").opacity(0.30), Color(hex: "F5A623").opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles.tv")
                            .font(.title2)
                        Text("Your first spotlight lands here")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(Color(hex: "0D0D0F"))
                )

            Text("Save a few movies and the app will surface a personalized pick here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

private struct FeaturedMovieCard: View {
    let movie: MovieResult
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 138, alignment: .leading)

                Text(movie.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(movie.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.09), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
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
