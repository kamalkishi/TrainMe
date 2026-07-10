import Foundation

struct WorkoutSession: Identifiable, Codable, Hashable {

    let id: UUID

    var workout: Workout

    var startedAt: Date
    var endedAt: Date?

    var completed: Bool

    init(
        id: UUID = UUID(),
        workout: Workout,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.workout = workout
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.completed = completed
    }
}
