import Foundation

struct WorkoutExerciseResult: Identifiable, Codable, Hashable {

    var id: UUID {
        exerciseID
    }

    let exerciseID: UUID
    var exerciseName: String
    var plannedSets: Int
    var plannedReps: Int
    var plannedRestSeconds: Int
    var completedSets: Int
    var completedReps: Int

    init(
        exerciseID: UUID,
        exerciseName: String,
        plannedSets: Int,
        plannedReps: Int,
        plannedRestSeconds: Int,
        completedSets: Int = 0,
        completedReps: Int = 0
    ) {
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.plannedSets = plannedSets
        self.plannedReps = plannedReps
        self.plannedRestSeconds = plannedRestSeconds
        self.completedSets = completedSets
        self.completedReps = completedReps
    }

    init(workoutExercise: WorkoutExercise) {
        self.init(
            exerciseID: workoutExercise.id,
            exerciseName: workoutExercise.exercise.name,
            plannedSets: workoutExercise.targetSets,
            plannedReps: workoutExercise.targetReps,
            plannedRestSeconds: workoutExercise.restSeconds
        )
    }

    mutating func recordCompletedSet(reps: Int) {
        completedSets = min(completedSets + 1, plannedSets)
        completedReps += max(reps, 0)
    }

    func refreshedMetadata(from workoutExercise: WorkoutExercise) -> WorkoutExerciseResult {
        WorkoutExerciseResult(
            exerciseID: workoutExercise.id,
            exerciseName: workoutExercise.exercise.name,
            plannedSets: workoutExercise.targetSets,
            plannedReps: workoutExercise.targetReps,
            plannedRestSeconds: workoutExercise.restSeconds,
            completedSets: min(max(completedSets, 0), workoutExercise.targetSets),
            completedReps: max(completedReps, 0)
        )
    }
}
