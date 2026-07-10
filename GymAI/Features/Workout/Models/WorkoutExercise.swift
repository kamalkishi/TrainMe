import Foundation

struct WorkoutExercise: Identifiable, Codable, Hashable {

    let id: UUID

    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int
    var restSeconds: Int

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetSets: Int,
        targetReps: Int,
        restSeconds: Int
    ) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.restSeconds = restSeconds
    }
}
