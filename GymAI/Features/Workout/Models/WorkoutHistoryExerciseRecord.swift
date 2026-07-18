import Foundation

struct WorkoutHistoryExerciseRecord: Identifiable, Codable, Hashable {

    var id: UUID {
        exerciseID
    }

    let exerciseID: UUID
    let exerciseName: String
    let plannedSets: Int
    let plannedReps: Int
    let plannedRestSeconds: Int
    let completedSets: Int
    let completedReps: Int

    init(
        exerciseID: UUID,
        exerciseName: String,
        plannedSets: Int,
        plannedReps: Int,
        plannedRestSeconds: Int,
        completedSets: Int,
        completedReps: Int
    ) {
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.plannedSets = plannedSets
        self.plannedReps = plannedReps
        self.plannedRestSeconds = plannedRestSeconds
        self.completedSets = completedSets
        self.completedReps = completedReps
    }

    init(result: WorkoutExerciseResult) {
        self.init(
            exerciseID: result.exerciseID,
            exerciseName: result.exerciseName,
            plannedSets: result.plannedSets,
            plannedReps: result.plannedReps,
            plannedRestSeconds: result.plannedRestSeconds,
            completedSets: result.completedSets,
            completedReps: result.completedReps
        )
    }
}
