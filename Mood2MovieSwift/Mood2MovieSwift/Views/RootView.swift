import SwiftUI

enum AppRoute: Hashable {
    case results(MoodSelection)
    case settings
    case myMovies
    case movieDetail(MovieResult)
}

struct RootView: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .results(let selection):
                        ResultsView(path: $path, selection: selection)
                    case .settings:
                        SettingsView(path: $path)
                    case .myMovies:
                        MyMoviesView(path: $path)
                    case .movieDetail(let movie):
                        MovieDetailView(movie: movie)
                    }
                }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 10) {
                TabContextStrip(tab: activeTab)
                PhoneTabBar(activeTab: activeTab) { tab in
                    switch tab {
                    case .home:
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                            path.removeAll()
                        }
                    case .library:
                        path = [.myMovies]
                    case .settings:
                        path = [.settings]
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    private var activeTab: ShellTab {
        guard let last = path.last else { return .home }
        switch last {
        case .settings: return .settings
        case .myMovies: return .library
        case .results, .movieDetail: return .home
        }
    }
}

private enum ShellTab: String, CaseIterable {
    case home
    case library
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "rectangle.stack.fill"
        case .settings: return "slider.horizontal.3"
        }
    }
}

private struct PhoneTabBar: View {
    let activeTab: ShellTab
    let onSelect: (ShellTab) -> Void

    var body: some View {
        VStack(spacing: 8) {
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.42))
                .frame(width: 128, height: 4)
                .padding(.top, 2)

            HStack(spacing: 8) {
                ForEach(ShellTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        let isActive = activeTab == tab
                        VStack(spacing: 4) {
                            Capsule(style: .continuous)
                                .fill(isActive ? Color(hex: "F5A623") : Color.clear)
                                .frame(width: isActive ? 22 : 12, height: 4)
                            Image(systemName: tab.symbol)
                                .font(.system(size: isActive ? 16 : 15, weight: .semibold))
                            Text(tab.title)
                                .font(.caption2.weight(isActive ? .bold : .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    isActive
                                    ? LinearGradient(
                                        colors: [Color(hex: "FFB84D"), Color(hex: "F5A623")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(isActive ? Color.white.opacity(0.14) : Color.clear, lineWidth: 1)
                                )
                        )
                        .foregroundStyle(isActive ? Color(hex: "0D0D0F") : Color.secondary)
                        .scaleEffect(isActive ? 1.01 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.24), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

private struct TabContextStrip: View {
    let tab: ShellTab

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: tab.symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "F5A623"))
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(tab.title)
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(Color.white)
                Text(contextCopy)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }

    private var contextCopy: String {
        switch tab {
        case .home: return "Curating your next watch"
        case .library: return "Saved picks and watchlist"
        case .settings: return "App, API, and sync preferences"
        }
    }
}
