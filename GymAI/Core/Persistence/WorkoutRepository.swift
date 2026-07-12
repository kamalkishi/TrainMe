import Foundation

import Observation

@Observable
final class WorkoutRepository: WorkoutRepositoryProtocol {

    static let shared = WorkoutRepository()

    private init() {}

    var activeSession: WorkoutSession?

    var history: [WorkoutSessionRecord] = []

    // MARK: - Active Session

    func startSession(for workout: Workout) {

        activeSession = WorkoutSession(workout: workout)
    }

    func fetchActiveSession() -> WorkoutSession? {

        activeSession
    }

    func updateSession(_ session: WorkoutSession) {

        activeSession = session
    }

    func clearActiveSession() {

        activeSession = nil
    }

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {

        history
    }

    func save(_ workout: WorkoutSessionRecord) {

        history.insert(workout, at: 0)
    }
}
