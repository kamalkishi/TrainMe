import Foundation

@MainActor
enum CatalogueWorkoutRuntimeMapper {

    enum MappingError: Error, Equatable {
        case missingExerciseDefinition(CatalogueSemanticKey)
        case unresolvedDisplayString(String)
        case unsupportedWorkoutCategory(WorkoutCategory)
        case unsupportedExerciseMetadata(CatalogueSemanticKey)
        case invalidRestDuration(CatalogueSemanticKey, TimeInterval)
    }

    static func workouts(from definitions: [CatalogueWorkoutDefinition]) throws -> [Workout] {
        try definitions.map(workout(from:))
    }

    static func workout(from definition: CatalogueWorkoutDefinition) throws -> Workout {
        Workout(
            id: definition.id,
            name: try DisplayStringResolver.string(for: definition.titleLocalizationKey),
            type: try workoutType(from: definition.category),
            exercises: try definition.exercises.map(workoutExercise(from:)),
            estimatedDuration: definition.estimatedDuration,
            description: try DisplayStringResolver.string(for: definition.descriptionLocalizationKey)
        )
    }

    static func workoutExercise(from definition: CatalogueWorkoutExercise) throws -> WorkoutExercise {
        guard let exerciseDefinition = BuiltInExerciseCatalogue.definition(for: definition.exerciseSemanticKey) else {
            throw MappingError.missingExerciseDefinition(definition.exerciseSemanticKey)
        }

        guard definition.restDuration >= 0,
              definition.restDuration.rounded(.towardZero) == definition.restDuration,
              definition.restDuration <= TimeInterval(Int.max) else {
            throw MappingError.invalidRestDuration(definition.exerciseSemanticKey, definition.restDuration)
        }

        return WorkoutExercise(
            id: definition.id,
            exercise: try exercise(from: exerciseDefinition),
            targetSets: definition.targetSets,
            targetReps: definition.targetReps,
            restSeconds: Int(definition.restDuration)
        )
    }

    static func exercise(from definition: CatalogueExerciseDefinition) throws -> Exercise {
        Exercise(
            id: definition.id,
            name: try DisplayStringResolver.string(for: definition.titleLocalizationKey),
            muscleGroups: try muscleGroups(from: definition),
            workoutType: try exerciseWorkoutType(from: definition),
            requiresWeight: requiresWeight(from: definition.metadata),
            unilateral: isUnilateral(definition.metadata.laterality)
        )
    }

    private static func workoutType(from category: WorkoutCategory) throws -> WorkoutType {
        switch category {
        case .strength:
            .strength
        case .hypertrophy:
            .hypertrophy
        case .cardio:
            .cardio
        case .hiit:
            .hiit
        case .mobility:
            .mobility
        case .flexibility:
            .flexibility
        case .rehabilitation:
            .rehabilitation
        default:
            throw MappingError.unsupportedWorkoutCategory(category)
        }
    }

    private static func exerciseWorkoutType(from definition: CatalogueExerciseDefinition) throws -> WorkoutType {
        let metadata = definition.metadata

        switch metadata.primaryMovementFamily {
        case .squat, .hinge, .lunge, .horizontalPush, .verticalPush, .horizontalPull, .verticalPull, .carry:
            return .strength
        case .locomotion, .cyclicCardio:
            return .cardio
        case .mobility:
            return .mobility
        case .stretch:
            return .flexibility
        default:
            throw MappingError.unsupportedExerciseMetadata(definition.semanticKey)
        }
    }

    private static func muscleGroups(from definition: CatalogueExerciseDefinition) throws -> [MuscleGroup] {
        var mappedGroups: [MuscleGroup] = []

        let displayMuscles = definition.metadata.primaryMuscles + definition.metadata.secondaryMuscles.filter { muscle in
            muscle != .rectusAbdominis
        }

        for muscle in displayMuscles {
            for muscleGroup in muscleGroups(for: muscle) where !mappedGroups.contains(muscleGroup) {
                mappedGroups.append(muscleGroup)
            }
        }

        guard !mappedGroups.isEmpty else {
            throw MappingError.unsupportedExerciseMetadata(definition.semanticKey)
        }

        return mappedGroups
    }

    private static func muscleGroups(for muscle: Muscle) -> [MuscleGroup] {
        switch muscle {
        case .pectoralisMajor:
            [.chest]
        case .triceps:
            [.triceps]
        case .latissimusDorsi, .rhomboids, .trapezius:
            [.back]
        case .biceps:
            [.biceps]
        case .quadriceps:
            [.quadriceps]
        case .gluteusMaximus:
            [.glutes]
        case .rectusAbdominis:
            [.core]
        case .erectorSpinae:
            [.lowerBack]
        }
    }

    private static func requiresWeight(from metadata: ExerciseMetadata) -> Bool {
        metadata.requiredEquipment.contains { equipment in
            equipment != .bodyweight && equipment != .none
        }
    }

    private static func isUnilateral(_ laterality: Laterality) -> Bool {
        switch laterality {
        case .unilateral, .alternating, .independentBilateral:
            true
        case .bilateral, .notApplicable:
            false
        }
    }
}

private enum DisplayStringResolver {

    static func string(for localizationKey: String) throws -> String {
        switch localizationKey {
        case "catalogue.workout.full_body_beginner.title":
            "Full Body Beginner"
        case "catalogue.workout.full_body_beginner.description":
            "A balanced workout targeting all major muscle groups."
        case "catalogue.workout.push_day.title":
            "Push Day"
        case "catalogue.workout.push_day.description":
            "Focus on chest, shoulders and triceps."
        case "catalogue.workout.pull_day.title":
            "Pull Day"
        case "catalogue.workout.pull_day.description":
            "Train your back, biceps and rear shoulders."
        case "catalogue.workout.leg_day.title":
            "Leg Day"
        case "catalogue.workout.leg_day.description":
            "Build lower body strength and stability."
        case "catalogue.exercise.goblet_squat.title":
            "Goblet Squat"
        case "catalogue.exercise.push_up.title":
            "Push-up"
        case "catalogue.exercise.bent_over_row.title":
            "Bent-over Row"
        default:
            throw CatalogueWorkoutRuntimeMapper.MappingError.unresolvedDisplayString(localizationKey)
        }
    }
}
