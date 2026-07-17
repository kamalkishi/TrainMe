import Foundation
import SwiftUI

@Observable
@MainActor
final class WorkoutHistoryViewModel {

    private let repository: WorkoutRepositoryProtocol
    private let diagnosticID = UUID()

    init() {
        self.repository = WorkoutRepository.shared
        WorkoutLifecycleLog.event("WorkoutHistoryViewModel.init", diagnosticFields)
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
        WorkoutLifecycleLog.event("WorkoutHistoryViewModel.initInjected", diagnosticFields)
    }

    var history: [WorkoutSessionRecord] {
        WorkoutLifecycleLog.event("WorkoutHistoryViewModel.history.begin", diagnosticFields)
        let records = repository.fetchWorkoutHistory()
        WorkoutLifecycleLog.event(
            "WorkoutHistoryViewModel.history.afterFetch",
            diagnosticFields + ["history.count=\(records.count)"]
        )
        return records
    }

    private var diagnosticFields: [String] {
        [
            "workoutHistoryViewModel.id=\(diagnosticID)",
            "workoutHistoryViewModel.object=\(ObjectIdentifier(self))"
        ]
    }
}
