import SwiftUI

struct WorkoutLibraryView: View {

    var body: some View {

        Text("Workout Library")
            .navigationTitle("Workouts")
    }
}

#Preview {
    NavigationStack {
        WorkoutLibraryView()
    }
}
