import Foundation

@MainActor
struct WorkoutService {

    func sampleWorkouts() -> [Workout] {
        do {
            return try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)
        } catch {
            preconditionFailure("Built-in workout catalogue failed runtime mapping: \(error)")
        }
    }
}
