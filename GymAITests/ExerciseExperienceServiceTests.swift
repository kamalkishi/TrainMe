import Foundation
import Testing
@testable import GymAI

@MainActor
struct ExerciseExperienceServiceTests {

    @Test func serviceReturnsAllBuiltInExerciseExperiences() {
        let experiences = ExerciseExperienceService().sampleExperiences()

        #expect(experiences.count == BuiltInExerciseExperienceCatalogue.definitions.count)
        #expect(experiences.count == 3)
    }

    @Test func serviceOrderingMatchesBuiltInExperienceCatalogue() {
        let experiences = ExerciseExperienceService().sampleExperiences()

        #expect(experiences.map(\.semanticKey) == BuiltInExerciseExperienceCatalogue.definitions.map(\.exerciseSemanticKey))
    }

    @Test func serviceOutputEqualsDirectMapperOutput() throws {
        let serviceExperiences = ExerciseExperienceService().sampleExperiences()
        let mappedExperiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()

        #expect(serviceExperiences == mappedExperiences)
    }

    @Test func repeatedServiceAccessProducesStableIdentities() {
        let firstExperiences = ExerciseExperienceService().sampleExperiences()
        let secondExperiences = ExerciseExperienceService().sampleExperiences()

        #expect(firstExperiences == secondExperiences)
        #expect(firstExperiences.map(\.id) == secondExperiences.map(\.id))
        #expect(firstExperiences.map { $0.instructionSteps.map(\.id) } == secondExperiences.map { $0.instructionSteps.map(\.id) })
        #expect(firstExperiences.map { $0.mediaReferences.map(\.id) } == secondExperiences.map { $0.mediaReferences.map(\.id) })
    }

    @Test func lookupByRuntimeExerciseIDReturnsMatchingExperience() throws {
        let service = ExerciseExperienceService()

        let gobletSquat = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let pushUp = try #require(BuiltInExerciseCatalogue.definition(for: Self.pushUpKey))
        let bentOverRow = try #require(BuiltInExerciseCatalogue.definition(for: Self.bentOverRowKey))

        #expect(service.experience(forExerciseID: gobletSquat.id)?.semanticKey == Self.gobletSquatKey)
        #expect(service.experience(forExerciseID: pushUp.id)?.semanticKey == Self.pushUpKey)
        #expect(service.experience(forExerciseID: bentOverRow.id)?.semanticKey == Self.bentOverRowKey)
    }

    @Test func unknownRuntimeExerciseIDReturnsNil() {
        let unknownID = UUID(uuidString: "00000000-0000-0000-0000-000000000301")!

        #expect(ExerciseExperienceService().experience(forExerciseID: unknownID) == nil)
    }

    @Test func lookupBySemanticKeyReturnsMatchingExperience() throws {
        let experience = try #require(ExerciseExperienceService().experience(for: Self.pushUpKey))

        #expect(experience.name == "Push-up")
        #expect(experience.semanticKey == Self.pushUpKey)
    }

    @Test func unknownSemanticKeyReturnsNil() throws {
        let unknownKey = try #require(CatalogueSemanticKey(rawValue: "exercise.unknown"))

        #expect(ExerciseExperienceService().experience(for: unknownKey) == nil)
    }

    @Test func serviceResultsAreComplete() {
        let experiences = ExerciseExperienceService().sampleExperiences()

        for experience in experiences {
            #expect(!experience.name.isEmpty)
            #expect(!experience.description.isEmpty)
            #expect(!experience.primaryMuscles.isEmpty)
            #expect(!experience.requiredEquipment.isEmpty)
            #expect(!experience.instructionSteps.isEmpty)
            #expect(!experience.tips.isEmpty)
            #expect(!experience.commonMistakes.isEmpty)
            #expect(!experience.safetyNotes.isEmpty)
            #expect(!experience.mediaReferences.isEmpty)
        }
    }

    @Test func serviceDoesNotReturnEmptyOrPartialExperiences() {
        let experiences = ExerciseExperienceService().sampleExperiences()

        #expect(experiences.allSatisfy { experience in
            !experience.instructionSteps.contains { $0.text.isEmpty }
        })
        #expect(experiences.allSatisfy { experience in
            !experience.mediaReferences.contains { reference in
                reference.resourceKey.rawValue.isEmpty || reference.accessibilityLabel.isEmpty
            }
        })
    }

    private static let gobletSquatKey = CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!
    private static let pushUpKey = CatalogueSemanticKey(rawValue: "exercise.push_up")!
    private static let bentOverRowKey = CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!
}
