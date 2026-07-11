import Foundation
import SwiftUI

@Observable
final class ActiveWorkoutViewModel {

    var activeWorkout: ActiveWorkout

    init(workout: Workout) {
        self.activeWorkout = ActiveWorkout(workout: workout)
    }

    var workout: Workout {
        activeWorkout.workout
    }

    var currentExercise: WorkoutExercise? {
        guard !workout.exercises.isEmpty else { return nil }
        return workout.exercises[activeWorkout.currentExerciseIndex]
    }

    var currentSet: Int {
        activeWorkout.currentSet
    }

    func nextExercise() {
        guard activeWorkout.currentExerciseIndex < workout.exercises.count - 1 else {
            return
        }

        activeWorkout.currentExerciseIndex += 1
        activeWorkout.currentSet = 1
    }

    func previousExercise() {
        guard activeWorkout.currentExerciseIndex > 0 else {
            return
        }

        activeWorkout.currentExerciseIndex -= 1
        activeWorkout.currentSet = 1
    }
}
