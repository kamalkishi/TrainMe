import SwiftUI

struct WorkoutCompletionSummaryView: View {

    let summary: WorkoutCompletionSummary
    let onBackToHome: () -> Void
    let onViewHistory: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header

                metrics

                plannedTargets

                VStack(spacing: Spacing.md) {
                    PrimaryButton(title: "workout.summary.back_home") {
                        onBackToHome()
                    }

                    Button {
                        onViewHistory()
                    } label: {
                        Label("workout.summary.view_history", systemImage: "clock.arrow.circlepath")
                            .font(AppFont.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(AppStyle.screenPadding)
        }
        .background(AppColor.background)
        .navigationTitle("workout.summary.title")
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(AppColor.primary)

            Text("workout.summary.completed")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textSecondary)

            Text(summary.workoutName)
                .font(AppFont.largeTitle)
        }
    }

    private var metrics: some View {
        Grid(alignment: .leading, horizontalSpacing: Spacing.lg, verticalSpacing: Spacing.md) {
            GridRow {
                metric(
                    title: "workout.summary.duration",
                    value: formattedDuration(summary.duration),
                    systemImage: "timer"
                )

                metric(
                    title: "workout.summary.exercises",
                    value: String(summary.completedExercises),
                    systemImage: "figure.strengthtraining.traditional"
                )
            }

            GridRow {
                metric(
                    title: "workout.summary.sets",
                    value: String(summary.completedSets),
                    systemImage: "repeat"
                )

                metric(
                    title: "workout.summary.reps",
                    value: String(summary.completedReps),
                    systemImage: "number"
                )
            }
        }
    }

    private var plannedTargets: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("workout.summary.planned_targets")
                .font(AppFont.headline)

            ForEach(summary.plannedTargets) { target in
                HStack(alignment: .firstTextBaseline) {
                    Text(target.exerciseName)
                        .font(AppFont.body)

                    Spacer()

                    Text(
                        String(
                            format: NSLocalizedString(
                                "workout.summary.target_sets_reps_format",
                                comment: "Workout summary target sets and reps."
                            ),
                            target.targetSets,
                            target.targetReps
                        )
                    )
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                }
                .padding(AppStyle.cardPadding)
                .background(AppColor.cardBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                )
            }
        }
    }

    private func metric(
        title: LocalizedStringKey,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(value)
                .font(AppFont.title)
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
        )
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        String(
            format: NSLocalizedString(
                "%lld min",
                comment: "Workout duration in minutes."
            ),
            Int(duration / 60)
        )
    }
}

#Preview {
    NavigationStack {
        WorkoutCompletionSummaryView(
            summary: WorkoutCompletionSummary(
                id: UUID(),
                workoutName: "Full Body Beginner",
                duration: 2_700,
                completedExercises: 3,
                completedSets: 9,
                completedReps: 102,
                plannedTargets: [
                    PlannedExerciseTarget(
                        exerciseName: "Goblet Squat",
                        targetSets: 3,
                        targetReps: 12
                    ),
                    PlannedExerciseTarget(
                        exerciseName: "Push-up",
                        targetSets: 3,
                        targetReps: 10
                    )
                ]
            )
        ) {
        } onViewHistory: {
        }
    }
}
