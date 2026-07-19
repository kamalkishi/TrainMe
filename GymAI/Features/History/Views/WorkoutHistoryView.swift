import SwiftUI

struct WorkoutHistoryView: View {

    @State
    private var viewModel = WorkoutHistoryViewModel()

    var body: some View {
        let _ = WorkoutLifecycleLog.event("WorkoutHistoryView.body")

        Group {

            if viewModel.history.isEmpty {

                ContentUnavailableView(
                    "history.empty_title",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("history.empty_message")
                )

            } else {

                List(viewModel.history) { workout in
                    NavigationLink {
                        WorkoutHistoryDetailView(record: workout)
                    } label: {
                        WorkoutHistoryRow(record: workout)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(
                            top: Spacing.xs,
                            leading: Spacing.md,
                            bottom: Spacing.xs,
                            trailing: Spacing.md
                        )
                    )
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("history.title")
    }
}

private struct WorkoutHistoryRow: View {

    let record: WorkoutSessionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(record.workoutName)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(completionDate)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            HStack(alignment: .top, spacing: Spacing.sm) {
                metricItem(
                    title: "history.detail.duration",
                    value: duration,
                    systemImage: "clock"
                )

                metricItem(
                    title: "history.detail.exercises_completed",
                    value: exercisesCompleted,
                    systemImage: "checklist"
                )
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
    }

    private var completionDate: String {
        record.completedAt.formatted(date: .abbreviated, time: .shortened)
    }

    private var duration: String {
        guard record.duration > 0 else {
            return String(localized: "history.detail.value_unavailable")
        }

        return String(
            format: String(localized: "history.detail.duration.minutes"),
            Int(record.duration / 60)
        )
    }

    private var exercisesCompleted: String {
        String(
            format: String(localized: "history.list.exercises_completed_format"),
            record.exercisesCompleted
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
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {

    NavigationStack {

        WorkoutHistoryView()
    }
}
