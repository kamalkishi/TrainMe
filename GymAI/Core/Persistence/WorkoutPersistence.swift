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

        WorkoutLifecycleLog.event(
            "Persistence.startWorkout.begin",
            WorkoutLifecycleLog.session(session)
        )

        let workoutEntity = try workoutEntity(for: session.workout)

        let entity = WorkoutSessionEntity(session: session)

        entity.workout = workoutEntity

        WorkoutLifecycleLog.event(
            "Persistence.startWorkout.beforeInsert",
            WorkoutLifecycleLog.entity(entity)
        )
        modelContext.insert(entity)

        WorkoutLifecycleLog.event(
            "Persistence.startWorkout.beforeSave",
            WorkoutLifecycleLog.entity(entity)
        )
        try modelContext.save()

        WorkoutLifecycleLog.event(
            "Persistence.startWorkout.afterSave",
            WorkoutLifecycleLog.entity(entity)
        )
        return entity
    }
    
    private func workoutEntity(for workout: Workout) throws -> WorkoutEntity {

        let descriptor = FetchDescriptor<WorkoutEntity>(
            predicate: #Predicate {
                $0.id == workout.id
            }
        )

        WorkoutLifecycleLog.event(
            "Persistence.workoutEntity.fetch.begin",
            WorkoutLifecycleLog.workout(workout)
        )

        if let existing = try modelContext.fetch(descriptor).first {
            try WorkoutMapper.update(existing, from: workout)
            WorkoutLifecycleLog.event(
                "Persistence.workoutEntity.reused",
                WorkoutLifecycleLog.workout(workout)
                + ["workoutEntity.snapshotExists=\(existing.workoutSnapshotData != nil)"]
            )
            return existing
        }

        let entity = try WorkoutMapper.entity(from: workout)
        modelContext.insert(entity)
        WorkoutLifecycleLog.event(
            "Persistence.workoutEntity.inserted",
            WorkoutLifecycleLog.workout(workout)
            + ["workoutEntity.snapshotExists=\(entity.workoutSnapshotData != nil)"]
        )

        return entity
    }
    
    func saveSession(
        _ session: WorkoutSession,
        sessionID: UUID
    ) throws {

        WorkoutLifecycleLog.event(
            "Persistence.saveSession.fetch.begin",
            ["sessionID=\(sessionID)"] + WorkoutLifecycleLog.session(session)
        )

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            WorkoutLifecycleLog.event("Persistence.saveSession.fetch.missing", ["sessionID=\(sessionID)"])
            throw PersistenceError.sessionNotFound(sessionID)
        }

        WorkoutLifecycleLog.event(
            "Persistence.saveSession.fetch.found",
            WorkoutLifecycleLog.entity(entity)
        )

        entity.workoutName = session.workout.name
        entity.startedAt = session.startedAt
        entity.endedAt = session.endedAt
        entity.completed = session.completed
        entity.currentExerciseIndex = session.currentExerciseIndex
        entity.currentSet = session.currentSet
        entity.completedExercises = session.completedExercises
        entity.completedReps = session.completedReps
        entity.elapsedTime = session.elapsedTime

        WorkoutLifecycleLog.event(
            "Persistence.saveSession.beforeWorkoutRefresh",
            WorkoutLifecycleLog.entity(entity)
        )

        if let workoutEntity = entity.workout {
            try WorkoutMapper.update(workoutEntity, from: session.workout)
        } else {
            entity.workout = try workoutEntity(for: session.workout)
        }

        WorkoutLifecycleLog.event(
            "Persistence.saveSession.beforeSave",
            WorkoutLifecycleLog.entity(entity)
        )
        try modelContext.save()
        WorkoutLifecycleLog.event(
            "Persistence.saveSession.afterSave",
            WorkoutLifecycleLog.entity(entity)
        )
    }
    
    func loadActiveSession() throws -> WorkoutSession? {

        WorkoutLifecycleLog.event("Persistence.loadActiveSession.fetch.begin")

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate<WorkoutSessionEntity> {
                $0.completed == false
            },
            sortBy: [
                SortDescriptor(\.startedAt, order: .reverse)
            ]
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            WorkoutLifecycleLog.event("Persistence.loadActiveSession.fetch.none")
            return nil
        }

        WorkoutLifecycleLog.event(
            "Persistence.loadActiveSession.fetch.found",
            WorkoutLifecycleLog.entity(entity)
        )

        let session = try WorkoutSession(entity: entity)
        WorkoutLifecycleLog.event(
            "Persistence.loadActiveSession.mapped",
            WorkoutLifecycleLog.session(session)
        )

        return session
    }

    func loadIncompleteSessions() throws -> [WorkoutSession] {

        WorkoutLifecycleLog.event("Persistence.loadIncompleteSessions.fetch.begin")

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate<WorkoutSessionEntity> {
                $0.completed == false
            },
            sortBy: [
                SortDescriptor(\.startedAt, order: .reverse)
            ]
        )

        let entities = try modelContext.fetch(descriptor)
        WorkoutLifecycleLog.event(
            "Persistence.loadIncompleteSessions.fetch.found",
            ["incomplete.count=\(entities.count)"]
        )

        return try entities.map { entity in
            WorkoutLifecycleLog.event(
                "Persistence.loadIncompleteSessions.map",
                WorkoutLifecycleLog.entity(entity)
            )
            return try WorkoutSession(entity: entity)
        }
    }
    
    func completeSession(sessionID: UUID) throws -> WorkoutSessionRecord {

        WorkoutLifecycleLog.event("Persistence.completeSession.begin", ["sessionID=\(sessionID)"])

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
        WorkoutLifecycleLog.event(
            "Persistence.completeSession.historyFetch",
            ["sessionID=\(sessionID)", "existingHistory=\(existingHistory != nil)"]
        )

        guard let session = try modelContext.fetch(descriptor).first else {
            WorkoutLifecycleLog.event("Persistence.completeSession.sessionMissing", ["sessionID=\(sessionID)"])
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

        WorkoutLifecycleLog.event(
            "Persistence.completeSession.sessionFound",
            WorkoutLifecycleLog.entity(session)
        )

        if let existingHistory {
            modelContext.delete(session)
            WorkoutLifecycleLog.event(
                "Persistence.completeSession.duplicateHistoryDeleteSession.beforeSave",
                WorkoutLifecycleLog.entity(session)
            )
            try modelContext.save()
            WorkoutLifecycleLog.event("Persistence.completeSession.duplicateHistoryDeleteSession.afterSave")

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
            WorkoutLifecycleLog.event(
                "Persistence.completeSession.historyInserted",
                [
                    "history.id=\(history.id)",
                    "history.workoutName=\"\(history.workoutName)\"",
                    "history.duration=\(history.duration)",
                    "history.exercisesCompleted=\(history.exercisesCompleted)"
                ]
            )

            modelContext.delete(session)
            WorkoutLifecycleLog.event(
                "Persistence.completeSession.sessionDeletedBeforeSave",
                WorkoutLifecycleLog.entity(session)
            )

            try modelContext.save()
            WorkoutLifecycleLog.event("Persistence.completeSession.afterSave", ["sessionID=\(sessionID)"])

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

        WorkoutLifecycleLog.event("Persistence.fetchWorkoutHistory.begin")

        let descriptor = FetchDescriptor<WorkoutHistoryEntity>(
            sortBy: [
                SortDescriptor(\.completedAt, order: .reverse)
            ]
        )

        let entities = try modelContext.fetch(descriptor)
        WorkoutLifecycleLog.event(
            "Persistence.fetchWorkoutHistory.fetched",
            ["history.count=\(entities.count)"]
        )

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

        WorkoutLifecycleLog.event("Persistence.deleteSession.fetch.begin", ["sessionID=\(sessionID)"])

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.id == sessionID && $0.completed == false
            }
        )

        guard let session = try modelContext.fetch(descriptor).first else {
            WorkoutLifecycleLog.event("Persistence.deleteSession.fetch.none", ["sessionID=\(sessionID)"])
            return
        }

        WorkoutLifecycleLog.event(
            "Persistence.deleteSession.beforeDelete",
            WorkoutLifecycleLog.entity(session)
        )
        modelContext.delete(session)

        WorkoutLifecycleLog.event("Persistence.deleteSession.beforeSave", ["sessionID=\(sessionID)"])
        try modelContext.save()
        WorkoutLifecycleLog.event("Persistence.deleteSession.afterSave", ["sessionID=\(sessionID)"])
    }

    func deleteIncompleteSessions() throws {

        WorkoutLifecycleLog.event("Persistence.deleteIncompleteSessions.fetch.begin")

        let descriptor = FetchDescriptor<WorkoutSessionEntity>(
            predicate: #Predicate {
                $0.completed == false
            }
        )

        let sessions = try modelContext.fetch(descriptor)
        WorkoutLifecycleLog.event(
            "Persistence.deleteIncompleteSessions.fetch.found",
            ["incomplete.count=\(sessions.count)"]
        )

        for session in sessions {
            WorkoutLifecycleLog.event(
                "Persistence.deleteIncompleteSessions.beforeDelete",
                WorkoutLifecycleLog.entity(session)
            )
            modelContext.delete(session)
        }

        WorkoutLifecycleLog.event(
            "Persistence.deleteIncompleteSessions.beforeSave",
            ["deleted.count=\(sessions.count)"]
        )
        try modelContext.save()
        WorkoutLifecycleLog.event(
            "Persistence.deleteIncompleteSessions.afterSave",
            ["deleted.count=\(sessions.count)"]
        )
    }
}
