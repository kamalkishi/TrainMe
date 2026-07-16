import Foundation

protocol WorkoutRepositoryProtocol {

    // MARK: - Active Session

    func startSession(for workout: Workout)

    func fetchActiveSession() -> WorkoutSession?

    func updateSession(_ session: WorkoutSession)

    func clearActiveSession()

    @discardableResult
    func abandonActiveSession() -> Bool

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord]

    func save(_ workout: WorkoutSessionRecord)
}
