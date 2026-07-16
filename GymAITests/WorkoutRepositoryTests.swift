import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout repository")
struct WorkoutRepositoryTests {

    @Test
    func repositoryPersistsProgressWithoutSharedSingletonState() throws {
        let container = try makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let workout = WorkoutMapperTests.makeWorkout()

        repository.startSession(for: workout)
        var session = try #require(repository.fetchActiveSession())
        session.currentExerciseIndex = 1
        session.currentSet = 2
        session.completedExercises = 1
        session.completedReps = 12
        session.elapsedTime = 120
        repository.updateSession(session)

        let freshPersistence = WorkoutPersistence(modelContext: ModelContext(container))
        let restored = try #require(try freshPersistence.loadActiveSession())

        #expect(repository.lastError == nil)
        #expect(restored.currentExerciseIndex == 1)
        #expect(restored.currentSet == 2)
        #expect(restored.completedExercises == 1)
        #expect(restored.completedReps == 12)
        #expect(restored.elapsedTime == 120)
    }

    @Test
    func saveCompletesPersistedSessionAndClearsMemoryAfterSuccess() throws {
        let container = try makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        repository.startSession(for: WorkoutMapperTests.makeWorkout())

        var session = try #require(repository.fetchActiveSession())
        session.completed = true
        session.endedAt = Date(timeIntervalSince1970: 5_000)
        session.completedExercises = 2
        session.completedReps = 44
        session.elapsedTime = 900
        repository.updateSession(session)

        repository.save(
            WorkoutSessionRecord(
                id: session.id,
                workoutName: "Conflicting Name",
                startedAt: Date(timeIntervalSince1970: 1),
                completedAt: Date(timeIntervalSince1970: 2),
                duration: 3,
                exercisesCompleted: 4
            )
        )

        let history = try WorkoutPersistence(modelContext: ModelContext(container)).fetchWorkoutHistory()

        #expect(repository.lastError == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(history.count == 1)
        #expect(history.first?.id == session.id)
        #expect(history.first?.workoutName == session.workout.name)
        #expect(history.first?.startedAt == session.startedAt)
        #expect(history.first?.completedAt == session.endedAt)
        #expect(history.first?.duration == session.elapsedTime)
        #expect(history.first?.exercisesCompleted == session.completedExercises)
    }

    @Test
    func clearActiveSessionDeletesOnlyCurrentUnfinishedSession() throws {
        let container = try makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let currentWorkout = WorkoutMapperTests.makeWorkout(name: "Current")
        let otherWorkout = WorkoutMapperTests.makeWorkout(name: "Other")
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let otherSession = WorkoutSession(
            workout: otherWorkout,
            startedAt: Date(timeIntervalSince1970: 200)
        )

        repository.startSession(for: currentWorkout)
        let currentSession = try #require(repository.fetchActiveSession())
        _ = try persistence.startWorkout(otherSession)

        repository.clearActiveSession()

        let restored = try #require(try persistence.loadActiveSession())
        #expect(repository.lastError == nil)
        #expect(repository.fetchActiveSession()?.id == restored.id)
        #expect(restored.id == otherSession.id)
        #expect(restored.id != currentSession.id)
    }

    @Test
    func repeatedConfigurationDoesNotReplaceExistingPersistenceOrResetState() throws {
        let firstContainer = try makeContainer()
        let secondContainer = try makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(firstContainer)))
        repository.startSession(for: WorkoutMapperTests.makeWorkout())
        let originalSession = try #require(repository.fetchActiveSession())

        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(secondContainer)))
        var updatedSession = originalSession
        updatedSession.currentSet = 2
        repository.updateSession(updatedSession)

        let firstRestored = try #require(
            try WorkoutPersistence(modelContext: ModelContext(firstContainer)).loadActiveSession()
        )
        let secondRestored = try WorkoutPersistence(modelContext: ModelContext(secondContainer)).loadActiveSession()

        #expect(firstRestored.id == originalSession.id)
        #expect(firstRestored.currentSet == 2)
        #expect(secondRestored == nil)
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
}
