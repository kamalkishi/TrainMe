import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout exercise results")
struct WorkoutExerciseResultTests {

    @Test
    func activeWorkoutInitializesOneResultPerWorkoutExercise() {
        let workout = WorkoutMapperTests.makeWorkout()
        let activeWorkout = ActiveWorkout(workout: workout)

        #expect(activeWorkout.exerciseResults.count == workout.exercises.count)
        #expect(activeWorkout.exerciseResults.map(\.exerciseID) == workout.exercises.map(\.id))
        #expect(activeWorkout.exerciseResults.map(\.exerciseName) == ["Goblet Squat", "Push-up"])
        #expect(activeWorkout.exerciseResults.map(\.plannedSets) == [3, 2])
        #expect(activeWorkout.exerciseResults.map(\.plannedReps) == [12, 10])
        #expect(activeWorkout.exerciseResults.map(\.plannedRestSeconds) == [60, 45])
        #expect(activeWorkout.exerciseResults.allSatisfy { $0.completedSets == 0 })
        #expect(activeWorkout.exerciseResults.allSatisfy { $0.completedReps == 0 })
    }

    @Test
    func completingSetUpdatesCurrentExerciseOnly() throws {
        let repository = ExerciseResultRepositorySpy()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()

        let results = viewModel.activeWorkout.exerciseResults
        #expect(results[0].completedSets == 1)
        #expect(results[0].completedReps == 12)
        #expect(results[1].completedSets == 0)
        #expect(results[1].completedReps == 0)
        #expect(repository.updatedSession?.exerciseResults == results)
    }

    @Test
    func completingMultipleSetsAccumulatesOnSameExercise() {
        let repository = ExerciseResultRepositorySpy()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()
        viewModel.completeSet()

        let result = viewModel.activeWorkout.exerciseResults[0]
        #expect(result.completedSets == 2)
        #expect(result.completedReps == 24)
        #expect(viewModel.currentExerciseNumber == 1)
        #expect(viewModel.currentSet == 3)
    }

    @Test
    func movingToNextExercisePreservesPriorExerciseResults() {
        let repository = ExerciseResultRepositorySpy()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()
        viewModel.completeSet()
        viewModel.completeSet()

        let results = viewModel.activeWorkout.exerciseResults
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(viewModel.currentSet == 1)
        #expect(results[0].completedSets == 3)
        #expect(results[0].completedReps == 36)
        #expect(results[1].completedSets == 0)
        #expect(results[1].completedReps == 0)
    }

    @Test
    func naturalCompletionRecordsAccurateExerciseResultsAndSummary() throws {
        let repository = ExerciseResultRepositorySpy()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        for _ in 0..<5 {
            viewModel.completeSet()
        }

        let summary = try #require(viewModel.completionSummary)
        let results = viewModel.activeWorkout.exerciseResults
        #expect(results[0].completedSets == 3)
        #expect(results[0].completedReps == 36)
        #expect(results[1].completedSets == 2)
        #expect(results[1].completedReps == 20)
        #expect(summary.completedExercises == 2)
        #expect(summary.completedSets == 5)
        #expect(summary.completedReps == 56)
        #expect(repository.saveCallCount == 1)
    }

    @Test
    func manualFinishPreservesPartialExerciseResults() throws {
        let repository = ExerciseResultRepositorySpy()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        for _ in 0..<4 {
            viewModel.completeSet()
        }
        let summary = try #require(viewModel.finishWorkout())

        let results = viewModel.activeWorkout.exerciseResults
        #expect(results[0].completedSets == 3)
        #expect(results[0].completedReps == 36)
        #expect(results[1].completedSets == 1)
        #expect(results[1].completedReps == 10)
        #expect(summary.completedExercises == 1)
        #expect(summary.completedSets == 4)
        #expect(summary.completedReps == 46)
        #expect(repository.savedRecords.count == 1)
    }

    @Test
    func activeSessionPersistenceRestoresExerciseResults() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let workout = WorkoutMapperTests.makeWorkout()
        repository.configure(with: persistence)
        repository.startSession(for: workout)
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        for _ in 0..<4 {
            viewModel.completeSet()
        }

