import SwiftUI
import SwiftData

struct RootView: View {

    @EnvironmentObject private var appState: AppStateManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            switch appState.state {

            case .launching:
                SplashView()

            case .unauthenticated:
                LoginView()

            case .authenticated:
                MainTabView()
            }
        }
        .onAppear {
            WorkoutRepository.shared.configure(
                with: WorkoutPersistence(modelContext: modelContext)
            )
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppStateManager())
        .modelContainer(
            for: [
                WorkoutEntity.self,
                WorkoutSessionEntity.self,
                WorkoutHistoryEntity.self
            ],
            inMemory: true
        )
}
