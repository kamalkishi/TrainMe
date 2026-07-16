//
//  WorkoutMapper.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation

enum WorkoutMapper {

    enum MappingError: Error {
        case corruptedWorkoutSnapshot(underlying: Error)
    }

    static func entity(from workout: Workout) throws -> WorkoutEntity {

        WorkoutEntity(
            id: workout.id,
            name: workout.name,
            type: workout.type.rawValue,
            estimatedDuration: workout.estimatedDuration,
            workoutDescription: workout.description,
            workoutSnapshotData: try encodeSnapshot(for: workout)
        )
    }

    static func update(_ entity: WorkoutEntity, from workout: Workout) throws {
        entity.name = workout.name
        entity.type = workout.type.rawValue
        entity.estimatedDuration = workout.estimatedDuration
        entity.workoutDescription = workout.description
        entity.workoutSnapshotData = try encodeSnapshot(for: workout)
    }

    static func workout(from entity: WorkoutEntity) throws -> Workout {

        guard let snapshotData = entity.workoutSnapshotData else {
            return legacyWorkout(from: entity)
        }

        do {
            return try JSONDecoder().decode(Workout.self, from: snapshotData)
        } catch {
            throw MappingError.corruptedWorkoutSnapshot(underlying: error)
        }
    }

    private static func encodeSnapshot(for workout: Workout) throws -> Data {
        try JSONEncoder().encode(workout)
    }

    private static func legacyWorkout(from entity: WorkoutEntity) -> Workout {

        Workout(
            id: entity.id,
            name: entity.name,
            type: WorkoutType(rawValue: entity.type) ?? .strength,
            exercises: [],
            estimatedDuration: entity.estimatedDuration ?? 0,
            description: entity.workoutDescription ?? ""
        )
    }
}
