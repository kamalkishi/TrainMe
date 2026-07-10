import SwiftUI

struct WorkoutListRow: View {

    let workout: Workout

    var body: some View {

        HStack(alignment: .top) {

            VStack(alignment: .leading,
                   spacing: Spacing.sm) {

                Text(workout.name)
                    .font(AppFont.title)

                Text(workout.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)

                HStack(spacing: Spacing.md) {

                    Label(
                        "\(Int(workout.estimatedDuration / 60)) min",
                        systemImage: "clock"
                    )

                    Label(
                        workout.type.rawValue.capitalized,
                        systemImage: "dumbbell"
                    )
                }
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColor.textSecondary)
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
