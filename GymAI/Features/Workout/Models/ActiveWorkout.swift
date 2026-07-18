import Foundation

struct ActiveWorkout {

    var workout: Workout

    var currentExerciseIndex: Int = 0
    var currentSet: Int = 1
    var completedReps: Int = 0
    var exerciseResults: [WorkoutExerciseResult]

    var elapsedTime: TimeInterval = 0

    var isRunning = false
    var isCompleted = false

    var completedExerciseCount: Int {
        exerciseResults.filter { result in
            result.completedSets >= result.plannedSets && result.plannedSets > 0
        }.count
    }

    var completedSetCount: Int {
        exerciseResults.reduce(0) { total, result in
            total + result.completedSets
        }
    }

    var completedResultReps: Int {
        exerciseResults.reduce(0) { total, result in
            total + result.completedReps
        }
    }

    init(workout: Workout) {
        self.workout = workout
        self.exerciseResults = Self.exerciseResults(for: workout)
    }

    init(session: WorkoutSession) {
        self.workout = session.workout
        self.currentExerciseIndex = Self.validExerciseIndex(
            session.currentExerciseIndex,
            workout: session.workout
        )
        self.currentSet = max(1, session.currentSet)
        self.completedReps = session.completedReps
        self.exerciseResults = Self.normalizedExerciseResults(
            session.exerciseResults.isEmpty
                ? Self.legacyExerciseResults(for: session)
                : session.exerciseResults,
            workout: session.workout
        )
        self.elapsedTime = session.elapsedTime
        self.isCompleted = session.completed
    }

    var currentWorkoutExercise: WorkoutExercise? {
        guard workout.exercises.indices.contains(currentExerciseIndex) else {
            return nil
        }

        return workout.exercises[currentExerciseIndex]
    }
    
    var hasCurrentExercise: Bool {
        workout.exercises.indices.contains(currentExerciseIndex)
    }

    var progress: Double {
        guard !workout.exercises.isEmpty else {
            return 0
        }

        let safeIndex = min(currentExerciseIndex, workout.exercises.count)

        return Double(safeIndex) / Double(workout.exercises.count)
    }

    private static func validExerciseIndex(_ index: Int, workout: Workout) -> Int {
        guard !workout.exercises.isEmpty else {
            return 0
        }

        return min(max(index, 0), workout.exercises.count - 1)
    }

    mutating func recordCompletedSet(for workoutExercise: WorkoutExercise) {
        refreshExerciseResultsIfNeeded()

        guard exerciseResults.indices.contains(currentExerciseIndex) else {
            return
        }

        guard exerciseResults[currentExerciseIndex].exerciseID == workoutExercise.id else {
            if let matchingIndex = exerciseResults.firstIndex(where: { $0.exerciseID == workoutExercise.id }) {
                exerciseResults[matchingIndex].recordCompletedSet(reps: workoutExercise.targetReps)
            }
            return
        }

        exerciseResults[currentExerciseIndex].recordCompletedSet(reps: workoutExercise.targetReps)
    }

    mutating func refreshExerciseResultsIfNeeded() {
        let normalizedResults = Self.normalizedExerciseResults(exerciseResults, workout: workout)

        if normalizedResults != exerciseResults {
            exerciseResults = normalizedResults
        }
    }

    private static func exerciseResults(for workout: Workout) -> [WorkoutExerciseResult] {
        workout.exercises.map { workoutExercise in
            WorkoutExerciseResult(
                exerciseID: workoutExercise.id,
                exerciseName: workoutExercise.exercise.name,
                plannedSets: workoutExercise.targetSets,
                plannedReps: workoutExercise.targetReps,
                plannedRestSeconds: workoutExercise.restSeconds
            )
        }
    }

    private static func normalizedExerciseResults(
        _ results: [WorkoutExerciseResult],
        workout: Workout
    ) -> [WorkoutExerciseResult] {
        var usedResultIDs = Set<UUID>()

        return workout.exercises.map { workoutExercise in
            guard let existingResult = results.first(where: {
                $0.exerciseID == workoutExercise.id && !usedResultIDs.contains($0.exerciseID)
            }) else {
                return WorkoutExerciseResult(workoutExercise: workoutExercise)
            }

            usedResultIDs.insert(existingResult.exerciseID)
            return existingResult.refreshedMetadata(from: workoutExercise)
        }
    }

    private static func legacyExerciseResults(for session: WorkoutSession) -> [WorkoutExerciseResult] {
        var results = exerciseResults(for: session.workout)

        guard !results.isEmpty else {
            return results
        }

        if session.completed {
            for index in results.indices {
                results[index].completedSets = results[index].plannedSets
                results[index].completedReps = results[index].plannedSets * results[index].plannedReps
            }
            return results
        }

        let safeExerciseIndex = validExerciseIndex(
            session.currentExerciseIndex,
            workout: session.workout
        )

        for index in results.indices {
            if index < safeExerciseIndex {
                results[index].completedSets = results[index].plannedSets
                results[index].completedReps = results[index].plannedSets * results[index].plannedReps
            } else if index == safeExerciseIndex {
                let completedCurrentSets = min(
                    max(session.currentSet - 1, 0),
                    results[index].plannedSets
                )
                results[index].completedSets = completedCurrentSets
                results[index].completedReps = completedCurrentSets * results[index].plannedReps
            }
        }

        return results
    }
}
