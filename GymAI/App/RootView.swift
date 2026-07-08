import SwiftUI

struct RootView: View {

    @EnvironmentObject private var appState: AppStateManager

    var body: some View {
        switch appState.state {

        case .launching:
            SplashView()

        case .unauthenticated:
            LoginView()

        case .authenticated:
            MainTabView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppStateManager())
}
