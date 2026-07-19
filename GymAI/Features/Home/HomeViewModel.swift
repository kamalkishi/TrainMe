import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    private let repository: WorkoutRepositoryProtocol
    private let completionLifecycle: WorkoutCompletionLifecycle
    private let diagnosticID = UUID()
    private var isResolvingWorkoutChoice = false

    private(set) var activeSession: WorkoutSession?

    var sessionToContinue: WorkoutSession?

    var shouldOpenWorkoutLibrary = false

    init() {
        let repository = WorkoutRepository.shared
        self.repository = repository
        self.completionLifecycle = WorkoutCompletionLifecycle(repository: repository)
        WorkoutLifecycleLog.event("HomeViewModel.init", diagnosticFields)
    }

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
        self.completionLifecycle = WorkoutCompletionLifecycle(repository: repository)
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
    func saveActiveSessionAndOpenWorkoutLibrary() -> Bool {
        guard !isResolvingWorkoutChoice else {
            WorkoutLifecycleLog.event("HomeViewModel.saveAndChooseAnother.ignoredAlreadyResolving", diagnosticFields)
            return false
        }

        loadActiveSession()

        guard let session = activeSession else {
            WorkoutLifecycleLog.event("HomeViewModel.saveAndChooseAnother.noActiveSession", diagnosticFields)
            shouldOpenWorkoutLibrary = true
            return true
        }

        isResolvingWorkoutChoice = true
        defer {
            isResolvingWorkoutChoice = false
        }

        let succeeded: Bool
        if hasMeaningfulProgress(session) {
            succeeded = completionLifecycle.finishActiveSession(session) != nil
        } else {
            succeeded = repository.clearActiveSession(ifSessionID: session.id)
        }

        guard succeeded, repository.fetchActiveSession() == nil else {
            WorkoutLifecycleLog.event(
                "HomeViewModel.saveAndChooseAnother.failed",
                diagnosticFields + WorkoutLifecycleLog.session(session, label: "home.activeSession")
            )
            loadActiveSession()
            return false
        }

        activeSession = nil
        sessionToContinue = nil
        shouldOpenWorkoutLibrary = true
        WorkoutLifecycleLog.event(
            "HomeViewModel.saveAndChooseAnother.succeeded",
            diagnosticFields + WorkoutLifecycleLog.session(session, label: "savedSession")
        )
        return true
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

    private func hasMeaningfulProgress(_ session: WorkoutSession) -> Bool {
        session.currentExerciseIndex > 0
        || session.currentSet > 1
        || session.completedExercises > 0
        || session.completedReps > 0
        || session.elapsedTime > 0
        || session.completed
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
