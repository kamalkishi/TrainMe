import Foundation

struct RuntimeProgram: Identifiable, Hashable {

    let id: UUID
    let name: String
    let description: String
    let trainingGoal: TrainingGoal
    let experienceLevel: ExperienceLevel
    let durationInWeeks: Int
    let recommendedSessionsPerWeek: Int
    let estimatedWeeklyDuration: TimeInterval
    let scheduleEntries: [RuntimeProgramScheduleEntry]

    init(
        id: UUID,
        name: String,
        description: String,
        trainingGoal: TrainingGoal,
        experienceLevel: ExperienceLevel,
        durationInWeeks: Int,
        recommendedSessionsPerWeek: Int,
        estimatedWeeklyDuration: TimeInterval,
        scheduleEntries: [RuntimeProgramScheduleEntry]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.trainingGoal = trainingGoal
        self.experienceLevel = experienceLevel
        self.durationInWeeks = durationInWeeks
        self.recommendedSessionsPerWeek = recommendedSessionsPerWeek
        self.estimatedWeeklyDuration = estimatedWeeklyDuration
        self.scheduleEntries = scheduleEntries
    }
}

struct RuntimeProgramScheduleEntry: Identifiable, Hashable {

    let id: UUID
    let weekNumber: Int
    let dayNumber: Int
    let sequenceNumber: Int
    let status: ProgramScheduleEntryStatus
    let workout: Workout
    let notes: String?

    init(
        id: UUID,
        weekNumber: Int,
        dayNumber: Int,
        sequenceNumber: Int,
        status: ProgramScheduleEntryStatus,
        workout: Workout,
        notes: String? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.dayNumber = dayNumber
        self.sequenceNumber = sequenceNumber
        self.status = status
        self.workout = workout
        self.notes = notes
    }
}
