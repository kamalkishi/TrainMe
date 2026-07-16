import SwiftUI

struct WorkoutHistoryDetailView: View {

    let record: WorkoutSessionRecord

    var body: some View {
        List {
            Section("history.detail.section.summary") {
                labeledValue(
                    title: "history.detail.workout",
                    value: record.workoutName
                )

                labeledValue(
                    title: "history.detail.started",
                    value: record.startedAt.formatted(date: .abbreviated, time: .shortened)
                )

                labeledValue(
                    title: "history.detail.completed",
                    value: record.completedAt.formatted(date: .abbreviated, time: .shortened)
                )

                labeledValue(
                    title: "history.detail.duration",
                    value: formattedDuration(record.duration)
                )

                labeledValue(
                    title: "history.detail.exercises_completed",
                    value: String(record.exercisesCompleted)
                )
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

    private func formattedDuration(_ duration: TimeInterval) -> String {
        String(
            format: NSLocalizedString("%lld min", comment: "Workout duration in minutes."),
            Int(duration / 60)
        )
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
