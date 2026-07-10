import SwiftUI

struct PrimaryButtonLabel: View {

    let title: String

    var body: some View {

        Text(title)
            .font(AppFont.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColor.primary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppStyle.cornerRadius
                )
            )
    }
}
