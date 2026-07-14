import Foundation

import Observation

@Observable
final class WorkoutRepository: WorkoutRepositoryProtocol {

    static let shared = WorkoutRepository()

    private init() {}
    
    private var persistence: WorkoutPersistence?
    
    private var activeSessionID: UUID?

    var activeSession: WorkoutSession?

    var history: [WorkoutSessionRecord] = []
    
    func configure(with persistence: WorkoutPersistence) {
        self.persistence = persistence
    }

    // MARK: - Active Session

    func startSession(for workout: Workout) {

        let session = WorkoutSession(workout: workout)

        activeSession = session

        guard let persistence else {
            return
        }

        do {
            let entity = try persistence.startWorkout(session)

            activeSessionID = entity.id

        } catch {

            print("Failed to start workout session: \(error)")
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

            // We'll populate activeSessionID in the next milestone.
            return session
        } catch {
            print("Failed to load active session: \(error)")
            return nil
        }
    }

    func updateSession(_ session: WorkoutSession) {
        activeSession = session
    }

    func clearActiveSession() {
        activeSession = nil
        activeSessionID = nil
    }

    // MARK: - History

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {

        guard let persistence else {
            return history
        }

        do {
            return try persistence.fetchWorkoutHistory()
        } catch {
            print("Failed to fetch workout history: \(error)")
            return history
        }
    }

    func save(_ workout: WorkoutSessionRecord) {

        history.insert(workout, at: 0)
    }
}
