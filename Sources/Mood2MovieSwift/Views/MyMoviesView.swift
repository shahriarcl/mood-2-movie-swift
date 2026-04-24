import SwiftUI

struct MyMoviesView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: [AppRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                if store.movies.isEmpty {
                    EmptyStateView(message: "Sign in support and remote sync can come next. For now, this local library is ready once you save a movie.")
                } else {
                    MoviesSection(title: "Watchlist", icon: "bookmark.fill", movies: store.watchlist) { movie in
                        save(movie, status: .watched)
                    } remove: { movie in
                        store.removeMovie(movie.tmdbId)
                    }

                    MoviesSection(title: "Watched", icon: "checkmark.circle.fill", movies: store.watched) { movie in
                        save(movie, status: .watchlist)
                    } remove: { movie in
                        store.removeMovie(movie.tmdbId)
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .background(backgroundView)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                if !path.isEmpty { path.removeLast() }
            } label: {
                Label("Home", systemImage: "chevron.left")
            }
            .buttonStyle(PlainBackButtonStyle())

            VStack(alignment: .leading, spacing: 6) {
                Text("My Movies")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                Text("Saved picks live here, split between watchlist and watched.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }

    private func save(_ movie: UserMovie, status: MovieStatus) {
        store.saveMovie(
            MovieResult(
                tmdbId: movie.tmdbId,
                title: movie.title,
                year: movie.year,
                posterPath: movie.posterPath,
                reason: "Saved from your library.",
                availability: [],
                primaryAvailability: Availability(type: .subscription, platformName: "Saved", platformKey: "saved"),
                genre: movie.genre
            ),
            status: status
        )
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

private struct MoviesSection: View {
    let title: String
    let icon: String
    let movies: [UserMovie]
    let swapStatus: (UserMovie) -> Void
    let remove: (UserMovie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(.headline.weight(.semibold))
                Text("\(movies.count)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                Spacer()
            }

            if movies.isEmpty {
                Text("Nothing here yet.")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .italic()
            } else {
                VStack(spacing: 10) {
                    ForEach(movies) { movie in
                        MovieListRow(movie: movie, swapStatus: {
                            swapStatus(movie)
                        }, remove: {
                            remove(movie)
                        })
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.045))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct MovieListRow: View {
    let movie: UserMovie
    let swapStatus: () -> Void
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .small)
            VStack(alignment: .leading, spacing: 3) {
                Text(movie.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(movie.year) • \(movie.status.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(movie.status == .watchlist ? "Watched" : "Watchlist", action: swapStatus)
                .buttonStyle(InlineActionButtonStyle(isActive: false))
            Button(role: .destructive, action: remove) {
                Image(systemName: "trash")
            }
            .buttonStyle(InlineActionButtonStyle(isActive: false))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
    }
}
