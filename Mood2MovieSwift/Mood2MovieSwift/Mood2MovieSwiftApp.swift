import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
@main
struct Mood2MovieSwiftApp: App {
    @State private var store = AppStore()
    @State private var configuration = AppConfigurationStore.shared
    @State private var cloud = CloudSyncService()
    @State private var showSplash = true

    init() {
        #if canImport(UIKit)
        let transparent = UINavigationBarAppearance()
        transparent.configureWithTransparentBackground()
        transparent.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = transparent
        UINavigationBar.appearance().compactAppearance = transparent
        UINavigationBar.appearance().scrollEdgeAppearance = transparent
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environment(store)
                    .environment(configuration)
                    .environment(cloud)
                    .opacity(showSplash ? 0 : 1)
                    .task {
                        await cloud.restoreSessionIfNeeded()
                        if cloud.isSignedIn {
                            let remote = await cloud.fetchRemoteLibrary()
                            store.mergeLibrary(with: remote)
                            await cloud.syncLocalLibrary(store.movies)
                        }
                    }

                if showSplash {
                    LaunchSplashView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(900))
                withAnimation(.easeOut(duration: 0.28)) {
                    showSplash = false
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
