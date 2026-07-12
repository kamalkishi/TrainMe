//
//  WorkoutMapper.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation

enum WorkoutMapper {

    static func entity(from workout: Workout) -> WorkoutEntity {

        WorkoutEntity(
            id: workout.id,
            name: workout.name,
            type: workout.type.rawValue
        )
    }

    static func workout(from entity: WorkoutEntity) -> Workout {

        Workout(
            id: entity.id,
            name: entity.name,
            type: WorkoutType(rawValue: entity.type) ?? .strength,
            exercises: [],
            estimatedDuration: 0,
            description: ""
        )
    }
}
