import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout persistence")
struct WorkoutPersistenceTests {

    @Test
    func startAndPersistSession() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let workout = WorkoutMapperTests.makeWorkout()
        let session = WorkoutSession(workout: workout)

        let entity = try persistence.startWorkout(session)

        #expect(entity.id == session.id)
        #expect(entity.workoutName == workout.name)
        #expect(entity.workout?.workoutSnapshotData != nil)
    }

    @Test
    func progressUpdatePersistsResumableState() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let entity = try persistence.startWorkout(session)

        session.currentExerciseIndex = 1
        session.currentSet = 2
        session.completedExercises = 1
        session.completedReps = 22
        session.elapsedTime = 300
        try persistence.saveSession(session, sessionID: entity.id)

        let restored = try #require(try persistence.loadActiveSession())
        #expect(restored.id == session.id)
        #expect(restored.currentExerciseIndex == 1)
        #expect(restored.currentSet == 2)
        #expect(restored.completedExercises == 1)
        #expect(restored.completedReps == 22)
        #expect(restored.elapsedTime == 300)
    }

    @Test
    func restorationWithFreshModelContextUsesPersistedSnapshot() throws {
        let container = try makeContainer()
        let workout = WorkoutMapperTests.makeWorkout()
        let session = WorkoutSession(workout: workout)

        let writer = WorkoutPersistence(modelContext: ModelContext(container))
        _ = try writer.startWorkout(session)

        let reader = WorkoutPersistence(modelContext: ModelContext(container))
        let restored = try #require(try reader.loadActiveSession())

        #expect(restored.id == session.id)
        #expect(restored.workout == workout)
    }

    @Test
    func newestIncompleteSessionIsRestoredDeterministically() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let older = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(name: "Older"),
            startedAt: Date(timeIntervalSince1970: 100)
        )
        let newer = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(name: "Newer"),
            startedAt: Date(timeIntervalSince1970: 200)
        )

        _ = try persistence.startWorkout(older)
        _ = try persistence.startWorkout(newer)

        let restored = try #require(try persistence.loadActiveSession())
        #expect(restored.id == newer.id)
        #expect(restored.workout.name == "Newer")
    }

    @Test
    func completionCreatesStableIDHistoryAndPreventsDuplicates() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let entity = try persistence.startWorkout(session)

        session.completed = true
        session.endedAt = Date(timeIntervalSince1970: 1_000)
        session.completedExercises = 2
        session.completedReps = 44
        session.elapsedTime = 600
        try persistence.saveSession(session, sessionID: entity.id)

        let firstRecord = try persistence.completeSession(sessionID: entity.id)
        let secondRecord = try persistence.completeSession(sessionID: entity.id)
        let history = try persistence.fetchWorkoutHistory()

        #expect(firstRecord.id == entity.id)
        #expect(secondRecord.id == entity.id)
        #expect(history.count == 1)
        #expect(history.first?.id == entity.id)
        #expect(history.first?.workoutName == session.workout.name)
        #expect(history.first?.startedAt == session.startedAt)
        #expect(history.first?.completedAt == session.endedAt)
        #expect(history.first?.duration == 600)
        #expect(history.first?.exercisesCompleted == 2)
    }

    @Test
    func completedSessionIsNotRestoredAsActive() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let entity = try persistence.startWorkout(session)

        session.completed = true
        session.endedAt = .now
        try persistence.saveSession(session, sessionID: entity.id)
        _ = try persistence.completeSession(sessionID: entity.id)

        let activeSession = try persistence.loadActiveSession()
        #expect(activeSession == nil)
    }

    @Test
    func historyIsSortedByCompletedAtDescending() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))

        try completeWorkout(
            named: "Earlier",
            completedAt: Date(timeIntervalSince1970: 1_000),
            persistence: persistence
        )
        try completeWorkout(
            named: "Later",
            completedAt: Date(timeIntervalSince1970: 2_000),
            persistence: persistence
        )

        let history = try persistence.fetchWorkoutHistory()
        #expect(history.map(\.workoutName) == ["Later", "Earlier"])
    }

    @Test
    func deletingUnfinishedSessionRemovesOnlyThatSession() throws {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let abandoned = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(name: "Abandoned"),
            startedAt: Date(timeIntervalSince1970: 100)
        )
        let retained = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(name: "Retained"),
            startedAt: Date(timeIntervalSince1970: 200)
        )

        _ = try persistence.startWorkout(abandoned)
        _ = try persistence.startWorkout(retained)
        try persistence.deleteSession(sessionID: abandoned.id)

        let restored = try #require(try persistence.loadActiveSession())
        #expect(restored.id == retained.id)
    }

    @Test
    func corruptedSnapshotDuringRestoreThrows() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let workoutEntity = WorkoutEntity(
            id: UUID(),
            name: "Corrupted",
            type: WorkoutType.cardio.rawValue,
            workoutSnapshotData: Data("bad".utf8)
        )
        let sessionEntity = WorkoutSessionEntity(workoutName: "Corrupted")
        sessionEntity.workout = workoutEntity
        context.insert(workoutEntity)
        context.insert(sessionEntity)
        try context.save()

        let persistence = WorkoutPersistence(modelContext: ModelContext(container))

        do {
            _ = try persistence.loadActiveSession()
            Issue.record("Expected corrupted snapshot restoration to throw.")
        } catch WorkoutMapper.MappingError.corruptedWorkoutSnapshot {
            #expect(true)
        } catch {
            Issue.record("Expected corruptedWorkoutSnapshot, got \(error).")
        }
    }

    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            WorkoutEntity.self,
            WorkoutSessionEntity.self,
            WorkoutHistoryEntity.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static func completeWorkout(
        named name: String,
        completedAt: Date,
        persistence: WorkoutPersistence
    ) throws {
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: name))
        _ = try persistence.startWorkout(session)
        session.completed = true
        session.endedAt = completedAt
        session.elapsedTime = completedAt.timeIntervalSince(session.startedAt)
        try persistence.saveSession(session, sessionID: session.id)
        _ = try persistence.completeSession(sessionID: session.id)
    }
}
