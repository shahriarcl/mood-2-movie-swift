import SwiftUI

struct MyMoviesView: View {
    @Environment(AppStore.self) private var store
    @Environment(CloudSyncService.self) private var cloud
    @Binding var path: [AppRoute]
    @State private var didAppear = false
    @State private var email = ""
    @State private var password = ""
    @State private var authMessage: String?
    @State private var authBusy = false
    @State private var syncMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                heroSummary
                authSection
                if store.movies.isEmpty {
                    emptyLibraryState
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
            .padding(.horizontal, 16)
            .frame(maxWidth: 400, alignment: .leading)
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 12)
        }
        .background(AppScreenBackground())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                didAppear = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                if !path.isEmpty { path.removeLast() }
            } label: {
                Label("Home", systemImage: "chevron.left")
            }
            .buttonStyle(PlainBackButtonStyle())

            ScreenHeader(
                eyebrow: "Your library",
                title: "Saved movies",
                subtitle: "Watchlist and watched titles live here, and cloud sync keeps them with you.",
                badge: "\(store.movies.count) saved"
            )
        }
    }

    private var authSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: cloud.isSignedIn ? "Cloud Sync" : "Sign In")
                        Text(cloud.isSignedIn ? "Your library can follow you across devices." : "Sign in to keep watchlists and watched titles in sync.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(cloud.isSignedIn ? "Connected" : "Offline")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(cloud.isSignedIn ? Color(hex: "F5A623").opacity(0.18) : Color.white.opacity(0.06))
                        )
                }

                if cloud.isSignedIn {
                    VStack(spacing: 10) {
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

                        VStack(spacing: 10) {
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

    private var heroSummary: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Saved titles")
                        .font(.caption2.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(Color(hex: "F5A623"))
                    Text("\(store.movies.count)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    Text("movies in the library")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    LibraryStat(label: "Watchlist", value: "\(store.watchlist.count)")
                    LibraryStat(label: "Watched", value: "\(store.watched.count)")
                    LibraryStat(label: "Sync", value: cloud.isSignedIn ? "On" : "Off")
                }

                Text(cloud.isSignedIn ? "Cloud sync is active." : "Sign in to move your library between devices.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyLibraryState: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Nothing saved yet")
                Text("Start from the Home screen, pick a mood, and save a title here to build your own watchlist.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    path.removeAll()
                } label: {
                    Text("Go explore moods")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryActionButtonStyle(isEnabled: true))
            }
        }
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
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                    Text(title)
                        .font(.headline.weight(.semibold))
                    Text("\(movies.count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                    Spacer()
                }

                Text(title == "Watchlist" ? "Ready for your next session." : "Titles you’ve already watched.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

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
        }
    }
}

private struct LibraryStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
        }
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
                Text(movie.genre.label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(hex: "F5A623"))
            }
            Spacer()
            VStack(spacing: 8) {
                Button(movie.status == .watchlist ? "Watched" : "Watchlist", action: swapStatus)
                    .buttonStyle(InlineActionButtonStyle(isActive: false))
                Button(role: .destructive, action: remove) {
                    Label("Remove", systemImage: "trash")
                }
                .buttonStyle(InlineActionButtonStyle(isActive: false))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
