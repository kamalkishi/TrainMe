//
//  WorkoutPersistence.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation
import SwiftData

@MainActor
final class WorkoutPersistence {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func startWorkout(_ workout: Workout) throws -> WorkoutSessionEntity {

        let workoutEntity = try workoutEntity(for: workout)

        let session = WorkoutSessionEntity(
            workoutName: workout.name
        )

        session.workout = workoutEntity

        modelContext.insert(session)

        try modelContext.save()

        return session
    }
    
    private func workoutEntity(for workout: Workout) throws -> WorkoutEntity {

        let descriptor = FetchDescriptor<WorkoutEntity>(
            predicate: #Predicate {
                $0.id == workout.id
            }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }

        let entity = WorkoutMapper.entity(from: workout)
        modelContext.insert(entity)

        return entity
    }
    
    func saveSession(
        _ activeWorkout: ActiveWorkout,
        sessionID: UUID
    ) throws {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        guard let session = try modelContext.fetch(descriptor).first else {
            return
        }

        session.currentExerciseIndex = activeWorkout.currentExerciseIndex
        session.currentSet = activeWorkout.currentSet
        session.completedExercises = activeWorkout.currentExerciseIndex
        session.completedReps = activeWorkout.completedReps
        session.elapsedTime = activeWorkout.elapsedTime
        session.completed = activeWorkout.isCompleted

        if activeWorkout.isCompleted {
            session.endedAt = .now
        }

        try modelContext.save()
    }
}
