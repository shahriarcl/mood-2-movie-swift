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
        ZStack {
            AppScreenBackground()

            VStack(spacing: 0) {
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
                .background(AppScreenBackground())
                .toolbar(.hidden, for: .navigationBar)

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
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
                            .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 9, weight: isActive ? .semibold : .regular, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.bottom, 2)
                    .foregroundStyle(isActive ? Color(hex: "F5A623") : Color(white: 0.42))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minHeight: 50)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 0.5)
                }
        )
    }
}
