import Foundation
import SwiftUI

@Observable
@MainActor
final class ActiveWorkoutViewModel {
    
    private let repository: WorkoutRepositoryProtocol
    private let diagnosticID = UUID()
    private var ownedSessionID: UUID?
    
    var activeWorkout: ActiveWorkout
    private(set) var completedSessionID: UUID?
    private(set) var completionSummary: WorkoutCompletionSummary?
    private(set) var pendingRestTimerContext: RestTimerContext?

    init(workout: Workout) {
        self.activeWorkout = ActiveWorkout(workout: workout)
        self.repository = WorkoutRepository.shared

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initWorkout.begin",
            diagnosticFields
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        ownedSessionID = repository.fetchActiveSession()?.id

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initWorkout.afterActiveSessionLookup",
            diagnosticFields
            + ["ownedSessionID=\(ownedSessionID?.uuidString ?? "nil")"]
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
        )
    }

    init(
        workout: Workout,
        repository: WorkoutRepositoryProtocol
    ) {
        self.activeWorkout = ActiveWorkout(workout: workout)
        self.repository = repository

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initWorkoutInjected.begin",
            diagnosticFields
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        ownedSessionID = repository.fetchActiveSession()?.id

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initWorkoutInjected.afterActiveSessionLookup",
            diagnosticFields
            + ["ownedSessionID=\(ownedSessionID?.uuidString ?? "nil")"]
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
        )
    }

    init(session: WorkoutSession) {
        self.repository = WorkoutRepository.shared
        self.activeWorkout = ActiveWorkout(session: session)
        self.ownedSessionID = session.id

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initSession.begin",
            diagnosticFields
            + ["ownedSessionID=\(ownedSessionID?.uuidString ?? "nil")"]
            + WorkoutLifecycleLog.session(session)
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initSession.ready",
            diagnosticFields
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )
    }

    init(
        session: WorkoutSession,
        repository: WorkoutRepositoryProtocol
    ) {
        self.repository = repository
        self.activeWorkout = ActiveWorkout(session: session)
        self.ownedSessionID = session.id

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initSessionInjected.begin",
            diagnosticFields
            + ["ownedSessionID=\(ownedSessionID?.uuidString ?? "nil")"]
            + WorkoutLifecycleLog.session(session)
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.initSessionInjected.ready",
            diagnosticFields
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )
    }

    var diagnosticIdentifier: UUID {
        diagnosticID
    }

    private var diagnosticFields: [String] {
        [
            "activeWorkoutViewModel.id=\(diagnosticID)",
            "activeWorkoutViewModel.object=\(ObjectIdentifier(self))",
            "ownedSessionID=\(ownedSessionID?.uuidString ?? "nil")"
        ]
    }

    var workout: Workout {
        activeWorkout.workout
    }

    var currentExercise: WorkoutExercise? {
        activeWorkout.currentWorkoutExercise
    }
    
    var currentExerciseNumber: Int {
        activeWorkout.currentExerciseIndex + 1
    }

    var totalExercises: Int {
        workout.exercises.count
    }

    var isFirstExercise: Bool {
        activeWorkout.currentExerciseIndex == 0
    }

    var isLastExercise: Bool {
        guard !workout.exercises.isEmpty else {
            return true
        }

        return activeWorkout.currentExerciseIndex == workout.exercises.count - 1
    }

    var currentSet: Int {
        activeWorkout.currentSet
    }
    
    var isWorkoutCompleted: Bool {
        activeWorkout.isCompleted
    }

    var hasMeaningfulProgress: Bool {
        activeWorkout.currentExerciseIndex > 0
        || activeWorkout.currentSet > 1
        || activeWorkout.completedReps > 0
        || activeWorkout.elapsedTime > 0
        || activeWorkout.isCompleted
    }

    private func hasMeaningfulProgress(_ session: WorkoutSession) -> Bool {
        session.currentExerciseIndex > 0
        || session.currentSet > 1
        || session.completedExercises > 0
        || session.completedReps > 0
        || session.elapsedTime > 0
        || session.completed
    }

    func nextExercise() {
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.nextExercise.begin",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard activeWorkout.currentExerciseIndex < workout.exercises.count - 1 else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.nextExercise.ignoredLastExercise",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }

        activeWorkout.currentExerciseIndex += 1
        activeWorkout.currentSet = 1
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.nextExercise.beforeSync",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )
        syncSession()
    }

    func previousExercise() {
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.previousExercise.begin",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard activeWorkout.currentExerciseIndex > 0 else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.previousExercise.ignoredFirstExercise",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }

        activeWorkout.currentExerciseIndex -= 1
        activeWorkout.currentSet = 1
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.previousExercise.beforeSync",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )
        syncSession()
    }
    
    func completeSet() {
        pendingRestTimerContext = nil

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.completeSet.begin",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard let workoutExercise = activeWorkout.currentWorkoutExercise else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.completeSet.noCurrentExercise",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }
        
        if activeWorkout.currentSet < workoutExercise.targetSets {

            activeWorkout.completedReps += workoutExercise.targetReps
            activeWorkout.currentSet += 1
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.completeSet.progressedSet.beforeSync",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            syncSession()
            prepareRestTimerContext(
                afterCompleting: workoutExercise,
                upcomingExercise: activeWorkout.currentWorkoutExercise,
                upcomingSet: activeWorkout.currentSet
            )

        } else {

            activeWorkout.completedReps += workoutExercise.targetReps
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.completeSet.finishedExercise",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )

            if activeWorkout.currentExerciseIndex < workout.exercises.count - 1 {

                activeWorkout.currentSet = 1
                activeWorkout.currentExerciseIndex += 1
                WorkoutLifecycleLog.event(
                    "ActiveWorkoutViewModel.completeSet.nextExercise.beforeSync",
                    diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
                )
                syncSession()
                prepareRestTimerContext(
                    afterCompleting: workoutExercise,
                    upcomingExercise: activeWorkout.currentWorkoutExercise,
                    upcomingSet: activeWorkout.currentSet
                )

            } else {
                activeWorkout.isCompleted = true
                WorkoutLifecycleLog.event(
                    "ActiveWorkoutViewModel.completeSet.finalSetCompleted",
                    diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
                )

        if var session = repository.fetchActiveSession() {
                    guard session.id == ownedSessionID else {
                        WorkoutLifecycleLog.event(
                            "ActiveWorkoutViewModel.completeSet.finalSet.skippedSessionMismatch",
                            diagnosticFields + WorkoutLifecycleLog.session(session, label: "fetchedActiveSession")
                        )
                        return
                    }

                    session.completed = true
                    session.endedAt = Date()
                    session.currentExerciseIndex = activeWorkout.currentExerciseIndex
                    session.currentSet = activeWorkout.currentSet
                    session.completedExercises = workout.exercises.count
                    session.completedReps = activeWorkout.completedReps
                    session.elapsedTime = session.endedAt?.timeIntervalSince(session.startedAt) ?? 0
                    WorkoutLifecycleLog.event(
                        "ActiveWorkoutViewModel.completeSet.finalSet.beforeSaveHistory",
                        diagnosticFields + WorkoutLifecycleLog.session(session)
                    )
                    repository.updateSession(session)
                    let record = WorkoutSessionRecord(
                        id: session.id,
                        workoutName: session.workout.name,
                        startedAt: session.startedAt,
                        completedAt: session.endedAt ?? .now,
                        duration: session.elapsedTime,
                        exercisesCompleted: session.completedExercises
                    )
                    repository.save(record)
                    completedSessionID = session.id
                    completionSummary = WorkoutCompletionSummary(
                        sessionID: session.id,
                        activeWorkout: activeWorkout,
                        duration: session.elapsedTime,
                        includesCurrentSetCompletion: true
                    )
                    WorkoutLifecycleLog.event(
                        "ActiveWorkoutViewModel.completionSummaryCreated",
                        diagnosticFields
                        + ["completedSessionID=\(session.id.uuidString)"]
                        + ["completionSummary.sets=\(completionSummary?.completedSets ?? 0)"]
                        + ["completionSummary.reps=\(completionSummary?.completedReps ?? 0)"]
                    )
                    WorkoutLifecycleLog.event(
                        "ActiveWorkoutViewModel.completeSet.finalSet.afterSaveHistory",
                        diagnosticFields
                        + ["completedSessionID=\(completedSessionID?.uuidString ?? "nil")"]
                        + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
                    )
                }
            }
        }
    }
    
    @discardableResult
    func finishWorkout() -> WorkoutCompletionSummary? {
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.finishWorkout.begin",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard completedSessionID == nil else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.finishWorkout.ignoredAlreadyCompleted",
                diagnosticFields
                + ["completedSessionID=\(completedSessionID?.uuidString ?? "nil")"]
            )
            return nil
        }

        guard var session = repository.fetchActiveSession() else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.finishWorkout.noActiveSession",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return nil
        }

        guard session.id == ownedSessionID else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.finishWorkout.skippedSessionMismatch",
                diagnosticFields + WorkoutLifecycleLog.session(session, label: "fetchedActiveSession")
            )
            return nil
        }

        session.completed = true
        session.endedAt = Date()
        session.completedReps = activeWorkout.completedReps
        session.elapsedTime = session.endedAt?.timeIntervalSince(session.startedAt) ?? 0

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.finishWorkout.beforeUpdateSession",
            diagnosticFields + WorkoutLifecycleLog.session(session)
        )
        repository.updateSession(session)
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.finishWorkout.afterUpdateSession",
            diagnosticFields
            + WorkoutLifecycleLog.session(session, label: "updatedSession")
        )

        let record = WorkoutSessionRecord(
            id: session.id,
            workoutName: session.workout.name,
            startedAt: session.startedAt,
            completedAt: session.endedAt ?? .now,
            duration: session.elapsedTime,
            exercisesCompleted: session.completedExercises
        )

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.finishWorkout.beforeSaveHistory",
            diagnosticFields + WorkoutLifecycleLog.history(record)
        )
        repository.save(record)

        activeWorkout.isCompleted = true
        pendingRestTimerContext = nil
        completedSessionID = session.id
        completionSummary = WorkoutCompletionSummary(
            sessionID: session.id,
            activeWorkout: activeWorkout,
            duration: session.elapsedTime,
            includesCurrentSetCompletion: false
        )
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.completionSummaryCreated",
            diagnosticFields
            + ["completedSessionID=\(session.id.uuidString)"]
            + ["completionSummary.sets=\(completionSummary?.completedSets ?? 0)"]
            + ["completionSummary.reps=\(completionSummary?.completedReps ?? 0)"]
        )
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.finishWorkout.afterSaveHistory",
            diagnosticFields
            + ["completedSessionID=\(completedSessionID?.uuidString ?? "nil")"]
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
        )

        return completionSummary
    }
    
    private func syncSession() {

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.syncSession.begin",
            diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard var session = repository.fetchActiveSession() else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.syncSession.noActiveSession",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }

        guard session.id == ownedSessionID else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.syncSession.skippedSessionMismatch",
                diagnosticFields + WorkoutLifecycleLog.session(session, label: "fetchedActiveSession")
            )
            return
        }

        session.currentExerciseIndex = activeWorkout.currentExerciseIndex
        session.currentSet = activeWorkout.currentSet
        session.completedExercises = activeWorkout.currentExerciseIndex
        session.completedReps = activeWorkout.completedReps
        session.elapsedTime = Date().timeIntervalSince(session.startedAt)

        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.syncSession.beforeUpdateSession",
            diagnosticFields + WorkoutLifecycleLog.session(session)
        )
        repository.updateSession(session)
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.syncSession.afterUpdateSession",
            diagnosticFields
            + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
        )
    }

    private func prepareRestTimerContext(
        afterCompleting workoutExercise: WorkoutExercise,
        upcomingExercise: WorkoutExercise?,
        upcomingSet: Int
    ) {
        guard
            workoutExercise.restSeconds > 0,
            let upcomingExercise
        else {
            return
        }

        pendingRestTimerContext = RestTimerContext(
            durationSeconds: workoutExercise.restSeconds,
            exerciseName: upcomingExercise.exercise.name,
            upcomingSet: upcomingSet
        )
    }

    func discardIfUnstarted() {
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.discardIfUnstarted.begin",
            diagnosticFields
            + ["hasMeaningfulProgress=\(hasMeaningfulProgress)"]
            + WorkoutLifecycleLog.activeWorkout(activeWorkout)
        )

        guard !hasMeaningfulProgress else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.discardIfUnstarted.preserved",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }

        guard let ownedSessionID else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.discardIfUnstarted.skippedMissingOwnedSession",
                diagnosticFields + WorkoutLifecycleLog.activeWorkout(activeWorkout)
            )
            return
        }

        let activeSession = repository.fetchActiveSession()
        let matchesActiveSession = activeSession?.id == ownedSessionID
        let activeSessionHasMeaningfulProgress = activeSession.map(hasMeaningfulProgress) ?? false
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.discardIfUnstarted.beforeOwnedClear",
            diagnosticFields
            + ["matchesActiveSession=\(matchesActiveSession)"]
            + ["activeSessionHasMeaningfulProgress=\(activeSessionHasMeaningfulProgress)"]
            + WorkoutLifecycleLog.session(activeSession, label: "fetchedActiveSession")
        )

        guard matchesActiveSession, !activeSessionHasMeaningfulProgress else {
            WorkoutLifecycleLog.event(
                "ActiveWorkoutViewModel.discardIfUnstarted.skippedOwnedClear",
                diagnosticFields
                + ["matchesActiveSession=\(matchesActiveSession)"]
                + ["activeSessionHasMeaningfulProgress=\(activeSessionHasMeaningfulProgress)"]
                + WorkoutLifecycleLog.session(activeSession, label: "fetchedActiveSession")
            )
            return
        }

        let cleared = repository.clearActiveSession(ifSessionID: ownedSessionID)
        WorkoutLifecycleLog.event(
            "ActiveWorkoutViewModel.discardIfUnstarted.cleared",
            diagnosticFields
            + ["cleared=\(cleared)"]
            + WorkoutLifecycleLog.session(repository.fetchActiveSession(), label: "fetchedActiveSession")
        )
    }
}
