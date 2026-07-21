import Foundation

enum BuiltInWorkoutCatalogue {

    static let allWorkouts: [CatalogueWorkoutDefinition] = [
        fullBodyBeginner,
        pushDay,
        pullDay,
        legDay
    ]

    static func workout(for semanticKey: CatalogueSemanticKey) -> CatalogueWorkoutDefinition? {
        workoutsBySemanticKey[semanticKey]
    }

    static func workout(id: UUID) -> CatalogueWorkoutDefinition? {
        workoutsByID[id]
    }

    private static let workoutsBySemanticKey: [CatalogueSemanticKey: CatalogueWorkoutDefinition] = {
        Dictionary(uniqueKeysWithValues: allWorkouts.map { workout in
            (workout.semanticKey, workout)
        })
    }()

    private static let workoutsByID: [UUID: CatalogueWorkoutDefinition] = {
        Dictionary(uniqueKeysWithValues: allWorkouts.map { workout in
            (workout.id, workout)
        })
    }()

    private static let fullBodyBeginner = CatalogueWorkoutDefinition(
        id: UUID(uuidString: "D2D7F44F-EB53-4683-98D2-1D9D3959AAE4")!,
        semanticKey: CatalogueSemanticKey(rawValue: "workout.full_body_beginner")!,
        titleLocalizationKey: "catalogue.workout.full_body_beginner.title",
        descriptionLocalizationKey: "catalogue.workout.full_body_beginner.description",
        category: .strength,
        trainingGoal: .generalFitness,
        experienceLevel: .beginner,
        estimatedDuration: 45 * 60,
        exercises: [
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "98D17B30-E4E8-4B55-B73C-8D17B425D071")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!,
                targetSets: 3,
                targetReps: 12,
                restDuration: 60
            ),
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "F22FA757-3913-4765-A252-C57AF29CC014")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.push_up")!,
                targetSets: 3,
                targetReps: 10,
                restDuration: 60
            ),
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "81E33F34-BD69-4693-9509-5DCBC8A4C060")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!,
                targetSets: 3,
                targetReps: 12,
                restDuration: 60
            )
        ]
    )

    private static let pushDay = CatalogueWorkoutDefinition(
        id: UUID(uuidString: "BC901012-CC9A-4047-B35D-3696D8F48A7D")!,
        semanticKey: CatalogueSemanticKey(rawValue: "workout.push_day")!,
        titleLocalizationKey: "catalogue.workout.push_day.title",
        descriptionLocalizationKey: "catalogue.workout.push_day.description",
        category: .hypertrophy,
        trainingGoal: .muscleGain,
        experienceLevel: .beginner,
        estimatedDuration: 50 * 60,
        exercises: [
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "49C0266C-3668-4383-8516-5350E6E6B694")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.push_up")!,
                targetSets: 3,
                targetReps: 10,
                restDuration: 60
            )
        ]
    )

    private static let pullDay = CatalogueWorkoutDefinition(
        id: UUID(uuidString: "616B9297-2A26-47C3-B358-6DF016F808A0")!,
        semanticKey: CatalogueSemanticKey(rawValue: "workout.pull_day")!,
        titleLocalizationKey: "catalogue.workout.pull_day.title",
        descriptionLocalizationKey: "catalogue.workout.pull_day.description",
        category: .hypertrophy,
        trainingGoal: .muscleGain,
        experienceLevel: .beginner,
        estimatedDuration: 50 * 60,
        exercises: [
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "052C9D90-2320-4795-8703-B7179DBAE8E8")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!,
                targetSets: 3,
                targetReps: 12,
                restDuration: 60
            )
        ]
    )

    private static let legDay = CatalogueWorkoutDefinition(
        id: UUID(uuidString: "FC372E4A-80DA-4688-B8AC-9FC068973BDB")!,
        semanticKey: CatalogueSemanticKey(rawValue: "workout.leg_day")!,
        titleLocalizationKey: "catalogue.workout.leg_day.title",
        descriptionLocalizationKey: "catalogue.workout.leg_day.description",
        category: .strength,
        trainingGoal: .strength,
        experienceLevel: .beginner,
        estimatedDuration: 60 * 60,
        exercises: [
            CatalogueWorkoutExercise(
                id: UUID(uuidString: "B16529CF-42D1-4CD4-9611-7782341D504A")!,
                exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!,
                targetSets: 3,
                targetReps: 12,
                restDuration: 60
            )
        ]
    )
}
