import Foundation

struct WorkoutService {

    func sampleWorkouts() -> [Workout] {

        [
            Workout(
                name: "Full Body Beginner",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "A balanced workout targeting all major muscle groups."
            ),

            Workout(
                name: "Push Day",
                type: .hypertrophy,
                estimatedDuration: 50 * 60,
                description: "Focus on chest, shoulders and triceps."
            ),

            Workout(
                name: "Pull Day",
                type: .hypertrophy,
                estimatedDuration: 50 * 60,
                description: "Train your back, biceps and rear shoulders."
            ),

            Workout(
                name: "Leg Day",
                type: .strength,
                estimatedDuration: 60 * 60,
                description: "Build lower body strength and stability."
            )
        ]
    }
}
