import Foundation
import Testing
@testable import GymAI

@MainActor
struct ProgramCatalogueTests {

    @Test func builtInProgramIDsAreUnique() {
        let ids = BuiltInProgramCatalogue.allPrograms.map(\.id)

        #expect(Set(ids).count == ids.count)
    }

    @Test func builtInProgramSemanticKeysAreUnique() {
        let semanticKeys = BuiltInProgramCatalogue.allPrograms.map(\.semanticKey)

        #expect(Set(semanticKeys).count == semanticKeys.count)
    }

    @Test func builtInProgramsContainNoDuplicateEntries() {
        let programs = BuiltInProgramCatalogue.allPrograms
        let uniquePrograms = Set(programs)

        #expect(uniquePrograms.count == programs.count)
    }

    @Test func builtInProgramScheduleEntriesReferenceExistingWorkoutDefinitions() throws {
        for program in BuiltInProgramCatalogue.allPrograms {
            for scheduleEntry in program.scheduleEntries {
                let referencedWorkout = BuiltInWorkoutCatalogue.workout(for: scheduleEntry.workoutSemanticKey)

                #expect(referencedWorkout != nil)
            }
        }
    }

    @Test func builtInProgramLookupReturnsDefinitionForSemanticKey() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "program.beginner_strength_foundation"))
        let program = try #require(BuiltInProgramCatalogue.program(for: semanticKey))

        #expect(program.semanticKey == semanticKey)
        #expect(program.titleLocalizationKey == "catalogue.program.beginner_strength_foundation.title")
    }

    @Test func builtInProgramLookupReturnsDefinitionForID() throws {
        let program = try #require(BuiltInProgramCatalogue.allPrograms.first)
        let matchingProgram = BuiltInProgramCatalogue.program(id: program.id)

        #expect(matchingProgram == program)
    }

    @Test func builtInProgramLookupReturnsNilForUnknownSemanticKey() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "program.unknown"))

        #expect(BuiltInProgramCatalogue.program(for: semanticKey) == nil)
    }

    @Test func builtInProgramLookupReturnsNilForUnknownID() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        #expect(BuiltInProgramCatalogue.program(id: id) == nil)
    }

    @Test func builtInProgramCatalogueAccessIsDeterministic() {
        let firstAccess = BuiltInProgramCatalogue.allPrograms
        let secondAccess = BuiltInProgramCatalogue.allPrograms

        #expect(firstAccess == secondAccess)
    }

    @Test func builtInProgramStableIdentityRemainsPinned() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "program.beginner_strength_foundation"))
        let program = try #require(BuiltInProgramCatalogue.program(for: semanticKey))

        #expect(program.id.uuidString == "0D3B4087-D6E5-492F-97E9-F9C8BD9195F4")
    }

    @Test func builtInProgramCatalogueContainsStableProgramKeyList() {
        let semanticKeys = BuiltInProgramCatalogue.allPrograms.map(\.semanticKey.rawValue)

        #expect(semanticKeys == [
            "program.beginner_strength_foundation"
        ])
    }

    @Test func catalogueProgramDefinitionCodableRoundTrips() throws {
        let program = try #require(BuiltInProgramCatalogue.allPrograms.first)
        let encodedProgram = try JSONEncoder().encode(program)
        let decodedProgram = try JSONDecoder().decode(CatalogueProgramDefinition.self, from: encodedProgram)

        #expect(decodedProgram == program)
    }

    @Test func catalogueProgramScheduleEntryCodableRoundTrips() throws {
        let program = try #require(BuiltInProgramCatalogue.allPrograms.first)
        let scheduleEntry = try #require(program.scheduleEntries.first)
        let encodedScheduleEntry = try JSONEncoder().encode(scheduleEntry)
        let decodedScheduleEntry = try JSONDecoder().decode(CatalogueProgramScheduleEntry.self, from: encodedScheduleEntry)

        #expect(decodedScheduleEntry == scheduleEntry)
    }

    @Test func programScheduleEntryStatusRawValuesAreStable() {
        #expect(ProgramScheduleEntryStatus.required.rawValue == "required")
        #expect(ProgramScheduleEntryStatus.recommended.rawValue == "recommended")
        #expect(ProgramScheduleEntryStatus.optional.rawValue == "optional")
    }
}
