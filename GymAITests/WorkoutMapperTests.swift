import Foundation
import Testing
@testable import GymAI

@Suite("Workout mapper")
@MainActor
struct WorkoutMapperTests {

    @Test
    func completeWorkoutSnapshotRoundTrip() throws {
        let workout = Self.makeWorkout()

        let entity = try WorkoutMapper.entity(from: workout)
        let restoredWorkout = try WorkoutMapper.workout(from: entity)

        #expect(restoredWorkout == workout)
        #expect(entity.name == workout.name)
        #expect(entity.type == workout.type.rawValue)
        #expect(entity.estimatedDuration == workout.estimatedDuration)
        #expect(entity.workoutDescription == workout.description)
        #expect(entity.workoutSnapshotData != nil)
    }

    @Test
    func missingSnapshotUsesLegacyFallback() throws {
        let entity = WorkoutEntity(
            id: UUID(),
            name: "Legacy Strength",
            type: WorkoutType.hypertrophy.rawValue,
            estimatedDuration: 1_800,
            workoutDescription: "Legacy stored workout",
            workoutSnapshotData: nil
        )

        let workout = try WorkoutMapper.workout(from: entity)

        #expect(workout.id == entity.id)
        #expect(workout.name == "Legacy Strength")
        #expect(workout.type == .hypertrophy)
        #expect(workout.exercises.isEmpty)
        #expect(workout.estimatedDuration == 1_800)
        #expect(workout.description == "Legacy stored workout")
    }

    @Test
    func missingSnapshotWithNilMetadataUsesExplicitFallbackValues() throws {
        let entity = WorkoutEntity(
            id: UUID(),
            name: "Legacy Minimal",
            type: WorkoutType.mobility.rawValue,
            estimatedDuration: nil,
            workoutDescription: nil,
            workoutSnapshotData: nil
        )

        let workout = try WorkoutMapper.workout(from: entity)

        #expect(workout.id == entity.id)
        #expect(workout.name == "Legacy Minimal")
        #expect(workout.type == WorkoutType.mobility)
        #expect(workout.exercises.isEmpty)
        #expect(workout.estimatedDuration == 0)
        #expect(workout.description == "")
    }

    @Test
    func corruptedSnapshotThrows() throws {
        let entity = WorkoutEntity(
            id: UUID(),
            name: "Corrupted",
            type: WorkoutType.strength.rawValue,
            estimatedDuration: 900,
            workoutDescription: "Bad snapshot",
            workoutSnapshotData: Data("not-json".utf8)
        )

        do {
            _ = try WorkoutMapper.workout(from: entity)
            Issue.record("Expected corrupted snapshot decoding to throw.")
        } catch WorkoutMapper.MappingError.corruptedWorkoutSnapshot {
            #expect(true)
        } catch {
            Issue.record("Expected corruptedWorkoutSnapshot, got \(error).")
        }
    }

    static func makeWorkout(id: UUID = UUID(), name: String = "Full Body Beginner") -> Workout {
        Workout(
            id: id,
            name: name,
            type: .hypertrophy,
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Goblet Squat",
                        muscleGroups: [.quadriceps, .glutes],
                        workoutType: .strength,
                        requiresWeight: true
                    ),
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                ),
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Push-up",
                        muscleGroups: [.chest, .triceps],
                        workoutType: .strength,
                        requiresWeight: false
                    ),
                    targetSets: 2,
                    targetReps: 10,
                    restSeconds: 45
                )
            ],
            estimatedDuration: 2_700,
            description: "A complete persisted workout."
        )
    }
}
