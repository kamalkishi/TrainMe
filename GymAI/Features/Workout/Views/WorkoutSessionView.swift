import SwiftUI

struct WorkoutSessionView: View {

    private let diagnosticID = UUID()
    private let onWorkoutCompleted: (WorkoutCompletionSummary) -> Void
    private let onWorkoutManuallyFinished: (WorkoutCompletionSummary) -> Void
    private let onRestTimerRequested: (RestTimerContext) -> Void

    @State private var viewModel: ActiveWorkoutViewModel
    @State private var didNotifyManualFinish = false
    @State private var isConfirmingFinishWorkout = false

    init(
        workout: Workout,
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onWorkoutManuallyFinished: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onWorkoutManuallyFinished = onWorkoutManuallyFinished
        self.onRestTimerRequested = onRestTimerRequested
        _viewModel = State(
            initialValue: ActiveWorkoutViewModel(workout: workout)
        )
        WorkoutLifecycleLog.event(
            "WorkoutSessionView.initWorkout",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "destinationKind=freshWorkout"
            ] + WorkoutLifecycleLog.workout(workout)
        )
    }

    init(
        session: WorkoutSession,
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onWorkoutManuallyFinished: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onWorkoutManuallyFinished = onWorkoutManuallyFinished
        self.onRestTimerRequested = onRestTimerRequested
        _viewModel = State(
            initialValue: ActiveWorkoutViewModel(session: session)
        )
        WorkoutLifecycleLog.event(
            "WorkoutSessionView.initSession",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "destinationKind=resumeSession"
            ] + WorkoutLifecycleLog.session(session)
        )
    }

    var body: some View {
        let _ = WorkoutLifecycleLog.event(
            "WorkoutSessionView.body",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
            ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
        )

        VStack(spacing: Spacing.lg) {
            if let exercise = viewModel.currentExercise {

                WorkoutProgressCard(
                    currentExercise: viewModel.currentExerciseNumber,
                    totalExercises: viewModel.totalExercises,
                    exerciseName: exercise.exercise.name,
                    currentSet: viewModel.currentSet,
                    targetSets: exercise.targetSets,
                    targetReps: exercise.targetReps,
                    restSeconds: exercise.restSeconds
                )

            } else {

                Text("workout.no_exercises")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: Spacing.md)
            
            PrimaryButton(
                title: "workout.complete_set"
            ) {
                WorkoutLifecycleLog.event(
                    "WorkoutSessionView.completeSetTapped",
                    [
                        "workoutSessionView.id=\(diagnosticID)",
                        "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                    ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
                )
                viewModel.completeSet()
                if !notifyCompletionIfNeeded() {
                    notifyRestTimerIfNeeded()
                }
            }
            .disabled(viewModel.isWorkoutCompleted)
            
            HStack(spacing: Spacing.md) {

                Button {
                    WorkoutLifecycleLog.event(
                        "WorkoutSessionView.previousTapped",
                        [
                            "workoutSessionView.id=\(diagnosticID)",
                            "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                        ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
                    )
                    viewModel.previousExercise()
                } label: {
                    Label("common.previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xs)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isFirstExercise)

                Button {
                    WorkoutLifecycleLog.event(
                        "WorkoutSessionView.nextTapped",
                        [
                            "workoutSessionView.id=\(diagnosticID)",
                            "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                        ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
                    )
                    viewModel.nextExercise()
                } label: {
                    Label("common.next", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xs)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLastExercise)
            }

            Button(role: .destructive) {
                WorkoutLifecycleLog.event(
                    "WorkoutSessionView.finishTapped",
                    [
                        "workoutSessionView.id=\(diagnosticID)",
                        "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                    ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
                )
                isConfirmingFinishWorkout = true
            } label: {
                Label("workout.finish", systemImage: "checkmark.circle")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xs)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .foregroundStyle(.red)
            .disabled(viewModel.isWorkoutCompleted || didNotifyManualFinish)
        }
        .alert("workout.finish.confirm_title", isPresented: $isConfirmingFinishWorkout) {
            Button("common.cancel", role: .cancel) {}

            Button("workout.finish.confirm_action", role: .destructive) {
                performManualFinish()
            }
        } message: {
            Text("workout.finish.confirm_message")
        }
        .padding(AppStyle.screenPadding)
        .navigationTitle(viewModel.workout.name)
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            WorkoutLifecycleLog.event(
                "WorkoutSessionView.onAppear",
                [
                    "workoutSessionView.id=\(diagnosticID)",
                    "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
            )
        }
        .onDisappear {
            WorkoutLifecycleLog.event(
                "WorkoutSessionView.onDisappear",
                [
                    "workoutSessionView.id=\(diagnosticID)",
                    "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
            )
            viewModel.discardIfUnstarted()
        }
    }

    private func notifyCompletionIfNeeded() -> Bool {
        guard
            let completedSessionID = viewModel.completedSessionID,
            let summary = viewModel.completionSummary
        else {
            return false
        }

        WorkoutLifecycleLog.event(
            "WorkoutSessionView.workoutCompleted",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)",
                "completedSessionID=\(completedSessionID.uuidString)"
            ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
        )
        WorkoutLifecycleLog.event(
            "WorkoutSessionView.summaryReady",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "summary.id=\(summary.id.uuidString)"
            ]
        )
        onWorkoutCompleted(summary)
        return true
    }

    private func performManualFinish() {
        if let summary = viewModel.finishWorkout() {
            notifyManualFinish(summary)
        }
    }

    private func notifyManualFinish(_ summary: WorkoutCompletionSummary) {
        guard !didNotifyManualFinish else {
            return
        }

        didNotifyManualFinish = true
        WorkoutLifecycleLog.event(
            "WorkoutSessionView.manualFinishCompleted",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)",
                "completedSessionID=\(summary.id.uuidString)",
                "workout.name=\(summary.workoutName)"
            ]
        )
        onWorkoutManuallyFinished(summary)
    }

    private func notifyRestTimerIfNeeded() {
        guard let context = viewModel.pendingRestTimerContext else {
            return
        }

        WorkoutLifecycleLog.event(
            "RestTimer.requested",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)",
                "restTimer.id=\(context.id.uuidString)",
                "exercise.name=\(context.exerciseName)",
                "durationSeconds=\(context.durationSeconds)",
                "upcomingSet=\(context.upcomingSet)"
            ]
        )
        onRestTimerRequested(context)
    }
}

#Preview {

    NavigationStack {

        WorkoutSessionView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
