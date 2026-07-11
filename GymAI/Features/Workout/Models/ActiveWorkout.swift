import Foundation

struct ActiveWorkout {

    var workout: Workout

    var currentExerciseIndex: Int = 0
    var currentSet: Int = 1
    var completedReps: Int = 0

    var elapsedTime: TimeInterval = 0

    var isRunning = false
    var isCompleted = false

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
}
