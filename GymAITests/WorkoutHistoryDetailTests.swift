import Foundation
import Testing
@testable import GymAI

@Suite("Workout history details")
struct WorkoutHistoryDetailTests {

    @Test
    func detailViewModelDisplaysWorkoutInformation() {
        let record = WorkoutSessionRecord(
            workoutName: "Full Body Beginner",
            startedAt: Date(timeIntervalSince1970: 1_000),
            completedAt: Date(timeIntervalSince1970: 2_000),
            duration: 45 * 60,
            exercisesCompleted: 4
        )

        let viewModel = WorkoutHistoryDetailViewModel(record: record)

        #expect(viewModel.workoutName == "Full Body Beginner")
        #expect(viewModel.completionStatus == String(localized: "history.detail.status.completed"))
        #expect(viewModel.duration == "45 min")
        #expect(viewModel.exercisesCompleted == "4")
    }

    @Test
    func detailViewModelRendersMissingPhaseOneValuesGracefully() {
        let record = WorkoutSessionRecord(
            workoutName: "   ",
            duration: 0,
            exercisesCompleted: 0
        )

        let viewModel = WorkoutHistoryDetailViewModel(record: record)

        #expect(viewModel.workoutName == String(localized: "history.detail.value_unavailable"))
        #expect(viewModel.duration == String(localized: "history.detail.value_unavailable"))
        #expect(viewModel.totalSetsCompleted == String(localized: "history.detail.value_unavailable"))
        #expect(viewModel.exerciseDetails.isEmpty)
        #expect(viewModel.exerciseBreakdownUnavailable == String(localized: "history.detail.exercise_breakdown_unavailable"))
        #expect(viewModel.comingSoon == String(localized: "history.detail.coming_soon"))
    }

    @Test
    func detailViewModelFormatsStartedAndCompletedDates() {
        let startedAt = Date(timeIntervalSince1970: 1_000)
        let completedAt = Date(timeIntervalSince1970: 2_000)
        let record = WorkoutSessionRecord(
            workoutName: "Cardio",
            startedAt: startedAt,
            completedAt: completedAt,
            duration: 30 * 60,
            exercisesCompleted: 2
        )

        let viewModel = WorkoutHistoryDetailViewModel(record: record)

        #expect(viewModel.startedAt == startedAt.formatted(date: .abbreviated, time: .shortened))
        #expect(viewModel.completedAt == completedAt.formatted(date: .abbreviated, time: .shortened))
    }

    @Test
    func detailViewModelFormatsCompletePartialAndUnstartedExercises() throws {
        let record = WorkoutSessionRecord(
            workoutName: "Strength",
            duration: 45 * 60,
            exercisesCompleted: 1,
            exerciseResults: [
                WorkoutHistoryExerciseRecord(
                    exerciseID: UUID(),
                    exerciseName: "Goblet Squat",
                    plannedSets: 3,
                    plannedReps: 12,
                    plannedRestSeconds: 60,
                    completedSets: 3,
                    completedReps: 36
                ),
                WorkoutHistoryExerciseRecord(
                    exerciseID: UUID(),
                    exerciseName: "Push-up",
                    plannedSets: 2,
                    plannedReps: 10,
                    plannedRestSeconds: 45,
                    completedSets: 1,
                    completedReps: 10
                ),
                WorkoutHistoryExerciseRecord(
                    exerciseID: UUID(),
                    exerciseName: "Plank",
                    plannedSets: 2,
                    plannedReps: 1,
                    plannedRestSeconds: 30,
                    completedSets: 0,
                    completedReps: 0
                )
            ]
        )

        let viewModel = WorkoutHistoryDetailViewModel(record: record)
        let details = viewModel.exerciseDetails

        #expect(viewModel.totalSetsCompleted == "4")
        #expect(details.count == 3)
        #expect(details[0].exerciseName == "Goblet Squat")
        #expect(details[0].sets == "3/3 sets")
        #expect(details[0].completedReps == "36 reps completed")
        #expect(details[0].plannedReps == "12 reps per set planned")
        #expect(details[0].plannedRest == "60 sec rest planned")
        #expect(details[0].status == String(localized: "history.detail.exercise.status.complete"))
        #expect(details[1].status == String(localized: "history.detail.exercise.status.partial"))
        #expect(details[2].status == String(localized: "history.detail.exercise.status.unstarted"))
    }
}
