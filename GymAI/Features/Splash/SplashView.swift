import SwiftUI

struct SplashView: View {

    @EnvironmentObject private var appState: AppStateManager

    var body: some View {
        VStack(spacing: Spacing.lg) {

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            Text("GymAI")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your AI Fitness Companion")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await startApp()
        }
    }

    private func startApp() async {

        // Temporary splash delay.
        // Later this will initialize services,
        // restore the user session,
        // preload ML models, etc.
        try? await Task.sleep(for: .seconds(2))

        appState.transitionToLogin()
    }
}

#Preview {
    SplashView()
        .environmentObject(AppStateManager())
}
