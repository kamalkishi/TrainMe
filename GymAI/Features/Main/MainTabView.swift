import SwiftUI

struct MainTabView: View {

    @State private var router = NavigationRouter()

    var body: some View {

        TabView {

            NavigationStack(path: $router.path) {

                HomeView()
                    .environment(router)

                    .navigationDestination(for: AppDestination.self) { destination in

                        switch destination {

                        case .home:
                            HomeView()

                        case .workout:
                            WorkoutLibraryView()

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
        }
    }
}

#Preview {
    MainTabView()
}
