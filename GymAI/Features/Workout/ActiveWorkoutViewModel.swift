import Foundation
import SwiftUI

@Observable
final class ActiveWorkoutViewModel {
    
    private let repository: WorkoutRepositoryProtocol
    
    var activeWorkout: ActiveWorkout

    init(
        workout: Workout,
        repository: WorkoutRepositoryProtocol = WorkoutRepository.shared
    ) {
        self.activeWorkout = ActiveWorkout(workout: workout)
        self.repository = repository
    }

    var workout: Workout {
        activeWorkout.workout
    }

    var currentExercise: WorkoutExercise? {
        activeWorkout.currentWorkoutExercise
    }
    
    var currentExerciseNumber: Int {
        activeWorkout.currentExerciseIndex + 1
    }

    var totalExercises: Int {
        workout.exercises.count
    }

    var isFirstExercise: Bool {
        activeWorkout.currentExerciseIndex == 0
    }

    var isLastExercise: Bool {
        activeWorkout.currentExerciseIndex == workout.exercises.count - 1
    }

    var currentSet: Int {
        activeWorkout.currentSet
    }
    
    var isWorkoutCompleted: Bool {
        activeWorkout.isCompleted
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
    
    func completeSet() {

        guard let workoutExercise = activeWorkout.currentWorkoutExercise else {
            return
        }
        
        if activeWorkout.currentSet < workoutExercise.targetSets {

            activeWorkout.currentSet += 1

        } else {

            activeWorkout.currentSet = 1

            if activeWorkout.currentExerciseIndex < workout.exercises.count - 1 {

                activeWorkout.currentExerciseIndex += 1

            } else {

                activeWorkout.isCompleted = true
            }
        }
    }
    
    func finishWorkout() {

        let record = WorkoutSessionRecord(
            workoutName: workout.name,
            duration: workout.estimatedDuration,
            exercisesCompleted: workout.exercises.count
        )

        repository.save(record)
    }
}
