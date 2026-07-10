import SwiftUI

struct WorkoutCard: View {
    @Environment(NavigationRouter.self) private var router
    var body: some View {

        VStack(alignment: .leading,
               spacing: Spacing.md) {

            Label("Today's Workout",
                  systemImage: "dumbbell.fill")
                .font(AppFont.headline)

            Text("Upper Body Strength")
                .font(AppFont.title)

            Text("Estimated Duration: 45 min")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)

            NavigationLink {
                WorkoutLibraryView()
            } label: {
                PrimaryButtonLabel(title: "Start Workout")
            }
        }
        .padding(AppStyle.cardPadding)
        .background(AppColor.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppStyle.cornerRadius
            )
        )
    }
}

#Preview {
    WorkoutCard()
        .padding()
}
