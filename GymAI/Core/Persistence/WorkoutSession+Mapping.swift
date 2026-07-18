//
//  WorkoutSession+Mapping.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation

enum WorkoutSessionMappingError: Error {
    case missingWorkoutRelationship(UUID)
}

extension WorkoutSession {

    init(entity: WorkoutSessionEntity) throws {

        guard let workoutEntity = entity.workout else {
            throw WorkoutSessionMappingError.missingWorkoutRelationship(entity.id)
        }

        self.init(
            id: entity.id,
            workout: try WorkoutMapper.workout(from: workoutEntity),
            startedAt: entity.startedAt,
            endedAt: entity.endedAt,
            completed: entity.completed,
            currentExerciseIndex: entity.currentExerciseIndex,
            currentSet: entity.currentSet,
            completedExercises: entity.completedExercises,
            completedReps: entity.completedReps,
            exerciseResults: Self.exerciseResults(from: entity),
            elapsedTime: entity.elapsedTime
        )
    }

    func update(_ entity: WorkoutSessionEntity) throws {

        entity.workoutName = workout.name
        entity.startedAt = startedAt
        entity.endedAt = endedAt
        entity.completed = completed
        entity.currentExerciseIndex = currentExerciseIndex
        entity.currentSet = currentSet
        entity.completedExercises = completedExercises
        entity.completedReps = completedReps
        entity.exerciseResultsData = try Self.encodeExerciseResults(exerciseResults)
        entity.elapsedTime = elapsedTime
    }

    static func encodeExerciseResults(_ exerciseResults: [WorkoutExerciseResult]) throws -> Data? {
        guard !exerciseResults.isEmpty else {
            return nil
        }

        return try JSONEncoder().encode(exerciseResults)
    }

    private static func exerciseResults(from entity: WorkoutSessionEntity) -> [WorkoutExerciseResult] {
        guard let exerciseResultsData = entity.exerciseResultsData else {
            return []
        }

        return (try? JSONDecoder().decode([WorkoutExerciseResult].self, from: exerciseResultsData)) ?? []
    }
}

extension WorkoutSessionEntity {

    convenience init(session: WorkoutSession) throws {

        self.init(
            id: session.id,
            workoutName: session.workout.name,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            completed: session.completed,
            currentExerciseIndex: session.currentExerciseIndex,
            currentSet: session.currentSet,
            completedExercises: session.completedExercises,
            completedReps: session.completedReps,
            exerciseResultsData: try WorkoutSession.encodeExerciseResults(session.exerciseResults),
            elapsedTime: session.elapsedTime
        )
    }
}
