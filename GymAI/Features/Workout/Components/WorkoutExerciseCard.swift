import SwiftUI

struct WorkoutExerciseCard: View {

    let workoutExercise: WorkoutExercise

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.md) {

            Text(workoutExercise.exercise.name)
                .font(AppFont.headline)

            Text(
                workoutExercise.exercise.muscleGroups
                    .map(\.rawValue)
                    .joined(separator: " • ")
            )
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)

            Divider()

            HStack {

                Label(
                    "\(workoutExercise.targetSets) sets",
                    systemImage: "repeat"
                )

                Spacer()

                Label(
                    "\(workoutExercise.targetReps) reps",
                    systemImage: "figure.strengthtraining.traditional"
                )
            }

            Label(
                "\(workoutExercise.restSeconds) sec rest",
                systemImage: "timer"
            )
            .foregroundStyle(AppColor.textSecondary)
        }
        .padding()
        .background(AppColor.cardBackground)
        .shadow(radius: 2)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
    }
}

#Preview {

    WorkoutExerciseCard(
        workoutExercise: WorkoutExercise(
            exercise: Exercise(
                name: "Squat",
                muscleGroups: [.quadriceps, .glutes],
                workoutType: .strength,
                requiresWeight: true
            ),
            targetSets: 4,
            targetReps: 10,
            restSeconds: 90
        )
    )
}
