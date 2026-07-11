import Foundation

enum WorkoutState: Codable {
    case ready
    case exercising
    case resting
    case paused
    case completed
}
