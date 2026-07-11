import Foundation

final class WorkoutRepository: WorkoutRepositoryProtocol {

    static let shared = WorkoutRepository()

    private init() {}

    private var history: [WorkoutSessionRecord] = []

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {
        history
    }

    func save(_ workout: WorkoutSessionRecord) {
        history.insert(workout, at: 0)
    }
}
