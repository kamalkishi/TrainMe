import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(AppColor.primary)
        .clipShape(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
        )
    }
}

#Preview {
    PrimaryButton(title: "Continue") {

    }
    .padding()
}
