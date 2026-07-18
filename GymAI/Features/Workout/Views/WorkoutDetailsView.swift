import SwiftUI

struct WorkoutDetailsView: View {

    let workout: Workout
    let onWorkoutCompleted: (WorkoutCompletionSummary) -> Void
    let onWorkoutManuallyFinished: (WorkoutCompletionSummary) -> Void
    let onRestTimerRequested: (RestTimerContext) -> Void

    @State private var viewModel = WorkoutDetailsViewModel()

    init(
        workout: Workout,
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onWorkoutManuallyFinished: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        self.workout = workout
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onWorkoutManuallyFinished = onWorkoutManuallyFinished
        self.onRestTimerRequested = onRestTimerRequested
    }

    var body: some View {
        let _ = WorkoutLifecycleLog.event(
            "WorkoutDetailsView.body",
            WorkoutLifecycleLog.workout(workout)
        )

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

                Text(workout.name)
                    .font(AppFont.largeTitle)

                Text(workout.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)

                Label(
                    "\(Int(workout.estimatedDuration / 60)) minutes",
                    systemImage: "clock"
                )

                Divider()

                Text("Exercises")
                    .font(AppFont.headline)

                if workout.exercises.isEmpty {

                    Text("Exercises will be added soon.")
                        .foregroundStyle(AppColor.textSecondary)

                } else {

                    ForEach(workout.exercises) { workoutExercise in

                        WorkoutExerciseCard(
                            workoutExercise: workoutExercise
                        )
                    }
                }

                Spacer(minLength: Spacing.lg)

                Button {
                    WorkoutLifecycleLog.event(
                        "WorkoutDetailsView.startWorkoutTapped",
                        WorkoutLifecycleLog.workout(workout)
                    )
                    viewModel.startWorkout(workout)
                } label: {
                    PrimaryButtonLabel(title: "workout.start")
                }
            }
            .padding(AppStyle.screenPadding)
        }
        .navigationTitle(workout.name)
        .navigationDestination(item: $viewModel.sessionToContinue) { session in
            let _ = WorkoutLifecycleLog.event(
                "WorkoutDetailsView.navigationDestination.resumeSession",
                WorkoutLifecycleLog.session(session)
            )
            WorkoutSessionView(
                session: session,
                onWorkoutCompleted: onWorkoutCompleted,
                onWorkoutManuallyFinished: { summary in
                    viewModel.dismissWorkoutSessionDestination(reason: "manualFinish.resumeSession")
                    onWorkoutManuallyFinished(summary)
                },
                onRestTimerRequested: onRestTimerRequested
            )
        }
        .navigationDestination(item: $viewModel.freshWorkoutDestination) { destination in
            let _ = WorkoutLifecycleLog.event(
                "WorkoutDetailsView.navigationDestination.freshWorkout",
                WorkoutLifecycleLog.workout(destination.workout)
                + ["freshDestination.id=\(destination.id)"]
            )
            WorkoutSessionView(
                session: destination.session,
                onWorkoutCompleted: onWorkoutCompleted,
                onWorkoutManuallyFinished: { summary in
                    viewModel.dismissWorkoutSessionDestination(reason: "manualFinish.freshSession")
                    onWorkoutManuallyFinished(summary)
                },
                onRestTimerRequested: onRestTimerRequested
            )
                .id(destination.id)
        }
        //.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {

    NavigationStack {

        WorkoutDetailsView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
