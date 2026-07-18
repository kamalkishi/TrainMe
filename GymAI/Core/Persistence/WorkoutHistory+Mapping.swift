import Foundation

extension WorkoutSessionRecord {

    init(entity: WorkoutHistoryEntity) {
        self.init(
            id: entity.id,
            workoutName: entity.workoutName,
            startedAt: entity.startedAt,
            completedAt: entity.completedAt,
            duration: entity.duration,
            exercisesCompleted: entity.exercisesCompleted,
            exerciseResults: Self.exerciseResults(from: entity)
        )
    }

    static func encodeExerciseSummary(_ exerciseResults: [WorkoutHistoryExerciseRecord]) throws -> Data? {
        guard !exerciseResults.isEmpty else {
            return nil
        }

        return try JSONEncoder().encode(exerciseResults)
    }

    static func exerciseSummary(from activeResults: [WorkoutExerciseResult]) -> [WorkoutHistoryExerciseRecord] {
        activeResults.map { result in
            WorkoutHistoryExerciseRecord(
                exerciseID: result.exerciseID,
                exerciseName: result.exerciseName,
                plannedSets: result.plannedSets,
                plannedReps: result.plannedReps,
                plannedRestSeconds: result.plannedRestSeconds,
                completedSets: result.completedSets,
                completedReps: result.completedReps
            )
        }
    }

    private static func exerciseResults(from entity: WorkoutHistoryEntity) -> [WorkoutHistoryExerciseRecord] {
        guard let exerciseSummaryData = entity.exerciseSummaryData else {
            return []
        }

        return (try? JSONDecoder().decode([WorkoutHistoryExerciseRecord].self, from: exerciseSummaryData)) ?? []
    }
}

extension WorkoutHistoryEntity {

    convenience init(record: WorkoutSessionRecord) throws {
        self.init(
            id: record.id,
            workoutName: record.workoutName,
            startedAt: record.startedAt,
            completedAt: record.completedAt,
            duration: record.duration,
            exercisesCompleted: record.exercisesCompleted,
            exerciseSummaryData: try WorkoutSessionRecord.encodeExerciseSummary(record.exerciseResults)
        )
    }
}
