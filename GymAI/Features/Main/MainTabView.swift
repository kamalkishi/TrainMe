import SwiftUI

struct MainTabView: View {

    var body: some View {

        TabView {

            NavigationStack {

                HomeView()

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
