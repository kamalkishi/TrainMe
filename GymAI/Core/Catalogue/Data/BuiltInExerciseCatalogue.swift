import Foundation

enum BuiltInExerciseCatalogue {

    static let definitions: [CatalogueExerciseDefinition] = [
        gobletSquat,
        pushUp,
        bentOverRow
    ]

    static func definition(for semanticKey: CatalogueSemanticKey) -> CatalogueExerciseDefinition? {
        definitionsBySemanticKey[semanticKey]
    }

    private static let definitionsBySemanticKey: [CatalogueSemanticKey: CatalogueExerciseDefinition] = {
        Dictionary(uniqueKeysWithValues: definitions.map { definition in
            (definition.semanticKey, definition)
        })
    }()

    private static let gobletSquat = CatalogueExerciseDefinition(
        id: UUID(uuidString: "4B9A24F4-6F7B-4BB7-B36A-0641F11E1F15")!,
        semanticKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!,
        titleLocalizationKey: "catalogue.exercise.goblet_squat.title",
        metadata: ExerciseMetadata(
            primaryMovementFamily: .squat,
            primaryMovementPattern: .bilateralSquat,
            bodyRegions: [.lowerBody, .glutes, .thighs, .core],
            primaryMuscles: [.quadriceps, .gluteusMaximus],
            secondaryMuscles: [.rectusAbdominis],
            stabilizerMuscles: [.erectorSpinae],
            requiredEquipment: [.kettlebell],
            optionalEquipment: [.dumbbell],
            mechanics: .compound,
            forceType: .push,
            movementPlane: .sagittal,
            kineticChain: .closedChain,
            bodyPosition: .standing,
            laterality: .bilateral,
            difficulty: .beginner,
            technicalDemand: .moderate,
            mobilityDemand: .moderate,
            balanceDemand: .low,
            supportedMeasurements: [.repetitions, .load],
            aiCapability: .planned,
            aliasLocalizationKeys: [
                "catalogue.exercise.goblet_squat.alias.kettlebell_squat"
            ]
        )
    )

    private static let pushUp = CatalogueExerciseDefinition(
        id: UUID(uuidString: "E0E7B04D-76E5-49A3-B9D3-091EF9369E2A")!,
        semanticKey: CatalogueSemanticKey(rawValue: "exercise.push_up")!,
        titleLocalizationKey: "catalogue.exercise.push_up.title",
        metadata: ExerciseMetadata(
            primaryMovementFamily: .horizontalPush,
            primaryMovementPattern: .pushUp,
            bodyRegions: [.upperBody, .chest, .arms, .core],
            primaryMuscles: [.pectoralisMajor, .triceps],
            secondaryMuscles: [.rectusAbdominis],
            requiredEquipment: [.bodyweight],
            mechanics: .compound,
            forceType: .push,
            movementPlane: .sagittal,
            kineticChain: .closedChain,
            bodyPosition: .prone,
            laterality: .bilateral,
            difficulty: .beginner,
            technicalDemand: .moderate,
            mobilityDemand: .low,
            balanceDemand: .moderate,
            supportedMeasurements: [.repetitions],
            aiCapability: .planned,
            aliasLocalizationKeys: [
                "catalogue.exercise.push_up.alias.press_up"
            ]
        )
    )

    private static let bentOverRow = CatalogueExerciseDefinition(
        id: UUID(uuidString: "C59D28F6-A362-481A-8E55-9B8AF0B0D830")!,
        semanticKey: CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!,
        titleLocalizationKey: "catalogue.exercise.bent_over_row.title",
        metadata: ExerciseMetadata(
            primaryMovementFamily: .horizontalPull,
            primaryMovementPattern: .row,
            bodyRegions: [.upperBody, .back, .arms],
            primaryMuscles: [.latissimusDorsi, .rhomboids, .trapezius],
            secondaryMuscles: [.biceps],
            stabilizerMuscles: [.erectorSpinae],
            requiredEquipment: [.dumbbell],
            optionalEquipment: [.barbell, .kettlebell],
            mechanics: .compound,
            forceType: .pull,
            movementPlane: .sagittal,
            kineticChain: .openChain,
            bodyPosition: .standing,
            laterality: .bilateral,
            difficulty: .beginner,
            technicalDemand: .moderate,
            mobilityDemand: .moderate,
            balanceDemand: .moderate,
            supportedMeasurements: [.repetitions, .load],
            aiCapability: .planned,
            aliasLocalizationKeys: [
                "catalogue.exercise.bent_over_row.alias.dumbbell_row"
            ]
        )
    )
}
