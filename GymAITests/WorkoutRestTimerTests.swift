import Foundation
import Testing
@testable import GymAI

@MainActor
@Suite("Workout rest timer")
struct WorkoutRestTimerTests {

    @Test
    func completingNormalNonFinalSetRequestsOneRestTimer() throws {
        let repository = RestTimerRepositorySpy()
        let workout = Self.makeWorkout(targetSets: 3, restSeconds: 75)
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()

        let context = try #require(viewModel.pendingRestTimerContext)
        #expect(context.durationSeconds == 75)
        #expect(context.exerciseName == "Goblet Squat")
        #expect(context.upcomingSet == 2)
        #expect(repository.updateSessionCallCount == 1)
        #expect(repository.saveCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func completingSecondSetOfSameExerciseRequestsThirdSetForCurrentExercise() throws {
        let repository = RestTimerRepositorySpy()
        let workout = Self.makeWorkout(targetSets: 3, restSeconds: 75)
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()
        viewModel.completeSet()

        let context = try #require(viewModel.pendingRestTimerContext)
        #expect(context.durationSeconds == 75)
        #expect(context.exerciseName == "Goblet Squat")
        #expect(context.upcomingSet == 3)
        #expect(repository.updateSessionCallCount == 2)
        #expect(repository.saveCallCount == 0)
    }

    @Test
    func completingExerciseFinalSetUsesUpcomingExerciseNameAndCompletedExerciseRest() throws {
        let repository = RestTimerRepositorySpy()
        let workout = Self.makeTwoExerciseWorkout(firstTargetSets: 3, firstRestSeconds: 45)
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()
        viewModel.completeSet()
        viewModel.completeSet()

        let context = try #require(viewModel.pendingRestTimerContext)
        #expect(context.durationSeconds == 45)
        #expect(context.exerciseName == "Push-up")
        #expect(context.upcomingSet == 1)
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(repository.saveCallCount == 0)
    }

    @Test
    func completingFinalWorkoutSetDoesNotRequestRestAndCreatesSummary() {
        let repository = RestTimerRepositorySpy()
        let workout = Self.makeWorkout(targetSets: 1, restSeconds: 90)
        let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

        viewModel.completeSet()

        #expect(viewModel.pendingRestTimerContext == nil)
        #expect(viewModel.completionSummary != nil)
        #expect(repository.saveCallCount == 1)
    }

    @Test
    func zeroOrNegativeRestDurationDoesNotRequestTimer() {
        for restSeconds in [0, -15] {
            let repository = RestTimerRepositorySpy()
            let workout = Self.makeWorkout(targetSets: 3, restSeconds: restSeconds)
            let viewModel = Self.makeStartedViewModel(workout: workout, repository: repository)

            viewModel.completeSet()

            #expect(viewModel.pendingRestTimerContext == nil)
            #expect(repository.updateSessionCallCount == 1)
            #expect(repository.saveCallCount == 0)
        }
    }

    @Test
    func skipDismissesTimerOnce() {
        let viewModel = RestTimerViewModel(
            context: RestTimerContext(
                durationSeconds: 30,
                exerciseName: "Rest Test",
                upcomingSet: 2
            )
        )
        var skipCount = 0

        viewModel.skip {
            skipCount += 1
        }
        viewModel.skip {
            skipCount += 1
        }

        #expect(skipCount == 1)
    }

    @Test
    func countdownCompletionDismissesTimerOnceWithoutNegativeTime() {
        let viewModel = RestTimerViewModel(
            context: RestTimerContext(
                durationSeconds: 2,
                exerciseName: "Rest Test",
                upcomingSet: 2
            )
        )
        var completionCount = 0

        viewModel.tick {
            completionCount += 1
        }
        viewModel.tick {
            completionCount += 1
        }
        viewModel.tick {
            completionCount += 1
        }

        #expect(completionCount == 1)
        #expect(viewModel.remainingSeconds == 0)
        #expect(viewModel.formattedRemainingTime == "00:00")
    }

    @Test
    func completionAndSkipCannotBothDismissTimer() {
        let viewModel = RestTimerViewModel(
            context: RestTimerContext(
                durationSeconds: 1,
                exerciseName: "Rest Test",
                upcomingSet: 2
            )
        )
        var completionCount = 0
        var skipCount = 0

        viewModel.tick {
            completionCount += 1
        }
        viewModel.skip {
            skipCount += 1
        }

        #expect(completionCount == 1)
        #expect(skipCount == 0)
    }

    @Test
    func timerDismissalDoesNotMutateRepositoryState() {
        let repository = RestTimerRepositorySpy()
        let workout = Self.makeWorkout(targetSets: 3, restSeconds: 30)
        repository.startSession(for: workout)
        let originalSessionID = repository.sessionToFetch?.id
        let timerViewModel = RestTimerViewModel(
            context: RestTimerContext(
                durationSeconds: 1,
                exerciseName: "Rest Test",
                upcomingSet: 2
            )
        )

        timerViewModel.skip {}
        timerViewModel.tick {}

        #expect(repository.sessionToFetch?.id == originalSessionID)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.saveCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    private static func makeWorkout(
        targetSets: Int,
        restSeconds: Int
    ) -> Workout {
        Workout(
            name: "Rest Timer Workout",
            type: .strength,
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Goblet Squat",
                        muscleGroups: [.quadriceps, .glutes],
                        workoutType: .strength,
                        requiresWeight: true
                    ),
                    targetSets: targetSets,
                    targetReps: 8,
                    restSeconds: restSeconds
                )
            ],
            estimatedDuration: 1_200,
            description: "Workout for rest timer tests."
        )
    }

    private static func makeStartedViewModel(
        workout: Workout,
        repository: RestTimerRepositorySpy
    ) -> ActiveWorkoutViewModel {
        repository.startSession(for: workout)
        let session = repository.sessionToFetch ?? WorkoutSession(workout: workout)
        return ActiveWorkoutViewModel(session: session, repository: repository)
    }

    private static func makeTwoExerciseWorkout(
        firstTargetSets: Int = 1,
        firstRestSeconds: Int
    ) -> Workout {
        Workout(
            name: "Two Exercise Rest Timer Workout",
            type: .strength,
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Goblet Squat",
                        muscleGroups: [.quadriceps, .glutes],
                        workoutType: .strength,
                        requiresWeight: true
                    ),
                    targetSets: firstTargetSets,
                    targetReps: 8,
                    restSeconds: firstRestSeconds
                ),
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Push-up",
                        muscleGroups: [.chest, .triceps],
                        workoutType: .strength,
                        requiresWeight: false
                    ),
                    targetSets: 1,
                    targetReps: 10,
                    restSeconds: 30
                )
            ],
            estimatedDuration: 1_200,
            description: "Workout for rest timer transition tests."
        )
    }
}

@MainActor
private final class RestTimerRepositorySpy: WorkoutRepositoryProtocol {

    var sessionToFetch: WorkoutSession?
    private(set) var updatedSession: WorkoutSession?
    private(set) var history: [WorkoutSessionRecord] = []

    private(set) var startSessionCallCount = 0
    private(set) var updateSessionCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var clearActiveSessionCallCount = 0
    private(set) var abandonActiveSessionCallCount = 0

    func startSession(for workout: Workout) {
        startSessionCallCount += 1
        sessionToFetch = WorkoutSession(workout: workout)
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
        history
    }

    func save(_ workout: WorkoutSessionRecord) {
        saveCallCount += 1
        history.insert(workout, at: 0)
        sessionToFetch = nil
    }
}
