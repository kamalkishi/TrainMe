import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout session restore integration")
struct WorkoutSessionRestoreTests {

    @Test
    func activeWorkoutRestoresCompleteSessionState() {
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            completed: false,
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 22,
            elapsedTime: 180
        )

        let activeWorkout = ActiveWorkout(session: session)

        #expect(activeWorkout.workout == session.workout)
        #expect(activeWorkout.currentExerciseIndex == 1)
        #expect(activeWorkout.currentSet == 2)
        #expect(activeWorkout.completedReps == 22)
        #expect(activeWorkout.elapsedTime == 180)
        #expect(activeWorkout.isCompleted == false)
    }

    @Test
    func activeWorkoutClampsInvalidSavedIndex() {
        let workout = WorkoutMapperTests.makeWorkout()
        let tooHighSession = WorkoutSession(
            workout: workout,
            currentExerciseIndex: 99,
            currentSet: 1
        )
        let negativeSession = WorkoutSession(
            workout: workout,
            currentExerciseIndex: -3,
            currentSet: 1
        )

        let tooHighWorkout = ActiveWorkout(session: tooHighSession)
        let negativeWorkout = ActiveWorkout(session: negativeSession)

        #expect(tooHighWorkout.currentExerciseIndex == workout.exercises.count - 1)
        #expect(negativeWorkout.currentExerciseIndex == 0)
    }

    @Test
    func restoredViewModelDoesNotStartNewRepositorySessionAndKeepsIdentity() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 22,
            elapsedTime: 300
        )

        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updatedSession?.id == session.id)
        #expect(viewModel.workout == session.workout)
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(viewModel.currentSet == 2)
    }

    @Test
    func homeViewModelLoadsAndRefreshesActiveSessionWithoutMutation() {
        let repository = SpyWorkoutRepository()
        let firstSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "First"))
        let secondSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Second"))
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = firstSession
        viewModel.loadActiveSession()

        #expect(viewModel.activeSession?.id == firstSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)

        repository.sessionToFetch = secondSession
        viewModel.loadActiveSession()

        #expect(viewModel.activeSession?.id == secondSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
    }

    @Test
    func freshRepositoryContextRestoresPersistedActiveSession() throws {
        let container = try Self.makeContainer()
        let writerRepository = WorkoutRepository()
        writerRepository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        writerRepository.startSession(for: WorkoutMapperTests.makeWorkout())
        var session = try #require(writerRepository.fetchActiveSession())
        session.currentExerciseIndex = 1
        session.currentSet = 2
        session.completedReps = 12
        session.elapsedTime = 120
        writerRepository.updateSession(session)

        let readerRepository = WorkoutRepository()
        readerRepository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let restoredSession = try #require(readerRepository.fetchActiveSession())

        #expect(restoredSession.id == session.id)
        #expect(restoredSession.currentExerciseIndex == 1)
        #expect(restoredSession.currentSet == 2)
        #expect(restoredSession.completedReps == 12)
        #expect(restoredSession.elapsedTime == 120)
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

@MainActor
private final class SpyWorkoutRepository: WorkoutRepositoryProtocol {

    var sessionToFetch: WorkoutSession?
    var updatedSession: WorkoutSession?
    var history: [WorkoutSessionRecord] = []

    private(set) var startSessionCallCount = 0
    private(set) var updateSessionCallCount = 0
    private(set) var clearActiveSessionCallCount = 0

    func startSession(for workout: Workout) {
        startSessionCallCount += 1
    }

    func fetchActiveSession() -> WorkoutSession? {
        sessionToFetch
    }

    func updateSession(_ session: WorkoutSession) {
        updateSessionCallCount += 1
        updatedSession = session
    }

    func clearActiveSession() {
        clearActiveSessionCallCount += 1
        sessionToFetch = nil
    }

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {
        history
    }

    func save(_ workout: WorkoutSessionRecord) {
        history.insert(workout, at: 0)
    }
}
