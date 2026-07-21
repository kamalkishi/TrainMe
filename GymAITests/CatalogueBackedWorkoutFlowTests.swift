import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
struct CatalogueBackedWorkoutFlowTests {
    @Test func sameCatalogueBackedWorkoutResumesActiveSessionWithoutConflict() throws {
        let repository = WorkoutRepository()
        let workout = try catalogueWorkout(named: "Push Day")
        let activeSession = try #require(repository.startSession(for: workout))
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(try catalogueWorkout(named: "Push Day"))

        #expect(viewModel.sessionToContinue?.id == activeSession.id)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
    }

    @Test func differentCatalogueBackedWorkoutCreatesSwitchConflict() throws {
        let repository = WorkoutRepository()
        let activeWorkout = try catalogueWorkout(named: "Push Day")
        let selectedWorkout = try catalogueWorkout(named: "Pull Day")
        let activeSession = try #require(repository.startSession(for: activeWorkout))
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)

        let conflict = try #require(viewModel.workoutSwitchConflict)
        #expect(conflict.activeSession.id == activeSession.id)
        #expect(conflict.selectedWorkout.id == selectedWorkout.id)
        #expect(viewModel.sessionToContinue == nil)
        #expect(viewModel.freshWorkoutDestination == nil)
    }

    @Test func oneExerciseCatalogueBackedWorkoutStartsWithExpectedActiveSession() throws {
        let (repository, _) = try makeRepository()
        let workout = try catalogueWorkout(named: "Push Day")

        let session = try #require(repository.startSession(for: workout))

        #expect(session.workout.id == workout.id)
        #expect(session.workout.name == "Push Day")
        #expect(session.workout.exercises.count == 1)
        let workoutExercise = try #require(session.workout.exercises.first)
        #expect(workoutExercise.exercise.name == "Push-up")
        #expect(workoutExercise.targetSets == 3)
        #expect(workoutExercise.targetReps == 10)
        #expect(workoutExercise.restSeconds == 60)
        #expect(session.exerciseResults.count == 1)
    }

    @Test func oneExerciseCatalogueBackedWorkoutCompletesNaturallyAndPersistsHistory() throws {
        let (repository, _) = try makeRepository()
        let workout = try catalogueWorkout(named: "Push Day")
        let session = try #require(repository.startSession(for: workout))
        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        completeAllSets(in: viewModel)

        let summary = try #require(viewModel.completionSummary)
        #expect(summary.workoutName == "Push Day")
        #expect(summary.completedExercises == 1)
        #expect(summary.plannedTargets.count == 1)
        #expect(summary.completedSets == 3)
        #expect(summary.completedReps == 30)
        #expect(summary.plannedTargets.map(\.exerciseName) == ["Push-up"])
        #expect(viewModel.pendingRestTimerContext == nil)
        #expect(repository.fetchActiveSession() == nil)

        let historyRecord = try #require(repository.fetchWorkoutHistory().first)
        #expect(historyRecord.workoutName == "Push Day")
        #expect(historyRecord.exerciseResults.count == 1)
        let exerciseResult = try #require(historyRecord.exerciseResults.first)
        #expect(exerciseResult.exerciseName == "Push-up")
        #expect(exerciseResult.plannedSets == 3)
        #expect(exerciseResult.plannedReps == 10)
        #expect(exerciseResult.plannedRestSeconds == 60)
        #expect(exerciseResult.completedSets == 3)
        #expect(exerciseResult.completedReps == 30)
    }

    @Test func threeExerciseCatalogueBackedWorkoutCompletesNaturallyAndPersistsOrderedHistory() throws {
        let (repository, _) = try makeRepository()
        let workout = try catalogueWorkout(named: "Full Body Beginner")
        let session = try #require(repository.startSession(for: workout))
        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        completeAllSets(in: viewModel)

        let summary = try #require(viewModel.completionSummary)
        #expect(summary.workoutName == "Full Body Beginner")
        #expect(summary.completedExercises == 3)
        #expect(summary.plannedTargets.count == 3)
        #expect(summary.completedSets == 9)
        #expect(summary.completedReps == 102)
        #expect(summary.plannedTargets.map(\.exerciseName) == ["Goblet Squat", "Push-up", "Bent-over Row"])
        #expect(viewModel.pendingRestTimerContext == nil)
        #expect(repository.fetchActiveSession() == nil)

        let historyRecord = try #require(repository.fetchWorkoutHistory().first)
        #expect(historyRecord.workoutName == "Full Body Beginner")
        #expect(historyRecord.exerciseResults.map(\.exerciseName) == ["Goblet Squat", "Push-up", "Bent-over Row"])
        #expect(historyRecord.exerciseResults.map(\.plannedSets) == [3, 3, 3])
        #expect(historyRecord.exerciseResults.map(\.plannedReps) == [12, 10, 12])
        #expect(historyRecord.exerciseResults.map(\.plannedRestSeconds) == [60, 60, 60])
        #expect(historyRecord.exerciseResults.map(\.completedSets) == [3, 3, 3])
        #expect(historyRecord.exerciseResults.map(\.completedReps) == [36, 30, 36])
    }

    @Test func saveAndStartConflictActionStartsSelectedCatalogueWorkout() throws {
        let repository = WorkoutRepository()
        let activeWorkout = try catalogueWorkout(named: "Push Day")
        let selectedWorkout = try catalogueWorkout(named: "Pull Day")
        _ = try #require(repository.startSession(for: activeWorkout))
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.sessionToContinue == nil)
        let destination = try #require(viewModel.freshWorkoutDestination)
        #expect(destination.workout.id == selectedWorkout.id)
        #expect(destination.workout.name == "Pull Day")
        #expect(repository.fetchActiveSession()?.workout.id == selectedWorkout.id)
    }

    @Test func cancelConflictActionLeavesActiveCatalogueWorkoutUnchanged() throws {
        let repository = WorkoutRepository()
        let activeWorkout = try catalogueWorkout(named: "Push Day")
        let selectedWorkout = try catalogueWorkout(named: "Pull Day")
        let activeSession = try #require(repository.startSession(for: activeWorkout))
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.cancelWorkoutSwitchConflict()

        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.sessionToContinue == nil)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(repository.fetchActiveSession()?.id == activeSession.id)
        #expect(repository.fetchActiveSession()?.workout.id == activeWorkout.id)
    }

    private func completeAllSets(in viewModel: ActiveWorkoutViewModel) {
        while viewModel.completionSummary == nil {
            viewModel.completeSet()
        }
    }

    private func catalogueWorkout(named name: String) throws -> Workout {
        let workout = try #require(WorkoutService().sampleWorkouts().first { $0.name == name })
        return workout
    }

    private func makeRepository() throws -> (WorkoutRepository, WorkoutPersistence) {
        let container = try makeContainer()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        let repository = WorkoutRepository()
        repository.configure(with: persistence)
        return (repository, persistence)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            WorkoutEntity.self,
            WorkoutSessionEntity.self,
            WorkoutHistoryEntity.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
