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

    var sessionToContinue: WorkoutSession?
    var freshWorkoutDestination: FreshWorkoutDestination?

    init() {
        self.repository = WorkoutRepository.shared
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
    }

    func startWorkout(_ workout: Workout) {
        if let activeSession = repository.fetchActiveSession() {
            sessionToContinue = activeSession
        } else {
            freshWorkoutDestination = FreshWorkoutDestination(workout: workout)
        }
    }
}
