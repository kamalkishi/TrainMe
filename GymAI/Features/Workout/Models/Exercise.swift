import Foundation

struct Exercise: Identifiable, Codable, Hashable {

    let id: UUID
    let name: String
    let muscleGroups: [MuscleGroup]
    let workoutType: WorkoutType

    let requiresWeight: Bool
    let unilateral: Bool

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroups: [MuscleGroup],
        workoutType: WorkoutType,
        requiresWeight: Bool,
        unilateral: Bool = false
    ) {
        self.id = id
        self.name = name
        self.muscleGroups = muscleGroups
        self.workoutType = workoutType
        self.requiresWeight = requiresWeight
        self.unilateral = unilateral
    }
}
