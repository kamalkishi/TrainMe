import Foundation
import Observation
import OSLog

enum WorkoutLifecycleLog {

    static let prefix = "[WorkoutLifecycle]"

    static func event(
        _ name: String,
        _ fields: [String] = []
    ) {
        print(([prefix, "event=\(name)"] + fields).joined(separator: " "))
    }

    static func workout(_ workout: Workout) -> [String] {
        [
            "workout.name=\"\(workout.name)\"",
            "workout.id=\(workout.id)"
        ]
    }

    static func session(
        _ session: WorkoutSession?,
        label: String = "session"
    ) -> [String] {
        guard let session else {
            return ["\(label).exists=false"]
        }

        return [
            "\(label).exists=true",
            "\(label).id=\(session.id)",
            "\(label).workout.name=\"\(session.workout.name)\"",
            "\(label).workout.id=\(session.workout.id)",
            "\(label).currentExerciseIndex=\(session.currentExerciseIndex)",
            "\(label).exerciseNumber=\(session.currentExerciseIndex + 1)",
            "\(label).currentSet=\(session.currentSet)",
            "\(label).completedReps=\(session.completedReps)",
            "\(label).completedExercises=\(session.completedExercises)",
            "\(label).elapsedTime=\(session.elapsedTime)",
            "\(label).completed=\(session.completed)"
        ]
    }

    static func activeWorkout(
        _ activeWorkout: ActiveWorkout,
        label: String = "activeWorkout"
    ) -> [String] {
        [
            "\(label).workout.name=\"\(activeWorkout.workout.name)\"",
            "\(label).workout.id=\(activeWorkout.workout.id)",
            "\(label).currentExerciseIndex=\(activeWorkout.currentExerciseIndex)",
            "\(label).exerciseNumber=\(activeWorkout.currentExerciseIndex + 1)",
            "\(label).currentSet=\(activeWorkout.currentSet)",
            "\(label).completedReps=\(activeWorkout.completedReps)",
            "\(label).elapsedTime=\(activeWorkout.elapsedTime)",
            "\(label).isRunning=\(activeWorkout.isRunning)",
            "\(label).isCompleted=\(activeWorkout.isCompleted)"
        ]
    }

    static func repositoryState(
        activeSession: WorkoutSession?,
        activeSessionID: UUID?
    ) -> [String] {
        [
            "repository.activeSession.exists=\(activeSession != nil)",
            "repository.activeSessionID=\(activeSessionID?.uuidString ?? "nil")"
        ] + session(activeSession, label: "repository.activeSession")
    }

    static func entity(
        _ entity: WorkoutSessionEntity?,
        label: String = "entity"
    ) -> [String] {
        guard let entity else {
            return ["\(label).exists=false"]
        }

        return [
            "\(label).exists=true",
            "\(label).id=\(entity.id)",
            "\(label).workoutName=\"\(entity.workoutName)\"",
            "\(label).currentExerciseIndex=\(entity.currentExerciseIndex)",
            "\(label).exerciseNumber=\(entity.currentExerciseIndex + 1)",
            "\(label).currentSet=\(entity.currentSet)",
            "\(label).completedReps=\(entity.completedReps)",
            "\(label).completedExercises=\(entity.completedExercises)",
            "\(label).elapsedTime=\(entity.elapsedTime)",
            "\(label).completed=\(entity.completed)"
        ]
    }

    static func history(
        _ record: WorkoutSessionRecord,
        label: String = "history"
    ) -> [String] {
        [
            "\(label).id=\(record.id)",
            "\(label).workoutName=\"\(record.workoutName)\"",
            "\(label).duration=\(record.duration)",
            "\(label).exercisesCompleted=\(record.exercisesCompleted)"
        ]
    }
}

@Observable
@MainActor
final class WorkoutRepository: WorkoutRepositoryProtocol {

