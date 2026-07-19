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
                   spacing: Spacing.lg) {

                Text(workout.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)

                workoutSummary

                Divider()

                Text("workout.details.exercises_title")
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
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert(
            "workout.switch.confirm_title",
            isPresented: isShowingWorkoutSwitchConflict,
            presenting: viewModel.workoutSwitchConflict
        ) { conflict in
            Button(role: .cancel) {
                viewModel.cancelWorkoutSwitchConflict()
            } label: {
                Text("common.cancel")
            }

            Button {
                viewModel.continueActiveWorkoutFromConflict()
            } label: {
                Text(
                    String(
                        format: NSLocalizedString(
                            "workout.switch.continue_action %@",
                            comment: "Continue the active workout from the switch confirmation."
                        ),
                        conflict.activeSession.workout.name
                    )
                )
            }

            Button(role: .destructive) {
                viewModel.saveAndSwitchFromConflict()
            } label: {
                Text(
                    String(
                        format: NSLocalizedString(
                            "workout.switch.save_and_start_action %@",
                            comment: "Save the active workout and start the selected workout."
                        ),
                        conflict.selectedWorkout.name
                    )
                )
            }
        } message: { conflict in
            Text(
                String(
                    format: NSLocalizedString(
                        "workout.switch.confirm_message %@ %@",
                        comment: "Workout switch confirmation message with active and selected workout names."
                    ),
                    conflict.activeSession.workout.name,
                    conflict.selectedWorkout.name
                )
            )
        }
        .alert(
            "workout.switch.failure_title",
            isPresented: isShowingWorkoutSwitchFailure,
            presenting: viewModel.workoutSwitchFailure
        ) { _ in
            Button("common.ok", role: .cancel) {}
        } message: { failure in
            Text(failure.messageKey)
        }
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

    private var workoutSummary: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            summaryItem(
                title: "workout.details.summary.type",
                value: workoutTypeTitle,
                systemImage: "dumbbell"
            )

            summaryItem(
                title: "workout.details.summary.exercise_count",
                value: formattedExerciseCount,
                systemImage: "list.bullet"
            )

            summaryItem(
                title: "workout.details.summary.estimated_duration",
                value: formattedEstimatedDuration,
                systemImage: "clock"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summaryItem(
        title: LocalizedStringKey,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(title, systemImage: systemImage)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(value)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var workoutTypeTitle: String {
        switch workout.type {
        case .strength:
            NSLocalizedString("workout.type.strength", comment: "Strength workout type.")
        case .hypertrophy:
            NSLocalizedString("workout.type.hypertrophy", comment: "Hypertrophy workout type.")
        case .cardio:
            NSLocalizedString("workout.type.cardio", comment: "Cardio workout type.")
        case .hiit:
            NSLocalizedString("workout.type.hiit", comment: "HIIT workout type.")
        case .mobility:
            NSLocalizedString("workout.type.mobility", comment: "Mobility workout type.")
        case .flexibility:
            NSLocalizedString("workout.type.flexibility", comment: "Flexibility workout type.")
        case .rehabilitation:
            NSLocalizedString("workout.type.rehabilitation", comment: "Rehabilitation workout type.")
        }
    }

    private var formattedExerciseCount: String {
        String(
            format: NSLocalizedString(
                "workout.details.summary.exercise_count_format %lld",
                comment: "The number of exercises in a workout."
            ),
            workout.exercises.count
        )
    }

    private var formattedEstimatedDuration: String {
        String(
            format: NSLocalizedString(
                "%lld minutes",
                comment: "A workout duration in minutes. The argument is the workout duration in minutes."
            ),
            Int(workout.estimatedDuration / 60)
        )
    }

    private var isShowingWorkoutSwitchConflict: Binding<Bool> {
        Binding {
            viewModel.workoutSwitchConflict != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.cancelWorkoutSwitchConflict()
            }
        }
    }

    private var isShowingWorkoutSwitchFailure: Binding<Bool> {
        Binding {
            viewModel.workoutSwitchFailure != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.workoutSwitchFailure = nil
            }
        }
    }
}

private extension WorkoutSwitchFailure {

    var messageKey: LocalizedStringKey {
        switch self {
        case .saveFailed:
            "workout.switch.save_failure_message"
        case .cleanupFailed:
            "workout.switch.cleanup_failure_message"
        case .startFailed:
            "workout.switch.start_failure_message"
        }
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
