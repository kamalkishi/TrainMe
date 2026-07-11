import Foundation
import SwiftUI

@Observable
final class WorkoutHistoryViewModel {

    private let repository: WorkoutRepositoryProtocol

    init(
        repository: WorkoutRepositoryProtocol = WorkoutRepository.shared
    ) {
        self.repository = repository
    }

    var history: [WorkoutSessionRecord] {
        repository.fetchWorkoutHistory()
    }
}
