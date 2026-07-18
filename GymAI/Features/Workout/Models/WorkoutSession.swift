import Foundation

struct WorkoutSession: Identifiable, Codable, Hashable {

    let id: UUID

    var workout: Workout

    var startedAt: Date
    var endedAt: Date?

    var completed: Bool

    // NEW
    var currentExerciseIndex: Int
    var currentSet: Int
    var completedExercises: Int
    var completedReps: Int
    var exerciseResults: [WorkoutExerciseResult]
    var elapsedTime: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case id
        case workout
        case startedAt
        case endedAt
        case completed
        case currentExerciseIndex
        case currentSet
        case completedExercises
        case completedReps
        case exerciseResults
        case elapsedTime
    }

    init(
        id: UUID = UUID(),
        workout: Workout,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        completed: Bool = false,
        currentExerciseIndex: Int = 0,
        currentSet: Int = 1,
        completedExercises: Int = 0,
        completedReps: Int = 0,
        exerciseResults: [WorkoutExerciseResult] = [],
        elapsedTime: TimeInterval = 0
    ) {
        self.id = id
        self.workout = workout
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.completed = completed
        self.currentExerciseIndex = currentExerciseIndex
        self.currentSet = currentSet
        self.completedExercises = completedExercises
        self.completedReps = completedReps
        self.exerciseResults = exerciseResults
        self.elapsedTime = elapsedTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            workout: try container.decode(Workout.self, forKey: .workout),
            startedAt: try container.decode(Date.self, forKey: .startedAt),
            endedAt: try container.decodeIfPresent(Date.self, forKey: .endedAt),
            completed: try container.decode(Bool.self, forKey: .completed),
            currentExerciseIndex: try container.decode(Int.self, forKey: .currentExerciseIndex),
            currentSet: try container.decode(Int.self, forKey: .currentSet),
            completedExercises: try container.decode(Int.self, forKey: .completedExercises),
            completedReps: try container.decode(Int.self, forKey: .completedReps),
            exerciseResults: try container.decodeIfPresent([WorkoutExerciseResult].self, forKey: .exerciseResults) ?? [],
            elapsedTime: try container.decode(TimeInterval.self, forKey: .elapsedTime)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(workout, forKey: .workout)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encodeIfPresent(endedAt, forKey: .endedAt)
        try container.encode(completed, forKey: .completed)
        try container.encode(currentExerciseIndex, forKey: .currentExerciseIndex)
        try container.encode(currentSet, forKey: .currentSet)
        try container.encode(completedExercises, forKey: .completedExercises)
        try container.encode(completedReps, forKey: .completedReps)
        try container.encode(exerciseResults, forKey: .exerciseResults)
        try container.encode(elapsedTime, forKey: .elapsedTime)
    }
}
