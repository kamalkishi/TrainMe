import Foundation

struct WorkoutSessionRecord: Identifiable, Codable, Hashable {

    let id: UUID
    let workoutName: String
    let completedAt: Date
    let duration: TimeInterval
    let exercisesCompleted: Int

    init(
        id: UUID = UUID(),
        workoutName: String,
        completedAt: Date = .now,
        duration: TimeInterval,
        exercisesCompleted: Int
    ) {
        self.id = id
        self.workoutName = workoutName
        self.completedAt = completedAt
        self.duration = duration
        self.exercisesCompleted = exercisesCompleted
    }
}
