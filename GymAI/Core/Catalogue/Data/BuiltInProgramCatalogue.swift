import Foundation

enum BuiltInProgramCatalogue {

    static let allPrograms: [CatalogueProgramDefinition] = [
        beginnerStrengthFoundation
    ]

    static func program(for semanticKey: CatalogueSemanticKey) -> CatalogueProgramDefinition? {
        programsBySemanticKey[semanticKey]
    }

    static func program(id: UUID) -> CatalogueProgramDefinition? {
        programsByID[id]
    }

    private static let programsBySemanticKey: [CatalogueSemanticKey: CatalogueProgramDefinition] = {
        Dictionary(uniqueKeysWithValues: allPrograms.map { program in
            (program.semanticKey, program)
        })
    }()

    private static let programsByID: [UUID: CatalogueProgramDefinition] = {
        Dictionary(uniqueKeysWithValues: allPrograms.map { program in
            (program.id, program)
        })
    }()

    private static let beginnerStrengthFoundation = CatalogueProgramDefinition(
        id: UUID(uuidString: "0D3B4087-D6E5-492F-97E9-F9C8BD9195F4")!,
        semanticKey: CatalogueSemanticKey(rawValue: "program.beginner_strength_foundation")!,
        titleLocalizationKey: "catalogue.program.beginner_strength_foundation.title",
        descriptionLocalizationKey: "catalogue.program.beginner_strength_foundation.description",
        trainingGoal: .strength,
        experienceLevel: .beginner,
        durationInWeeks: 1,
        recommendedSessionsPerWeek: 4,
        estimatedWeeklyDuration: 205 * 60,
        scheduleEntries: [
            CatalogueProgramScheduleEntry(
                id: UUID(uuidString: "2B407D66-0889-4E21-AB76-BD30940C708B")!,
                workoutSemanticKey: CatalogueSemanticKey(rawValue: "workout.full_body_beginner")!,
                weekNumber: 1,
                dayNumber: 1,
                sequenceNumber: 1,
                status: .required
            ),
            CatalogueProgramScheduleEntry(
                id: UUID(uuidString: "6A8AC894-729F-44A5-9270-4FC72FC0D3CB")!,
                workoutSemanticKey: CatalogueSemanticKey(rawValue: "workout.push_day")!,
                weekNumber: 1,
                dayNumber: 3,
                sequenceNumber: 2,
                status: .required
            ),
            CatalogueProgramScheduleEntry(
                id: UUID(uuidString: "D53344C1-37BD-4E25-8731-8D1BC0500CC8")!,
                workoutSemanticKey: CatalogueSemanticKey(rawValue: "workout.pull_day")!,
                weekNumber: 1,
                dayNumber: 5,
                sequenceNumber: 3,
                status: .required
            ),
            CatalogueProgramScheduleEntry(
                id: UUID(uuidString: "E4326817-BD91-4A42-B8F2-F549E487B694")!,
                workoutSemanticKey: CatalogueSemanticKey(rawValue: "workout.leg_day")!,
                weekNumber: 1,
                dayNumber: 7,
                sequenceNumber: 4,
                status: .recommended
            )
        ]
    )
}
