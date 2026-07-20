import Foundation
import Testing
@testable import GymAI

@Suite("Catalogue taxonomy")
struct CatalogueTaxonomyTests {

    @Test
    func semanticKeyAcceptsStableCatalogueIdentifiers() throws {
        let exerciseKey = try #require(CatalogueSemanticKey(rawValue: "exercise.goblet_squat"))
        let workoutKey = try #require(CatalogueSemanticKey(rawValue: "workout.full_body_beginner_a"))
        let programKey = try #require(CatalogueSemanticKey(rawValue: "program.beginner_strength_foundation.v1"))

        #expect(exerciseKey.rawValue == "exercise.goblet_squat")
        #expect(workoutKey.rawValue == "workout.full_body_beginner_a")
        #expect(programKey.rawValue == "program.beginner_strength_foundation.v1")
    }

    @Test
    func semanticKeyRejectsInvalidCatalogueIdentifiers() {
        let invalidKeys = [
            "",
            "exercise",
            ".exercise.goblet_squat",
            "exercise.goblet_squat.",
            "exercise..goblet_squat",
            "Exercise.goblet_squat",
            "exercise.GobletSquat",
            "exercise.goblet-squat",
            "exercise.goblet squat",
            "exercise._goblet_squat",
            "exercise.goblet_squat_",
            "exercise.goblet__squat"
        ]

        for invalidKey in invalidKeys {
            #expect(CatalogueSemanticKey(rawValue: invalidKey) == nil, "Expected invalid semantic key: \(invalidKey)")
            #expect(!CatalogueSemanticKey.isValid(invalidKey), "Expected invalid semantic key: \(invalidKey)")
        }
    }

