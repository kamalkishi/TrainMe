import Foundation

protocol WorkoutRepositoryProtocol {

    func fetchWorkoutHistory() -> [WorkoutSessionRecord]

    func save(_ workout: WorkoutSessionRecord)
}
