import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout repository")
struct WorkoutRepositoryTests {

    @Test
    func startSessionReturnsPersistedActiveSessionAfterSuccess() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let workout = WorkoutMapperTests.makeWorkout(name: "Started")

        let startedSession = try #require(repository.startSession(for: workout))
        let fetchedSession = try #require(repository.fetchActiveSession())
        let persistedSession = try #require(try persistence.loadActiveSession())

        #expect(startedSession.id == fetchedSession.id)
        #expect(startedSession.id == persistedSession.id)
        #expect(startedSession.workout.id == workout.id)
        #expect(fetchedSession.workout.id == workout.id)
        #expect(repository.lastError == nil)
    }

    @Test
    func startSessionPersistenceFailureReturnsNilAndLeavesNoActiveSession() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: FailingStartWorkoutPersistence(realPersistence: persistence))
        let workout = WorkoutMapperTests.makeWorkout(name: "Failed Start")

        let startedSession = repository.startSession(for: workout)

        #expect(startedSession == nil)
        #expect(repository.lastError != nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(repository.activeSession == nil)
        #expect(try persistence.loadActiveSession() == nil)
    }

    @Test
    func repositoryPersistsProgressWithoutSharedSingletonState() throws {
        let container = try Self.makeContainer()
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
        let container = try Self.makeContainer()
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
    func clearActiveSessionDeletesAllUnfinishedSessions() throws {
        let container = try Self.makeContainer()
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

        #expect(repository.lastError == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(try persistence.fetchWorkoutHistory().isEmpty)
        #expect(currentSession.id != otherSession.id)
    }

    @Test
    func startFreshAbandonRemovesMultipleUnfinishedSessionsAndPreservesHistory() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        try Self.completeWorkout(named: "Completed", completedAt: Date(timeIntervalSince1970: 3_000), persistence: persistence)
        _ = try persistence.startWorkout(
            WorkoutSession(
                workout: WorkoutMapperTests.makeWorkout(name: "Older"),
                startedAt: Date(timeIntervalSince1970: 1_000)
            )
        )
        _ = try persistence.startWorkout(
            WorkoutSession(
                workout: WorkoutMapperTests.makeWorkout(name: "Middle"),
                startedAt: Date(timeIntervalSince1970: 2_000)
            )
        )
        repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Newest"))
        let activeBeforeAbandon = try #require(repository.fetchActiveSession())

        let abandoned = repository.abandonActiveSession()

        #expect(abandoned == true)
        #expect(activeBeforeAbandon.workout.name == "Newest")
        #expect(repository.activeSession == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(try persistence.fetchWorkoutHistory().count == 1)
    }

    @Test
    func abandonActiveSessionDeletesUnfinishedSessionWithoutHistoryCreation() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: WorkoutMapperTests.makeWorkout())
        _ = try #require(repository.fetchActiveSession())

        let abandoned = repository.abandonActiveSession()

        #expect(abandoned == true)
        #expect(repository.lastError == nil)
        #expect(repository.activeSession == nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(try persistence.fetchWorkoutHistory().isEmpty)
        #expect(repository.fetchActiveSession() == nil)
    }

    @Test
    func abandonThenStartFreshCreatesNewSessionID() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Original"))
        let originalSession = try #require(repository.fetchActiveSession())

        let abandoned = repository.abandonActiveSession()
        repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Fresh"))

        let freshSession = try #require(repository.fetchActiveSession())
        let persistedSession = try #require(try persistence.loadActiveSession())

        #expect(abandoned == true)
        #expect(repository.lastError == nil)
        #expect(freshSession.id != originalSession.id)
        #expect(freshSession.currentExerciseIndex == 0)
        #expect(freshSession.currentSet == 1)
        #expect(freshSession.completedReps == 0)
        #expect(freshSession.elapsedTime == 0)
        #expect(persistedSession.id == freshSession.id)
        #expect(persistedSession.workout.name == "Fresh")
        #expect(persistedSession.currentExerciseIndex == 0)
        #expect(persistedSession.currentSet == 1)
        #expect(persistedSession.completedReps == 0)
        #expect(persistedSession.elapsedTime == 0)
        #expect(try persistence.fetchWorkoutHistory().isEmpty)
    }

    @Test
    func abandonActiveSessionPreservesCompletedHistory() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Completed"))
        var completedSession = try #require(repository.fetchActiveSession())
        completedSession.completed = true
        completedSession.endedAt = Date(timeIntervalSince1970: 3_600)
        completedSession.elapsedTime = 600
        completedSession.completedExercises = 2
        repository.updateSession(completedSession)
        repository.save(
            WorkoutSessionRecord(
                id: completedSession.id,
                workoutName: completedSession.workout.name,
                startedAt: completedSession.startedAt,
                completedAt: completedSession.endedAt ?? .now,
                duration: completedSession.elapsedTime,
                exercisesCompleted: completedSession.completedExercises
            )
        )
        let historyBeforeAbandon = try persistence.fetchWorkoutHistory()

        repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Unfinished"))
        let abandoned = repository.abandonActiveSession()
        let historyAfterAbandon = try persistence.fetchWorkoutHistory()

        #expect(abandoned == true)
        #expect(historyBeforeAbandon.count == 1)
        #expect(historyAfterAbandon == historyBeforeAbandon)
        #expect(try persistence.loadActiveSession() == nil)
    }

    @Test
    func abandonFailurePreventsNewSessionCreationWhenCallerRequiresSuccess() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let originalSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Original"))
        repository.activeSession = originalSession

        let abandoned = repository.abandonActiveSession()

        if abandoned {
            repository.startSession(for: WorkoutMapperTests.makeWorkout(name: "Fresh"))
        }

        #expect(abandoned == false)
        #expect(repository.activeSession?.id == originalSession.id)
        #expect(repository.lastError != nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(try persistence.fetchWorkoutHistory().isEmpty)
    }

    @Test
    func repeatedConfigurationDoesNotReplaceExistingPersistenceOrResetState() throws {
        let firstContainer = try Self.makeContainer()
        let secondContainer = try Self.makeContainer()
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

    @Test
    func saveWithPersistenceAndMissingActiveSessionIDRecordsErrorWithoutHistoryOrClearingSession() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        repository.activeSession = session

        repository.save(
            WorkoutSessionRecord(
                id: session.id,
                workoutName: session.workout.name,
                startedAt: session.startedAt,
                completedAt: .now,
                duration: 1,
                exercisesCompleted: 1
            )
        )

        #expect(repository.activeSession == session)
        #expect(repository.history.isEmpty)
        #expect(repository.lastError != nil)
    }

    @Test
    func completionFailureRetainsActiveSessionForRetry() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: WorkoutMapperTests.makeWorkout())
        var session = try #require(repository.fetchActiveSession())
        try persistence.deleteSession(sessionID: session.id)

        session.completed = true
        session.endedAt = .now
        repository.save(
            WorkoutSessionRecord(
                id: session.id,
                workoutName: session.workout.name,
                startedAt: session.startedAt,
                completedAt: session.endedAt ?? .now,
                duration: 1,
                exercisesCompleted: 1
            )
        )

        #expect(repository.activeSession?.id == session.id)
        #expect(repository.history.isEmpty)
        #expect(repository.lastError != nil)
    }

    @Test
    func repeatedRepositoryCompletionDoesNotCreateDuplicateHistory() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: WorkoutMapperTests.makeWorkout())
        var session = try #require(repository.fetchActiveSession())
        session.completed = true
        session.endedAt = Date(timeIntervalSince1970: 4_000)
        session.completedExercises = 2
        session.completedReps = 56
        session.elapsedTime = 600
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
        repository.save(record)

        let history = try persistence.fetchWorkoutHistory()
        #expect(history.count == 1)
        #expect(history.first?.id == session.id)
        #expect(repository.fetchActiveSession() == nil)
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

@MainActor
private final class FailingStartWorkoutPersistence: WorkoutPersistenceProtocol {

    enum Failure: Error {
        case startFailed
    }

    private let realPersistence: WorkoutPersistence

    init(realPersistence: WorkoutPersistence) {
        self.realPersistence = realPersistence
    }

    func startWorkout(_ session: WorkoutSession) throws -> WorkoutSessionEntity {
        throw Failure.startFailed
    }

    func loadActiveSession() throws -> WorkoutSession? {
        try realPersistence.loadActiveSession()
    }

    func saveSession(_ session: WorkoutSession, sessionID: UUID) throws {
        try realPersistence.saveSession(session, sessionID: sessionID)
    }

    func deleteIncompleteSessions() throws {
        try realPersistence.deleteIncompleteSessions()
    }

    func deleteSession(sessionID: UUID) throws {
        try realPersistence.deleteSession(sessionID: sessionID)
    }

    func completeSession(sessionID: UUID) throws -> WorkoutSessionRecord {
        try realPersistence.completeSession(sessionID: sessionID)
    }

    func fetchWorkoutHistory() throws -> [WorkoutSessionRecord] {
        try realPersistence.fetchWorkoutHistory()
    }
}
