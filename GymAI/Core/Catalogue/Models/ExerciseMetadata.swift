import Foundation

struct CatalogueExerciseDefinition: Identifiable, Codable, Hashable, Sendable {

    let id: UUID
    let semanticKey: CatalogueSemanticKey
    let titleLocalizationKey: String
    let metadata: ExerciseMetadata
    let source: CatalogueSource
    let ownership: CatalogueOwnership
    let publicationStatus: PublicationStatus
    let schemaVersion: Int
    let contentRevision: Int

    init(
        id: UUID,
        semanticKey: CatalogueSemanticKey,
        titleLocalizationKey: String,
        metadata: ExerciseMetadata,
        source: CatalogueSource = .builtIn,
        ownership: CatalogueOwnership = .gymAI,
        publicationStatus: PublicationStatus = .published,
        schemaVersion: Int = 1,
        contentRevision: Int = 1
    ) {
        self.id = id
        self.semanticKey = semanticKey
        self.titleLocalizationKey = titleLocalizationKey
        self.metadata = metadata
        self.source = source
        self.ownership = ownership
        self.publicationStatus = publicationStatus
        self.schemaVersion = schemaVersion
        self.contentRevision = contentRevision
    }
}

struct ExerciseMetadata: Codable, Hashable, Sendable {

    let primaryMovementFamily: MovementFamily
    let primaryMovementPattern: MovementPattern
    let secondaryMovementPatterns: [MovementPattern]
    let bodyRegions: [BodyRegion]
    let primaryMuscles: [Muscle]
    let secondaryMuscles: [Muscle]
    let stabilizerMuscles: [Muscle]
    let requiredEquipment: [Equipment]
    let optionalEquipment: [Equipment]
    let mechanics: ExerciseMechanics
    let forceType: ForceType
    let movementPlane: MovementPlane
    let kineticChain: KineticChain
    let bodyPosition: BodyPosition
    let laterality: Laterality
    let difficulty: ExerciseDifficulty
    let technicalDemand: DemandLevel
    let mobilityDemand: DemandLevel
    let balanceDemand: DemandLevel
    let supportedMeasurements: [MeasurementType]
    let aiCapability: AICapabilityState
    let aliasLocalizationKeys: [String]

    init(
        primaryMovementFamily: MovementFamily,
        primaryMovementPattern: MovementPattern,
        secondaryMovementPatterns: [MovementPattern] = [],
        bodyRegions: [BodyRegion],
        primaryMuscles: [Muscle],
        secondaryMuscles: [Muscle] = [],
        stabilizerMuscles: [Muscle] = [],
        requiredEquipment: [Equipment],
        optionalEquipment: [Equipment] = [],
        mechanics: ExerciseMechanics,
        forceType: ForceType,
        movementPlane: MovementPlane,
        kineticChain: KineticChain,
        bodyPosition: BodyPosition,
        laterality: Laterality,
        difficulty: ExerciseDifficulty,
        technicalDemand: DemandLevel,
        mobilityDemand: DemandLevel,
        balanceDemand: DemandLevel,
        supportedMeasurements: [MeasurementType],
        aiCapability: AICapabilityState = .planned,
        aliasLocalizationKeys: [String] = []
    ) {
        self.primaryMovementFamily = primaryMovementFamily
        self.primaryMovementPattern = primaryMovementPattern
        self.secondaryMovementPatterns = secondaryMovementPatterns
        self.bodyRegions = bodyRegions
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.stabilizerMuscles = stabilizerMuscles
        self.requiredEquipment = requiredEquipment
        self.optionalEquipment = optionalEquipment
        self.mechanics = mechanics
        self.forceType = forceType
        self.movementPlane = movementPlane
        self.kineticChain = kineticChain
        self.bodyPosition = bodyPosition
        self.laterality = laterality
        self.difficulty = difficulty
        self.technicalDemand = technicalDemand
        self.mobilityDemand = mobilityDemand
        self.balanceDemand = balanceDemand
        self.supportedMeasurements = supportedMeasurements
        self.aiCapability = aiCapability
        self.aliasLocalizationKeys = aliasLocalizationKeys
    }
}

enum Muscle: String, CaseIterable, Codable, Hashable, Sendable {
    case pectoralisMajor
    case triceps
    case latissimusDorsi
    case biceps
    case quadriceps
    case gluteusMaximus
    case rhomboids
    case trapezius
    case erectorSpinae
    case rectusAbdominis
}
