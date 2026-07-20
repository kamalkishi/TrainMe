import Foundation
import Testing
@testable import GymAI

@Suite("Exercise metadata")
@MainActor
struct ExerciseMetadataTests {

    @Test
    func exerciseMetadataCodableRoundTripPreservesValues() throws {
        let metadata = ExerciseMetadata(
            primaryMovementFamily: .squat,
            primaryMovementPattern: .bilateralSquat,
            secondaryMovementPatterns: [.splitSquat],
            bodyRegions: [.lowerBody, .glutes],
            primaryMuscles: [.quadriceps, .gluteusMaximus],
            secondaryMuscles: [.rectusAbdominis],
            stabilizerMuscles: [.erectorSpinae],
            requiredEquipment: [.kettlebell],
            optionalEquipment: [.dumbbell],
            mechanics: .compound,
            forceType: .push,
            movementPlane: .sagittal,
            kineticChain: .closedChain,
            bodyPosition: .standing,
            laterality: .bilateral,
            difficulty: .beginner,
            technicalDemand: .moderate,
            mobilityDemand: .moderate,
            balanceDemand: .low,
            supportedMeasurements: [.repetitions, .load],
            aiCapability: .planned,
            aliasLocalizationKeys: ["catalogue.exercise.goblet_squat.alias.kettlebell_squat"]
        )

        let encoded = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(ExerciseMetadata.self, from: encoded)

        #expect(decoded == metadata)
    }

    @Test
    func catalogueExerciseDefinitionCodableRoundTripPreservesValues() throws {
        let definition = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let encoded = try JSONEncoder().encode(definition)
        let decoded = try JSONDecoder().decode(CatalogueExerciseDefinition.self, from: encoded)

        #expect(decoded == definition)
    }

