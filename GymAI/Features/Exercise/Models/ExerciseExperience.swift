import Foundation

struct ExerciseExperience: Identifiable, Hashable, Sendable {
    let id: UUID
    let semanticKey: CatalogueSemanticKey
    let name: String
    let description: String
    let primaryMuscles: [Muscle]
    let secondaryMuscles: [Muscle]
    let stabilizerMuscles: [Muscle]
    let requiredEquipment: [Equipment]
    let optionalEquipment: [Equipment]
    let difficulty: ExerciseDifficulty
    let movementFamily: MovementFamily
    let movementPatterns: [MovementPattern]
    let mechanics: ExerciseMechanics
    let laterality: Laterality
    let bodyPosition: BodyPosition
    let instructionSteps: [ExerciseExperienceInstructionStep]
    let tips: [String]
    let commonMistakes: [String]
    let safetyNotes: [String]
    let mediaReferences: [ExerciseExperienceMediaReference]
}

struct ExerciseExperienceInstructionStep: Identifiable, Hashable, Sendable {
    let id: UUID
    let text: String
    let sequenceNumber: Int
}

struct ExerciseExperienceMediaReference: Identifiable, Hashable, Sendable {
    let id: UUID
    let kind: ExerciseMediaKind
    let resourceKey: CatalogueSemanticKey
    let accessibilityLabel: String
    let posterResourceKey: CatalogueSemanticKey?
}
