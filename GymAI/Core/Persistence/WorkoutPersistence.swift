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

    enum PersistenceError: Error {
        case sessionNotFound(UUID)
    }

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
            try WorkoutMapper.update(existing, from: workout)
            return existing
        }

        let entity = try WorkoutMapper.entity(from: workout)
        modelContext.insert(entity)

        return entity
    }
    
    func saveSession(
        _ session: WorkoutSession,
        sessionID: UUID
    ) throws {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.sessionNotFound(sessionID)
        }

        entity.workoutName = session.workout.name
        entity.startedAt = session.startedAt
        entity.endedAt = session.endedAt
        entity.completed = session.completed
        entity.currentExerciseIndex = session.currentExerciseIndex
        entity.currentSet = session.currentSet
        entity.completedExercises = session.completedExercises
        entity.completedReps = session.completedReps
        entity.elapsedTime = session.elapsedTime

        if let workoutEntity = entity.workout {
            try WorkoutMapper.update(workoutEntity, from: session.workout)
        } else {
            entity.workout = try workoutEntity(for: session.workout)
        }

        try modelContext.save()
    }
    
    func loadActiveSession() throws -> WorkoutSession? {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate<WorkoutSessionEntity> {
                $0.completed == false
            },
            sortBy: [
                SortDescriptor(\.startedAt, order: .reverse)
            ]
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return try WorkoutSession(entity: entity)
    }
    
    func completeSession(sessionID: UUID) throws -> WorkoutSessionRecord {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        let historyDescriptor = FetchDescriptor<WorkoutHistoryEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        let existingHistory = try modelContext.fetch(historyDescriptor).first

        guard let session = try modelContext.fetch(descriptor).first else {
            if let existingHistory {
                return WorkoutSessionRecord(
                    id: existingHistory.id,
                    workoutName: existingHistory.workoutName,
                    startedAt: existingHistory.startedAt,
                    completedAt: existingHistory.completedAt,
                    duration: existingHistory.duration,
                    exercisesCompleted: existingHistory.exercisesCompleted
                )
            }

            throw PersistenceError.sessionNotFound(sessionID)
        }

        if let existingHistory {
            modelContext.delete(session)
            try modelContext.save()

            return WorkoutSessionRecord(
                id: existingHistory.id,
                workoutName: existingHistory.workoutName,
                startedAt: existingHistory.startedAt,
                completedAt: existingHistory.completedAt,
                duration: existingHistory.duration,
                exercisesCompleted: existingHistory.exercisesCompleted
            )
        } else {
            session.completed = true

            if session.endedAt == nil {
                session.endedAt = .now
            }

            let completedAt = session.endedAt ?? .now
            let duration = session.elapsedTime > 0
                ? session.elapsedTime
                : completedAt.timeIntervalSince(session.startedAt)

            let history = WorkoutHistoryEntity(
                id: session.id,
                workoutName: session.workoutName,
                startedAt: session.startedAt,
                completedAt: completedAt,
                duration: duration,
                exercisesCompleted: session.completedExercises
            )

            modelContext.insert(history)

            modelContext.delete(session)

            try modelContext.save()

            return WorkoutSessionRecord(
                id: history.id,
                workoutName: history.workoutName,
                startedAt: history.startedAt,
                completedAt: history.completedAt,
                duration: history.duration,
                exercisesCompleted: history.exercisesCompleted
            )
        }
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

    func deleteSession(sessionID: UUID) throws {

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID && $0.completed == false
            }
        )

        guard let session = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(session)

        try modelContext.save()
    }
}
