import Foundation

protocol WorkoutRepositoryProtocol {

    // MARK: - Active Session

    func startSession(for workout: Workout)

    func fetchActiveSession() -> WorkoutSession?

    func updateSession(_ session: WorkoutSession)

    func clearActiveSession()

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord]

    func save(_ workout: WorkoutSessionRecord)
}
