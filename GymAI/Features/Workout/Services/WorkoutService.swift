import Foundation

struct WorkoutService {
    
    private let gobletSquat = Exercise(
        name: "Goblet Squat",
        muscleGroups: [.quadriceps, .glutes],
        workoutType: .strength,
        requiresWeight: true
    )

    private let pushUp = Exercise(
        name: "Push-up",
        muscleGroups: [.chest, .triceps],
        workoutType: .strength,
        requiresWeight: false
    )

    private let bentOverRow = Exercise(
        name: "Bent-over Row",
        muscleGroups: [.back, .biceps],
        workoutType: .strength,
        requiresWeight: true
    )
    
    func sampleWorkouts() -> [Workout] {

        [
            Workout(
                name: "Full Body Beginner",
                type: .strength,
                exercises: [
                    WorkoutExercise(
                        exercise: gobletSquat,
                        targetSets: 3,
                        targetReps: 12,
                        restSeconds: 60
                    ),
                    WorkoutExercise(
                        exercise: pushUp,
                        targetSets: 3,
                        targetReps: 10,
                        restSeconds: 60
                    ),
                    WorkoutExercise(
                        exercise: bentOverRow,
                        targetSets: 3,
                        targetReps: 12,
                        restSeconds: 60
                    )
                ],
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
