//
//  WorkoutSession+Mapping.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation

extension WorkoutSession {

    init(entity: WorkoutSessionEntity) {

        self.init(
            id: entity.id,
            workout: Workout(
                name: entity.workoutName,
                type: .strength,
                estimatedDuration: 0,
                description: ""
            ),
            startedAt: entity.startedAt,
            endedAt: entity.endedAt,
            completed: entity.completed,
            currentExerciseIndex: entity.currentExerciseIndex,
            currentSet: entity.currentSet,
            completedExercises: entity.completedExercises
        )
    }

    func update(_ entity: WorkoutSessionEntity) {

        entity.workoutName = workout.name
        entity.startedAt = startedAt
        entity.endedAt = endedAt
        entity.completed = completed
        entity.currentExerciseIndex = currentExerciseIndex
        entity.currentSet = currentSet
        entity.completedExercises = completedExercises
    }
}
