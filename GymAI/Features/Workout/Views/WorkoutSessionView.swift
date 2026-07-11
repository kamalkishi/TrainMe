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
            
            Text("Exercise \(viewModel.currentExerciseNumber) of \(viewModel.totalExercises)")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textSecondary)

            if let exercise = viewModel.currentExercise {

                WorkoutProgressCard(
                    currentExercise: viewModel.currentExerciseNumber,
                    totalExercises: viewModel.totalExercises,
                    exerciseName: exercise.exercise.name,
                    currentSet: viewModel.currentSet,
                    targetSets: exercise.targetSets,
                    targetReps: exercise.targetReps,
                    restSeconds: exercise.restSeconds
                )

            } else {

                Text("No exercises available.")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.md) {

                Button("Previous") {
                    viewModel.previousExercise()
                }
                .disabled(viewModel.isFirstExercise)

                Spacer()

                Button("Next") {
                    viewModel.nextExercise()
                }
                .disabled(viewModel.isLastExercise)
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
