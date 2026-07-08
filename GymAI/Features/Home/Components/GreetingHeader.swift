import SwiftUI

struct GreetingHeader: View {

    var body: some View {

        VStack(alignment: .leading,
               spacing: Spacing.sm) {

            Text("Good Evening 👋")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textSecondary)

            Text("Kamal")
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text("Ready to crush today's workout?")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview {
    GreetingHeader()
        .padding()
}
