import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    private let repository: WorkoutRepositoryProtocol
    private let diagnosticID = UUID()

    private(set) var activeSession: WorkoutSession?

    var sessionToContinue: WorkoutSession?

    var shouldOpenWorkoutLibrary = false

    init() {
        self.repository = WorkoutRepository.shared
        WorkoutLifecycleLog.event("HomeViewModel.init", diagnosticFields)
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
        WorkoutLifecycleLog.event("HomeViewModel.initInjected", diagnosticFields)
    }

    func loadActiveSession() {
        WorkoutLifecycleLog.event(
            "HomeViewModel.loadActiveSession.begin",
            diagnosticFields + displayFields
        )
        activeSession = repository.fetchActiveSession()
        WorkoutLifecycleLog.event(
            "HomeViewModel.loadActiveSession.afterFetch",
            diagnosticFields + displayFields + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
        )
    }

    func continueActiveSession() {
        WorkoutLifecycleLog.event(
            "HomeViewModel.continueActiveSession.begin",
            diagnosticFields + displayFields + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
        )
        loadActiveSession()
        sessionToContinue = activeSession
        WorkoutLifecycleLog.event(
            "HomeViewModel.continueActiveSession.afterRefresh",
            diagnosticFields + displayFields + WorkoutLifecycleLog.session(sessionToContinue, label: "home.sessionToContinue")
        )
    }

    func workoutNavigationPresentationChanged(isPresented: Bool) {
        WorkoutLifecycleLog.event(
            "HomeViewModel.workoutNavigationPresentationChanged",
            diagnosticFields + displayFields + ["workoutNavigation.isPresented=\(isPresented)"]
        )

        guard isPresented == false else {
            return
        }

        WorkoutLifecycleLog.event(
            "HomeViewModel.workoutNavigationClosed.beforeLoadActiveSession",
            diagnosticFields + displayFields
        )
        loadActiveSession()
        WorkoutLifecycleLog.event(
            "HomeViewModel.workoutNavigationClosed.afterLoadActiveSession",
            diagnosticFields + displayFields + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
        )
    }

    func handleWorkoutCompleted(sessionID: UUID) {
        WorkoutLifecycleLog.event(
            "HomeViewModel.handleWorkoutCompleted.begin",
            diagnosticFields
            + displayFields
            + ["completedSessionID=\(sessionID.uuidString)"]
            + WorkoutLifecycleLog.session(activeSession, label: "home.cachedActiveSession")
            + WorkoutLifecycleLog.session(sessionToContinue, label: "home.sessionToContinue")
        )

        guard activeSession?.id == sessionID || sessionToContinue?.id == sessionID else {
            WorkoutLifecycleLog.event(
                "HomeViewModel.handleWorkoutCompleted.skippedSessionMismatch",
                diagnosticFields
                + displayFields
                + ["completedSessionID=\(sessionID.uuidString)"]
                + WorkoutLifecycleLog.session(activeSession, label: "home.cachedActiveSession")
            )
            return
        }

        if activeSession?.id == sessionID {
            activeSession = nil
        }
        if sessionToContinue?.id == sessionID {
            sessionToContinue = nil
        }
        WorkoutLifecycleLog.event(
            "HomeViewModel.handleWorkoutCompleted.afterPresentationSync",
            diagnosticFields + displayFields + ["completedSessionID=\(sessionID.uuidString)"]
        )

        loadActiveSession()
        WorkoutLifecycleLog.event(
            "HomeViewModel.handleWorkoutCompleted.afterVerificationLoad",
            diagnosticFields
            + displayFields
            + ["completedSessionID=\(sessionID.uuidString)"]
            + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
        )
    }

    func dismissWorkoutCompletionSummary() {
        WorkoutLifecycleLog.event(
            "HomeViewModel.dismissWorkoutCompletionSummary",
            diagnosticFields
            + displayFields
            + WorkoutLifecycleLog.session(sessionToContinue, label: "home.sessionToContinue")
        )
        sessionToContinue = nil
    }

    @discardableResult
    func abandonActiveSession() -> Bool {
        WorkoutLifecycleLog.event(
            "HomeViewModel.abandonActiveSession.begin",
            diagnosticFields + displayFields + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
        )
        let abandoned = repository.abandonActiveSession()

        if abandoned {
            loadActiveSession()
            sessionToContinue = nil
            shouldOpenWorkoutLibrary = true
        }

        WorkoutLifecycleLog.event(
            "HomeViewModel.abandonActiveSession.after",
            diagnosticFields
            + displayFields
            + ["abandoned=\(abandoned)"]
            + WorkoutLifecycleLog.session(activeSession, label: "home.activeSession")
            + WorkoutLifecycleLog.session(sessionToContinue, label: "home.sessionToContinue")
        )
        return abandoned
    }

    private var diagnosticFields: [String] {
        [
            "homeViewModel.id=\(diagnosticID)",
            "homeViewModel.object=\(ObjectIdentifier(self))"
        ]
    }

    private var displayFields: [String] {
        [
            "home.displaysContinue=\(activeSession != nil)",
            "home.shouldOpenWorkoutLibrary=\(shouldOpenWorkoutLibrary)"
        ]
    }
}
