import SwiftUI

struct WorkoutLibraryView: View {

    private let workoutService = WorkoutService()
    private let onWorkoutCompleted: (UUID) -> Void

    init(onWorkoutCompleted: @escaping (UUID) -> Void = { _ in }) {
        self.onWorkoutCompleted = onWorkoutCompleted
    }

    var body: some View {

        List(workoutService.sampleWorkouts()) { workout in

            NavigationLink {

                WorkoutDetailsView(
                    workout: workout,
                    onWorkoutCompleted: onWorkoutCompleted
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
