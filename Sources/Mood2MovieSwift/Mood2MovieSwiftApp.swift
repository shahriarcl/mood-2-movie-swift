import SwiftUI

@main
struct Mood2MovieSwiftApp: App {
    @State private var store = AppStore()
    @State private var cloud = CloudSyncService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(cloud)
                .task {
                    await cloud.restoreSessionIfNeeded()
                    if cloud.isSignedIn {
                        let remote = await cloud.fetchRemoteLibrary()
                        if !remote.isEmpty {
                            store.replaceLibrary(with: remote)
                        }
                    }
                }
        }
    }
}
