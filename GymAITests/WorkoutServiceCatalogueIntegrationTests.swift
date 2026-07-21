import Foundation
import Testing
@testable import GymAI

@MainActor
struct WorkoutServiceCatalogueIntegrationTests {

    @Test func sampleWorkoutsExposeFourCatalogueBackedWorkoutsInOrder() {
        let workouts = WorkoutService().sampleWorkouts()

        #expect(workouts.count == 4)
        #expect(workouts.map(\.name) == [
            "Full Body Beginner",
            "Push Day",
            "Pull Day",
            "Leg Day"
        ])
        #expect(workouts.map(\.id) == BuiltInWorkoutCatalogue.allWorkouts.map(\.id))
    }

    @Test func sampleWorkoutsExposeExactNamesDescriptionsTypesAndDurations() {
        let workouts = WorkoutService().sampleWorkouts()

        #expect(workouts.map(\.description) == [
            "A balanced workout targeting all major muscle groups.",
            "Focus on chest, shoulders and triceps.",
            "Train your back, biceps and rear shoulders.",
            "Build lower body strength and stability."
        ])
        let workoutTypes: [WorkoutType] = [.strength, .hypertrophy, .hypertrophy, .strength]
        let estimatedDurations: [TimeInterval] = [45 * 60, 50 * 60, 50 * 60, 60 * 60]

        #expect(workouts.map(\.type) == workoutTypes)
        #expect(workouts.map(\.estimatedDuration) == estimatedDurations)
    }

    @Test func fullBodyBeginnerContainsCatalogueExercisesInOrder() throws {
        let workout = try #require(WorkoutService().sampleWorkouts().first { $0.name == "Full Body Beginner" })

        #expect(workout.exercises.map(\.exercise.name) == [
            "Goblet Squat",
            "Push-up",
            "Bent-over Row"
        ])
        #expect(workout.exercises.map(\.targetSets) == [3, 3, 3])
        #expect(workout.exercises.map(\.targetReps) == [12, 10, 12])
        #expect(workout.exercises.map(\.restSeconds) == [60, 60, 60])
    }

    @Test func pushPullAndLegDaysContainCatalogueDefinedExercises() throws {
        let workouts = WorkoutService().sampleWorkouts()
        let pushDay = try #require(workouts.first { $0.name == "Push Day" })
        let pullDay = try #require(workouts.first { $0.name == "Pull Day" })
        let legDay = try #require(workouts.first { $0.name == "Leg Day" })

        #expect(pushDay.exercises.map(\.exercise.name) == ["Push-up"])
        #expect(pushDay.exercises.map(\.targetSets) == [3])
        #expect(pushDay.exercises.map(\.targetReps) == [10])
        #expect(pushDay.exercises.map(\.restSeconds) == [60])

        #expect(pullDay.exercises.map(\.exercise.name) == ["Bent-over Row"])
        #expect(pullDay.exercises.map(\.targetSets) == [3])
        #expect(pullDay.exercises.map(\.targetReps) == [12])
        #expect(pullDay.exercises.map(\.restSeconds) == [60])

        #expect(legDay.exercises.map(\.exercise.name) == ["Goblet Squat"])
        #expect(legDay.exercises.map(\.targetSets) == [3])
        #expect(legDay.exercises.map(\.targetReps) == [12])
        #expect(legDay.exercises.map(\.restSeconds) == [60])
    }

    @Test func sampleWorkoutExerciseRuntimeFieldsMatchCatalogueMetadata() throws {
        let workouts = WorkoutService().sampleWorkouts()
        let exercises = workouts.flatMap(\.exercises)

        let gobletSquat = try #require(exercises.first { $0.exercise.name == "Goblet Squat" })
        let pushUp = try #require(exercises.first { $0.exercise.name == "Push-up" })
        let bentOverRow = try #require(exercises.first { $0.exercise.name == "Bent-over Row" })

        #expect(gobletSquat.exercise.muscleGroups == [.quadriceps, .glutes])
        #expect(gobletSquat.exercise.workoutType == .strength)
        #expect(gobletSquat.exercise.requiresWeight == true)
        #expect(gobletSquat.exercise.unilateral == false)

        #expect(pushUp.exercise.muscleGroups == [.chest, .triceps])
        #expect(pushUp.exercise.workoutType == .strength)
        #expect(pushUp.exercise.requiresWeight == false)
        #expect(pushUp.exercise.unilateral == false)

        #expect(bentOverRow.exercise.muscleGroups == [.back, .biceps])
        #expect(bentOverRow.exercise.workoutType == .strength)
        #expect(bentOverRow.exercise.requiresWeight == true)
        #expect(bentOverRow.exercise.unilateral == false)
    }

    @Test func repeatedServiceAccessProducesStableBuiltInIdentities() {
        let firstWorkouts = WorkoutService().sampleWorkouts()
        let secondWorkouts = WorkoutService().sampleWorkouts()

        #expect(firstWorkouts.map(\.id) == secondWorkouts.map(\.id))
        #expect(firstWorkouts.map { $0.exercises.map(\.id) } == secondWorkouts.map { $0.exercises.map(\.id) })
        #expect(firstWorkouts.map { $0.exercises.map(\.exercise.id) } == secondWorkouts.map { $0.exercises.map(\.exercise.id) })
        #expect(firstWorkouts == secondWorkouts)
    }

    @Test func serviceOutputMatchesDirectCatalogueMapperOutput() throws {
        let serviceWorkouts = WorkoutService().sampleWorkouts()
        let mappedWorkouts = try CatalogueWorkoutRuntimeMapper.workouts(from: BuiltInWorkoutCatalogue.allWorkouts)

        #expect(serviceWorkouts == mappedWorkouts)
    }
}
