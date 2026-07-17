import Foundation

struct RestTimerContext: Identifiable, Hashable {

    let id: UUID
    let durationSeconds: Int
    let exerciseName: String
    let upcomingSet: Int

    init(
        id: UUID = UUID(),
        durationSeconds: Int,
        exerciseName: String,
        upcomingSet: Int
    ) {
        self.id = id
        self.durationSeconds = durationSeconds
        self.exerciseName = exerciseName
        self.upcomingSet = upcomingSet
    }
}
