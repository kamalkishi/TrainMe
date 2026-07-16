import SwiftUI

struct WorkoutDetailsView: View {

    let workout: Workout

    @State private var viewModel = WorkoutDetailsViewModel()

    var body: some View {

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

                Text(workout.name)
                    .font(AppFont.largeTitle)

                Text(workout.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)

                Label(
                    "\(Int(workout.estimatedDuration / 60)) minutes",
                    systemImage: "clock"
                )

                Divider()

                Text("Exercises")
                    .font(AppFont.headline)

                if workout.exercises.isEmpty {

                    Text("Exercises will be added soon.")
                        .foregroundStyle(AppColor.textSecondary)

                } else {

                    ForEach(workout.exercises) { workoutExercise in

                        WorkoutExerciseCard(
                            workoutExercise: workoutExercise
                        )
                    }
                }

                Spacer(minLength: Spacing.lg)

                Button {
                    viewModel.startWorkout(workout)
                } label: {
                    PrimaryButtonLabel(title: "workout.start")
                }
            }
            .padding(AppStyle.screenPadding)
        }
        .navigationTitle(workout.name)
        .navigationDestination(item: $viewModel.sessionToContinue) { session in
            WorkoutSessionView(session: session)
        }
        .navigationDestination(item: $viewModel.freshWorkoutDestination) { destination in
            WorkoutSessionView(workout: destination.workout)
                .id(destination.id)
        }
        //.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {

    NavigationStack {

        WorkoutDetailsView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
