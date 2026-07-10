import Foundation

struct Workout: Identifiable, Codable, Hashable {

    let id: UUID

    var name: String
    var type: WorkoutType
    var exercises: [WorkoutExercise]
    var estimatedDuration: TimeInterval
    var description: String

    init(
        id: UUID = UUID(),
        name: String,
        type: WorkoutType,
        exercises: [WorkoutExercise] = [],
        estimatedDuration: TimeInterval,
        description: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.exercises = exercises
        self.estimatedDuration = estimatedDuration
        self.description = description
    }
}
