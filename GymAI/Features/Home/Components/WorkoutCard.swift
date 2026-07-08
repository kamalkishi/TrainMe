import SwiftUI

struct WorkoutCard: View {

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

            PrimaryButton(title: "Start Workout") {

                // TODO:
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
