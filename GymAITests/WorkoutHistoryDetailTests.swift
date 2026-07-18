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
}
