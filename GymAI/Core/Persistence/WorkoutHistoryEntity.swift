import Foundation
import SwiftData

@Model
final class WorkoutHistoryEntity {

    @Attribute(.unique)
    var id: UUID

    var workoutName: String

    var startedAt: Date
    var completedAt: Date

    var duration: TimeInterval

    var exercisesCompleted: Int
    var exerciseSummaryData: Data?

    init(
        id: UUID = UUID(),
        workoutName: String,
        startedAt: Date,
        completedAt: Date,
        duration: TimeInterval,
        exercisesCompleted: Int,
        exerciseSummaryData: Data? = nil
    ) {
        self.id = id
        self.workoutName = workoutName
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.exercisesCompleted = exercisesCompleted
        self.exerciseSummaryData = exerciseSummaryData
    }
}
