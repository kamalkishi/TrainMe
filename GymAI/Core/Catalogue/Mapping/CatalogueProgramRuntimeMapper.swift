import Foundation

@MainActor
enum CatalogueProgramRuntimeMapper {

    enum MappingError: Error, Equatable {
        case missingWorkoutDefinition(CatalogueSemanticKey)
        case unresolvedDisplayString(String)
    }

    static func programs(from definitions: [CatalogueProgramDefinition]) throws -> [RuntimeProgram] {
        try definitions.map(program(from:))
    }

    static func program(from definition: CatalogueProgramDefinition) throws -> RuntimeProgram {
        RuntimeProgram(
            id: definition.id,
            name: try ProgramDisplayStringResolver.string(for: definition.titleLocalizationKey),
            description: try ProgramDisplayStringResolver.string(for: definition.descriptionLocalizationKey),
            trainingGoal: definition.trainingGoal,
            experienceLevel: definition.experienceLevel,
            durationInWeeks: definition.durationInWeeks,
            recommendedSessionsPerWeek: definition.recommendedSessionsPerWeek,
            estimatedWeeklyDuration: definition.estimatedWeeklyDuration,
            scheduleEntries: try definition.scheduleEntries.map(scheduleEntry(from:))
        )
    }

    static func scheduleEntry(from definition: CatalogueProgramScheduleEntry) throws -> RuntimeProgramScheduleEntry {
        guard let workoutDefinition = BuiltInWorkoutCatalogue.workout(for: definition.workoutSemanticKey) else {
            throw MappingError.missingWorkoutDefinition(definition.workoutSemanticKey)
        }

        return RuntimeProgramScheduleEntry(
            id: definition.id,
            weekNumber: definition.weekNumber,
            dayNumber: definition.dayNumber,
            sequenceNumber: definition.sequenceNumber,
            status: definition.status,
            workout: try CatalogueWorkoutRuntimeMapper.workout(from: workoutDefinition),
            notes: try definition.notesLocalizationKey.map(ProgramDisplayStringResolver.string(for:))
        )
    }
}

private enum ProgramDisplayStringResolver {

    static func string(for localizationKey: String) throws -> String {
        switch localizationKey {
        case "catalogue.program.beginner_strength_foundation.title":
            "Beginner Strength Foundation"
        case "catalogue.program.beginner_strength_foundation.description":
            "Build foundational strength with four beginner workouts."
        default:
            throw CatalogueProgramRuntimeMapper.MappingError.unresolvedDisplayString(localizationKey)
        }
    }
}
