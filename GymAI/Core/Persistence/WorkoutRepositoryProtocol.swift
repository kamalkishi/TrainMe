import Foundation

protocol WorkoutRepositoryProtocol {

    // MARK: - Active Session

    @discardableResult
    func startSession(for workout: Workout) -> WorkoutSession?

    func fetchActiveSession() -> WorkoutSession?

    func updateSession(_ session: WorkoutSession)

    func clearActiveSession()

    @discardableResult
    func clearActiveSession(ifSessionID sessionID: UUID) -> Bool

    @discardableResult
    func abandonActiveSession() -> Bool

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord]

    func save(_ workout: WorkoutSessionRecord)
}
