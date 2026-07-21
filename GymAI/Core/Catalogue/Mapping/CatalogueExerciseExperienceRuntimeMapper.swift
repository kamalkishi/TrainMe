import Foundation

enum CatalogueExerciseExperienceRuntimeMapper {
    enum MappingError: Error, Equatable {
        case duplicateExperienceContent(CatalogueSemanticKey)
        case missingExerciseDefinition(CatalogueSemanticKey)
        case missingExerciseExperienceContent(CatalogueSemanticKey)
        case mismatchedExerciseContent(expected: CatalogueSemanticKey, actual: CatalogueSemanticKey)
        case invalidInstructionOrdering(CatalogueSemanticKey)
        case invalidMediaReference(exerciseSemanticKey: CatalogueSemanticKey, resourceKey: CatalogueSemanticKey)
        case unresolvedContentKey(String)
    }

    static func experiences(from contents: [ExerciseExperienceContent] = BuiltInExerciseExperienceCatalogue.definitions) throws -> [ExerciseExperience] {
        var seenSemanticKeys: Set<CatalogueSemanticKey> = []
        for content in contents {
            guard seenSemanticKeys.insert(content.exerciseSemanticKey).inserted else {
                throw MappingError.duplicateExperienceContent(content.exerciseSemanticKey)
            }
        }

        return try contents.map { content in
            try experience(from: content)
        }
    }

    static func experience(for semanticKey: CatalogueSemanticKey) throws -> ExerciseExperience {
        guard let content = BuiltInExerciseExperienceCatalogue.definition(for: semanticKey) else {
            throw MappingError.missingExerciseExperienceContent(semanticKey)
        }

        return try experience(from: content)
    }

    static func experience(from definition: CatalogueExerciseDefinition) throws -> ExerciseExperience {
        guard let content = BuiltInExerciseExperienceCatalogue.definition(for: definition.semanticKey) else {
            throw MappingError.missingExerciseExperienceContent(definition.semanticKey)
        }

        return try experience(from: definition, content: content)
    }

    static func experience(from content: ExerciseExperienceContent) throws -> ExerciseExperience {
        guard let definition = BuiltInExerciseCatalogue.definition(for: content.exerciseSemanticKey) else {
            throw MappingError.missingExerciseDefinition(content.exerciseSemanticKey)
        }

        return try experience(from: definition, content: content)
    }

    static func experience(
        from definition: CatalogueExerciseDefinition,
        content: ExerciseExperienceContent
    ) throws -> ExerciseExperience {
        guard definition.semanticKey == content.exerciseSemanticKey else {
            throw MappingError.mismatchedExerciseContent(
                expected: definition.semanticKey,
                actual: content.exerciseSemanticKey
            )
        }

        try validateInstructionOrdering(content)
        try validateMediaReferences(content)

        let runtimeExercise = try CatalogueWorkoutRuntimeMapper.exercise(from: definition)
        let metadata = definition.metadata
        let movementPatterns = [metadata.primaryMovementPattern] + metadata.secondaryMovementPatterns

        return ExerciseExperience(
            id: definition.id,
            semanticKey: definition.semanticKey,
            name: runtimeExercise.name,
            description: try resolve(content.descriptionLocalizationKey),
            primaryMuscles: metadata.primaryMuscles,
            secondaryMuscles: metadata.secondaryMuscles,
            stabilizerMuscles: metadata.stabilizerMuscles,
            requiredEquipment: metadata.requiredEquipment,
            optionalEquipment: metadata.optionalEquipment,
            difficulty: metadata.difficulty,
            movementFamily: metadata.primaryMovementFamily,
            movementPatterns: movementPatterns,
            mechanics: metadata.mechanics,
            laterality: metadata.laterality,
            bodyPosition: metadata.bodyPosition,
            instructionSteps: try content.instructionSteps.map { step in
                ExerciseExperienceInstructionStep(
                    id: step.id,
                    text: try resolve(step.textLocalizationKey),
                    sequenceNumber: step.sequenceNumber
                )
            },
            tips: try content.tipLocalizationKeys.map { try resolve($0) },
            commonMistakes: try content.commonMistakeLocalizationKeys.map { try resolve($0) },
            safetyNotes: try content.safetyNoteLocalizationKeys.map { try resolve($0) },
            mediaReferences: try content.mediaReferences.map { reference in
                ExerciseExperienceMediaReference(
                    id: reference.id,
                    kind: reference.kind,
                    resourceKey: reference.resourceKey,
                    accessibilityLabel: try resolve(reference.accessibilityLabelLocalizationKey),
                    posterResourceKey: reference.posterResourceKey
                )
            }
        )
    }
}

private extension CatalogueExerciseExperienceRuntimeMapper {
    static func validateInstructionOrdering(_ content: ExerciseExperienceContent) throws {
        guard !content.instructionSteps.isEmpty else {
            throw MappingError.invalidInstructionOrdering(content.exerciseSemanticKey)
        }

        let sequenceNumbers = content.instructionSteps.map(\.sequenceNumber)
        guard sequenceNumbers == sequenceNumbers.sorted(),
              Set(sequenceNumbers).count == sequenceNumbers.count,
              sequenceNumbers.allSatisfy({ $0 > 0 }) else {
            throw MappingError.invalidInstructionOrdering(content.exerciseSemanticKey)
        }
    }

