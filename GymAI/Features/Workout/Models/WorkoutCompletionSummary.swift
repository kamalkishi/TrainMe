import Foundation

struct WorkoutCompletionSummary: Identifiable, Hashable {

    let id: UUID
    let workoutName: String
    let duration: TimeInterval
    let completedExercises: Int
    let completedSets: Int
    let completedReps: Int
    let plannedTargets: [PlannedExerciseTarget]

    init(
        id: UUID,
        workoutName: String,
        duration: TimeInterval,
        completedExercises: Int,
        completedSets: Int,
        completedReps: Int,
        plannedTargets: [PlannedExerciseTarget]
    ) {
        self.id = id
        self.workoutName = workoutName
        self.duration = duration
        self.completedExercises = completedExercises
        self.completedSets = completedSets
        self.completedReps = completedReps
        self.plannedTargets = plannedTargets
    }

    init(
        sessionID: UUID,
        activeWorkout: ActiveWorkout,
        duration: TimeInterval,
        includesCurrentSetCompletion: Bool
    ) {
        let workout = activeWorkout.workout

        self.init(
            id: sessionID,
            workoutName: workout.name,
            duration: duration,
            completedExercises: activeWorkout.completedExerciseCount,
            completedSets: activeWorkout.completedSetCount,
            completedReps: activeWorkout.completedResultReps,
            plannedTargets: workout.exercises.map(PlannedExerciseTarget.init(workoutExercise:))
        )
    }
}

struct PlannedExerciseTarget: Identifiable, Hashable {

    let id: UUID
    let exerciseName: String
    let targetSets: Int
    let targetReps: Int

    init(
        id: UUID = UUID(),
        exerciseName: String,
        targetSets: Int,
        targetReps: Int
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.targetReps = targetReps
    }

    init(workoutExercise: WorkoutExercise) {
        self.init(
            id: workoutExercise.id,
            exerciseName: workoutExercise.exercise.name,
            targetSets: workoutExercise.targetSets,
            targetReps: workoutExercise.targetReps
        )
    }
}
