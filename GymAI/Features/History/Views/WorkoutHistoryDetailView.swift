import SwiftUI

struct WorkoutHistoryDetailViewModel {

    let record: WorkoutSessionRecord

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
        String(localized: "history.detail.value_unavailable")
    }

    var comingSoon: String {
        String(localized: "history.detail.coming_soon")
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
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
}

#Preview {
    NavigationStack {
        WorkoutHistoryDetailView(
            record: WorkoutSessionRecord(
                workoutName: "Full Body Beginner",
                startedAt: .now.addingTimeInterval(-2_700),
                completedAt: .now,
                duration: 2_700,
                exercisesCompleted: 3
            )
        )
    }
}
