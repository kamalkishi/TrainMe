import Foundation

@MainActor
struct WorkoutCompletionLifecycle {

    let repository: WorkoutRepositoryProtocol

    @discardableResult
    func finishActiveSession(_ session: WorkoutSession) -> WorkoutCompletionSummary? {
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )

        guard let summary = viewModel.finishWorkout() else {
            return nil
        }

        guard repository.fetchActiveSession() == nil else {
            return nil
        }

        guard repository.fetchWorkoutHistory().contains(where: { $0.id == summary.id }) else {
            return nil
        }

        return summary
    }
}
