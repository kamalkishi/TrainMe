import Foundation

struct CatalogueProgramDefinition: Identifiable, Codable, Hashable, Sendable {

    let id: UUID
    let semanticKey: CatalogueSemanticKey
    let titleLocalizationKey: String
    let descriptionLocalizationKey: String
    let trainingGoal: TrainingGoal
    let experienceLevel: ExperienceLevel
    let durationInWeeks: Int
    let recommendedSessionsPerWeek: Int
    let estimatedWeeklyDuration: TimeInterval
    let scheduleEntries: [CatalogueProgramScheduleEntry]
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
        trainingGoal: TrainingGoal,
        experienceLevel: ExperienceLevel,
        durationInWeeks: Int,
        recommendedSessionsPerWeek: Int,
        estimatedWeeklyDuration: TimeInterval,
        scheduleEntries: [CatalogueProgramScheduleEntry],
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
        self.trainingGoal = trainingGoal
        self.experienceLevel = experienceLevel
        self.durationInWeeks = durationInWeeks
        self.recommendedSessionsPerWeek = recommendedSessionsPerWeek
        self.estimatedWeeklyDuration = estimatedWeeklyDuration
        self.scheduleEntries = scheduleEntries
        self.source = source
        self.ownership = ownership
        self.publicationStatus = publicationStatus
        self.schemaVersion = schemaVersion
        self.contentRevision = contentRevision
    }
}

struct CatalogueProgramScheduleEntry: Identifiable, Codable, Hashable, Sendable {

    let id: UUID
    let workoutSemanticKey: CatalogueSemanticKey
    let weekNumber: Int
    let dayNumber: Int
    let sequenceNumber: Int
    let status: ProgramScheduleEntryStatus
    let notesLocalizationKey: String?

    init(
        id: UUID,
        workoutSemanticKey: CatalogueSemanticKey,
        weekNumber: Int,
        dayNumber: Int,
        sequenceNumber: Int,
        status: ProgramScheduleEntryStatus,
        notesLocalizationKey: String? = nil
    ) {
        self.id = id
        self.workoutSemanticKey = workoutSemanticKey
        self.weekNumber = weekNumber
        self.dayNumber = dayNumber
        self.sequenceNumber = sequenceNumber
        self.status = status
        self.notesLocalizationKey = notesLocalizationKey
    }
}

enum ProgramScheduleEntryStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case required
    case recommended
    case optional
}
