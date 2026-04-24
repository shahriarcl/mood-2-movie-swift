import SwiftUI

@MainActor
@main
struct Mood2MovieSwiftApp: App {
    @State private var store = AppStore()
    @State private var configuration = AppConfigurationStore.shared
    @State private var cloud = CloudSyncService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(configuration)
                .environment(cloud)
                .task {
                    await cloud.restoreSessionIfNeeded()
                    if cloud.isSignedIn {
                        let remote = await cloud.fetchRemoteLibrary()
                        store.mergeLibrary(with: remote)
                        await cloud.syncLocalLibrary(store.movies)
                    }
                }
        }
    }
}
