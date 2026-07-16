import Foundation
import SwiftUI

@Observable
@MainActor
final class WorkoutHistoryViewModel {

    private let repository: WorkoutRepositoryProtocol

    init() {
        self.repository = WorkoutRepository.shared
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
    }

    var history: [WorkoutSessionRecord] {
        repository.fetchWorkoutHistory()
    }
}
