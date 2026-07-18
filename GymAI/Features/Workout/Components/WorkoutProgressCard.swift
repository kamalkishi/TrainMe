import SwiftUI

struct WorkoutProgressCard: View {

    let currentExercise: Int
    let totalExercises: Int

    let exerciseName: String

    let currentSet: Int
    let targetSets: Int

    let targetReps: Int
    let restSeconds: Int

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.md) {

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(formattedExerciseProgress)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)

                Text(exerciseName)
                    .font(AppFont.title)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Grid(
                alignment: .leading,
                horizontalSpacing: Spacing.sm,
                verticalSpacing: Spacing.sm
            ) {
                metricRow(
                    title: "workout.progress.current_set",
                    value: formattedSetProgress,
                    systemImage: "repeat"
                )

                metricRow(
                    title: "workout.progress.target_reps",
                    value: formattedTargetReps,
                    systemImage: "figure.strengthtraining.traditional"
                )

                metricRow(
                    title: "workout.progress.planned_rest",
                    value: formattedRest,
                    systemImage: "timer"
                )
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
    }

    private var formattedExerciseProgress: String {
        String(
            format: NSLocalizedString(
                "workout.exercise_progress",
                comment: "Workout exercise progress."
            ),
            String(currentExercise),
            String(totalExercises)
        )
    }

    private var formattedSetProgress: String {
        String(
            format: NSLocalizedString(
                "workout.progress.set_format",
                comment: "Current set and planned sets."
            ),
            currentSet,
            targetSets
        )
    }

    private var formattedTargetReps: String {
        String(
            format: NSLocalizedString(
                "%lld reps",
                comment: "A label that shows the number of repetitions for a workout exercise."
            ),
            targetReps
        )
    }

    private var formattedRest: String {
        String(
            format: NSLocalizedString(
                "%lld sec rest",
                comment: "A label that shows the rest time for a workout exercise."
            ),
            restSeconds
        )
    }

    private func metricRow(
        title: LocalizedStringKey,
        value: String,
        systemImage: String
    ) -> some View {
        GridRow(alignment: .firstTextBaseline) {
            Image(systemName: systemImage)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 24, alignment: .center)

            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {

    WorkoutProgressCard(
        currentExercise: 1,
        totalExercises: 5,
        exerciseName: "Bench Press",
        currentSet: 1,
        targetSets: 4,
        targetReps: 10,
        restSeconds: 90
    )
}
