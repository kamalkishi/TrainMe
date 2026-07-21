import Foundation
import Testing
@testable import GymAI

@MainActor
struct CatalogueProgramRuntimeMapperTests {

    @Test func everyBuiltInProgramMapsSuccessfully() throws {
        let programs = try CatalogueProgramRuntimeMapper.programs(from: BuiltInProgramCatalogue.allPrograms)

        #expect(programs.count == BuiltInProgramCatalogue.allPrograms.count)
    }

    @Test func builtInProgramFieldsMapToRuntimeProgramFields() throws {
        let definition = try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey))
        let program = try CatalogueProgramRuntimeMapper.program(from: definition)

        #expect(program.id == definition.id)
        #expect(program.name == "Beginner Strength Foundation")
        #expect(program.description == "Build foundational strength with four beginner workouts.")
        #expect(program.trainingGoal == .strength)
        #expect(program.experienceLevel == .beginner)
        #expect(program.durationInWeeks == 1)
        #expect(program.recommendedSessionsPerWeek == 4)
        #expect(program.estimatedWeeklyDuration == 205 * 60)
    }

    @Test func builtInProgramScheduleMapsAllCatalogueEntriesInOrder() throws {
        let definition = try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey))
        let program = try CatalogueProgramRuntimeMapper.program(from: definition)

        #expect(program.scheduleEntries.count == 4)
        #expect(program.scheduleEntries.map(\.id) == definition.scheduleEntries.map(\.id))
        #expect(program.scheduleEntries.map(\.weekNumber) == [1, 1, 1, 1])
        #expect(program.scheduleEntries.map(\.dayNumber) == [1, 3, 5, 7])
        #expect(program.scheduleEntries.map(\.sequenceNumber) == [1, 2, 3, 4])
        #expect(program.scheduleEntries.map(\.status) == [.required, .required, .required, .recommended])
    }

    @Test func scheduleEntriesResolveExpectedCatalogueWorkouts() throws {
        let program = try CatalogueProgramRuntimeMapper.program(from: try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey)))
        let expectedWorkoutKeys = [
            Self.fullBodyBeginnerKey,
            Self.pushDayKey,
            Self.pullDayKey,
            Self.legDayKey
        ]
        let expectedWorkoutDefinitions = try expectedWorkoutKeys.map { key in
            try #require(BuiltInWorkoutCatalogue.workout(for: key))
        }

        #expect(program.scheduleEntries.map { $0.workout.id } == expectedWorkoutDefinitions.map(\.id))
        #expect(program.scheduleEntries.map { $0.workout.name } == [
            "Full Body Beginner",
            "Push Day",
            "Pull Day",
            "Leg Day"
        ])
    }

    @Test func resolvedRuntimeWorkoutsMatchDirectWorkoutMapperOutput() throws {
        let program = try CatalogueProgramRuntimeMapper.program(from: try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey)))
        let directlyMappedWorkouts = try [
            Self.fullBodyBeginnerKey,
            Self.pushDayKey,
            Self.pullDayKey,
            Self.legDayKey
        ].map { key in
            try CatalogueWorkoutRuntimeMapper.workout(from: try #require(BuiltInWorkoutCatalogue.workout(for: key)))
        }

        #expect(program.scheduleEntries.map(\.workout) == directlyMappedWorkouts)
    }

    @Test func repeatedProgramMappingProducesEquivalentDeterministicOutput() throws {
        let definition = try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey))
        let firstProgram = try CatalogueProgramRuntimeMapper.program(from: definition)
        let secondProgram = try CatalogueProgramRuntimeMapper.program(from: definition)

        #expect(firstProgram == secondProgram)
        #expect(firstProgram.scheduleEntries.map(\.id) == secondProgram.scheduleEntries.map(\.id))
        #expect(firstProgram.scheduleEntries.map { $0.workout.id } == secondProgram.scheduleEntries.map { $0.workout.id })
    }

    @Test func missingWorkoutReferenceFailsDeterministically() throws {
        let missingKey = try #require(CatalogueSemanticKey(rawValue: "workout.missing"))
        let definition = CatalogueProgramScheduleEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            workoutSemanticKey: missingKey,
            weekNumber: 1,
            dayNumber: 1,
            sequenceNumber: 1,
            status: .required
        )

        do {
            _ = try CatalogueProgramRuntimeMapper.scheduleEntry(from: definition)
            Issue.record("Expected missing workout mapping to throw.")
        } catch CatalogueProgramRuntimeMapper.MappingError.missingWorkoutDefinition(let semanticKey) {
            #expect(semanticKey == missingKey)
        } catch {
            Issue.record("Expected missingWorkoutDefinition, got \(error).")
        }
    }

    @Test func unresolvedProgramDisplayKeyFailsDeterministically() throws {
        let invalidProgram = CatalogueProgramDefinition(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            semanticKey: try #require(CatalogueSemanticKey(rawValue: "program.invalid_display")),
            titleLocalizationKey: "catalogue.program.invalid_display.title",
            descriptionLocalizationKey: "catalogue.program.invalid_display.description",
            trainingGoal: .strength,
            experienceLevel: .beginner,
            durationInWeeks: 1,
            recommendedSessionsPerWeek: 1,
            estimatedWeeklyDuration: 45 * 60,
            scheduleEntries: []
        )

        do {
            _ = try CatalogueProgramRuntimeMapper.program(from: invalidProgram)
            Issue.record("Expected unresolved display-string mapping to throw.")
        } catch CatalogueProgramRuntimeMapper.MappingError.unresolvedDisplayString(let key) {
            #expect(key == "catalogue.program.invalid_display.title")
        } catch {
            Issue.record("Expected unresolvedDisplayString, got \(error).")
        }
    }

    @Test func invalidScheduleEntryDoesNotProducePartialProgram() throws {
        let missingKey = try #require(CatalogueSemanticKey(rawValue: "workout.missing"))
        let invalidProgram = CatalogueProgramDefinition(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            semanticKey: try #require(CatalogueSemanticKey(rawValue: "program.invalid_schedule")),
            titleLocalizationKey: "catalogue.program.beginner_strength_foundation.title",
            descriptionLocalizationKey: "catalogue.program.beginner_strength_foundation.description",
            trainingGoal: .strength,
            experienceLevel: .beginner,
            durationInWeeks: 1,
            recommendedSessionsPerWeek: 2,
            estimatedWeeklyDuration: 95 * 60,
            scheduleEntries: [
                CatalogueProgramScheduleEntry(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                    workoutSemanticKey: Self.fullBodyBeginnerKey,
                    weekNumber: 1,
                    dayNumber: 1,
                    sequenceNumber: 1,
                    status: .required
                ),
                CatalogueProgramScheduleEntry(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                    workoutSemanticKey: missingKey,
                    weekNumber: 1,
                    dayNumber: 2,
                    sequenceNumber: 2,
                    status: .required
                )
            ]
        )

        do {
            _ = try CatalogueProgramRuntimeMapper.program(from: invalidProgram)
            Issue.record("Expected invalid schedule mapping to throw.")
        } catch CatalogueProgramRuntimeMapper.MappingError.missingWorkoutDefinition(let semanticKey) {
            #expect(semanticKey == missingKey)
        } catch {
            Issue.record("Expected missingWorkoutDefinition, got \(error).")
        }
    }

    @Test func noScheduleEntryIsSilentlySkipped() throws {
        let definition = try #require(BuiltInProgramCatalogue.program(for: Self.beginnerStrengthFoundationKey))
        let program = try CatalogueProgramRuntimeMapper.program(from: definition)

        #expect(program.scheduleEntries.count == definition.scheduleEntries.count)
    }

    private static let beginnerStrengthFoundationKey = CatalogueSemanticKey(rawValue: "program.beginner_strength_foundation")!
    private static let fullBodyBeginnerKey = CatalogueSemanticKey(rawValue: "workout.full_body_beginner")!
    private static let pushDayKey = CatalogueSemanticKey(rawValue: "workout.push_day")!
    private static let pullDayKey = CatalogueSemanticKey(rawValue: "workout.pull_day")!
    private static let legDayKey = CatalogueSemanticKey(rawValue: "workout.leg_day")!
}
