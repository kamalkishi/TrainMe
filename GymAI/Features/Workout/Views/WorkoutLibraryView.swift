import SwiftUI

struct WorkoutLibraryView: View {

    private let workoutService = WorkoutService()

    var body: some View {

        List(workoutService.sampleWorkouts()) { workout in

            NavigationLink {

                WorkoutDetailsView(workout: workout)

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
