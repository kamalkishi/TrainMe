import SwiftUI

struct WorkoutLibraryView: View {

    private let workoutService = WorkoutService()
    private let onWorkoutCompleted: (WorkoutCompletionSummary) -> Void
    private let onWorkoutManuallyFinished: (WorkoutCompletionSummary) -> Void
    private let onRestTimerRequested: (RestTimerContext) -> Void

    @State private var selectedWorkout: Workout?

    init(
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onWorkoutManuallyFinished: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onWorkoutManuallyFinished = onWorkoutManuallyFinished
        self.onRestTimerRequested = onRestTimerRequested
    }

    var body: some View {

        List(workoutService.sampleWorkouts()) { workout in

            Button {
                WorkoutLifecycleLog.event(
                    "WorkoutLibraryView.workoutSelected",
                    WorkoutLifecycleLog.workout(workout)
                )
                selectedWorkout = workout
            } label: {

                WorkoutListRow(workout: workout)

            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .navigationTitle("Workouts")
        .navigationDestination(item: $selectedWorkout) { workout in

            WorkoutDetailsView(
                workout: workout,
                onWorkoutCompleted: onWorkoutCompleted,
                onWorkoutManuallyFinished: { summary in
                    WorkoutLifecycleLog.event(
                        "WorkoutLibraryView.manualFinishDismissingDetails",
                        [
                            "completedSessionID=\(summary.id.uuidString)",
                            "selectedWorkout.id=\(selectedWorkout?.id.uuidString ?? "nil")"
                        ]
                    )
                    selectedWorkout = nil
                    onWorkoutManuallyFinished(summary)
                },
                onRestTimerRequested: onRestTimerRequested
            )
        }
    }
}

#Preview {

    NavigationStack {

        WorkoutLibraryView()

    }
}
