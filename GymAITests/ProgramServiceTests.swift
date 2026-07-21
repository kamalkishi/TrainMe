import Foundation
import Testing
@testable import GymAI

@MainActor
struct ProgramServiceTests {

    @Test func sampleProgramsReturnsBuiltInRuntimePrograms() {
        let programs = ProgramService().samplePrograms()

        #expect(programs.count == BuiltInProgramCatalogue.allPrograms.count)
    }

    @Test func sampleProgramsPreservesBuiltInProgramOrdering() {
        let programs = ProgramService().samplePrograms()

        #expect(programs.map(\.id) == BuiltInProgramCatalogue.allPrograms.map(\.id))
        #expect(programs.map(\.name) == ["Beginner Strength Foundation"])
    }

    @Test func sampleProgramsMatchesDirectProgramMapperOutput() throws {
        let servicePrograms = ProgramService().samplePrograms()
        let mappedPrograms = try CatalogueProgramRuntimeMapper.programs(from: BuiltInProgramCatalogue.allPrograms)

        #expect(servicePrograms == mappedPrograms)
    }

    @Test func repeatedServiceAccessProducesStableProgramAndScheduleIdentities() {
        let firstPrograms = ProgramService().samplePrograms()
        let secondPrograms = ProgramService().samplePrograms()

        #expect(firstPrograms == secondPrograms)
        #expect(firstPrograms.map(\.id) == secondPrograms.map(\.id))
        #expect(firstPrograms.map { $0.scheduleEntries.map(\.id) } == secondPrograms.map { $0.scheduleEntries.map(\.id) })
        #expect(firstPrograms.map { $0.scheduleEntries.map { $0.workout.id } } == secondPrograms.map { $0.scheduleEntries.map { $0.workout.id } })
    }

    @Test func beginnerStrengthProgramResolvesAllExpectedWorkoutsInScheduleOrder() throws {
        let program = try #require(ProgramService().samplePrograms().first)

        #expect(program.name == "Beginner Strength Foundation")
        #expect(program.scheduleEntries.map { $0.workout.name } == [
            "Full Body Beginner",
            "Push Day",
            "Pull Day",
            "Leg Day"
        ])
        #expect(program.scheduleEntries.map { $0.workout.exercises.count } == [3, 1, 1, 1])
    }

    @Test func sampleProgramsDoNotContainEmptyOrPartialSchedules() {
        let programs = ProgramService().samplePrograms()

        #expect(programs.allSatisfy { !$0.scheduleEntries.isEmpty })
        #expect(programs.allSatisfy { program in
            program.scheduleEntries.allSatisfy { !$0.workout.exercises.isEmpty }
        })
    }
}
