import Foundation

struct ExerciseExperienceContent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let exerciseSemanticKey: CatalogueSemanticKey
    let descriptionLocalizationKey: String
    let instructionSteps: [ExerciseInstructionStep]
    let tipLocalizationKeys: [String]
    let commonMistakeLocalizationKeys: [String]
    let safetyNoteLocalizationKeys: [String]
    let mediaReferences: [ExerciseMediaReference]
}

struct ExerciseInstructionStep: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let textLocalizationKey: String
    let sequenceNumber: Int
}

struct ExerciseMediaReference: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let kind: ExerciseMediaKind
    let resourceKey: CatalogueSemanticKey
    let accessibilityLabelLocalizationKey: String
    let posterResourceKey: CatalogueSemanticKey?
}

enum ExerciseMediaKind: String, CaseIterable, Codable, Hashable, Sendable {
    case image
    case animatedImage = "animated_image"
    case video
}
