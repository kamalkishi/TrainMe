import Foundation
import Observation

struct FreshWorkoutDestination: Identifiable, Hashable {

    let id: UUID
    let workout: Workout

    init(
        id: UUID = UUID(),
        workout: Workout
    ) {
        self.id = id
        self.workout = workout
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
            sessionToContinue = activeSession
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.resumeExisting",
                diagnosticFields + WorkoutLifecycleLog.session(activeSession)
            )
        } else {
            freshWorkoutDestination = FreshWorkoutDestination(workout: workout)
            WorkoutLifecycleLog.event(
                "WorkoutDetailsViewModel.startWorkout.freshDestinationCreated",
                diagnosticFields
                + WorkoutLifecycleLog.workout(workout)
                + ["freshDestination.id=\(freshWorkoutDestination?.id.uuidString ?? "nil")"]
            )
        }
    }

    private var diagnosticFields: [String] {
        [
            "workoutDetailsViewModel.id=\(diagnosticID)",
            "workoutDetailsViewModel.object=\(ObjectIdentifier(self))"
        ]
    }
}
