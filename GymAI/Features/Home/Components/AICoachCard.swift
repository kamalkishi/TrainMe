import SwiftUI

struct AICoachCard: View {

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.md) {

            Label("AI Coach", systemImage: "brain.head.profile")
                .font(AppFont.headline)

            Text("You're making great progress!")

            Text("Complete today's workout to keep your streak alive.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
        )
    }
}

#Preview {
    AICoachCard()
        .padding()
}
