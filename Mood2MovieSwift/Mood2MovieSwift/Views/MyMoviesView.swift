import SwiftUI

struct MyMoviesView: View {
    @Environment(AppStore.self) private var store
    @Environment(CloudSyncService.self) private var cloud
    @Binding var path: [AppRoute]
    @State private var email = ""
    @State private var password = ""
    @State private var authMessage: String?
    @State private var authBusy = false
    @State private var syncMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                authSection
                if store.movies.isEmpty {
                    EmptyStateView(message: "Sign in support and remote sync can come next. For now, this local library is ready once you save a movie.")
                } else {
                    MoviesSection(
                        title: "Watchlist",
                        icon: "bookmark.fill",
                        movies: store.watchlist,
                        onOpenDetail: openDetail,
                        swapStatus: { movie in
                            save(movie, status: .watched)
                        },
                        remove: remove
                    )

                    MoviesSection(
                        title: "Watched",
                        icon: "checkmark.circle.fill",
                        movies: store.watched,
                        onOpenDetail: openDetail,
                        swapStatus: { movie in
                            save(movie, status: .watchlist)
                        },
                        remove: remove
                    )
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

    private var authSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: cloud.isSignedIn ? "Cloud Sync" : "Sign In")

            if cloud.isSignedIn {
                HStack(spacing: 10) {
                    Button {
                        Task {
                            syncMessage = "Syncing..."
                            await cloud.syncLocalLibrary(store.movies)
                            syncMessage = "Cloud sync complete."
                        }
                    } label: {
                        Text("Sync now")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryActionButtonStyle(isEnabled: true))

                    Button(role: .destructive) {
                        Task {
                            await cloud.signOut()
                            syncMessage = nil
                        }
                    } label: {
                        Text("Sign out")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }

                if let syncMessage {
                    Text(syncMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 10) {
                        Button {
                            Task { await signIn() }
                        } label: {
                            Text(authBusy ? "Working..." : "Sign in")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryActionButtonStyle(isEnabled: true))
                        .disabled(authBusy)

                        Button {
                            Task { await signUp() }
                        } label: {
                            Text("Create account")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                        .disabled(authBusy)
                    }

                    if let authMessage {
                        Text(authMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
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
        Task { await cloud.syncLocalLibrary(store.movies) }
    }

    private func remove(_ movie: UserMovie) {
        store.removeMovie(movie.tmdbId)
        Task { await cloud.syncDelete(movie.tmdbId) }
    }

    private func openDetail(for movie: UserMovie) {
        path.append(.movieDetail(
            MovieResult(
                tmdbId: movie.tmdbId,
                title: movie.title,
                year: movie.year,
                posterPath: movie.posterPath,
                reason: "Saved in your library.",
                availability: [],
                primaryAvailability: Availability(type: .subscription, platformName: "Saved", platformKey: "saved"),
                genre: movie.genre
            )
        ))
    }

    private func signIn() async {
        authBusy = true
        defer { authBusy = false }
        do {
            try await cloud.signIn(email: email, password: password)
            authMessage = "Signed in."
            let remote = await cloud.fetchRemoteLibrary()
            store.mergeLibrary(with: remote)
            await cloud.syncLocalLibrary(store.movies)
        } catch {
            authMessage = "Sign in failed. Check your email/password and Supabase settings."
        }
    }

    private func signUp() async {
        authBusy = true
        defer { authBusy = false }
        do {
            try await cloud.signUp(email: email, password: password)
            authMessage = "Account created. You can sign in now."
        } catch {
            authMessage = "Sign up failed."
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

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.045))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct MoviesSection: View {
    let title: String
    let icon: String
    let movies: [UserMovie]
    let onOpenDetail: (UserMovie) -> Void
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
                            MovieListRow(
                                movie: movie,
                                onOpenDetail: {
                                    onOpenDetail(movie)
                                },
                                swapStatus: {
                                    swapStatus(movie)
                                },
                                remove: {
                                    remove(movie)
                                }
                            )
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
    let onOpenDetail: () -> Void
    let swapStatus: () -> Void
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpenDetail) {
                PosterBadge(genre: movie.genre, title: movie.title, year: movie.year, size: .small)
            }
            .buttonStyle(.plain)
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
