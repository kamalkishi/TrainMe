import SwiftUI
import Combine

@MainActor
final class AppStateManager: ObservableObject {

    @Published private(set) var state: AppState = .launching

    func transitionToLogin() {
        state = .unauthenticated
    }

    func transitionToAuthenticated() {
        state = .authenticated
    }

    func logout() {
        state = .unauthenticated
    }
}