    @Test
    func semanticKeyCodableRoundTripPreservesRawValue() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "exercise.push_up"))
        let encoded = try JSONEncoder().encode(semanticKey)
        let decoded = try JSONDecoder().decode(CatalogueSemanticKey.self, from: encoded)

        #expect(decoded == semanticKey)
        #expect(decoded.rawValue == "exercise.push_up")
    }

    @Test
    func semanticKeyDecodingRejectsInvalidRawValue() throws {
        let encoded = try JSONEncoder().encode("Exercise.PushUp")

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(CatalogueSemanticKey.self, from: encoded)
        }
    }

    @Test
    func taxonomyRawValuesAreStableDurableIdentifiers() {
        #expect(CatalogueSource.builtIn.rawValue == "builtIn")
        #expect(CatalogueSource.gymAICloud.rawValue == "gymAICloud")
        #expect(PublicationStatus.internalReview.rawValue == "internalReview")
        #expect(WorkoutCategory.muscularEndurance.rawValue == "muscularEndurance")
        #expect(WorkoutCategory.warmUp.rawValue == "warmUp")
        #expect(TrainingGoal.returnToTraining.rawValue == "returnToTraining")
        #expect(ExperienceLevel.allLevels.rawValue == "allLevels")
        #expect(IntensityLevel.veryHigh.rawValue == "veryHigh")
        #expect(ImpactLevel.noImpact.rawValue == "noImpact")
        #expect(TrainingEnvironment.outdoors.rawValue == "outdoors")
        #expect(SessionFormat.straightSets.rawValue == "straightSets")
        #expect(MovementFamily.horizontalPush.rawValue == "horizontalPush")
        #expect(MovementFamily.throw.rawValue == "throw")
        #expect(MovementPattern.romanianDeadlift.rawValue == "romanianDeadlift")
        #expect(BodyRegion.feetAndAnkles.rawValue == "feetAndAnkles")
        #expect(Equipment.pullUpBar.rawValue == "pullUpBar")
        #expect(ExerciseMechanics.isometric.rawValue == "isometric")
        #expect(ForceType.pushAndPull.rawValue == "pushAndPull")
        #expect(MovementPlane.multiplanar.rawValue == "multiplanar")
        #expect(KineticChain.closedChain.rawValue == "closedChain")
        #expect(BodyPosition.sideLying.rawValue == "sideLying")
        #expect(Laterality.independentBilateral.rawValue == "independentBilateral")
        #expect(ExerciseDifficulty.foundational.rawValue == "foundational")
        #expect(DemandLevel.veryHigh.rawValue == "veryHigh")
        #expect(MeasurementType.holdDuration.rawValue == "holdDuration")
        #expect(AICapabilityState.formCoachable.rawValue == "formCoachable")
    }

    @Test
    func taxonomyRawValuesAreUniqueWithinEachType() {
        assertUniqueRawValues(CatalogueSource.self)
        assertUniqueRawValues(CatalogueOwnership.self)
        assertUniqueRawValues(PublicationStatus.self)
        assertUniqueRawValues(WorkoutCategory.self)
        assertUniqueRawValues(TrainingGoal.self)
        assertUniqueRawValues(ExperienceLevel.self)
        assertUniqueRawValues(IntensityLevel.self)
        assertUniqueRawValues(ImpactLevel.self)
        assertUniqueRawValues(TrainingEnvironment.self)
        assertUniqueRawValues(SessionFormat.self)
        assertUniqueRawValues(MovementFamily.self)
        assertUniqueRawValues(MovementPattern.self)
        assertUniqueRawValues(BodyRegion.self)
        assertUniqueRawValues(Equipment.self)
        assertUniqueRawValues(ExerciseMechanics.self)
        assertUniqueRawValues(ForceType.self)
        assertUniqueRawValues(MovementPlane.self)
        assertUniqueRawValues(KineticChain.self)
        assertUniqueRawValues(BodyPosition.self)
        assertUniqueRawValues(Laterality.self)
        assertUniqueRawValues(ExerciseDifficulty.self)
        assertUniqueRawValues(DemandLevel.self)
        assertUniqueRawValues(MeasurementType.self)
        assertUniqueRawValues(AICapabilityState.self)
    }

    @Test
    func taxonomyCodableRoundTripsPreserveValues() throws {
        try assertCodableRoundTrip(CatalogueSource.gymAICloud)
        try assertCodableRoundTrip(CatalogueOwnership.coach)
        try assertCodableRoundTrip(PublicationStatus.deprecated)
        try assertCodableRoundTrip(WorkoutCategory.sportsPerformance)
        try assertCodableRoundTrip(TrainingGoal.athleticPerformance)
        try assertCodableRoundTrip(ExperienceLevel.intermediate)
        try assertCodableRoundTrip(IntensityLevel.moderate)
        try assertCodableRoundTrip(ImpactLevel.lowImpact)
        try assertCodableRoundTrip(TrainingEnvironment.studio)
        try assertCodableRoundTrip(SessionFormat.amrap)
        try assertCodableRoundTrip(MovementFamily.antiRotation)
        try assertCodableRoundTrip(MovementPattern.pullUp)
        try assertCodableRoundTrip(BodyRegion.upperBody)
        try assertCodableRoundTrip(Equipment.resistanceBand)
        try assertCodableRoundTrip(ExerciseMechanics.compound)
        try assertCodableRoundTrip(ForceType.locomotion)
        try assertCodableRoundTrip(MovementPlane.transverse)
        try assertCodableRoundTrip(KineticChain.mixed)
        try assertCodableRoundTrip(BodyPosition.halfKneeling)
        try assertCodableRoundTrip(Laterality.alternating)
        try assertCodableRoundTrip(ExerciseDifficulty.advanced)
        try assertCodableRoundTrip(DemandLevel.high)
        try assertCodableRoundTrip(MeasurementType.breathCycles)
        try assertCodableRoundTrip(AICapabilityState.repCountable)
    }

    private func assertUniqueRawValues<T>(
        _ type: T.Type,
        sourceLocation: SourceLocation = #_sourceLocation
    ) where T: CaseIterable & RawRepresentable, T.RawValue == String {
        let rawValues = T.allCases.map(\.rawValue)
        #expect(
            Set(rawValues).count == rawValues.count,
            "Duplicate raw value in \(type): \(rawValues)",
            sourceLocation: sourceLocation
        )
    }

    private func assertCodableRoundTrip<T>(
        _ value: T,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws where T: Codable & Equatable {
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(T.self, from: encoded)

        #expect(decoded == value, sourceLocation: sourceLocation)
    }
}
