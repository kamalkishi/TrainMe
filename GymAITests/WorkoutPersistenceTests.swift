import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout persistence")
struct WorkoutPersistenceTests {

    @Test
    func startAndPersistSession() throws {
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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
    func completionPersistsExerciseSummarySnapshotBeforeDeletingActiveSession() throws {
        let container = try Self.makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        session.exerciseResults = Self.partialExerciseResults(for: session.workout)
        let entity = try persistence.startWorkout(session)

        session.completed = true
        session.endedAt = Date(timeIntervalSince1970: 1_000)
        session.completedExercises = 1
        session.completedReps = 46
        session.elapsedTime = 600
        try persistence.saveSession(session, sessionID: entity.id)

        let completedRecord = try persistence.completeSession(sessionID: entity.id)
        let fetchedRecord = try #require(try persistence.fetchWorkoutHistory().first)

        #expect(completedRecord.exerciseResults == fetchedRecord.exerciseResults)
        #expect(fetchedRecord.exerciseResults.count == 2)
        #expect(fetchedRecord.exerciseResults[0].exerciseName == "Goblet Squat")
        #expect(fetchedRecord.exerciseResults[0].plannedSets == 3)
        #expect(fetchedRecord.exerciseResults[0].plannedReps == 12)
        #expect(fetchedRecord.exerciseResults[0].plannedRestSeconds == 60)
        #expect(fetchedRecord.exerciseResults[0].completedSets == 3)
        #expect(fetchedRecord.exerciseResults[0].completedReps == 36)
        #expect(fetchedRecord.exerciseResults[1].exerciseName == "Push-up")
        #expect(fetchedRecord.exerciseResults[1].completedSets == 1)
        #expect(fetchedRecord.exerciseResults[1].completedReps == 10)
        #expect(try persistence.loadActiveSession() == nil)
    }

    @Test
    func completionPersistsUnstartedExercisesFromRuntimeSnapshotWithoutMarkingComplete() throws {
        let container = try Self.makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        var session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        session.exerciseResults = ActiveWorkout(workout: session.workout).exerciseResults
        session.exerciseResults[0].completedSets = 1
        session.exerciseResults[0].completedReps = 12
        let entity = try persistence.startWorkout(session)

        session.completed = true
        session.endedAt = Date(timeIntervalSince1970: 1_000)
        session.completedExercises = 0
        session.completedReps = 12
        session.elapsedTime = 600
        try persistence.saveSession(session, sessionID: entity.id)
        _ = try persistence.completeSession(sessionID: entity.id)

        let history = try #require(try persistence.fetchWorkoutHistory().first)

        #expect(history.exercisesCompleted == 0)
        #expect(history.exerciseResults[0].completedSets == 1)
        #expect(history.exerciseResults[0].completedReps == 12)
        #expect(history.exerciseResults[1].completedSets == 0)
        #expect(history.exerciseResults[1].completedReps == 0)
    }

    @Test
    func legacyHistoryWithoutExerciseSnapshotLoadsSummaryOnly() throws {
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let history = WorkoutHistoryEntity(
            workoutName: "Legacy",
            startedAt: Date(timeIntervalSince1970: 1),
            completedAt: Date(timeIntervalSince1970: 2),
            duration: 60,
            exercisesCompleted: 2
        )
        context.insert(history)
        try context.save()

        let records = try WorkoutPersistence(modelContext: ModelContext(container)).fetchWorkoutHistory()

        #expect(records.count == 1)
        #expect(records.first?.workoutName == "Legacy")
        #expect(records.first?.exercisesCompleted == 2)
        #expect(records.first?.exerciseResults.isEmpty == true)
    }

    @Test
    func corruptedHistoryExerciseSnapshotLoadsSummaryOnly() throws {
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let history = WorkoutHistoryEntity(
            workoutName: "Corrupted Summary",
            startedAt: Date(timeIntervalSince1970: 1),
            completedAt: Date(timeIntervalSince1970: 2),
            duration: 60,
            exercisesCompleted: 2,
            exerciseSummaryData: Data("not-json".utf8)
        )
        context.insert(history)
        try context.save()

        let records = try WorkoutPersistence(modelContext: ModelContext(container)).fetchWorkoutHistory()

        #expect(records.count == 1)
        #expect(records.first?.workoutName == "Corrupted Summary")
        #expect(records.first?.exercisesCompleted == 2)
        #expect(records.first?.exerciseResults.isEmpty == true)
    }

    @Test
    func completedSessionIsNotRestoredAsActive() throws {
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))

        try Self.completeWorkout(
            named: "Earlier",
            completedAt: Date(timeIntervalSince1970: 1_000),
            persistence: persistence
        )
        try Self.completeWorkout(
            named: "Later",
            completedAt: Date(timeIntervalSince1970: 2_000),
            persistence: persistence
        )

        let history = try persistence.fetchWorkoutHistory()
        #expect(history.map { $0.workoutName } == ["Later", "Earlier"])
    }

    @Test
    func deletingUnfinishedSessionRemovesOnlyThatSession() throws {
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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

    @Test
    func missingWorkoutRelationshipDuringRestoreThrows() throws {
        let container = try Self.makeContainer()
        let context = ModelContext(container)
        let sessionEntity = WorkoutSessionEntity(workoutName: "Missing Workout")
        context.insert(sessionEntity)
        try context.save()

        let persistence = WorkoutPersistence(modelContext: ModelContext(container))

        do {
            _ = try persistence.loadActiveSession()
            Issue.record("Expected missing workout relationship restoration to throw.")
        } catch WorkoutSessionMappingError.missingWorkoutRelationship(let id) {
            #expect(id == sessionEntity.id)
        } catch {
            Issue.record("Expected missingWorkoutRelationship, got \(error).")
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

    private static func partialExerciseResults(for workout: Workout) -> [WorkoutExerciseResult] {
        var results = ActiveWorkout(workout: workout).exerciseResults
        results[0].completedSets = 3
        results[0].completedReps = 36
        results[1].completedSets = 1
        results[1].completedReps = 10
        return results
    }
}
