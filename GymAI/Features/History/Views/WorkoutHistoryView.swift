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

                        VStack(alignment: .leading, spacing: Spacing.xs) {

                            Text(workout.workoutName)
                                .font(AppFont.headline)

                            Text(workout.completedAt, style: .date)
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("history.title")
    }
}

#Preview {

    NavigationStack {

        WorkoutHistoryView()
    }
}
