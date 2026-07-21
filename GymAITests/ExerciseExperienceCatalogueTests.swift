import Foundation
import Testing
@testable import GymAI

@MainActor
struct ExerciseExperienceCatalogueTests {

    @Test func catalogueContainsOneExperienceForEachBuiltInExercise() {
        let definitions = BuiltInExerciseExperienceCatalogue.definitions

        #expect(definitions.count == BuiltInExerciseCatalogue.definitions.count)
        #expect(definitions.map(\.exerciseSemanticKey) == BuiltInExerciseCatalogue.definitions.map(\.semanticKey))
    }

    @Test func everyExperienceSemanticKeyResolvesToBuiltInExerciseCatalogue() throws {
        for definition in BuiltInExerciseExperienceCatalogue.definitions {
            let exerciseDefinition = BuiltInExerciseCatalogue.definition(for: definition.exerciseSemanticKey)

            #expect(exerciseDefinition != nil)
        }
    }

    @Test func experienceSemanticKeysAndStableIDsAreUnique() {
        let definitions = BuiltInExerciseExperienceCatalogue.definitions
        let ids = definitions.map(\.id)
        let semanticKeys = definitions.map(\.exerciseSemanticKey)

        #expect(Set(ids).count == ids.count)
        #expect(Set(semanticKeys).count == semanticKeys.count)
    }

    @Test func instructionAndMediaIDsAreStableAndUnique() {
        let definitions = BuiltInExerciseExperienceCatalogue.definitions
        let instructionIDs = definitions.flatMap { $0.instructionSteps.map(\.id) }
        let mediaIDs = definitions.flatMap { $0.mediaReferences.map(\.id) }

        #expect(Set(instructionIDs).count == instructionIDs.count)
        #expect(Set(mediaIDs).count == mediaIDs.count)
        #expect(instructionIDs.contains(UUID(uuidString: "0E99E816-B36D-4B6C-A3AA-68E4934541A1")!))
        #expect(mediaIDs.contains(UUID(uuidString: "2F4E41EF-2169-4D5D-AE0A-89C3A1257E8D")!))
    }

    @Test func mediaKindRawValuesAreStable() {
        #expect(ExerciseMediaKind.image.rawValue == "image")
        #expect(ExerciseMediaKind.animatedImage.rawValue == "animated_image")
        #expect(ExerciseMediaKind.video.rawValue == "video")
    }

    @Test func mediaResourceKeysAreStableAndNonEmpty() throws {
        let resourceKeys = BuiltInExerciseExperienceCatalogue.definitions.flatMap { definition in
            definition.mediaReferences.map(\.resourceKey)
        }

        #expect(resourceKeys.map(\.rawValue) == [
            "exercise.goblet_squat.demo.primary",
            "exercise.push_up.demo.primary",
            "exercise.bent_over_row.demo.primary"
        ])
        #expect(resourceKeys.allSatisfy { !$0.rawValue.isEmpty })
    }

    @Test func everyExperienceHasCompleteFoundationContent() {
        for definition in BuiltInExerciseExperienceCatalogue.definitions {
            #expect(!definition.descriptionLocalizationKey.isEmpty)
            #expect(!definition.instructionSteps.isEmpty)
            #expect(!definition.tipLocalizationKeys.isEmpty)
            #expect(!definition.commonMistakeLocalizationKeys.isEmpty)
            #expect(!definition.safetyNoteLocalizationKeys.isEmpty)
            #expect(!definition.mediaReferences.isEmpty)
        }
    }

    @Test func instructionOrderingIsDeterministic() {
        for definition in BuiltInExerciseExperienceCatalogue.definitions {
            let sequenceNumbers = definition.instructionSteps.map(\.sequenceNumber)

            #expect(sequenceNumbers == sequenceNumbers.sorted())
            #expect(Set(sequenceNumbers).count == sequenceNumbers.count)
            #expect(sequenceNumbers.first == 1)
        }
    }

    @Test func semanticKeyLookupReturnsExpectedDefinition() throws {
        let pushUp = try #require(BuiltInExerciseExperienceCatalogue.definition(for: Self.pushUpKey))

        #expect(pushUp.exerciseSemanticKey == Self.pushUpKey)
        #expect(pushUp.descriptionLocalizationKey == "catalogue.exercise.push_up.description")
    }

    @Test func missingSemanticKeyLookupReturnsNil() throws {
        let unknownKey = try #require(CatalogueSemanticKey(rawValue: "exercise.unknown"))

        #expect(BuiltInExerciseExperienceCatalogue.definition(for: unknownKey) == nil)
    }

    @Test func catalogueCodableRoundTripPreservesContentAndIdentity() throws {
        let definition = try #require(BuiltInExerciseExperienceCatalogue.definition(for: Self.gobletSquatKey))
        let encoded = try JSONEncoder().encode(definition)
        let decoded = try JSONDecoder().decode(ExerciseExperienceContent.self, from: encoded)

        #expect(decoded == definition)
    }

    @Test func builtInCatalogueOrderingIsDeterministic() {
        let firstDefinitions = BuiltInExerciseExperienceCatalogue.definitions
        let secondDefinitions = BuiltInExerciseExperienceCatalogue.definitions

        #expect(firstDefinitions == secondDefinitions)
        #expect(firstDefinitions.map(\.exerciseSemanticKey) == [
            Self.gobletSquatKey,
            Self.pushUpKey,
            Self.bentOverRowKey
        ])
    }

    private static let gobletSquatKey = CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!
    private static let pushUpKey = CatalogueSemanticKey(rawValue: "exercise.push_up")!
    private static let bentOverRowKey = CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!
}
