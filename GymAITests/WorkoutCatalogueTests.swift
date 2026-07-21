import Foundation
import Testing
@testable import GymAI

@MainActor
struct WorkoutCatalogueTests {

    @Test func builtInWorkoutIDsAreUnique() {
        let ids = BuiltInWorkoutCatalogue.allWorkouts.map(\.id)

        #expect(Set(ids).count == ids.count)
    }

    @Test func builtInWorkoutSemanticKeysAreUnique() {
        let semanticKeys = BuiltInWorkoutCatalogue.allWorkouts.map(\.semanticKey)

        #expect(Set(semanticKeys).count == semanticKeys.count)
    }

    @Test func builtInWorkoutsContainNoDuplicateEntries() {
        let workouts = BuiltInWorkoutCatalogue.allWorkouts
        let uniqueWorkouts = Set(workouts)

        #expect(uniqueWorkouts.count == workouts.count)
    }

    @Test func builtInWorkoutExercisesReferenceExistingExerciseDefinitions() throws {
        for workout in BuiltInWorkoutCatalogue.allWorkouts {
            for workoutExercise in workout.exercises {
                let referencedExercise = BuiltInExerciseCatalogue.definition(for: workoutExercise.exerciseSemanticKey)

                #expect(referencedExercise != nil)
            }
        }
    }

    @Test func builtInWorkoutLookupReturnsDefinitionForSemanticKey() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "workout.full_body_beginner"))
        let workout = try #require(BuiltInWorkoutCatalogue.workout(for: semanticKey))

        #expect(workout.semanticKey == semanticKey)
        #expect(workout.titleLocalizationKey == "catalogue.workout.full_body_beginner.title")
    }

    @Test func builtInWorkoutLookupReturnsDefinitionForID() throws {
        let workout = try #require(BuiltInWorkoutCatalogue.allWorkouts.first)
        let matchingWorkout = BuiltInWorkoutCatalogue.workout(id: workout.id)

        #expect(matchingWorkout == workout)
    }

    @Test func builtInWorkoutLookupReturnsNilForUnknownSemanticKey() throws {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: "workout.unknown"))

        #expect(BuiltInWorkoutCatalogue.workout(for: semanticKey) == nil)
    }

    @Test func builtInWorkoutLookupReturnsNilForUnknownID() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        #expect(BuiltInWorkoutCatalogue.workout(id: id) == nil)
    }

    @Test func builtInWorkoutCatalogueAccessIsDeterministic() {
        let firstAccess = BuiltInWorkoutCatalogue.allWorkouts
        let secondAccess = BuiltInWorkoutCatalogue.allWorkouts

        #expect(firstAccess == secondAccess)
    }

    @Test func builtInWorkoutStableIdentitiesRemainPinned() throws {
        let expectedWorkouts: [(semanticKey: String, id: String)] = [
            ("workout.full_body_beginner", "D2D7F44F-EB53-4683-98D2-1D9D3959AAE4"),
            ("workout.push_day", "BC901012-CC9A-4047-B35D-3696D8F48A7D"),
            ("workout.pull_day", "616B9297-2A26-47C3-B358-6DF016F808A0"),
            ("workout.leg_day", "FC372E4A-80DA-4688-B8AC-9FC068973BDB")
        ]

        for expectedWorkout in expectedWorkouts {
            let semanticKey = try #require(CatalogueSemanticKey(rawValue: expectedWorkout.semanticKey))
            let workout = try #require(BuiltInWorkoutCatalogue.workout(for: semanticKey))

            #expect(workout.id.uuidString == expectedWorkout.id)
        }
    }

    @Test func builtInWorkoutCatalogueContainsExistingWorkoutKeysOnly() {
        let semanticKeys = BuiltInWorkoutCatalogue.allWorkouts.map(\.semanticKey.rawValue)

        #expect(semanticKeys == [
            "workout.full_body_beginner",
            "workout.push_day",
            "workout.pull_day",
            "workout.leg_day"
        ])
    }

    @Test func catalogueWorkoutDefinitionCodableRoundTrips() throws {
        let workout = try #require(BuiltInWorkoutCatalogue.allWorkouts.first)
        let encodedWorkout = try JSONEncoder().encode(workout)
        let decodedWorkout = try JSONDecoder().decode(CatalogueWorkoutDefinition.self, from: encodedWorkout)

        #expect(decodedWorkout == workout)
    }

    @Test func catalogueWorkoutExerciseCodableRoundTrips() throws {
        let workout = try #require(BuiltInWorkoutCatalogue.allWorkouts.first)
        let workoutExercise = try #require(workout.exercises.first)
        let encodedWorkoutExercise = try JSONEncoder().encode(workoutExercise)
        let decodedWorkoutExercise = try JSONDecoder().decode(CatalogueWorkoutExercise.self, from: encodedWorkoutExercise)

        #expect(decodedWorkoutExercise == workoutExercise)
    }
}
