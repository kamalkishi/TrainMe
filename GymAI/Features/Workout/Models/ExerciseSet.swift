import Foundation

struct ExerciseSet: Identifiable, Codable, Hashable {

    let id: UUID

    var reps: Int
    var weight: Double

    var duration: TimeInterval?
    var restTime: TimeInterval?

    var completed: Bool

    init(
        id: UUID = UUID(),
        reps: Int = 0,
        weight: Double = 0,
        duration: TimeInterval? = nil,
        restTime: TimeInterval? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.restTime = restTime
        self.completed = completed
    }
}
