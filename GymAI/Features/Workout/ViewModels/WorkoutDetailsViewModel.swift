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

@MainActor
@Observable
final class WorkoutDetailsViewModel {

    private let repository: WorkoutRepositoryProtocol
    private let diagnosticID = UUID()

    var sessionToContinue: WorkoutSession?
    var freshWorkoutDestination: FreshWorkoutDestination?

    init() {
        self.repository = WorkoutRepository.shared
        WorkoutLifecycleLog.event("WorkoutDetailsViewModel.init", diagnosticFields)
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
        WorkoutLifecycleLog.event("WorkoutDetailsViewModel.initInjected", diagnosticFields)
    }

    func startWorkout(_ workout: Workout) {
        WorkoutLifecycleLog.event(
            "WorkoutDetailsViewModel.startWorkout.begin",
            diagnosticFields + WorkoutLifecycleLog.workout(workout)
        )

        if let activeSession = repository.fetchActiveSession() {
            freshWorkoutDestination = nil
            sessionToContinue = activeSession
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.resumeExisting",
                diagnosticFields + WorkoutLifecycleLog.session(activeSession)
            )
        } else {
            sessionToContinue = nil
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.createFreshSession",
                diagnosticFields + WorkoutLifecycleLog.workout(workout)
            )
            repository.startSession(for: workout)

            guard let session = repository.fetchActiveSession() else {
                WorkoutLifecycleLog.event(
                    "WorkoutDetailsViewModel.startWorkout.freshSessionMissing",
                    diagnosticFields + WorkoutLifecycleLog.workout(workout)
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

    private var diagnosticFields: [String] {
        [
            "workoutDetailsViewModel.id=\(diagnosticID)",
            "workoutDetailsViewModel.object=\(ObjectIdentifier(self))"
        ]
    }
}
