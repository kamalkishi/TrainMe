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
    
    func startWorkout(_ session: WorkoutSession) throws -> WorkoutSessionEntity {

        let workoutEntity = try workoutEntity(for: session.workout)

        let entity = WorkoutSessionEntity(session: session)

        entity.workout = workoutEntity

        modelContext.insert(entity)

        try modelContext.save()

        return entity
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
    
    func loadActiveSession() throws -> WorkoutSession? {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate<WorkoutSessionEntity> {
                $0.completed == false
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return WorkoutSession(entity: entity)
    }
    
    func completeSession(sessionID: UUID) throws {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        guard let session = try modelContext.fetch(descriptor).first else {
            return
        }

        let history = WorkoutHistoryEntity(
            workoutName: session.workoutName,
            startedAt: session.startedAt,
            completedAt: session.endedAt ?? .now,
            duration: session.elapsedTime,
            exercisesCompleted: session.completedExercises
        )

        modelContext.insert(history)

        modelContext.delete(session)

        try modelContext.save()
    }
    
    func fetchWorkoutHistory() throws -> [WorkoutSessionRecord] {

        let descriptor = FetchDescriptor<WorkoutHistoryEntity>(
            sortBy: [
                SortDescriptor(\.completedAt, order: .reverse)
            ]
        )

        let entities = try modelContext.fetch(descriptor)

        return entities.map {

            WorkoutSessionRecord(
                id: $0.id,
                workoutName: $0.workoutName,
                startedAt: $0.startedAt,
                completedAt: $0.completedAt,
                duration: $0.duration,
                exercisesCompleted: $0.exercisesCompleted
            )
        }
    }
}
