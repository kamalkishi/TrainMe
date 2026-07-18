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
        let statusKind: ExerciseStatusKind
    }

    enum ExerciseStatusKind: Hashable {
        case complete
        case partial
        case unstarted
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
                status: status(for: exercise),
                statusKind: statusKind(for: exercise)
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
        switch statusKind(for: exercise) {
        case .complete:
            return String(localized: "history.detail.exercise.status.complete")
        case .partial:
            return String(localized: "history.detail.exercise.status.partial")
        case .unstarted:
            return String(localized: "history.detail.exercise.status.unstarted")
        }
    }

    private func statusKind(for exercise: WorkoutHistoryExerciseRecord) -> ExerciseStatusKind {
        if exercise.completedSets >= exercise.plannedSets && exercise.plannedSets > 0 {
            return .complete
        }

        if exercise.completedSets > 0 || exercise.completedReps > 0 {
            return .partial
        }

        return .unstarted
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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Text(exercise.exerciseName)
                    .font(AppFont.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: Spacing.sm)

                statusBadge(exercise.status, kind: exercise.statusKind)
            }

            VStack(spacing: Spacing.xs) {
                exerciseMetric(title: "history.detail.exercise.sets", value: exercise.sets)
                exerciseMetric(title: "history.detail.exercise.completed_reps", value: exercise.completedReps)
                exerciseMetric(title: "history.detail.exercise.planned_reps", value: exercise.plannedReps)
                exerciseMetric(title: "history.detail.exercise.rest", value: exercise.plannedRest)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private func exerciseMetric(title: LocalizedStringKey, value: String) -> some View {
        LabeledContent {
            Text(value)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.trailing)
        } label: {
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private func statusBadge(
        _ status: String,
        kind: WorkoutHistoryDetailViewModel.ExerciseStatusKind
    ) -> some View {
        let tint = statusTint(for: kind)

        return Text(status)
            .font(AppFont.caption)
            .foregroundStyle(tint)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }

    private func statusTint(for kind: WorkoutHistoryDetailViewModel.ExerciseStatusKind) -> Color {
        switch kind {
        case .complete:
            return AppColor.accent
        case .partial:
            return AppColor.primary
        case .unstarted:
            return AppColor.textSecondary
        }
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
