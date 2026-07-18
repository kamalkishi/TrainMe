import Foundation
import SwiftData

@Model
final class WorkoutSessionEntity {

    @Attribute(.unique)
    var id: UUID
    
    @Relationship
    var workout: WorkoutEntity?

    var workoutName: String
    var startedAt: Date
    var endedAt: Date?
    var completed: Bool
    var currentExerciseIndex: Int
    var currentSet: Int
    var completedExercises: Int
    var completedReps: Int
    var exerciseResultsData: Data?
    var elapsedTime: TimeInterval

    init(
        id: UUID = UUID(),
        workoutName: String,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        completed: Bool = false,
        currentExerciseIndex: Int = 0,
        currentSet: Int = 1,
        completedExercises: Int = 0,
        completedReps: Int = 0,
        exerciseResultsData: Data? = nil,
        elapsedTime: TimeInterval = 0
    ) {
        self.id = id
        self.workoutName = workoutName
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.completed = completed
        self.currentExerciseIndex = currentExerciseIndex
        self.currentSet = currentSet
        self.completedExercises = completedExercises
        self.completedReps = completedReps
        self.exerciseResultsData = exerciseResultsData
        self.elapsedTime = elapsedTime
    }
}
