import SwiftUI

struct MainTabView: View {

    @State private var router = NavigationRouter()
    @State private var selectedTab = MainTab.home
    @State private var homeViewModel = HomeViewModel()

    private var navigationCoordinator: MainTabNavigationCoordinator {
        MainTabNavigationCoordinator(homeViewModel: homeViewModel)
    }

    var body: some View {

        TabView(selection: $selectedTab) {

            NavigationStack(path: $router.path) {

                HomeView(viewModel: homeViewModel)
                    .environment(router)

                    .navigationDestination(for: AppDestination.self) { destination in

                        switch destination {

                        case .home:
                            HomeView(viewModel: homeViewModel)
                                .environment(router)

                        case .workout:
                            WorkoutLibraryView(
                                onWorkoutCompleted: { completedSessionID in
                                    navigationCoordinator.handleWorkoutCompleted(
                                        sessionID: completedSessionID
                                    )
                                }
                            )

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
