import Foundation

struct ActiveWorkout {

    var workout: Workout

    var currentExerciseIndex: Int = 0
    var currentSet: Int = 1
    var completedReps: Int = 0

    var elapsedTime: TimeInterval = 0

    var isRunning = false
    var isCompleted = false

    init(workout: Workout) {
        self.workout = workout
    }

    init(session: WorkoutSession) {
        self.workout = session.workout
        self.currentExerciseIndex = Self.validExerciseIndex(
            session.currentExerciseIndex,
            workout: session.workout
        )
        self.currentSet = max(1, session.currentSet)
        self.completedReps = session.completedReps
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
}
