import Foundation
import SwiftData
import Testing
@testable import GymAI

@MainActor
@Suite("Workout session restore integration")
struct WorkoutSessionRestoreTests {

    @Test
    func activeWorkoutRestoresCompleteSessionState() {
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            completed: false,
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 22,
            elapsedTime: 180
        )

        let activeWorkout = ActiveWorkout(session: session)

        #expect(activeWorkout.workout == session.workout)
        #expect(activeWorkout.currentExerciseIndex == 1)
        #expect(activeWorkout.currentSet == 2)
        #expect(activeWorkout.completedReps == 22)
        #expect(activeWorkout.elapsedTime == 180)
        #expect(activeWorkout.isCompleted == false)
    }

    @Test
    func activeWorkoutClampsInvalidSavedIndex() {
        let workout = WorkoutMapperTests.makeWorkout()
        let tooHighSession = WorkoutSession(
            workout: workout,
            currentExerciseIndex: 99,
            currentSet: 1
        )
        let negativeSession = WorkoutSession(
            workout: workout,
            currentExerciseIndex: -3,
            currentSet: 1
        )

        let tooHighWorkout = ActiveWorkout(session: tooHighSession)
        let negativeWorkout = ActiveWorkout(session: negativeSession)

        #expect(tooHighWorkout.currentExerciseIndex == workout.exercises.count - 1)
        #expect(negativeWorkout.currentExerciseIndex == 0)
    }

    @Test
    func restoredViewModelDoesNotStartNewRepositorySessionAndKeepsIdentity() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 22,
            elapsedTime: 300
        )

        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(viewModel.workout == session.workout)
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(viewModel.currentSet == 2)
    }

    @Test
    func freshViewModelConstructionDoesNotStartOrUpdateRepositorySession() {
        let repository = SpyWorkoutRepository()
        let workout = WorkoutMapperTests.makeWorkout(name: "Fresh Construction")

        let firstViewModel = ActiveWorkoutViewModel(workout: workout, repository: repository)
        let secondViewModel = ActiveWorkoutViewModel(workout: workout, repository: repository)

        #expect(firstViewModel.workout == workout)
        #expect(secondViewModel.workout == workout)
        #expect(firstViewModel.currentExerciseNumber == 1)
        #expect(secondViewModel.currentExerciseNumber == 1)
        #expect(firstViewModel.currentSet == 1)
        #expect(secondViewModel.currentSet == 1)
        #expect(repository.fetchActiveSession() == nil)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
    }

    @Test
    func homeViewModelLoadsAndRefreshesActiveSessionWithoutMutation() {
        let repository = SpyWorkoutRepository()
        let firstSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "First"))
        let secondSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Second"))
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = firstSession
        viewModel.loadActiveSession()

        #expect(viewModel.activeSession?.id == firstSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)

        repository.sessionToFetch = secondSession
        viewModel.loadActiveSession()

        #expect(viewModel.activeSession?.id == secondSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeContinueFetchesLatestActiveSessionAtTapTime() {
        let repository = SpyWorkoutRepository()
        let sessionID = UUID()
        let staleSession = WorkoutSession(
            id: sessionID,
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 0,
            currentSet: 1,
            completedReps: 0,
            elapsedTime: 0
        )
        let latestSession = WorkoutSession(
            id: sessionID,
            workout: staleSession.workout,
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 46,
            elapsedTime: 240
        )
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = staleSession
        viewModel.loadActiveSession()

        repository.sessionToFetch = latestSession
        viewModel.continueActiveSession()

        #expect(viewModel.activeSession?.id == sessionID)
        #expect(viewModel.activeSession?.currentExerciseIndex == 1)
        #expect(viewModel.activeSession?.currentSet == 2)
        #expect(viewModel.activeSession?.completedReps == 46)
        #expect(viewModel.sessionToContinue?.id == sessionID)
        #expect(viewModel.sessionToContinue?.currentExerciseIndex == 1)
        #expect(viewModel.sessionToContinue?.currentSet == 2)
        #expect(viewModel.sessionToContinue?.completedReps == 46)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
    }

    @Test
    func homeNavigationCloseRefreshesNilCacheToShowProgressedActiveSession() {
        let repository = SpyWorkoutRepository()
        let progressedSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 46,
            elapsedTime: 240
        )
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = nil
        viewModel.loadActiveSession()
        #expect(viewModel.activeSession == nil)

        viewModel.shouldOpenWorkoutLibrary = true
        repository.sessionToFetch = progressedSession
        viewModel.workoutNavigationPresentationChanged(isPresented: false)

        #expect(viewModel.activeSession?.id == progressedSession.id)
        #expect(viewModel.activeSession?.currentExerciseIndex == 1)
        #expect(viewModel.activeSession?.currentSet == 2)
        #expect(viewModel.activeSession?.completedReps == 46)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeNavigationCloseRefreshesCachedSessionToHideContinueAfterCompletionOrAbandonment() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedReps: 46
        )
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = session
        viewModel.loadActiveSession()
        #expect(viewModel.activeSession?.id == session.id)

        viewModel.shouldOpenWorkoutLibrary = true
        repository.sessionToFetch = nil
        viewModel.workoutNavigationPresentationChanged(isPresented: false)

        #expect(viewModel.activeSession == nil)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeNavigationOpenDoesNotRefreshOrMutateSessions() {
        let repository = SpyWorkoutRepository()
        let cachedSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Cached"))
        let hiddenSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Hidden"))
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = cachedSession
        viewModel.loadActiveSession()
        repository.sessionToFetch = hiddenSession

        viewModel.workoutNavigationPresentationChanged(isPresented: true)

        #expect(viewModel.activeSession?.id == cachedSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func mainTabCoordinatorRefreshesHomeWhenHomeTabPathBecomesVisible() {
        let repository = SpyWorkoutRepository()
        let progressedSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedExercises: 1,
            completedReps: 46,
            elapsedTime: 240
        )
        let homeViewModel = HomeViewModel(repository: repository)
        let coordinator = MainTabNavigationCoordinator(homeViewModel: homeViewModel)

        repository.sessionToFetch = nil
        homeViewModel.loadActiveSession()
        #expect(homeViewModel.activeSession == nil)

        repository.sessionToFetch = progressedSession
        coordinator.refreshHomeIfVisible(
            selectedTab: .home,
            homeNavigationPathCount: 0,
            reason: "testPathReturnedToHome"
        )

        #expect(homeViewModel.activeSession?.id == progressedSession.id)
        #expect(homeViewModel.activeSession?.currentExerciseIndex == 1)
        #expect(homeViewModel.activeSession?.currentSet == 2)
        #expect(homeViewModel.activeSession?.completedReps == 46)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func mainTabCoordinatorRefreshesHomeToHideContinueWhenNoActiveSessionExists() {
        let repository = SpyWorkoutRepository()
        let cachedSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedReps: 46
        )
        let homeViewModel = HomeViewModel(repository: repository)
        let coordinator = MainTabNavigationCoordinator(homeViewModel: homeViewModel)

        repository.sessionToFetch = cachedSession
        homeViewModel.loadActiveSession()
        #expect(homeViewModel.activeSession?.id == cachedSession.id)

        repository.sessionToFetch = nil
        coordinator.refreshHomeIfVisible(
            selectedTab: .home,
            homeNavigationPathCount: 0,
            reason: "testNoActiveSession"
        )

        #expect(homeViewModel.activeSession == nil)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func mainTabCoordinatorDoesNotRefreshWhileHomeNavigationPathIsNotVisible() {
        let repository = SpyWorkoutRepository()
        let cachedSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Cached"))
        let hiddenSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Hidden"))
        let homeViewModel = HomeViewModel(repository: repository)
        let coordinator = MainTabNavigationCoordinator(homeViewModel: homeViewModel)

        repository.sessionToFetch = cachedSession
        homeViewModel.loadActiveSession()
        repository.sessionToFetch = hiddenSession

        coordinator.refreshHomeIfVisible(
            selectedTab: .home,
            homeNavigationPathCount: 1,
            reason: "testStillInWorkoutNavigation"
        )

        #expect(homeViewModel.activeSession?.id == cachedSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeViewModelClearsCachedCompletedSessionAndActiveSessionNavigation() {
        let repository = SpyWorkoutRepository()
        let completedSessionID = UUID()
        let completedSession = WorkoutSession(
            id: completedSessionID,
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 3,
            completedExercises: 2,
            completedReps: 66
        )
        let homeViewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = completedSession
        homeViewModel.loadActiveSession()
        homeViewModel.continueActiveSession()
        repository.sessionToFetch = nil

        homeViewModel.handleWorkoutCompleted(sessionID: completedSessionID)

        #expect(homeViewModel.activeSession == nil)
        #expect(homeViewModel.sessionToContinue == nil)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeViewModelIgnoresCompletionForDifferentSessionID() {
        let repository = SpyWorkoutRepository()
        let currentSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 0,
            currentSet: 2,
            completedReps: 12
        )
        let homeViewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = currentSession
        homeViewModel.loadActiveSession()

        homeViewModel.handleWorkoutCompleted(sessionID: UUID())

        #expect(homeViewModel.activeSession?.id == currentSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func mainTabCoordinatorCompletionClearsHomeCardWithoutNavigatingHome() {
        let repository = SpyWorkoutRepository()
        let completedSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 3,
            completedReps: 66
        )
        let homeViewModel = HomeViewModel(repository: repository)
        let coordinator = MainTabNavigationCoordinator(homeViewModel: homeViewModel)

        repository.sessionToFetch = completedSession
        homeViewModel.loadActiveSession()
        repository.sessionToFetch = nil

        coordinator.handleWorkoutCompleted(sessionID: completedSession.id)

        #expect(homeViewModel.activeSession == nil)
        #expect(homeViewModel.sessionToContinue == nil)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 0)
        #expect(repository.abandonActiveSessionCallCount == 0)
    }

    @Test
    func homeViewModelSuccessfulDiscardRefreshesActiveSessionAndOpensWorkoutLibrary() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = session
        viewModel.loadActiveSession()

        let abandoned = viewModel.abandonActiveSession()

        #expect(abandoned == true)
        #expect(viewModel.activeSession == nil)
        #expect(viewModel.shouldOpenWorkoutLibrary == true)
        #expect(repository.abandonActiveSessionCallCount == 1)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func homeViewModelAbandonFailureKeepsActiveSessionForRetryAndDoesNotOpenWorkoutLibrary() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let viewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = session
        repository.shouldAbandonActiveSessionSucceed = false
        viewModel.loadActiveSession()

        let abandoned = viewModel.abandonActiveSession()

        #expect(abandoned == false)
        #expect(viewModel.activeSession?.id == session.id)
        #expect(viewModel.shouldOpenWorkoutLibrary == false)
        #expect(repository.abandonActiveSessionCallCount == 1)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func continueWithoutDiscardRestoresOriginalSession() {
        let session = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedReps: 18,
            elapsedTime: 240
        )
        let repository = SpyWorkoutRepository()

        let viewModel = ActiveWorkoutViewModel(session: session, repository: repository)

        #expect(repository.abandonActiveSessionCallCount == 0)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.updateSessionCallCount == 0)
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(viewModel.currentSet == 2)
    }

    @Test
    func workoutDetailsStartsFreshAfterStartFreshDiscard() {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let homeViewModel = HomeViewModel(repository: repository)

        repository.sessionToFetch = session
        homeViewModel.loadActiveSession()
        _ = homeViewModel.abandonActiveSession()

        let detailsViewModel = WorkoutDetailsViewModel(repository: repository)
        let workout = WorkoutMapperTests.makeWorkout(name: "Fresh")
        detailsViewModel.startWorkout(workout)

        #expect(homeViewModel.activeSession == nil)
        #expect(detailsViewModel.freshWorkoutDestination?.workout == workout)
        #expect(detailsViewModel.freshWorkoutDestination?.session.workout == workout)
        #expect(detailsViewModel.sessionToContinue == nil)
        #expect(repository.startSessionCallCount == 1)
    }

    @Test
    func workoutDetailsStartCreatesExactlyOneFreshSessionAndReusesItOnSecondTap() throws {
        let repository = SpyWorkoutRepository()
        let workout = WorkoutMapperTests.makeWorkout(name: "Explicit Start")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(workout)
        let firstDestination = try #require(viewModel.freshWorkoutDestination)
        viewModel.startWorkout(workout)

        #expect(repository.startSessionCallCount == 1)
        #expect(firstDestination.session.workout == workout)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.sessionToContinue?.id == firstDestination.session.id)
    }

    @Test
    func workoutDetailsDismissesNestedSessionDestinationAfterManualFinish() throws {
        let repository = SpyWorkoutRepository()
        let workout = WorkoutMapperTests.makeWorkout(name: "Manual Finish")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(workout)
        _ = try #require(viewModel.freshWorkoutDestination)

        viewModel.dismissWorkoutSessionDestination(reason: "testManualFinish")

        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.sessionToContinue == nil)
        #expect(repository.startSessionCallCount == 1)
        #expect(repository.updateSessionCallCount == 0)
    }

    @Test
    func freshWorkoutLaunchesUseDistinctNavigationIdentities() {
        let repository = SpyWorkoutRepository()
        let workout = WorkoutMapperTests.makeWorkout()
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(workout)
        let firstDestination = viewModel.freshWorkoutDestination
        repository.sessionToFetch = nil
        viewModel.freshWorkoutDestination = nil
        viewModel.startWorkout(workout)
        let secondDestination = viewModel.freshWorkoutDestination

        #expect(firstDestination?.id != secondDestination?.id)
        #expect(firstDestination?.session.id != secondDestination?.session.id)
        #expect(firstDestination?.workout == workout)
        #expect(secondDestination?.workout == workout)
        #expect(repository.startSessionCallCount == 2)
    }

    @Test
    func workoutDetailsDefensiveFallbackPreventsDuplicateSessionCreation() throws {
        let repository = SpyWorkoutRepository()
        let session = WorkoutSession(workout: WorkoutMapperTests.makeWorkout())
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Fresh")
        repository.sessionToFetch = session
        viewModel.startWorkout(selectedWorkout)

        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.sessionToContinue == nil)
        let conflict = try #require(viewModel.workoutSwitchConflict)
        #expect(conflict.activeSession.id == session.id)
        #expect(conflict.selectedWorkout.id == selectedWorkout.id)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func workoutDetailsStartsSelectedWorkoutWhenNoActiveSessionExists() throws {
        let repository = SpyWorkoutRepository()
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)

        let destination = try #require(viewModel.freshWorkoutDestination)
        #expect(destination.session.workout == selectedWorkout)
        #expect(viewModel.sessionToContinue == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(repository.startSessionCallCount == 1)
    }

    @Test
    func workoutDetailsResumesSameWorkoutActiveSessionWithoutConflict() throws {
        let repository = SpyWorkoutRepository()
        let workoutID = UUID()
        let workout = WorkoutMapperTests.makeWorkout(id: workoutID, name: "Same Workout")
        let activeSession = WorkoutSession(workout: workout)
        let viewModel = WorkoutDetailsViewModel(repository: repository)
        repository.sessionToFetch = activeSession

        viewModel.startWorkout(WorkoutMapperTests.makeWorkout(id: workoutID, name: "Same Workout"))

        let sessionToContinue = try #require(viewModel.sessionToContinue)
        #expect(sessionToContinue.id == activeSession.id)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func workoutDetailsDifferentActiveWorkoutCreatesConflictWithoutNavigation() throws {
        let repository = SpyWorkoutRepository()
        let activeSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Active"))
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)
        repository.sessionToFetch = activeSession

        viewModel.startWorkout(selectedWorkout)

        let conflict = try #require(viewModel.workoutSwitchConflict)
        #expect(conflict.activeSession.id == activeSession.id)
        #expect(conflict.selectedWorkout.id == selectedWorkout.id)
        #expect(viewModel.sessionToContinue == nil)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func cancellingWorkoutSwitchPreservesActiveSession() {
        let repository = SpyWorkoutRepository()
        let activeSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Active"))
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)
        repository.sessionToFetch = activeSession
        viewModel.startWorkout(selectedWorkout)

        viewModel.cancelWorkoutSwitchConflict()

        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.sessionToContinue == nil)
        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(repository.fetchActiveSession()?.id == activeSession.id)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func continuingWorkoutSwitchConflictOpensOriginalSessionUnchanged() throws {
        let repository = SpyWorkoutRepository()
        let activeSession = WorkoutSession(
            workout: WorkoutMapperTests.makeWorkout(name: "Active"),
            currentExerciseIndex: 1,
            currentSet: 2,
            completedReps: 42,
            elapsedTime: 300
        )
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)
        repository.sessionToFetch = activeSession
        viewModel.startWorkout(selectedWorkout)

        viewModel.continueActiveWorkoutFromConflict()

        let sessionToContinue = try #require(viewModel.sessionToContinue)
        #expect(sessionToContinue.id == activeSession.id)
        #expect(sessionToContinue.workout.name == "Active")
        #expect(sessionToContinue.currentExerciseIndex == 1)
        #expect(sessionToContinue.currentSet == 2)
        #expect(sessionToContinue.completedReps == 42)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(repository.startSessionCallCount == 0)
    }

    @Test
    func saveAndSwitchSavesProgressedActiveWorkoutBeforeStartingSelectedWorkout() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let activeWorkout = WorkoutMapperTests.makeWorkout(name: "Active")
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        repository.startSession(for: activeWorkout)
        var activeSession = try #require(repository.fetchActiveSession())
        activeSession.startedAt = Date(timeIntervalSinceNow: -900)
        repository.updateSession(activeSession)
        let activeViewModel = ActiveWorkoutViewModel(session: activeSession, repository: repository)

        for _ in 0..<4 {
            activeViewModel.completeSet()
        }

        let viewModel = WorkoutDetailsViewModel(repository: repository)
        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        let history = repository.fetchWorkoutHistory()
        let newSession = try #require(repository.fetchActiveSession())
        #expect(history.count == 1)
        #expect(history.first?.id == activeSession.id)
        #expect(history.first?.workoutName == "Active")
        #expect(newSession.workout.id == selectedWorkout.id)
        #expect(newSession.id != activeSession.id)
        #expect(viewModel.freshWorkoutDestination?.session.id == newSession.id)
    }

    @Test
    func saveAndSwitchHistoryPreservesPartialExerciseResults() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let activeWorkout = WorkoutMapperTests.makeWorkout(name: "Active")
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        repository.startSession(for: activeWorkout)
        let activeSession = try #require(repository.fetchActiveSession())
        let activeViewModel = ActiveWorkoutViewModel(session: activeSession, repository: repository)

        for _ in 0..<4 {
            activeViewModel.completeSet()
        }

        let viewModel = WorkoutDetailsViewModel(repository: repository)
        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        let history = try #require(repository.fetchWorkoutHistory().first)
        #expect(history.exerciseResults.count == 2)
        #expect(history.exerciseResults[0].completedSets == 3)
        #expect(history.exerciseResults[0].completedReps == 36)
        #expect(history.exerciseResults[1].completedSets == 1)
        #expect(history.exerciseResults[1].completedReps == 10)
    }

    @Test
    func saveAndSwitchCleansEmptyActiveWorkoutWithoutHistoryBeforeStartingSelectedWorkout() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let activeWorkout = WorkoutMapperTests.makeWorkout(name: "Empty Active")
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        repository.startSession(for: activeWorkout)
        let activeSession = try #require(repository.fetchActiveSession())
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        let newSession = try #require(repository.fetchActiveSession())
        #expect(activeSession.id != newSession.id)
        #expect(newSession.workout.id == selectedWorkout.id)
        #expect(repository.fetchWorkoutHistory().isEmpty)
    }

    @Test
    func saveAndSwitchSaveFailureDoesNotStartSelectedWorkout() {
        let repository = SpyWorkoutRepository()
        repository.shouldSaveHistorySucceed = false
        var activeSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Active"))
        activeSession.currentSet = 2
        activeSession.completedReps = 12
        repository.sessionToFetch = activeSession
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.workoutSwitchFailure == .saveFailed)
        #expect(repository.fetchActiveSession()?.id == activeSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.saveCallCount == 1)

        viewModel.startWorkout(selectedWorkout)

        #expect(viewModel.workoutSwitchFailure == nil)
        #expect(viewModel.workoutSwitchConflict?.activeSession.id == activeSession.id)
        #expect(viewModel.workoutSwitchConflict?.selectedWorkout.id == selectedWorkout.id)
    }

    @Test
    func saveAndSwitchCleanupFailureDoesNotStartSelectedWorkout() {
        let repository = SpyWorkoutRepository()
        repository.shouldClearActiveSessionSucceed = false
        let activeSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Empty Active"))
        repository.sessionToFetch = activeSession
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()

        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.workoutSwitchFailure == .cleanupFailed)
        #expect(repository.fetchActiveSession()?.id == activeSession.id)
        #expect(repository.startSessionCallCount == 0)
        #expect(repository.clearActiveSessionCallCount == 1)

        viewModel.startWorkout(selectedWorkout)

        #expect(viewModel.workoutSwitchFailure == nil)
        #expect(viewModel.workoutSwitchConflict?.activeSession.id == activeSession.id)
        #expect(viewModel.workoutSwitchConflict?.selectedWorkout.id == selectedWorkout.id)
    }

    @Test
    func saveAndSwitchStartFailureDoesNotNavigateAndCanRetryWithoutDuplicateHistory() throws {
        let repository = SpyWorkoutRepository()
        var activeSession = WorkoutSession(workout: WorkoutMapperTests.makeWorkout(name: "Active"))
        activeSession.currentSet = 2
        activeSession.completedReps = 12
        repository.sessionToFetch = activeSession
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        repository.shouldStartSessionSucceed = false
        viewModel.saveAndSwitchFromConflict()

        #expect(viewModel.freshWorkoutDestination == nil)
        #expect(viewModel.workoutSwitchConflict == nil)
        #expect(viewModel.workoutSwitchFailure == .startFailed)
        #expect(repository.fetchActiveSession() == nil)
        #expect(repository.history.count == 1)
        #expect(repository.history.first?.id == activeSession.id)

        repository.shouldStartSessionSucceed = true
        viewModel.startWorkout(selectedWorkout)

        let destination = try #require(viewModel.freshWorkoutDestination)
        #expect(destination.session.workout.id == selectedWorkout.id)
        #expect(repository.history.count == 1)
        #expect(repository.history.first?.id == activeSession.id)
    }

    @Test
    func repeatedSaveAndSwitchDoesNotDuplicateHistoryOrActiveSessions() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let activeWorkout = WorkoutMapperTests.makeWorkout(name: "Active")
        let selectedWorkout = WorkoutMapperTests.makeWorkout(name: "Selected")
        repository.startSession(for: activeWorkout)
        let activeSession = try #require(repository.fetchActiveSession())
        let activeViewModel = ActiveWorkoutViewModel(session: activeSession, repository: repository)
        activeViewModel.completeSet()
        let viewModel = WorkoutDetailsViewModel(repository: repository)

        viewModel.startWorkout(selectedWorkout)
        viewModel.saveAndSwitchFromConflict()
        viewModel.saveAndSwitchFromConflict()

        let history = repository.fetchWorkoutHistory()
        let activeAfterSwitch = try #require(repository.fetchActiveSession())
        #expect(history.count == 1)
        #expect(history.first?.id == activeSession.id)
        #expect(activeAfterSwitch.workout.id == selectedWorkout.id)
        #expect(viewModel.workoutSwitchConflict == nil)
    }

    @Test
    func freshRepositoryContextRestoresPersistedActiveSession() throws {
        let container = try Self.makeContainer()
        let writerRepository = WorkoutRepository()
        writerRepository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        writerRepository.startSession(for: WorkoutMapperTests.makeWorkout())
        var session = try #require(writerRepository.fetchActiveSession())
        session.currentExerciseIndex = 1
        session.currentSet = 2
        session.completedReps = 12
        session.elapsedTime = 120
        writerRepository.updateSession(session)

        let readerRepository = WorkoutRepository()
        readerRepository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let restoredSession = try #require(readerRepository.fetchActiveSession())

        #expect(restoredSession.id == session.id)
        #expect(restoredSession.currentExerciseIndex == 1)
        #expect(restoredSession.currentSet == 2)
        #expect(restoredSession.completedReps == 12)
        #expect(restoredSession.elapsedTime == 120)
    }

    @Test
    func startFreshDetailsAndHomeContinueKeepStableSessionAndLatestProgress() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        let oldWorkout = WorkoutMapperTests.makeWorkout(name: "Old Workout")

        repository.startSession(for: oldWorkout)
        let oldSession = try #require(repository.fetchActiveSession())
        #expect(repository.abandonActiveSession() == true)
        #expect(repository.fetchActiveSession() == nil)

        let freshWorkout = Self.makeResumeRegressionWorkout()
        let firstDetailsViewModel = WorkoutDetailsViewModel(repository: repository)
        firstDetailsViewModel.startWorkout(freshWorkout)
        let freshDestination = try #require(firstDetailsViewModel.freshWorkoutDestination)
        let freshViewModel = ActiveWorkoutViewModel(
            session: freshDestination.session,
            repository: repository
        )
        let freshSession = try #require(repository.fetchActiveSession())

        #expect(freshSession.id != oldSession.id)
        #expect(freshSession.currentExerciseIndex == 0)
        #expect(freshSession.currentSet == 1)
        #expect(freshSession.completedReps == 0)
        #expect(freshSession.elapsedTime == 0)

        freshViewModel.completeSet()
        freshViewModel.completeSet()
        freshViewModel.completeSet()
        freshViewModel.completeSet()
        let exerciseTwoSetTwo = try #require(repository.fetchActiveSession())
        #expect(exerciseTwoSetTwo.id == freshSession.id)
        #expect(exerciseTwoSetTwo.currentExerciseIndex == 1)
        #expect(exerciseTwoSetTwo.currentSet == 2)
        #expect(exerciseTwoSetTwo.completedReps == 46)

        let secondDetailsViewModel = WorkoutDetailsViewModel(repository: repository)
        secondDetailsViewModel.startWorkout(freshWorkout)
        let detailsContinueSession = try #require(secondDetailsViewModel.sessionToContinue)
        #expect(detailsContinueSession.id == freshSession.id)
        #expect(detailsContinueSession.currentExerciseIndex == 1)
        #expect(detailsContinueSession.currentSet == 2)
        #expect(detailsContinueSession.completedReps == 46)
        #expect(secondDetailsViewModel.freshWorkoutDestination == nil)

        let homeViewModel = HomeViewModel(repository: repository)
        homeViewModel.loadActiveSession()
        homeViewModel.continueActiveSession()
        let firstHomeContinueSession = try #require(homeViewModel.sessionToContinue)
        #expect(firstHomeContinueSession.id == freshSession.id)
        #expect(firstHomeContinueSession.currentExerciseIndex == 1)
        #expect(firstHomeContinueSession.currentSet == 2)
        #expect(firstHomeContinueSession.completedReps == 46)

        let resumedViewModel = ActiveWorkoutViewModel(
            session: firstHomeContinueSession,
            repository: repository
        )
        resumedViewModel.completeSet()
        let latestSession = try #require(repository.fetchActiveSession())
        #expect(latestSession.id == freshSession.id)
        #expect(latestSession.currentExerciseIndex == 1)
        #expect(latestSession.currentSet == 3)
        #expect(latestSession.completedReps == 56)

        homeViewModel.loadActiveSession()
        homeViewModel.continueActiveSession()
        let secondHomeContinueSession = try #require(homeViewModel.sessionToContinue)
        #expect(secondHomeContinueSession.id == freshSession.id)
        #expect(secondHomeContinueSession.currentExerciseIndex == latestSession.currentExerciseIndex)
        #expect(secondHomeContinueSession.currentSet == latestSession.currentSet)
        #expect(secondHomeContinueSession.completedReps == latestSession.completedReps)
        #expect(repository.fetchWorkoutHistory().isEmpty)
    }

    @Test
    func freshWorkoutStartsWithDefaultSessionState() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))

        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())

        #expect(session.currentExerciseIndex == 0)
        #expect(session.currentSet == 1)
        #expect(session.completedExercises == 0)
        #expect(session.completedReps == 0)
        #expect(session.elapsedTime == 0)
        #expect(session.completed == false)
    }

    @Test
    func backingOutBeforeCompletingSetRemovesUnresumableSession() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )
        let startedSession = session

        viewModel.discardIfUnstarted()

        #expect(startedSession.currentExerciseIndex == 0)
        #expect(startedSession.currentSet == 1)
        #expect(startedSession.completedReps == 0)
        #expect(repository.fetchActiveSession() == nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(try persistence.fetchWorkoutHistory().isEmpty)
    }

    @Test
    func backingOutAfterCompletingSetPreservesResumableProgress() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )
        let startedSession = session

        viewModel.completeSet()
        viewModel.discardIfUnstarted()

        let restored = try #require(repository.fetchActiveSession())
        let persisted = try #require(try persistence.loadActiveSession())
        #expect(restored.id == startedSession.id)
        #expect(persisted.id == startedSession.id)
        #expect(restored.currentExerciseIndex == 0)
        #expect(restored.currentSet == 2)
        #expect(restored.completedReps == 12)
    }

    @Test
    func duplicateFreshViewModelInitializationReusesOneSessionAndStaleDisappearDoesNotDeleteProgress() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let workout = Self.makeResumeRegressionWorkout()

        repository.startSession(for: workout)
        let firstSession = try #require(repository.fetchActiveSession())
        let staleViewModel = ActiveWorkoutViewModel(session: firstSession, repository: repository)
        let activeViewModel = ActiveWorkoutViewModel(session: firstSession, repository: repository)
        let secondSession = try #require(repository.fetchActiveSession())

        activeViewModel.completeSet()
        staleViewModel.discardIfUnstarted()

        let restored = try #require(repository.fetchActiveSession())
        let persisted = try #require(try persistence.loadActiveSession())
        #expect(firstSession.id == secondSession.id)
        #expect(restored.id == firstSession.id)
        #expect(persisted.id == firstSession.id)
        #expect(restored.currentExerciseIndex == 0)
        #expect(restored.currentSet == 2)
        #expect(restored.completedReps == 12)
    }

    @Test
    func finalSetCompletionClearsActiveSessionAndCreatesSingleHistoryRecord() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let workout = Self.makeResumeRegressionWorkout()
        repository.startSession(for: workout)
        let startedSession = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(session: startedSession, repository: repository)

        for _ in 0..<6 {
            viewModel.completeSet()
        }

        let history = repository.fetchWorkoutHistory()
        #expect(viewModel.isWorkoutCompleted == true)
        #expect(viewModel.currentExerciseNumber == 2)
        #expect(viewModel.currentSet == 3)
        #expect(repository.activeSession == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(try persistence.loadActiveSession() == nil)
        #expect(history.count == 1)
        #expect(history.first?.id == startedSession.id)
        #expect(history.first?.workoutName == workout.name)

        repository.save(
            WorkoutSessionRecord(
                id: startedSession.id,
                workoutName: workout.name,
                startedAt: startedSession.startedAt,
                completedAt: .now,
                duration: 1,
                exercisesCompleted: workout.exercises.count
            )
        )

        #expect(repository.fetchWorkoutHistory().count == 1)
    }

    @Test
    func completionSummaryCountsFinalSetOfFinalExercise() {
        let workout = Self.makeResumeRegressionWorkout()
        var activeWorkout = ActiveWorkout(workout: workout)
        activeWorkout.currentExerciseIndex = 1
        activeWorkout.currentSet = 3
        activeWorkout.completedReps = 66
        activeWorkout.exerciseResults[0].completedSets = 3
        activeWorkout.exerciseResults[0].completedReps = 36
        activeWorkout.exerciseResults[1].completedSets = 3
        activeWorkout.exerciseResults[1].completedReps = 30
        activeWorkout.isCompleted = true

        let summary = WorkoutCompletionSummary(
            sessionID: UUID(),
            activeWorkout: activeWorkout,
            duration: 1_200,
            includesCurrentSetCompletion: true
        )

        #expect(summary.workoutName == workout.name)
        #expect(summary.completedExercises == 2)
        #expect(summary.completedSets == 6)
        #expect(summary.completedReps == 66)
        #expect(summary.plannedTargets.count == 2)
        #expect(summary.plannedTargets.first?.exerciseName == "Goblet Squat")
        #expect(summary.plannedTargets.first?.targetSets == 3)
        #expect(summary.plannedTargets.first?.targetReps == 12)
    }

    @Test
    func completionSummaryDoesNotCountUnfinishedCurrentSetForEarlyFinish() {
        let workout = Self.makeResumeRegressionWorkout()
        var activeWorkout = ActiveWorkout(workout: workout)
        activeWorkout.currentExerciseIndex = 1
        activeWorkout.currentSet = 2
        activeWorkout.completedReps = 46
        activeWorkout.exerciseResults[0].completedSets = 3
        activeWorkout.exerciseResults[0].completedReps = 36
        activeWorkout.exerciseResults[1].completedSets = 1
        activeWorkout.exerciseResults[1].completedReps = 10
        activeWorkout.isCompleted = true

        let summary = WorkoutCompletionSummary(
            sessionID: UUID(),
            activeWorkout: activeWorkout,
            duration: 900,
            includesCurrentSetCompletion: false
        )

        #expect(summary.completedExercises == 1)
        #expect(summary.completedSets == 4)
        #expect(summary.completedReps == 46)
    }

    @Test
    func finalSetCompletionCreatesRuntimeSummaryAfterSuccessfulSave() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )

        for _ in 0..<6 {
            viewModel.completeSet()
        }

        let summary = try #require(viewModel.completionSummary)
        #expect(summary.id == viewModel.completedSessionID)
        #expect(summary.workoutName == "Fresh Workout")
        #expect(summary.completedExercises == 2)
        #expect(summary.completedSets == 6)
        #expect(summary.completedReps == 66)
        #expect(repository.fetchWorkoutHistory().count == 1)
    }

    @Test
    func manualFinishSavesOnceClearsActiveSessionAndCreatesSingleHistoryRecord() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )
        let startedSession = try #require(repository.fetchActiveSession())

        viewModel.completeSet()
        let firstSummary = try #require(viewModel.finishWorkout())
        let secondSummary = viewModel.finishWorkout()

        let history = repository.fetchWorkoutHistory()
        #expect(firstSummary.id == startedSession.id)
        #expect(firstSummary.workoutName == "Fresh Workout")
        #expect(firstSummary.completedExercises == 0)
        #expect(firstSummary.completedSets == 1)
        #expect(firstSummary.completedReps == 12)
        #expect(secondSummary == nil)
        #expect(viewModel.completedSessionID == startedSession.id)
        #expect(viewModel.pendingRestTimerContext == nil)
        #expect(repository.activeSession == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(history.count == 1)
        #expect(history.first?.id == startedSession.id)
        #expect(history.first?.workoutName == "Fresh Workout")
    }

    @Test
    func workoutSavedBannerNormalizesEmptyWorkoutName() {
        let namedBanner = WorkoutSavedBanner(workoutName: " Fresh Workout ")
        let unnamedBanner = WorkoutSavedBanner(workoutName: "   ")

        #expect(namedBanner.workoutName == "Fresh Workout")
        #expect(unnamedBanner.workoutName == nil)
    }

    @Test
    func updateMissingCompletedSessionDoesNotExposeStaleActiveMemory() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        repository.configure(with: WorkoutPersistence(modelContext: ModelContext(container)))
        repository.startSession(for: Self.makeResumeRegressionWorkout())
        let session = try #require(repository.fetchActiveSession())
        let viewModel = ActiveWorkoutViewModel(
            session: session,
            repository: repository
        )

        for _ in 0..<6 {
            viewModel.completeSet()
        }

        let completedSessionID = try #require(viewModel.completedSessionID)
        let staleSession = WorkoutSession(
            id: completedSessionID,
            workout: Self.makeResumeRegressionWorkout(),
            completed: false,
            currentExerciseIndex: 1,
            currentSet: 3,
            completedExercises: 1,
            completedReps: 56,
            elapsedTime: 900
        )

        repository.updateSession(staleSession)

        #expect(repository.activeSession == nil)
        #expect(repository.fetchActiveSession() == nil)
        #expect(repository.fetchWorkoutHistory().count == 1)
    }

    @Test
    func startingCompletedWorkoutAgainCreatesFreshDefaultSession() throws {
        let container = try Self.makeContainer()
        let repository = WorkoutRepository()
        let persistence = WorkoutPersistence(modelContext: ModelContext(container))
        repository.configure(with: persistence)
        let workout = Self.makeResumeRegressionWorkout()
        repository.startSession(for: workout)
        let firstSession = try #require(repository.fetchActiveSession())
        let firstViewModel = ActiveWorkoutViewModel(session: firstSession, repository: repository)

        for _ in 0..<6 {
            firstViewModel.completeSet()
        }

        #expect(repository.fetchActiveSession() == nil)

        _ = ActiveWorkoutViewModel(workout: workout, repository: repository)
        #expect(repository.fetchActiveSession() == nil)

        let detailsViewModel = WorkoutDetailsViewModel(repository: repository)
        detailsViewModel.startWorkout(workout)
        let secondSession = try #require(detailsViewModel.freshWorkoutDestination?.session)

        #expect(secondSession.id != firstSession.id)
        #expect(secondSession.currentExerciseIndex == 0)
        #expect(secondSession.currentSet == 1)
        #expect(secondSession.completedReps == 0)
        #expect(secondSession.completedExercises == 0)
        #expect(secondSession.completed == false)
        #expect(repository.fetchWorkoutHistory().count == 1)
    }

    private static func makeResumeRegressionWorkout() -> Workout {
        Workout(
            name: "Fresh Workout",
            type: .hypertrophy,
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Goblet Squat",
                        muscleGroups: [.quadriceps, .glutes],
                        workoutType: .strength,
                        requiresWeight: true
                    ),
                    targetSets: 3,
                    targetReps: 12,
                    restSeconds: 60
                ),
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Push-up",
                        muscleGroups: [.chest, .triceps],
                        workoutType: .strength,
                        requiresWeight: false
                    ),
                    targetSets: 3,
                    targetReps: 10,
                    restSeconds: 45
                )
            ],
            estimatedDuration: 2_700,
            description: "A complete persisted workout."
        )
    }

    private static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            WorkoutEntity.self,
            WorkoutSessionEntity.self,
            WorkoutHistoryEntity.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

