import Foundation

struct CatalogueWorkoutDefinition: Identifiable, Codable, Hashable, Sendable {

    let id: UUID
    let semanticKey: CatalogueSemanticKey
    let titleLocalizationKey: String
    let descriptionLocalizationKey: String
    let category: WorkoutCategory
    let trainingGoal: TrainingGoal
    let experienceLevel: ExperienceLevel
    let estimatedDuration: TimeInterval
    let exercises: [CatalogueWorkoutExercise]
    let source: CatalogueSource
    let ownership: CatalogueOwnership
    let publicationStatus: PublicationStatus
    let schemaVersion: Int
    let contentRevision: Int

    init(
        id: UUID,
        semanticKey: CatalogueSemanticKey,
        titleLocalizationKey: String,
        descriptionLocalizationKey: String,
        category: WorkoutCategory,
        trainingGoal: TrainingGoal,
        experienceLevel: ExperienceLevel,
        estimatedDuration: TimeInterval,
        exercises: [CatalogueWorkoutExercise] = [],
        source: CatalogueSource = .builtIn,
        ownership: CatalogueOwnership = .gymAI,
        publicationStatus: PublicationStatus = .published,
        schemaVersion: Int = 1,
        contentRevision: Int = 1
    ) {
        self.id = id
        self.semanticKey = semanticKey
        self.titleLocalizationKey = titleLocalizationKey
        self.descriptionLocalizationKey = descriptionLocalizationKey
        self.category = category
        self.trainingGoal = trainingGoal
        self.experienceLevel = experienceLevel
        self.estimatedDuration = estimatedDuration
        self.exercises = exercises
        self.source = source
        self.ownership = ownership
        self.publicationStatus = publicationStatus
        self.schemaVersion = schemaVersion
        self.contentRevision = contentRevision
    }
}

struct CatalogueWorkoutExercise: Identifiable, Codable, Hashable, Sendable {

    let id: UUID
    let exerciseSemanticKey: CatalogueSemanticKey
    let targetSets: Int
    let targetReps: Int
    let restDuration: TimeInterval
    let notesLocalizationKey: String?

    init(
        id: UUID,
        exerciseSemanticKey: CatalogueSemanticKey,
        targetSets: Int,
        targetReps: Int,
        restDuration: TimeInterval,
        notesLocalizationKey: String? = nil
    ) {
        self.id = id
        self.exerciseSemanticKey = exerciseSemanticKey
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.restDuration = restDuration
        self.notesLocalizationKey = notesLocalizationKey
    }
}
