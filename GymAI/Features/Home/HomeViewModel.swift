import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    private let repository: WorkoutRepositoryProtocol

    private(set) var activeSession: WorkoutSession?

    var sessionToContinue: WorkoutSession?

    var shouldOpenWorkoutLibrary = false

    init() {
        self.repository = WorkoutRepository.shared
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
    }

    func loadActiveSession() {
        activeSession = repository.fetchActiveSession()
    }

    func continueActiveSession() {
        loadActiveSession()
        sessionToContinue = activeSession
    }

    @discardableResult
    func abandonActiveSession() -> Bool {
        let abandoned = repository.abandonActiveSession()

        if abandoned {
            loadActiveSession()
            sessionToContinue = nil
            shouldOpenWorkoutLibrary = true
        }

        return abandoned
    }
}
