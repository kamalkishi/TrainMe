import Foundation
import SwiftUI

@Observable
@MainActor
final class ActiveWorkoutViewModel {
    
    private let repository: WorkoutRepositoryProtocol
    
    var activeWorkout: ActiveWorkout

    init(workout: Workout) {
        self.activeWorkout = ActiveWorkout(workout: workout)
        self.repository = WorkoutRepository.shared

        repository.startSession(for: workout)
    }

    init(
        workout: Workout,
        repository: WorkoutRepositoryProtocol
    ) {
        self.activeWorkout = ActiveWorkout(workout: workout)
        self.repository = repository

        repository.startSession(for: workout)
    }

    init(session: WorkoutSession) {
        self.repository = WorkoutRepository.shared
        self.activeWorkout = ActiveWorkout(session: session)

        repository.updateSession(session)
    }

    init(
        session: WorkoutSession,
        repository: WorkoutRepositoryProtocol
    ) {
        self.repository = repository
        self.activeWorkout = ActiveWorkout(session: session)

        repository.updateSession(session)
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
        guard !workout.exercises.isEmpty else {
            return true
        }

        return activeWorkout.currentExerciseIndex == workout.exercises.count - 1
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

            activeWorkout.completedReps += workoutExercise.targetReps
            activeWorkout.currentSet += 1
            syncSession()

        } else {

            activeWorkout.completedReps += workoutExercise.targetReps
            activeWorkout.currentSet = 1

            if activeWorkout.currentExerciseIndex < workout.exercises.count - 1 {

                activeWorkout.currentExerciseIndex += 1
                syncSession()

            } else {
                activeWorkout.isCompleted = true

                if var session = repository.fetchActiveSession() {
                    session.completedExercises = workout.exercises.count
                    session.completedReps = activeWorkout.completedReps
                    session.elapsedTime = Date().timeIntervalSince(session.startedAt)
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
        session.completedReps = activeWorkout.completedReps
        session.elapsedTime = session.endedAt?.timeIntervalSince(session.startedAt) ?? 0

        repository.updateSession(session)

        let record = WorkoutSessionRecord(
            id: session.id,
            workoutName: session.workout.name,
            startedAt: session.startedAt,
            completedAt: session.endedAt ?? .now,
            duration: session.elapsedTime,
            exercisesCompleted: session.completedExercises
        )

        repository.save(record)

        activeWorkout.isCompleted = true
    }
    
    private func syncSession() {

        guard var session = repository.fetchActiveSession() else {
            return
        }

        session.currentExerciseIndex = activeWorkout.currentExerciseIndex
        session.currentSet = activeWorkout.currentSet
        session.completedExercises = activeWorkout.currentExerciseIndex
        session.completedReps = activeWorkout.completedReps
        session.elapsedTime = Date().timeIntervalSince(session.startedAt)

        repository.updateSession(session)
    }
}
