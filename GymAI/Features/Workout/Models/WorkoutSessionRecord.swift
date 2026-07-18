import Foundation

struct WorkoutSessionRecord: Identifiable, Codable, Hashable {

    let id: UUID
    let workoutName: String
    let startedAt: Date
    let completedAt: Date
    let duration: TimeInterval
    let exercisesCompleted: Int
    let exerciseResults: [WorkoutHistoryExerciseRecord]

    private enum CodingKeys: String, CodingKey {
        case id
        case workoutName
        case startedAt
        case completedAt
        case duration
        case exercisesCompleted
        case exerciseResults
    }

    init(
        id: UUID = UUID(),
        workoutName: String,
        startedAt: Date = .now,
        completedAt: Date = .now,
        duration: TimeInterval,
        exercisesCompleted: Int,
        exerciseResults: [WorkoutHistoryExerciseRecord] = []
    ) {
        self.id = id
        self.workoutName = workoutName
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.exercisesCompleted = exercisesCompleted
        self.exerciseResults = exerciseResults
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            workoutName: try container.decode(String.self, forKey: .workoutName),
            startedAt: try container.decode(Date.self, forKey: .startedAt),
            completedAt: try container.decode(Date.self, forKey: .completedAt),
            duration: try container.decode(TimeInterval.self, forKey: .duration),
            exercisesCompleted: try container.decode(Int.self, forKey: .exercisesCompleted),
            exerciseResults: try container.decodeIfPresent([WorkoutHistoryExerciseRecord].self, forKey: .exerciseResults) ?? []
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(workoutName, forKey: .workoutName)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(duration, forKey: .duration)
        try container.encode(exercisesCompleted, forKey: .exercisesCompleted)
        try container.encode(exerciseResults, forKey: .exerciseResults)
    }
}
