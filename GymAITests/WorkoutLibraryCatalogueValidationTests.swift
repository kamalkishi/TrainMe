import Foundation
import Testing
@testable import GymAI

@MainActor
struct WorkoutLibraryCatalogueValidationTests {
    @Test func libraryReturnsExactlyFourUniqueBuiltInWorkouts() {
        let workouts = WorkoutService().sampleWorkouts()

        #expect(workouts.count == 4)
        #expect(Set(workouts.map(\.id)).count == 4)
    }

    @Test func libraryPreservesCatalogueOrderingAndUserVisibleWorkoutFields() {
        let workouts = WorkoutService().sampleWorkouts()

        #expect(workouts.map(\.name) == [
            "Full Body Beginner",
            "Push Day",
            "Pull Day",
            "Leg Day"
        ])
        #expect(workouts.map(\.description) == [
            "A balanced workout targeting all major muscle groups.",
            "Focus on chest, shoulders and triceps.",
            "Train your back, biceps and rear shoulders.",
            "Build lower body strength and stability."
        ])
        let expectedWorkoutTypes: [WorkoutType] = [.strength, .hypertrophy, .hypertrophy, .strength]
        let expectedDurations: [TimeInterval] = [45 * 60, 50 * 60, 50 * 60, 60 * 60]
        #expect(workouts.map(\.type) == expectedWorkoutTypes)
        #expect(workouts.map(\.estimatedDuration) == expectedDurations)
    }

    @Test func libraryWorkoutExerciseCountsMatchCatalogueBackedContent() {
        let workouts = WorkoutService().sampleWorkouts()

        #expect(workouts.map { $0.exercises.count } == [3, 1, 1, 1])
        #expect(workouts.allSatisfy { !$0.exercises.isEmpty })
    }

    @Test func runtimeWorkoutIDsMatchCatalogueDefinitions() throws {
        let workouts = WorkoutService().sampleWorkouts()
        let expectedIDs = try [
            catalogueWorkout("workout.full_body_beginner").id,
            catalogueWorkout("workout.push_day").id,
            catalogueWorkout("workout.pull_day").id,
            catalogueWorkout("workout.leg_day").id
        ]

        #expect(workouts.map(\.id) == expectedIDs)
    }

    @Test func detailsFacingExerciseValuesAreCorrectForEveryWorkout() throws {
        let workouts = WorkoutService().sampleWorkouts()

        try expect(
            workout: workout(named: "Full Body Beginner", in: workouts),
            exercises: [
                ExpectedExercise(
                    name: "Goblet Squat",
                    muscleGroups: [.quadriceps, .glutes],
                    workoutType: .strength,
                    requiresWeight: true,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                ),
                ExpectedExercise(
                    name: "Push-up",
                    muscleGroups: [.chest, .triceps],
                    workoutType: .strength,
                    requiresWeight: false,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 10,
                    restSeconds: 60
                ),
                ExpectedExercise(
                    name: "Bent-over Row",
                    muscleGroups: [.back, .biceps],
                    workoutType: .strength,
                    requiresWeight: true,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                )
            ]
        )
        try expect(
            workout: workout(named: "Push Day", in: workouts),
            exercises: [
                ExpectedExercise(
                    name: "Push-up",
                    muscleGroups: [.chest, .triceps],
                    workoutType: .strength,
                    requiresWeight: false,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 10,
                    restSeconds: 60
                )
            ]
        )
        try expect(
            workout: workout(named: "Pull Day", in: workouts),
            exercises: [
                ExpectedExercise(
                    name: "Bent-over Row",
                    muscleGroups: [.back, .biceps],
                    workoutType: .strength,
                    requiresWeight: true,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                )
            ]
        )
        try expect(
            workout: workout(named: "Leg Day", in: workouts),
            exercises: [
                ExpectedExercise(
                    name: "Goblet Squat",
                    muscleGroups: [.quadriceps, .glutes],
                    workoutType: .strength,
                    requiresWeight: true,
                    unilateral: false,
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                )
            ]
        )
    }

    @Test func runtimeExerciseIDsMatchCatalogueDefinitions() throws {
        let workouts = WorkoutService().sampleWorkouts()
        let expectedIDsByName = try [
            "Goblet Squat": catalogueExercise("exercise.goblet_squat").id,
            "Push-up": catalogueExercise("exercise.push_up").id,
            "Bent-over Row": catalogueExercise("exercise.bent_over_row").id
        ]

        for workout in workouts {
            for workoutExercise in workout.exercises {
                let expectedID = try #require(expectedIDsByName[workoutExercise.exercise.name])
                #expect(workoutExercise.exercise.id == expectedID)
            }
        }
    }

    @Test func runtimeWorkoutExerciseIDsMatchCatalogueDefinitions() throws {
        let workouts = WorkoutService().sampleWorkouts()

        for workout in workouts {
            let catalogueDefinition = try catalogueWorkout(forRuntimeWorkoutName: workout.name)
            #expect(workout.exercises.map(\.id) == catalogueDefinition.exercises.map(\.id))
        }
    }

    @Test func repeatedWorkoutServiceAccessReturnsEquivalentOrderedContentAndStableIdentities() {
        let firstAccess = WorkoutService().sampleWorkouts()
        let secondAccess = WorkoutService().sampleWorkouts()

        #expect(firstAccess == secondAccess)
        #expect(firstAccess.map(\.id) == secondAccess.map(\.id))
        #expect(firstAccess.map { $0.exercises.map(\.id) } == secondAccess.map { $0.exercises.map(\.id) })
        #expect(firstAccess.map { $0.exercises.map { $0.exercise.id } } == secondAccess.map { $0.exercises.map { $0.exercise.id } })
    }

    private struct ExpectedExercise {
        let name: String
        let muscleGroups: [MuscleGroup]
        let workoutType: WorkoutType
        let requiresWeight: Bool
        let unilateral: Bool
        let targetSets: Int
        let targetReps: Int
        let restSeconds: Int
    }

    private func expect(workout: Workout, exercises expectedExercises: [ExpectedExercise]) {
        #expect(workout.exercises.count == expectedExercises.count)

        for (workoutExercise, expectedExercise) in zip(workout.exercises, expectedExercises) {
            #expect(workoutExercise.exercise.name == expectedExercise.name)
            #expect(workoutExercise.exercise.muscleGroups == expectedExercise.muscleGroups)
            #expect(workoutExercise.exercise.workoutType == expectedExercise.workoutType)
            #expect(workoutExercise.exercise.requiresWeight == expectedExercise.requiresWeight)
            #expect(workoutExercise.exercise.unilateral == expectedExercise.unilateral)
            #expect(workoutExercise.targetSets == expectedExercise.targetSets)
            #expect(workoutExercise.targetReps == expectedExercise.targetReps)
            #expect(workoutExercise.restSeconds == expectedExercise.restSeconds)
        }
    }

    private func workout(named name: String, in workouts: [Workout]) throws -> Workout {
        try #require(workouts.first { $0.name == name })
    }

    private func catalogueWorkout(_ rawKey: String) throws -> CatalogueWorkoutDefinition {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: rawKey))
        return try #require(BuiltInWorkoutCatalogue.workout(for: semanticKey))
    }

    private func catalogueWorkout(forRuntimeWorkoutName name: String) throws -> CatalogueWorkoutDefinition {
        let rawKey: String
        switch name {
        case "Full Body Beginner":
            rawKey = "workout.full_body_beginner"
        case "Push Day":
            rawKey = "workout.push_day"
        case "Pull Day":
            rawKey = "workout.pull_day"
        case "Leg Day":
            rawKey = "workout.leg_day"
        default:
            Issue.record("Unexpected workout name: \(name)")
            rawKey = "workout.unknown"
        }

        return try catalogueWorkout(rawKey)
    }

    private func catalogueExercise(_ rawKey: String) throws -> CatalogueExerciseDefinition {
        let semanticKey = try #require(CatalogueSemanticKey(rawValue: rawKey))
        return try #require(BuiltInExerciseCatalogue.definition(for: semanticKey))
    }
}
