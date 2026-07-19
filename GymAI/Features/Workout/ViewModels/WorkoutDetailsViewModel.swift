import Foundation
import Observation

struct FreshWorkoutDestination: Identifiable, Hashable {

    let id: UUID
    let session: WorkoutSession

    var workout: Workout {
        session.workout
    }

    init(
        id: UUID = UUID(),
        session: WorkoutSession
    ) {
        self.id = id
        self.session = session
    }
}

struct ActiveWorkoutSwitchConflict: Identifiable, Hashable {

    var id: UUID {
        activeSession.id
    }

    let activeSession: WorkoutSession
    let selectedWorkout: Workout
}

enum WorkoutSwitchFailure: Equatable, Identifiable {
    case saveFailed
    case cleanupFailed
    case startFailed

    var id: String {
        switch self {
        case .saveFailed:
            "saveFailed"
        case .cleanupFailed:
            "cleanupFailed"
        case .startFailed:
            "startFailed"
        }
    }
}

@MainActor
@Observable
final class WorkoutDetailsViewModel {

    private let repository: WorkoutRepositoryProtocol
    private let completionLifecycle: WorkoutCompletionLifecycle
    private let diagnosticID = UUID()
    private var isResolvingWorkoutSwitch = false

    var sessionToContinue: WorkoutSession?
    var freshWorkoutDestination: FreshWorkoutDestination?
    var workoutSwitchConflict: ActiveWorkoutSwitchConflict?
    var workoutSwitchFailure: WorkoutSwitchFailure?

    init() {
        let repository = WorkoutRepository.shared
        self.repository = repository
        self.completionLifecycle = WorkoutCompletionLifecycle(repository: repository)
        WorkoutLifecycleLog.event("WorkoutDetailsViewModel.init", diagnosticFields)
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
        self.completionLifecycle = WorkoutCompletionLifecycle(repository: repository)
        WorkoutLifecycleLog.event("WorkoutDetailsViewModel.initInjected", diagnosticFields)
    }

    func startWorkout(_ workout: Workout) {
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.startWorkout.begin",
            diagnosticFields + WorkoutLifecycleLog.workout(workout)
        )

