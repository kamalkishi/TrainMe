import SwiftUI

struct WorkoutExerciseCard: View {

    let workoutExercise: WorkoutExercise

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.sm) {

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

            HStack(alignment: .top, spacing: Spacing.sm) {
                metricItem(
                    title: "workout.details.exercise.sets",
                    value: formattedSets,
                    systemImage: "repeat"
                )

                metricItem(
                    title: "workout.details.exercise.reps",
                    value: formattedReps,
                    systemImage: "figure.strengthtraining.traditional"
                )

                metricItem(
                    title: "workout.details.exercise.rest",
                    value: formattedRest,
                    systemImage: "timer"
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .shadow(radius: 2)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
    }

    private var formattedSets: String {
        String(
            format: NSLocalizedString(
                "%lld sets",
                comment: "A label that shows the number of sets and reps for a workout exercise."
            ),
            workoutExercise.targetSets
        )
    }

    private var formattedReps: String {
        String(
            format: NSLocalizedString(
                "%lld reps",
                comment: "A label that shows the number of repetitions for a workout exercise."
            ),
            workoutExercise.targetReps
        )
    }

    private var formattedRest: String {
        String(
            format: NSLocalizedString(
                "%lld sec rest",
                comment: "A label that shows the rest time for a workout exercise."
            ),
            workoutExercise.restSeconds
        )
    }

    private func metricItem(
        title: LocalizedStringKey,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(value)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