    @Test
    func builtInCatalogueContainsOnlyInitialExerciseDefinitions() {
        let definitions = BuiltInExerciseCatalogue.definitions

        #expect(definitions.count == 3)
        #expect(definitions.map(\.semanticKey) == [
            Self.gobletSquatKey,
            Self.pushUpKey,
            Self.bentOverRowKey
        ])
    }

    @Test
    func builtInExerciseIdentitiesAreStable() throws {
        let gobletSquat = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let pushUp = try #require(BuiltInExerciseCatalogue.definition(for: Self.pushUpKey))
        let bentOverRow = try #require(BuiltInExerciseCatalogue.definition(for: Self.bentOverRowKey))

        #expect(gobletSquat.id.uuidString == "4B9A24F4-6F7B-4BB7-B36A-0641F11E1F15")
        #expect(pushUp.id.uuidString == "E0E7B04D-76E5-49A3-B9D3-091EF9369E2A")
        #expect(bentOverRow.id.uuidString == "C59D28F6-A362-481A-8E55-9B8AF0B0D830")
    }

    @Test
    func builtInExerciseIDsAndSemanticKeysAreUnique() {
        let definitions = BuiltInExerciseCatalogue.definitions
        let ids = definitions.map(\.id)
        let semanticKeys = definitions.map(\.semanticKey)

        #expect(Set(ids).count == ids.count)
        #expect(Set(semanticKeys).count == semanticKeys.count)
    }

    @Test
    func semanticKeyLookupReturnsExpectedDefinitions() throws {
        let gobletSquat = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let pushUp = try #require(BuiltInExerciseCatalogue.definition(for: Self.pushUpKey))
        let bentOverRow = try #require(BuiltInExerciseCatalogue.definition(for: Self.bentOverRowKey))

        #expect(gobletSquat.titleLocalizationKey == "catalogue.exercise.goblet_squat.title")
        #expect(pushUp.titleLocalizationKey == "catalogue.exercise.push_up.title")
        #expect(bentOverRow.titleLocalizationKey == "catalogue.exercise.bent_over_row.title")
    }

    @Test
    func missingSemanticKeyLookupReturnsNil() throws {
        let unknownKey = try #require(CatalogueSemanticKey(rawValue: "exercise.unknown"))

        #expect(BuiltInExerciseCatalogue.definition(for: unknownKey) == nil)
    }

    @Test
    func repeatedCatalogueAccessReturnsDeterministicIdentities() {
        let firstDefinitions = BuiltInExerciseCatalogue.definitions
        let secondDefinitions = BuiltInExerciseCatalogue.definitions

        #expect(firstDefinitions.map(\.id) == secondDefinitions.map(\.id))
        #expect(firstDefinitions.map(\.semanticKey) == secondDefinitions.map(\.semanticKey))
        #expect(firstDefinitions == secondDefinitions)
    }

    @Test
    func builtInExerciseMetadataIsCompleteForFoundationCatalogue() {
        for definition in BuiltInExerciseCatalogue.definitions {
            #expect(!definition.titleLocalizationKey.isEmpty)
            #expect(!definition.metadata.bodyRegions.isEmpty)
            #expect(!definition.metadata.primaryMuscles.isEmpty)
            #expect(!definition.metadata.requiredEquipment.isEmpty)
            #expect(!definition.metadata.supportedMeasurements.isEmpty)
            #expect(definition.schemaVersion > 0)
            #expect(definition.contentRevision > 0)
            #expect(definition.source == .builtIn)
            #expect(definition.ownership == .gymAI)
            #expect(definition.publicationStatus == .published)
        }
    }

    @Test
    func builtInExerciseMetadataMatchesCurrentExerciseIntent() throws {
        let gobletSquat = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let pushUp = try #require(BuiltInExerciseCatalogue.definition(for: Self.pushUpKey))
        let bentOverRow = try #require(BuiltInExerciseCatalogue.definition(for: Self.bentOverRowKey))

        #expect(gobletSquat.metadata.primaryMovementFamily == .squat)
        #expect(gobletSquat.metadata.primaryMuscles == [.quadriceps, .gluteusMaximus])
        #expect(gobletSquat.metadata.requiredEquipment == [.kettlebell])
        #expect(gobletSquat.metadata.supportedMeasurements == [.repetitions, .load])

        #expect(pushUp.metadata.primaryMovementFamily == .horizontalPush)
        #expect(pushUp.metadata.primaryMuscles == [.pectoralisMajor, .triceps])
        #expect(pushUp.metadata.requiredEquipment == [.bodyweight])
        #expect(pushUp.metadata.supportedMeasurements == [.repetitions])

        #expect(bentOverRow.metadata.primaryMovementFamily == .horizontalPull)
        #expect(bentOverRow.metadata.primaryMuscles == [.latissimusDorsi, .rhomboids, .trapezius])
        #expect(bentOverRow.metadata.requiredEquipment == [.dumbbell])
        #expect(bentOverRow.metadata.supportedMeasurements == [.repetitions, .load])
    }

    @Test
    func muscleRawValuesAreStableDurableIdentifiers() {
        #expect(Muscle.pectoralisMajor.rawValue == "pectoralisMajor")
        #expect(Muscle.triceps.rawValue == "triceps")
        #expect(Muscle.latissimusDorsi.rawValue == "latissimusDorsi")
        #expect(Muscle.biceps.rawValue == "biceps")
        #expect(Muscle.quadriceps.rawValue == "quadriceps")
        #expect(Muscle.gluteusMaximus.rawValue == "gluteusMaximus")
        #expect(Muscle.rhomboids.rawValue == "rhomboids")
        #expect(Muscle.trapezius.rawValue == "trapezius")
        #expect(Muscle.erectorSpinae.rawValue == "erectorSpinae")
        #expect(Muscle.rectusAbdominis.rawValue == "rectusAbdominis")
    }

    @Test
    func muscleRawValuesAreUnique() {
        let rawValues = Muscle.allCases.map(\.rawValue)

        #expect(Set(rawValues).count == rawValues.count)
    }

    private static let gobletSquatKey = CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!
    private static let pushUpKey = CatalogueSemanticKey(rawValue: "exercise.push_up")!
    private static let bentOverRowKey = CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!
}
