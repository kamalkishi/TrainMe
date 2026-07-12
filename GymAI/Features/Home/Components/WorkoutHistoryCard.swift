import SwiftUI

struct WorkoutHistoryCard: View {

    var body: some View {

        NavigationLink {

            WorkoutHistoryView()

        } label: {

            VStack(alignment: .leading, spacing: Spacing.md) {

                HStack {

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundStyle(AppColor.primary)

                    Text("history.title")
                        .font(AppFont.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.textSecondary)
                }

                Text("history.subtitle")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppStyle.cornerRadius
                )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {

    NavigationStack {

        WorkoutHistoryCard()
    }
}