    static let shared = WorkoutRepository()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "GymAI",
        category: "WorkoutRepository"
    )

    init() {}
    
    private var persistence: WorkoutPersistence?
    
    private var activeSessionID: UUID?

    var activeSession: WorkoutSession?

    var history: [WorkoutSessionRecord] = []

    private(set) var lastError: Error?

    enum RepositoryError: Error {
        case missingActiveSessionID
    }
    
    func configure(with persistence: WorkoutPersistence) {
        guard self.persistence == nil else {
            WorkoutLifecycleLog.event(
                "Repository.configure.skipped",
                WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return
        }

        self.persistence = persistence
        WorkoutLifecycleLog.event(
            "Repository.configure.attached",
            WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )
    }

    // MARK: - Active Session

    func startSession(for workout: Workout) {

        WorkoutLifecycleLog.event(
            "Repository.startSession.begin",
            WorkoutLifecycleLog.workout(workout)
            + WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        if let activeSession {
            WorkoutLifecycleLog.event(
                "Repository.startSession.skippedExistingActiveSession",
                WorkoutLifecycleLog.workout(workout)
                + WorkoutLifecycleLog.session(activeSession, label: "existingSession")
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return
        }

        var session = WorkoutSession(workout: workout)
        session.exerciseResults = ActiveWorkout(workout: workout).exerciseResults

        activeSession = session
        activeSessionID = session.id

        WorkoutLifecycleLog.event(
            "Repository.startSession.memorySet",
            WorkoutLifecycleLog.session(session)
            + WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        guard let persistence else {
            WorkoutLifecycleLog.event(
                "Repository.startSession.noPersistence",
                WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return
        }

        do {
            let entity = try persistence.startWorkout(session)

            activeSessionID = entity.id
            lastError = nil

            WorkoutLifecycleLog.event(
                "Repository.startSession.persisted",
                WorkoutLifecycleLog.entity(entity)
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )

        } catch {

            lastError = error
            logger.error("Failed to start workout session: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.startSession.failed",
                ["error=\"\(error.localizedDescription)\""]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
        }
    }

    func fetchActiveSession() -> WorkoutSession? {

        WorkoutLifecycleLog.event(
            "Repository.fetchActiveSession.begin",
            WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        if let activeSession {
            guard activeSession.completed == false else {
                WorkoutLifecycleLog.event(
                    "Repository.fetchActiveSession.clearedCompletedMemory",
                    WorkoutLifecycleLog.session(activeSession)
                )
                self.activeSession = nil
                self.activeSessionID = nil
                return fetchActiveSession()
            }

            WorkoutLifecycleLog.event(
                "Repository.fetchActiveSession.memoryHit",
                WorkoutLifecycleLog.session(activeSession)
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: self.activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return activeSession
        }

        guard let persistence else {
            WorkoutLifecycleLog.event("Repository.fetchActiveSession.noPersistence")
            return nil
        }

        do {
            let session = try persistence.loadActiveSession()
            activeSession = session
            activeSessionID = session?.id

            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.fetchActiveSession.loaded",
                WorkoutLifecycleLog.session(session)
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return session
        } catch {
            lastError = error
            logger.error("Failed to load active session: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.fetchActiveSession.failed",
                ["error=\"\(error.localizedDescription)\""]
            )
            return nil
        }
    }

    func updateSession(_ session: WorkoutSession) {
        WorkoutLifecycleLog.event(
            "Repository.updateSession.begin",
            WorkoutLifecycleLog.session(session)
            + WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        activeSession = session

        guard let persistence else {
            WorkoutLifecycleLog.event(
                "Repository.updateSession.noPersistence",
                WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return
        }

        let sessionID = activeSessionID ?? session.id
        activeSessionID = sessionID

        do {
            try persistence.saveSession(session, sessionID: sessionID)
            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.updateSession.persisted",
                WorkoutLifecycleLog.session(session)
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
        } catch {
            lastError = error
            logger.error("Failed to update workout session: \(error.localizedDescription)")

            if case WorkoutPersistence.PersistenceError.sessionNotFound = error {
                WorkoutLifecycleLog.event(
                    "Repository.updateSession.clearingMissingSessionMemory",
                    WorkoutLifecycleLog.session(session)
                    + WorkoutLifecycleLog.repositoryState(
                        activeSession: activeSession,
                        activeSessionID: activeSessionID
                    )
                )
                activeSession = nil
                activeSessionID = nil
            }

            WorkoutLifecycleLog.event(
                "Repository.updateSession.failed",
                ["error=\"\(error.localizedDescription)\""]
                + WorkoutLifecycleLog.session(session)
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
        }
    }

    func clearActiveSession() {
        _ = abandonActiveSession()
    }

    @discardableResult
    func clearActiveSession(ifSessionID sessionID: UUID) -> Bool {
        WorkoutLifecycleLog.event(
            "Repository.clearActiveSessionIfCurrent.begin",
            ["requestedSessionID=\(sessionID)"]
            + WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        guard activeSessionID == sessionID else {
            WorkoutLifecycleLog.event(
                "Repository.clearActiveSessionIfCurrent.skippedSessionMismatch",
                ["requestedSessionID=\(sessionID)"]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return false
        }

        guard let persistence else {
            activeSession = nil
            activeSessionID = nil
            WorkoutLifecycleLog.event("Repository.clearActiveSessionIfCurrent.memoryClearedNoPersistence")
            return true
        }

        do {
            try persistence.deleteSession(sessionID: sessionID)
            activeSession = nil
            activeSessionID = nil
            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.clearActiveSessionIfCurrent.deletedAndCleared",
                ["requestedSessionID=\(sessionID)"]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return true
        } catch {
            lastError = error
            logger.error("Failed to clear active workout session: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.clearActiveSessionIfCurrent.failed",
                ["requestedSessionID=\(sessionID)", "error=\"\(error.localizedDescription)\""]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return false
        }
    }

    @discardableResult
    func abandonActiveSession() -> Bool {
        WorkoutLifecycleLog.event(
            "Repository.abandonActiveSession.begin",
            WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        guard activeSessionID != nil else {
            guard activeSession != nil else {
                lastError = nil
                WorkoutLifecycleLog.event("Repository.abandonActiveSession.noActiveSession")
                return true
            }

            guard persistence == nil else {
                lastError = RepositoryError.missingActiveSessionID
                logger.error("Failed to abandon active workout session: missing active session ID")
                WorkoutLifecycleLog.event(
                    "Repository.abandonActiveSession.failedMissingID",
                    WorkoutLifecycleLog.repositoryState(
                        activeSession: activeSession,
                        activeSessionID: activeSessionID
                    )
                )
                return false
            }

            activeSession = nil
            WorkoutLifecycleLog.event("Repository.abandonActiveSession.memoryClearedNoPersistence")
            return true
        }

        guard let persistence else {
            activeSession = nil
            activeSessionID = nil
            WorkoutLifecycleLog.event("Repository.abandonActiveSession.memoryClearedNoPersistence")
            return true
        }

        do {
            try persistence.deleteIncompleteSessions()
            activeSession = nil
            activeSessionID = nil
            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.abandonActiveSession.deletedIncompleteAndCleared",
                WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return true
        } catch {
            lastError = error
            logger.error("Failed to abandon active workout session: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.abandonActiveSession.failed",
                ["error=\"\(error.localizedDescription)\""]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
            return false
        }
    }

    private func clearCompletedSessionFromMemory() {
        activeSession = nil
        activeSessionID = nil
        WorkoutLifecycleLog.event("Repository.clearCompletedSessionFromMemory")
    }

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {
        WorkoutLifecycleLog.event("Repository.fetchWorkoutHistory.begin")

        guard let persistence else {
            WorkoutLifecycleLog.event(
                "Repository.fetchWorkoutHistory.memory",
                ["history.count=\(history.count)"]
            )
            return history
        }

        do {
            let records = try persistence.fetchWorkoutHistory()
            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.fetchWorkoutHistory.loaded",
                ["history.count=\(records.count)"]
            )
            return records
        } catch {
            lastError = error
            logger.error("Failed to fetch workout history: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.fetchWorkoutHistory.failed",
                ["error=\"\(error.localizedDescription)\"", "fallback.count=\(history.count)"]
            )
            return history
        }
    }

    func save(_ workout: WorkoutSessionRecord) {
        WorkoutLifecycleLog.event(
            "Repository.saveHistory.begin",
            WorkoutLifecycleLog.history(workout)
            + WorkoutLifecycleLog.repositoryState(
                activeSession: activeSession,
                activeSessionID: activeSessionID
            )
        )

        guard let sessionID = activeSessionID else {
            if persistence == nil {
                history.insert(workout, at: 0)
                WorkoutLifecycleLog.event(
                    "Repository.saveHistory.memoryInserted",
                    ["history.count=\(history.count)"]
                )
            } else {
                lastError = RepositoryError.missingActiveSessionID
                logger.error("Failed to complete workout session: missing active session ID")
                WorkoutLifecycleLog.event("Repository.saveHistory.failedMissingID")
            }

            return
        }

        guard let persistence else {
            history.insert(workout, at: 0)
            clearCompletedSessionFromMemory()
            WorkoutLifecycleLog.event(
                "Repository.saveHistory.memoryInsertedAndCleared",
                ["history.count=\(history.count)"]
            )
            return
        }

        do {
            if var session = activeSession {
                WorkoutLifecycleLog.event(
                    "Repository.saveHistory.finalSessionBeforePersist",
                    WorkoutLifecycleLog.session(session)
                )

                session.completed = true

                if session.endedAt == nil {
                    session.endedAt = workout.completedAt
                }

                if session.elapsedTime == 0 {
                    session.elapsedTime = workout.duration
                }

                if session.completedExercises == 0 {
                    session.completedExercises = workout.exercisesCompleted
                }

                activeSession = session

                try persistence.saveSession(session, sessionID: sessionID)
                WorkoutLifecycleLog.event(
                    "Repository.saveHistory.finalSessionPersisted",
                    WorkoutLifecycleLog.session(session)
                )
            }

            let completedRecord = try persistence.completeSession(sessionID: sessionID)
            history.removeAll { $0.id == sessionID }
            history.insert(completedRecord, at: 0)
            clearCompletedSessionFromMemory()
            lastError = nil
            WorkoutLifecycleLog.event(
                "Repository.saveHistory.completed",
                WorkoutLifecycleLog.history(completedRecord)
                + ["history.count=\(history.count)"]
            )
        } catch {
            lastError = error
            logger.error("Failed to complete workout session: \(error.localizedDescription)")
            WorkoutLifecycleLog.event(
                "Repository.saveHistory.failed",
                ["error=\"\(error.localizedDescription)\""]
                + WorkoutLifecycleLog.repositoryState(
                    activeSession: activeSession,
                    activeSessionID: activeSessionID
                )
            )
        }
    }
}