    static func validateMediaReferences(_ content: ExerciseExperienceContent) throws {
        for reference in content.mediaReferences {
            guard reference.resourceKey.rawValue.hasPrefix("\(content.exerciseSemanticKey.rawValue).demo.") else {
                throw MappingError.invalidMediaReference(
                    exerciseSemanticKey: content.exerciseSemanticKey,
                    resourceKey: reference.resourceKey
                )
            }
        }
    }

    static func resolve(_ key: String) throws -> String {
        guard let value = contentStrings[key] else {
            throw MappingError.unresolvedContentKey(key)
        }

        return value
    }

    static let contentStrings: [String: String] = [
        "catalogue.exercise.goblet_squat.description": "A beginner lower-body strength exercise using a weight held close to the chest to train squatting mechanics, legs and glutes.",
        "catalogue.exercise.goblet_squat.instruction.1": "Hold the weight close to your chest with elbows pointed down.",
        "catalogue.exercise.goblet_squat.instruction.2": "Stand with feet about shoulder-width apart and toes slightly turned out.",
        "catalogue.exercise.goblet_squat.instruction.3": "Brace your torso, sit down under control and keep your knees tracking over your toes.",
        "catalogue.exercise.goblet_squat.instruction.4": "Stand by pressing through your whole foot while keeping your chest tall.",
        "catalogue.exercise.goblet_squat.tip.1": "Keep the weight close so your upper back stays engaged.",
        "catalogue.exercise.goblet_squat.tip.2": "Move slowly enough to feel balance through your midfoot and heel.",
        "catalogue.exercise.goblet_squat.tip.3": "Use a depth you can control without losing your brace.",
        "catalogue.exercise.goblet_squat.mistake.1": "Letting the lower back round at the bottom.",
        "catalogue.exercise.goblet_squat.mistake.2": "Allowing the knees to collapse inward.",
        "catalogue.exercise.goblet_squat.mistake.3": "Rising onto the toes as you stand.",
        "catalogue.exercise.goblet_squat.safety.1": "Choose a load you can control for every rep.",
        "catalogue.exercise.goblet_squat.safety.2": "Stop the set if pain changes your squat mechanics.",
        "catalogue.exercise.goblet_squat.media.primary.accessibility_label": "Goblet squat demonstration",

        "catalogue.exercise.push_up.description": "A bodyweight upper-body exercise that trains pressing strength while requiring a stable trunk position.",
        "catalogue.exercise.push_up.instruction.1": "Place your hands slightly wider than shoulder width with fingers spread.",
        "catalogue.exercise.push_up.instruction.2": "Step back into a straight line from head to heels and brace your torso.",
        "catalogue.exercise.push_up.instruction.3": "Lower under control with elbows angled back rather than straight out.",
        "catalogue.exercise.push_up.instruction.4": "Press through the floor until your arms are straight without losing body alignment.",
        "catalogue.exercise.push_up.tip.1": "Think about moving your chest and hips together.",
        "catalogue.exercise.push_up.tip.2": "Use an elevated surface if the floor version breaks your position.",
        "catalogue.exercise.push_up.tip.3": "Keep your neck neutral and eyes slightly ahead of your hands.",
        "catalogue.exercise.push_up.mistake.1": "Letting the hips sag toward the floor.",
        "catalogue.exercise.push_up.mistake.2": "Flaring the elbows straight out to the sides.",
        "catalogue.exercise.push_up.mistake.3": "Cutting the range short before the chest lowers under control.",
        "catalogue.exercise.push_up.safety.1": "Use a regression that lets you keep a straight body line.",
        "catalogue.exercise.push_up.safety.2": "Stop if wrist, shoulder or elbow discomfort changes your form.",
        "catalogue.exercise.push_up.media.primary.accessibility_label": "Push-up demonstration",

        "catalogue.exercise.bent_over_row.description": "A hip-hinged pulling exercise that trains the upper back while challenging trunk position.",
        "catalogue.exercise.bent_over_row.instruction.1": "Hinge at the hips with a neutral spine and a soft bend in the knees.",
        "catalogue.exercise.bent_over_row.instruction.2": "Brace your torso and let the weights hang under your shoulders.",
        "catalogue.exercise.bent_over_row.instruction.3": "Pull toward your lower ribs while keeping your shoulders away from your ears.",
        "catalogue.exercise.bent_over_row.instruction.4": "Lower the weight under control until your arms are straight.",
        "catalogue.exercise.bent_over_row.tip.1": "Keep the torso angle steady throughout the set.",
        "catalogue.exercise.bent_over_row.tip.2": "Lead the pull with your elbows rather than your hands.",
        "catalogue.exercise.bent_over_row.tip.3": "Pause briefly at the top if you can do so without shrugging.",
        "catalogue.exercise.bent_over_row.mistake.1": "Using torso momentum to start each rep.",
        "catalogue.exercise.bent_over_row.mistake.2": "Rounding the spine as the weight lowers.",
        "catalogue.exercise.bent_over_row.mistake.3": "Shrugging the shoulders instead of pulling the elbows back.",
        "catalogue.exercise.bent_over_row.safety.1": "Use a load that lets your back position stay consistent.",
        "catalogue.exercise.bent_over_row.safety.2": "Stop or reduce the load if back discomfort changes your hinge.",
        "catalogue.exercise.bent_over_row.media.primary.accessibility_label": "Bent-over row demonstration"
    ]
}
