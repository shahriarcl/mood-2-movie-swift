import SwiftUI

enum AppRoute: Hashable {
    case results(MoodSelection)
    case settings
    case myMovies
    case movieDetail(MovieResult)
}

struct RootView: View {
    @State private var path: [AppRoute] = []
    @State private var focusSearch = false

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path, focusSearch: $focusSearch)
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
                    focusSearch = false
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        path.removeAll()
                    }
                case .search:
                    focusSearch = true
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        path.removeAll()
                    }
                case .library:
                    focusSearch = false
                    path = [.myMovies]
                case .settings:
                    focusSearch = false
                    path = [.settings]
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.top, 2)
            .padding(.bottom, 6)
        }
    }

    private var activeTab: ShellTab {
        if focusSearch { return .search }
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
    case search
    case library
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "bookmark.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

private struct PhoneTabBar: View {
    let activeTab: ShellTab
    let onSelect: (ShellTab) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ShellTab.allCases, id: \.self) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    let isActive = activeTab == tab
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: isActive ? 17 : 16, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(isActive ? .bold : .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(isActive ? Color(hex: "F5A623") : Color.secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isActive ? Color(hex: "F5A623").opacity(0.14) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
    }
}
