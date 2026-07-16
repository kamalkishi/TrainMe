import Foundation
import Observation
import OSLog

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
            return
        }

        self.persistence = persistence
    }

    // MARK: - Active Session

    func startSession(for workout: Workout) {

        let session = WorkoutSession(workout: workout)

        activeSession = session
        activeSessionID = session.id

        guard let persistence else {
            return
        }

        do {
            let entity = try persistence.startWorkout(session)

            activeSessionID = entity.id
            lastError = nil

        } catch {

            lastError = error
            logger.error("Failed to start workout session: \(error.localizedDescription)")
        }
    }

    func fetchActiveSession() -> WorkoutSession? {

        if let activeSession {
            return activeSession
        }

        guard let persistence else {
            return nil
        }

        do {
            let session = try persistence.loadActiveSession()
            activeSession = session
            activeSessionID = session?.id

            lastError = nil
            return session
        } catch {
            lastError = error
            logger.error("Failed to load active session: \(error.localizedDescription)")
            return nil
        }
    }

    func updateSession(_ session: WorkoutSession) {
        activeSession = session

        guard let persistence else {
            return
        }

        let sessionID = activeSessionID ?? session.id
        activeSessionID = sessionID

        do {
            try persistence.saveSession(session, sessionID: sessionID)
            lastError = nil
        } catch {
            lastError = error
            logger.error("Failed to update workout session: \(error.localizedDescription)")
        }
    }

    func clearActiveSession() {
        _ = abandonActiveSession()
    }

    @discardableResult
    func abandonActiveSession() -> Bool {
        guard let sessionID = activeSessionID else {
            guard activeSession != nil else {
                lastError = nil
                return true
            }

            guard persistence == nil else {
                lastError = RepositoryError.missingActiveSessionID
                logger.error("Failed to abandon active workout session: missing active session ID")
                return false
            }

            activeSession = nil
            return true
        }

        guard let persistence else {
            activeSession = nil
            activeSessionID = nil
            return true
        }

        do {
            try persistence.deleteSession(sessionID: sessionID)
            activeSession = nil
            activeSessionID = nil
            lastError = nil
            return true
        } catch {
            lastError = error
            logger.error("Failed to abandon active workout session: \(error.localizedDescription)")
            return false
        }
    }

    private func clearCompletedSessionFromMemory() {
        activeSession = nil
        activeSessionID = nil
    }

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {

        guard let persistence else {
            return history
        }

        do {
            let records = try persistence.fetchWorkoutHistory()
            lastError = nil
            return records
        } catch {
            lastError = error
            logger.error("Failed to fetch workout history: \(error.localizedDescription)")
            return history
        }
    }

    func save(_ workout: WorkoutSessionRecord) {

        guard let sessionID = activeSessionID else {
            if persistence == nil {
                history.insert(workout, at: 0)
            } else {
                lastError = RepositoryError.missingActiveSessionID
                logger.error("Failed to complete workout session: missing active session ID")
            }

            return
        }

        guard let persistence else {
            history.insert(workout, at: 0)
            clearCompletedSessionFromMemory()
            return
        }

        do {
            if var session = activeSession {
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
            }

            let completedRecord = try persistence.completeSession(sessionID: sessionID)
            history.removeAll { $0.id == sessionID }
            history.insert(completedRecord, at: 0)
            clearCompletedSessionFromMemory()
            lastError = nil
        } catch {
            lastError = error
            logger.error("Failed to complete workout session: \(error.localizedDescription)")
        }
    }
}
