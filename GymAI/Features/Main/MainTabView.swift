import SwiftUI

struct MainTabView: View {

    @State private var router = NavigationRouter()
    @State private var selectedTab = MainTab.home
    @State private var homeViewModel = HomeViewModel()
    @State private var completionSummary: WorkoutCompletionSummary?
    @State private var restTimerContext: RestTimerContext?
    @State private var presentedRestTimerContext: RestTimerContext?

    private var navigationCoordinator: MainTabNavigationCoordinator {
        MainTabNavigationCoordinator(homeViewModel: homeViewModel)
    }

    var body: some View {

        TabView(selection: $selectedTab) {

            NavigationStack(path: $router.path) {

                HomeView(
                    viewModel: homeViewModel,
                    onWorkoutCompleted: presentCompletionSummary,
                    onRestTimerRequested: presentRestTimer
                )
                    .environment(router)

                    .navigationDestination(for: AppDestination.self) { destination in

                        switch destination {

                        case .home:
                            HomeView(
                                viewModel: homeViewModel,
                                onWorkoutCompleted: presentCompletionSummary,
                                onRestTimerRequested: presentRestTimer
                            )
                                .environment(router)

                        case .workout:
                            WorkoutLibraryView(
                                onWorkoutCompleted: { summary in
                                    navigationCoordinator.handleWorkoutCompleted(
                                        sessionID: summary.id
                                    )
                                    presentCompletionSummary(summary)
                                },
                                onRestTimerRequested: presentRestTimer
                            )

                        case .history:
                            WorkoutHistoryView()

                        case .profile:
                            Text("Profile")

                        case .progress:
                            Text("Progress")

                        case .settings:
                            Text("Settings")
                        }
                    }

            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(MainTab.home)
        }
        .onChange(of: selectedTab) { previousTab, currentTab in
            WorkoutLifecycleLog.event(
                "MainTabView.selectedTabChanged",
                [
                    "selectedTab.previous=\(previousTab.rawValue)",
                    "selectedTab.current=\(currentTab.rawValue)",
                    "navigationRouter.pathCount=\(router.path.count)"
                ]
            )

            navigationCoordinator.refreshHomeIfVisible(
                selectedTab: currentTab,
                homeNavigationPathCount: router.path.count,
                reason: "selectedTabChanged"
            )
        }
        .onChange(of: router.path.count) { previousCount, currentCount in
            WorkoutLifecycleLog.event(
                "MainTabView.navigationPathCountChanged",
                [
                    "selectedTab.current=\(selectedTab.rawValue)",
                    "navigationRouter.pathCount.previous=\(previousCount)",
                    "navigationRouter.pathCount.current=\(currentCount)"
                ]
            )

            navigationCoordinator.refreshHomeIfVisible(
                selectedTab: selectedTab,
                homeNavigationPathCount: currentCount,
                reason: "navigationPathChanged"
            )
        }
        .sheet(item: $completionSummary) { summary in
            WorkoutCompletionSummaryView(
                summary: summary,
                onBackToHome: {
                    WorkoutLifecycleLog.event(
                        "MainTabView.summaryDismissed.backToHome",
                        ["summary.id=\(summary.id.uuidString)"]
                    )
                    completionSummary = nil
                    homeViewModel.dismissWorkoutCompletionSummary()
                    router.popToRoot()
                },
                onViewHistory: {
                    WorkoutLifecycleLog.event(
                        "MainTabView.summaryDismissed.viewHistory",
                        ["summary.id=\(summary.id.uuidString)"]
                    )
                    completionSummary = nil
                    homeViewModel.dismissWorkoutCompletionSummary()
                    router.path = [.history]
                }
            )
            .onAppear {
                WorkoutLifecycleLog.event(
                    "MainTabView.summaryPresented",
                    ["summary.id=\(summary.id.uuidString)"]
                )
            }
        }
        .sheet(
            item: $restTimerContext,
            onDismiss: {
                if let context = presentedRestTimerContext {
                    dismissRestTimer(context)
                }
            }
        ) { context in
            RestTimerView(
                context: context,
                onCompleted: {
                    WorkoutLifecycleLog.event(
                        "RestTimer.completed",
                        restTimerLogFields(context)
                    )
                    dismissRestTimer(context)
                },
                onSkipped: {
                    WorkoutLifecycleLog.event(
                        "RestTimer.skipped",
                        restTimerLogFields(context)
                    )
                    dismissRestTimer(context)
                }
            )
            .onAppear {
                WorkoutLifecycleLog.event(
                    "RestTimer.presented",
                    restTimerLogFields(context)
                )
            }
        }
    }

    private func presentCompletionSummary(_ summary: WorkoutCompletionSummary) {
        WorkoutLifecycleLog.event(
            "MainTabView.summaryPresentationRequested",
            ["summary.id=\(summary.id.uuidString)"]
        )
        restTimerContext = nil
        completionSummary = summary
    }

    private func presentRestTimer(_ context: RestTimerContext) {
        guard completionSummary == nil else {
            return
        }

        presentedRestTimerContext = context
        restTimerContext = context
    }

    private func dismissRestTimer(_ context: RestTimerContext) {
        WorkoutLifecycleLog.event(
            "RestTimer.dismissed",
            restTimerLogFields(context)
        )
        presentedRestTimerContext = nil
        restTimerContext = nil
    }

    private func restTimerLogFields(_ context: RestTimerContext) -> [String] {
        [
            "restTimer.id=\(context.id.uuidString)",
            "exercise.name=\(context.exerciseName)",
            "durationSeconds=\(context.durationSeconds)",
            "upcomingSet=\(context.upcomingSet)"
        ]
    }
}

enum MainTab: String, Hashable {
    case home
}

@MainActor
struct MainTabNavigationCoordinator {

    let homeViewModel: HomeViewModel

    func refreshHomeIfVisible(
        selectedTab: MainTab,
        homeNavigationPathCount: Int,
        reason: String
    ) {
        let isHomeVisible = selectedTab == .home && homeNavigationPathCount == 0

        WorkoutLifecycleLog.event(
            "MainTabNavigationCoordinator.refreshHomeIfVisible",
            [
                "reason=\(reason)",
                "selectedTab.current=\(selectedTab.rawValue)",
                "navigationRouter.pathCount=\(homeNavigationPathCount)",
                "home.isVisible=\(isHomeVisible)"
            ]
        )

        guard isHomeVisible else {
            return
        }

        WorkoutLifecycleLog.event("MainTabNavigationCoordinator.homeVisibleRefreshingActiveSession")
        homeViewModel.loadActiveSession()
    }

    func handleWorkoutCompleted(sessionID: UUID) {
        WorkoutLifecycleLog.event(
            "MainTabNavigationCoordinator.handleWorkoutCompleted",
            ["completedSessionID=\(sessionID.uuidString)"]
        )
        homeViewModel.handleWorkoutCompleted(sessionID: sessionID)
    }
}

#Preview {
    MainTabView()
}
