import Foundation

struct Workout: Identifiable, Codable, Hashable {

    let id: UUID

    var name: String
    var type: WorkoutType

    var exercises: [Exercise]

    init(
        id: UUID = UUID(),
        name: String,
        type: WorkoutType,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.exercises = exercises
    }
}
