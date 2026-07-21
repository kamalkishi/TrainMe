import Foundation
import Testing
@testable import GymAI

@MainActor
struct CatalogueWorkoutRuntimeMapperTests {

    @Test func everyBuiltInCatalogueWorkoutMapsSuccessfully() throws {
        let workouts = try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)

        #expect(workouts.count == BuiltInWorkoutCatalogue.allWorkouts.count)
    }

    @Test func catalogueWorkoutFieldsMapToRuntimeWorkoutFields() throws {
        let definition = try #require(BuiltInWorkoutCatalogue.workout(for: Self.fullBodyBeginnerKey))
        let workout = try CatalogueWorkoutRuntimeMapper.workout(from: definition)

        #expect(workout.id == definition.id)
        #expect(workout.name == "Full Body Beginner")
        #expect(workout.type == .strength)
        #expect(workout.estimatedDuration == 45 * 60)
        #expect(workout.description == "A balanced workout targeting all major muscle groups.")
    }

    @Test func exerciseSemanticKeyReferencesResolveToRuntimeExercises() throws {
        let definition = try #require(BuiltInWorkoutCatalogue.workout(for: Self.fullBodyBeginnerKey))
        let workout = try CatalogueWorkoutRuntimeMapper.workout(from: definition)

        #expect(workout.exercises.map(\.exercise.name) == [
            "Goblet Squat",
            "Push-up",
            "Bent-over Row"
        ])
    }

    @Test func exerciseMetadataMapsToRuntimeExerciseFields() throws {
        let gobletSquatDefinition = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let pushUpDefinition = try #require(BuiltInExerciseCatalogue.definition(for: Self.pushUpKey))
        let bentOverRowDefinition = try #require(BuiltInExerciseCatalogue.definition(for: Self.bentOverRowKey))

        let gobletSquat = try CatalogueWorkoutRuntimeMapper.exercise(from: gobletSquatDefinition)
        let pushUp = try CatalogueWorkoutRuntimeMapper.exercise(from: pushUpDefinition)
        let bentOverRow = try CatalogueWorkoutRuntimeMapper.exercise(from: bentOverRowDefinition)

        #expect(gobletSquat.id == gobletSquatDefinition.id)
        #expect(gobletSquat.name == "Goblet Squat")
        #expect(gobletSquat.muscleGroups == [.quadriceps, .glutes])
        #expect(gobletSquat.workoutType == .strength)
        #expect(gobletSquat.requiresWeight == true)
        #expect(gobletSquat.unilateral == false)

        #expect(pushUp.id == pushUpDefinition.id)
        #expect(pushUp.name == "Push-up")
        #expect(pushUp.muscleGroups == [.chest, .triceps])
        #expect(pushUp.workoutType == .strength)
        #expect(pushUp.requiresWeight == false)
        #expect(pushUp.unilateral == false)

        #expect(bentOverRow.id == bentOverRowDefinition.id)
        #expect(bentOverRow.name == "Bent-over Row")
        #expect(bentOverRow.muscleGroups == [.back, .biceps])
        #expect(bentOverRow.workoutType == .strength)
        #expect(bentOverRow.requiresWeight == true)
        #expect(bentOverRow.unilateral == false)
    }

    @Test func exercisePrescriptionsMapSetsRepsAndRestExactly() throws {
        let definition = try #require(BuiltInWorkoutCatalogue.workout(for: Self.fullBodyBeginnerKey))
        let workout = try CatalogueWorkoutRuntimeMapper.workout(from: definition)

        #expect(workout.exercises.map(\.targetSets) == [3, 3, 3])
        #expect(workout.exercises.map(\.targetReps) == [12, 10, 12])
        #expect(workout.exercises.map(\.restSeconds) == [60, 60, 60])
    }

    @Test func workoutAndExerciseOrderingArePreserved() throws {
        let workouts = try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)

        #expect(workouts.map(\.name) == [
            "Full Body Beginner",
            "Push Day",
            "Pull Day",
            "Leg Day"
        ])
        #expect(workouts[0].exercises.map(\.exercise.name) == [
            "Goblet Squat",
            "Push-up",
            "Bent-over Row"
        ])
    }

    @Test func runtimeWorkoutAndExerciseIDsUseCatalogueUUIDs() throws {
        let definition = try #require(BuiltInWorkoutCatalogue.workout(for: Self.fullBodyBeginnerKey))
        let workout = try CatalogueWorkoutRuntimeMapper.workout(from: definition)

        #expect(workout.id == definition.id)
        #expect(workout.exercises.map(\.id) == definition.exercises.map(\.id))
        #expect(workout.exercises.map(\.exercise.id) == [
            UUID(uuidString: "4B9A24F4-6F7B-4BB7-B36A-0641F11E1F15")!,
            UUID(uuidString: "E0E7B04D-76E5-49A3-B9D3-091EF9369E2A")!,
            UUID(uuidString: "C59D28F6-A362-481A-8E55-9B8AF0B0D830")!
        ])
    }

    @Test func missingExerciseReferenceFailsDeterministically() throws {
        let missingKey = try #require(CatalogueSemanticKey(rawValue: "exercise.missing"))
        let definition = CatalogueWorkoutExercise(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            exerciseSemanticKey: missingKey,
            targetSets: 3,
            targetReps: 10,
            restDuration: 60
        )

        do {
            _ = try CatalogueWorkoutRuntimeMapper.workoutExercise(from: definition)
            Issue.record("Expected missing exercise mapping to throw.")
        } catch CatalogueWorkoutRuntimeMapper.MappingError.missingExerciseDefinition(let semanticKey) {
            #expect(semanticKey == missingKey)
        } catch {
            Issue.record("Expected missingExerciseDefinition, got \(error).")
        }
    }

    @Test func repeatedMappingProducesEquivalentRuntimeContent() throws {
        let firstWorkouts = try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)
        let secondWorkouts = try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)

        #expect(firstWorkouts == secondWorkouts)
    }

    @Test func noCatalogueExerciseReferenceIsSilentlySkipped() throws {
        let definitions = BuiltInWorkoutCatalogue.allWorkouts
        let workouts = try CatalogueWorkoutRuntimeMapper.workouts(from: definitions)
        let catalogueExerciseCount = definitions.reduce(0) { count, definition in
            count + definition.exercises.count
        }
        let runtimeExerciseCount = workouts.reduce(0) { count, workout in
            count + workout.exercises.count
        }

        #expect(runtimeExerciseCount == catalogueExerciseCount)
    }

    private static let fullBodyBeginnerKey = CatalogueSemanticKey(rawValue: "workout.full_body_beginner")!
    private static let gobletSquatKey = CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!
    private static let pushUpKey = CatalogueSemanticKey(rawValue: "exercise.push_up")!
    private static let bentOverRowKey = CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!
}
