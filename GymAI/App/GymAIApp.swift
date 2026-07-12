import SwiftUI
import SwiftData

@main
struct GymAIApp: App {

    @StateObject
    private var appStateManager = AppStateManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appStateManager)
        }
        .modelContainer(for: [
            WorkoutEntity.self,
            WorkoutSessionEntity.self,
            WorkoutHistoryEntity.self
        ])
    }
}
