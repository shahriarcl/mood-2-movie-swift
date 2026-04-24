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
        HStack(spacing: 10) {
            ForEach(ShellTab.allCases, id: \.self) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    let isActive = activeTab == tab
                    VStack(spacing: 4) {
                        Capsule(style: .continuous)
                            .fill(isActive ? Color(hex: "F5A623") : Color.clear)
                            .frame(width: 18, height: 4)
                        Image(systemName: tab.symbol)
                            .font(.system(size: isActive ? 16 : 15, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(isActive ? .bold : .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isActive ? Color(hex: "F5A623").opacity(0.92) : Color.clear)
                    )
                    .foregroundStyle(isActive ? Color(hex: "0D0D0F") : Color.secondary)
                    .scaleEffect(isActive ? 1.01 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.26), radius: 22, x: 0, y: 12)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}
