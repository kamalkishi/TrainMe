import SwiftUI

struct HomeView: View {

    var body: some View {

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

                GreetingHeader()

                WorkoutCard()

                AICoachCard()

                Spacer(minLength: Spacing.lg)
            }
            .padding(AppStyle.screenPadding)
        }
        .background(AppColor.background)
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
