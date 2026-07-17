import SwiftUI

struct WorkoutLibraryView: View {

    private let workoutService = WorkoutService()
    private let onWorkoutCompleted: (WorkoutCompletionSummary) -> Void
    private let onRestTimerRequested: (RestTimerContext) -> Void

    init(
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onRestTimerRequested = onRestTimerRequested
    }

    var body: some View {

        List(workoutService.sampleWorkouts()) { workout in

            NavigationLink {

                WorkoutDetailsView(
                    workout: workout,
                    onWorkoutCompleted: onWorkoutCompleted,
                    onRestTimerRequested: onRestTimerRequested
                )

            } label: {

                WorkoutListRow(workout: workout)

            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .navigationTitle("Workouts")
    }
}

#Preview {

    NavigationStack {

        WorkoutLibraryView()

    }
}
