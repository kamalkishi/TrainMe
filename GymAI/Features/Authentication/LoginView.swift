import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var appState: AppStateManager

    var body: some View {

        VStack(spacing: Spacing.xl) {

            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            VStack(spacing: Spacing.sm) {

                Text("Welcome to GymAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your AI-powered fitness companion.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {

                appState.transitionToAuthenticated()

            } label: {

                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

        }
        .padding(Spacing.lg)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppStateManager())
}
