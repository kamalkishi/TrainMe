import SwiftUI

@main
struct GymAIApp: App {

    @StateObject
    private var appStateManager = AppStateManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appStateManager)
        }
    }
}
