import SwiftUI

struct WorkoutCard: View {
    @Environment(NavigationRouter.self) private var router
    var body: some View {

        VStack(alignment: .leading,
               spacing: Spacing.md) {

            Label("home.browse_workouts.label",
                  systemImage: "dumbbell.fill")
                .font(AppFont.headline)

            Text("home.browse_workouts.title")
                .font(AppFont.title)

            Text("home.browse_workouts.subtitle")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)

            Button {
                WorkoutLifecycleLog.event(
                    "WorkoutCard.startWorkoutTapped",
                    ["navigationRouter.pathCount=\(router.path.count)"]
                )
                router.push(.workout)
            } label: {
                PrimaryButtonLabel(title: "home.browse_workouts.button")
            }
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .environment(NavigationRouter())
        .padding()
}
