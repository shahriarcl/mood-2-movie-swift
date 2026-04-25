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
        .background(AppScreenBackground())
        .toolbar(.hidden, for: .navigationBar)
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
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        HStack(spacing: 0) {
            ForEach(ShellTab.allCases, id: \.self) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    let isActive = activeTab == tab
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 10, weight: isActive ? .semibold : .regular, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                    .foregroundStyle(isActive ? Color(hex: "F5A623") : Color(white: 0.42))
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
