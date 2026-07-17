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
        let exerciseIndex = Self.validExerciseIndex(
            activeWorkout.currentExerciseIndex,
            exerciseCount: workout.exercises.count
        )
        let completedSets = Self.completedSets(
            workout: workout,
            currentExerciseIndex: exerciseIndex,
            currentSet: activeWorkout.currentSet,
            includesCurrentSetCompletion: includesCurrentSetCompletion
        )

        self.init(
            id: sessionID,
            workoutName: workout.name,
            duration: duration,
            completedExercises: activeWorkout.isCompleted
                ? workout.exercises.count
                : min(max(activeWorkout.currentExerciseIndex, 0), workout.exercises.count),
            completedSets: completedSets,
            completedReps: activeWorkout.completedReps,
            plannedTargets: workout.exercises.map(PlannedExerciseTarget.init(workoutExercise:))
        )
    }

    private static func completedSets(
        workout: Workout,
        currentExerciseIndex: Int,
        currentSet: Int,
        includesCurrentSetCompletion: Bool
    ) -> Int {
        guard workout.exercises.indices.contains(currentExerciseIndex) else {
            return 0
        }

        let priorExerciseSets = workout.exercises
            .prefix(currentExerciseIndex)
            .reduce(0) { total, workoutExercise in
                total + workoutExercise.targetSets
            }
        let currentExercise = workout.exercises[currentExerciseIndex]
        let currentExerciseCompletedSets: Int

        if includesCurrentSetCompletion {
            currentExerciseCompletedSets = min(
                max(currentSet, 0),
                currentExercise.targetSets
            )
        } else {
            currentExerciseCompletedSets = min(
                max(currentSet - 1, 0),
                currentExercise.targetSets
            )
        }

        return priorExerciseSets + currentExerciseCompletedSets
    }

    private static func validExerciseIndex(
        _ index: Int,
        exerciseCount: Int
    ) -> Int {
        guard exerciseCount > 0 else {
            return 0
        }

        return min(max(index, 0), exerciseCount - 1)
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
