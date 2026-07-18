import SwiftUI

struct WorkoutHistoryDetailViewModel {

    let record: WorkoutSessionRecord

    struct ExerciseDetail: Identifiable, Hashable {
        let id: UUID
        let exerciseName: String
        let sets: String
        let completedReps: String
        let plannedReps: String
        let plannedRest: String
        let status: String
    }

    var workoutName: String {
        let trimmedName = record.workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty
            ? String(localized: "history.detail.value_unavailable")
            : trimmedName
    }

    var completionStatus: String {
        String(localized: "history.detail.status.completed")
    }

    var startedAt: String {
        formattedDate(record.startedAt)
    }

    var completedAt: String {
        formattedDate(record.completedAt)
    }

    var duration: String {
        guard record.duration > 0 else {
            return String(localized: "history.detail.value_unavailable")
        }

        return String(
            format: String(localized: "history.detail.duration.minutes"),
            Int(record.duration / 60)
        )
    }

    var exercisesCompleted: String {
        String(record.exercisesCompleted)
    }

    var totalSetsCompleted: String {
        guard !record.exerciseResults.isEmpty else {
            return String(localized: "history.detail.value_unavailable")
        }

        let completedSets = record.exerciseResults.reduce(0) { total, exercise in
            total + exercise.completedSets
        }

        return String(completedSets)
    }

    var exerciseDetails: [ExerciseDetail] {
        record.exerciseResults.map { exercise in
            ExerciseDetail(
                id: exercise.id,
                exerciseName: exercise.exerciseName,
                sets: String(
                    format: String(localized: "history.detail.exercise.sets_format"),
                    exercise.completedSets,
                    exercise.plannedSets
                ),
                completedReps: String(
                    format: String(localized: "history.detail.exercise.completed_reps_format"),
                    exercise.completedReps
                ),
                plannedReps: String(
                    format: String(localized: "history.detail.exercise.planned_reps_format"),
                    exercise.plannedReps
                ),
                plannedRest: String(
                    format: String(localized: "history.detail.exercise.rest_format"),
                    exercise.plannedRestSeconds
                ),
                status: status(for: exercise)
            )
        }
    }

    var exerciseBreakdownUnavailable: String {
        String(localized: "history.detail.exercise_breakdown_unavailable")
    }

    var comingSoon: String {
        String(localized: "history.detail.coming_soon")
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    private func status(for exercise: WorkoutHistoryExerciseRecord) -> String {
        if exercise.completedSets >= exercise.plannedSets && exercise.plannedSets > 0 {
            return String(localized: "history.detail.exercise.status.complete")
        }

        if exercise.completedSets > 0 || exercise.completedReps > 0 {
            return String(localized: "history.detail.exercise.status.partial")
        }

        return String(localized: "history.detail.exercise.status.unstarted")
    }
}

struct WorkoutHistoryDetailView: View {

    private let viewModel: WorkoutHistoryDetailViewModel

    init(record: WorkoutSessionRecord) {
        self.viewModel = WorkoutHistoryDetailViewModel(record: record)
    }

    var body: some View {
        List {
            Section("history.detail.section.summary") {
                labeledValue(
                    title: "history.detail.workout",
                    value: viewModel.workoutName
                )

                labeledValue(
                    title: "history.detail.status",
                    value: viewModel.completionStatus
                )

                labeledValue(
                    title: "history.detail.started",
                    value: viewModel.startedAt
                )

                labeledValue(
                    title: "history.detail.completed",
                    value: viewModel.completedAt
                )

                labeledValue(
                    title: "history.detail.duration",
                    value: viewModel.duration
                )

                labeledValue(
                    title: "history.detail.exercises_completed",
                    value: viewModel.exercisesCompleted
                )

                labeledValue(
                    title: "history.detail.total_sets_completed",
                    value: viewModel.totalSetsCompleted
                )
            }

            Section("history.detail.section.exercises") {
                if viewModel.exerciseDetails.isEmpty {
                    Text(viewModel.exerciseBreakdownUnavailable)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    ForEach(viewModel.exerciseDetails) { exercise in
                        exerciseDetail(exercise)
                    }
                }
            }

            Section("history.detail.section.notes") {
                Text(viewModel.comingSoon)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Section("history.detail.section.ai_insights") {
                Text(viewModel.comingSoon)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .navigationTitle("history.detail.title")
    }

    private func labeledValue(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(value)
                .font(AppFont.body)
        }
    }

    private func exerciseDetail(_ exercise: WorkoutHistoryDetailViewModel.ExerciseDetail) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(exercise.exerciseName)
                    .font(AppFont.headline)

                Spacer()

                Text(exercise.status)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Text(exercise.sets)
                .font(AppFont.body)

            Text(exercise.completedReps)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(exercise.plannedReps)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(exercise.plannedRest)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryDetailView(
            record: WorkoutSessionRecord(
                workoutName: "Full Body Beginner",
                startedAt: .now.addingTimeInterval(-2_700),
                completedAt: .now,
                duration: 2_700,
                exercisesCompleted: 3,
                exerciseResults: [
                    WorkoutHistoryExerciseRecord(
                        exerciseID: UUID(),
                        exerciseName: "Goblet Squat",
                        plannedSets: 3,
                        plannedReps: 12,
                        plannedRestSeconds: 60,
                        completedSets: 3,
                        completedReps: 36
                    )
                ]
            )
        )
    }
}
