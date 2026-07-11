import SwiftUI

struct WorkoutSessionView: View {

    @State private var viewModel: ActiveWorkoutViewModel

    init(workout: Workout) {
        _viewModel = State(
            initialValue: ActiveWorkoutViewModel(workout: workout)
        )
    }

    var body: some View {

        VStack(spacing: Spacing.xl) {

            Text(viewModel.workout.name)
                .font(AppFont.largeTitle)

            if let exercise = viewModel.currentExercise {

                VStack(spacing: Spacing.md) {

                    Text(exercise.exercise.name)
                        .font(AppFont.title)

                    Text("Set \(viewModel.currentSet) of \(exercise.targetSets)")

                    Text("Target: \(exercise.targetReps) reps")
                }

            } else {

                Text("No exercises available.")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.md) {

                Button("Previous") {
                    viewModel.previousExercise()
                }

                Spacer()

                Button("Next") {
                    viewModel.nextExercise()
                }
            }

            PrimaryButton(
                title: "Finish Workout"
            ) {
                // Completion logic coming next milestone
            }
        }
        .padding(AppStyle.screenPadding)
        .navigationTitle("Workout")
    }
}

#Preview {

    NavigationStack {

        WorkoutSessionView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
