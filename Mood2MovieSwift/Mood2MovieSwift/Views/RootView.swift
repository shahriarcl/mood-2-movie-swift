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
        GlassCard {
            HStack(spacing: 10) {
                ForEach(ShellTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.symbol)
                                .font(.system(size: 15, weight: .semibold))
                            Text(tab.title)
                                .font(.caption2.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(activeTab == tab ? Color(hex: "F5A623").opacity(0.95) : Color.white.opacity(0.04))
                        )
                        .foregroundStyle(activeTab == tab ? Color(hex: "0D0D0F") : Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .background(.clear)
    }
}
