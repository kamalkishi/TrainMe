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

        repository.startSession(for: workout)
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
        syncSession()
    }

    func previousExercise() {
        guard activeWorkout.currentExerciseIndex > 0 else {
            return
        }

        activeWorkout.currentExerciseIndex -= 1
        activeWorkout.currentSet = 1
        syncSession()
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
                syncSession()

            } else {
                activeWorkout.isCompleted = true

                if var session = repository.fetchActiveSession() {
                    session.completedExercises = workout.exercises.count
                    repository.updateSession(session)
                }
            }
        }
    }
    
    func finishWorkout() {

        guard var session = repository.fetchActiveSession() else {
            return
        }

        session.completed = true
        session.endedAt = Date()

        repository.updateSession(session)

        let duration = session.endedAt?.timeIntervalSince(session.startedAt) ?? 0

        let record = WorkoutSessionRecord(
            workoutName: session.workout.name,
            completedAt: session.endedAt ?? .now,
            duration: duration,
            exercisesCompleted: session.completedExercises
        )

        repository.save(record)

        repository.clearActiveSession()

        activeWorkout.isCompleted = true
    }
    
    private func syncSession() {

        guard var session = repository.fetchActiveSession() else {
            return
        }

        session.currentExerciseIndex = activeWorkout.currentExerciseIndex
        session.currentSet = activeWorkout.currentSet
        session.completedExercises = activeWorkout.currentExerciseIndex

        repository.updateSession(session)
    }
}