        let restoredSession = try #require(try WorkoutPersistence(modelContext: ModelContext(container)).loadActiveSession())
        let restoredWorkout = ActiveWorkout(session: restoredSession)

        #expect(restoredSession.exerciseResults.count == workout.exercises.count)
        #expect(restoredWorkout.exerciseResults[0].completedSets == 3)
        #expect(restoredWorkout.exerciseResults[0].completedReps == 36)
        #expect(restoredWorkout.exerciseResults[1].completedSets == 1)
        #expect(restoredWorkout.exerciseResults[1].completedReps == 10)
    }

    @Test
    func restoringSessionDoesNotDuplicateExerciseResults() {
        let workout = WorkoutMapperTests.makeWorkout()
        let duplicateResults = ActiveWorkout(workout: workout).exerciseResults + ActiveWorkout(workout: workout).exerciseResults
        let session = WorkoutSession(workout: workout, exerciseResults: duplicateResults)

        let firstRestore = ActiveWorkout(session: session)
        let secondRestore = ActiveWorkout(session: WorkoutSession(workout: workout, exerciseResults: firstRestore.exerciseResults))

        #expect(firstRestore.exerciseResults.count == workout.exercises.count)
        #expect(secondRestore.exerciseResults.count == workout.exercises.count)
        #expect(secondRestore.exerciseResults.map(\.exerciseID) == workout.exercises.map(\.id))
    }

    @Test
    func legacyActiveSessionWithoutExerciseResultsLoadsSafely() {
        let workout = WorkoutMapperTests.makeWorkout()
        let legacySession = WorkoutSession(
            workout: workout,
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 46,
            exerciseResults: [],
            elapsedTime: 300
        )

        let restored = ActiveWorkout(session: legacySession)

        #expect(restored.exerciseResults.count == workout.exercises.count)
        #expect(restored.exerciseResults[0].completedSets == 3)
        #expect(restored.exerciseResults[0].completedReps == 36)
        #expect(restored.exerciseResults[1].completedSets == 1)
        #expect(restored.exerciseResults[1].completedReps == 10)
    }

    private static func makeStartedViewModel(
        workout: Workout,
        repository: ExerciseResultRepositorySpy
    ) -> ActiveWorkoutViewModel {
        repository.startSession(for: workout)
        let session = repository.sessionToFetch ?? WorkoutSession(workout: workout)
        return ActiveWorkoutViewModel(session: session, repository: repository)
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
private final class ExerciseResultRepositorySpy: WorkoutRepositoryProtocol {

    var sessionToFetch: WorkoutSession?
    private(set) var updatedSession: WorkoutSession?
    private(set) var savedRecords: [WorkoutSessionRecord] = []

    private(set) var startSessionCallCount = 0
    private(set) var updateSessionCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var clearActiveSessionCallCount = 0
    private(set) var abandonActiveSessionCallCount = 0

    func startSession(for workout: Workout) {
        startSessionCallCount += 1
        var session = WorkoutSession(workout: workout)
        session.exerciseResults = ActiveWorkout(workout: workout).exerciseResults
        sessionToFetch = session
    }

    func fetchActiveSession() -> WorkoutSession? {
        sessionToFetch
    }

    func updateSession(_ session: WorkoutSession) {
        updateSessionCallCount += 1
        updatedSession = session
        sessionToFetch = session
    }

    func clearActiveSession() {
        clearActiveSessionCallCount += 1
        sessionToFetch = nil
    }

    func clearActiveSession(ifSessionID sessionID: UUID) -> Bool {
        clearActiveSessionCallCount += 1

        guard sessionToFetch?.id == sessionID else {
            return false
        }

        sessionToFetch = nil
        return true
    }

    func abandonActiveSession() -> Bool {
        abandonActiveSessionCallCount += 1
        sessionToFetch = nil
        return true
    }

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {
        savedRecords
    }

    func save(_ workout: WorkoutSessionRecord) {
        saveCallCount += 1
        savedRecords.insert(workout, at: 0)
        sessionToFetch = nil
    }
}