        if let activeSession = repository.fetchActiveSession() {
            if activeSession.workout.id == workout.id {
                resumeActiveSession(activeSession)
            } else {
                freshWorkoutDestination = nil
                sessionToContinue = nil
                workoutSwitchFailure = nil
                workoutSwitchConflict = ActiveWorkoutSwitchConflict(
                    activeSession: activeSession,
                    selectedWorkout: workout
                )
                WorkoutLifecycleLog.event(
                    "WorkoutDetailsViewModel.startWorkout.switchConflict",
                    diagnosticFields
                    + WorkoutLifecycleLog.session(activeSession, label: "activeSession")
                    + WorkoutLifecycleLog.workout(workout)
                )
            }
        } else {
            startFreshWorkout(workout)
        }
    }

    func cancelWorkoutSwitchConflict() {
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.switchConflictCancelled",
            diagnosticFields
            + WorkoutLifecycleLog.session(workoutSwitchConflict?.activeSession, label: "conflict.activeSession")
        )
        workoutSwitchConflict = nil
    }

    func continueActiveWorkoutFromConflict() {
        guard let conflict = workoutSwitchConflict else {
            return
        }

        workoutSwitchConflict = nil
        resumeActiveSession(conflict.activeSession)
    }

    func saveAndSwitchFromConflict() {
        guard !isResolvingWorkoutSwitch else {
            WorkoutLifecycleLog.event("WorkoutDetailsViewModel.saveAndSwitch.ignoredAlreadyResolving", diagnosticFields)
            return
        }

        guard let conflict = workoutSwitchConflict else {
            return
        }

        isResolvingWorkoutSwitch = true
        defer {
            isResolvingWorkoutSwitch = false
        }

        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.saveAndSwitch.begin",
            diagnosticFields
            + WorkoutLifecycleLog.session(conflict.activeSession, label: "activeSession")
            + WorkoutLifecycleLog.workout(conflict.selectedWorkout)
        )

        if hasMeaningfulProgress(conflict.activeSession) {
            guard completionLifecycle.finishActiveSession(conflict.activeSession) != nil else {
                workoutSwitchConflict = nil
                workoutSwitchFailure = .saveFailed
                WorkoutLifecycleLog.event("WorkoutDetailsViewModel.saveAndSwitch.saveFailed", diagnosticFields)
                return
            }
        } else {
            guard repository.clearActiveSession(ifSessionID: conflict.activeSession.id) else {
                workoutSwitchConflict = nil
                workoutSwitchFailure = .cleanupFailed
                WorkoutLifecycleLog.event("WorkoutDetailsViewModel.saveAndSwitch.cleanupFailed", diagnosticFields)
                return
            }
        }

        guard repository.fetchActiveSession() == nil else {
            workoutSwitchConflict = nil
            workoutSwitchFailure = hasMeaningfulProgress(conflict.activeSession) ? .saveFailed : .cleanupFailed
            WorkoutLifecycleLog.event("WorkoutDetailsViewModel.saveAndSwitch.activeSessionStillPresent", diagnosticFields)
            return
        }

        workoutSwitchConflict = nil
        startFreshWorkout(conflict.selectedWorkout)

        if freshWorkoutDestination == nil {
            workoutSwitchFailure = .startFailed
            WorkoutLifecycleLog.event("WorkoutDetailsViewModel.saveAndSwitch.startFailed", diagnosticFields)
        }
    }

    func dismissWorkoutSessionDestination(reason: String) {
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.dismissWorkoutSessionDestination",
            diagnosticFields
            + ["reason=\(reason)"]
            + WorkoutLifecycleLog.session(sessionToContinue, label: "details.sessionToContinue")
            + WorkoutLifecycleLog.session(freshWorkoutDestination?.session, label: "details.freshSession")
        )
        sessionToContinue = nil
        freshWorkoutDestination = nil
    }

    private func resumeActiveSession(_ activeSession: WorkoutSession) {
        freshWorkoutDestination = nil
        workoutSwitchConflict = nil
        workoutSwitchFailure = nil
        sessionToContinue = activeSession
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.startWorkout.resumeExisting",
            diagnosticFields + WorkoutLifecycleLog.session(activeSession)
        )
    }

    private func startFreshWorkout(_ workout: Workout) {
        sessionToContinue = nil
        workoutSwitchFailure = nil
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.startWorkout.createFreshSession",
            diagnosticFields + WorkoutLifecycleLog.workout(workout)
        )
        guard let session = repository.startSession(for: workout) else {
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.freshSessionMissing",
                diagnosticFields + WorkoutLifecycleLog.workout(workout)
            )
            return
        }

        guard session.workout.id == workout.id else {
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.freshSessionMismatch",
                diagnosticFields
                + WorkoutLifecycleLog.workout(workout)
                + WorkoutLifecycleLog.session(session, label: "startedSession")
            )
            return
        }

        freshWorkoutDestination = FreshWorkoutDestination(session: session)
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.startWorkout.freshDestinationCreated",
            diagnosticFields
            + WorkoutLifecycleLog.session(session)
            + ["freshDestination.id=\(freshWorkoutDestination?.id.uuidString ?? "nil")"]
        )
    }

    private func hasMeaningfulProgress(_ session: WorkoutSession) -> Bool {
        session.currentExerciseIndex > 0
        || session.currentSet > 1
        || session.completedExercises > 0
        || session.completedReps > 0
        || session.elapsedTime > 0
        || session.completed
    }

    private var diagnosticFields: [String] {
        [
            "workoutDetailsViewModel.id=\(diagnosticID)",
            "workoutDetailsViewModel.object=\(ObjectIdentifier(self))"
        ]
    }
}
