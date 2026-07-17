import SwiftUI

struct WorkoutSessionView: View {

    private let diagnosticID = UUID()
    private let onWorkoutCompleted: (UUID) -> Void

    @State private var viewModel: ActiveWorkoutViewModel

    init(
        workout: Workout,
        onWorkoutCompleted: @escaping (UUID) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
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
        onWorkoutCompleted: @escaping (UUID) -> Void = { _ in }
    ) {
        self.onWorkoutCompleted = onWorkoutCompleted
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

        VStack(spacing: Spacing.xl) {

            Text(viewModel.workout.name)
                .font(AppFont.largeTitle)
            
            Text(
                "workout.exercise_progress \(viewModel.currentExerciseNumber) \(viewModel.totalExercises)"
            )
            .font(AppFont.headline)
            .foregroundStyle(AppColor.textSecondary)

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

            Spacer(minLength: Spacing.lg)
            
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
                notifyCompletionIfNeeded()
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
                }
                .disabled(viewModel.isFirstExercise)

                Spacer()

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
                }
                .disabled(viewModel.isLastExercise)
            }

            PrimaryButton(
                title: "workout.finish"
            ) {
                WorkoutLifecycleLog.event(
                    "WorkoutSessionView.finishTapped",
                    [
                        "workoutSessionView.id=\(diagnosticID)",
                        "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)"
                    ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
                )
                viewModel.finishWorkout()
                notifyCompletionIfNeeded()
            }
        }
        .padding(AppStyle.screenPadding)
        .navigationTitle("workout.title")
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

    private func notifyCompletionIfNeeded() {
        guard let completedSessionID = viewModel.completedSessionID else {
            return
        }

        WorkoutLifecycleLog.event(
            "WorkoutSessionView.workoutCompleted",
            [
                "workoutSessionView.id=\(diagnosticID)",
                "activeWorkoutViewModel.id=\(viewModel.diagnosticIdentifier)",
                "completedSessionID=\(completedSessionID.uuidString)"
            ] + WorkoutLifecycleLog.activeWorkout(viewModel.activeWorkout)
        )
        onWorkoutCompleted(completedSessionID)
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