@MainActor
private final class SpyWorkoutRepository: WorkoutRepositoryProtocol {

    var sessionToFetch: WorkoutSession?
    var updatedSession: WorkoutSession?
    var history: [WorkoutSessionRecord] = []
    var shouldAbandonActiveSessionSucceed = true
    var shouldClearActiveSessionSucceed = true
    var shouldSaveHistorySucceed = true
    var shouldStartSessionSucceed = true

    private(set) var startSessionCallCount = 0
    private(set) var updateSessionCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var clearActiveSessionCallCount = 0
    private(set) var abandonActiveSessionCallCount = 0

    @discardableResult
    func startSession(for workout: Workout) -> WorkoutSession? {
        startSessionCallCount += 1

        guard sessionToFetch == nil else {
            return nil
        }

        guard shouldStartSessionSucceed else {
            return nil
        }

        let session = WorkoutSession(workout: workout)
        sessionToFetch = session
        return session
    }

    func fetchActiveSession() -> WorkoutSession? {
        sessionToFetch
    }

    func updateSession(_ session: WorkoutSession) {
        updateSessionCallCount += 1
        updatedSession = session
        sessionToFetch = session
    }

    func clearActiveSession() {
        clearActiveSessionCallCount += 1
        sessionToFetch = nil
    }

    func clearActiveSession(ifSessionID sessionID: UUID) -> Bool {
        clearActiveSessionCallCount += 1

        guard shouldClearActiveSessionSucceed else {
            return false
        }

        guard sessionToFetch?.id == sessionID else {
            return false
        }

        sessionToFetch = nil
        return true
    }

    func abandonActiveSession() -> Bool {
        abandonActiveSessionCallCount += 1

        if shouldAbandonActiveSessionSucceed {
            sessionToFetch = nil
        }

        return shouldAbandonActiveSessionSucceed
    }

    func fetchWorkoutHistory() -> [WorkoutSessionRecord] {
        history
    }

    func save(_ workout: WorkoutSessionRecord) {
        saveCallCount += 1

        guard shouldSaveHistorySucceed else {
            return
        }

        history.insert(workout, at: 0)

        if sessionToFetch?.id == workout.id {
            sessionToFetch = nil
        }
    }
}
