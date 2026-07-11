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
            
            Text(
                "workout.exercise_progress \(viewModel.currentExerciseNumber) \(viewModel.totalExercises)"
            )
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

                Text("workout.no_exercises")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: Spacing.lg)
            
            PrimaryButton(
                title: "workout.complete_set"
            ) {
                viewModel.completeSet()
            }
            .disabled(viewModel.isWorkoutCompleted)
            
            HStack(spacing: Spacing.md) {

                Button {
                    viewModel.previousExercise()
                } label: {
                    Label("common.previous", systemImage: "chevron.left")
                }
                .disabled(viewModel.isFirstExercise)

                Spacer()

                Button {
                    viewModel.nextExercise()
                } label: {
                    Label("common.next", systemImage: "chevron.right")
                }
                .disabled(viewModel.isLastExercise)
            }

            PrimaryButton(
                title: "workout.finish"
            ) {
                // Completion logic coming next milestone
            }
        }
        .padding(AppStyle.screenPadding)
        .navigationTitle("workout.title")
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
