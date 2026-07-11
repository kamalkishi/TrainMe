import SwiftUI

struct PrimaryButton: View {

    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            PrimaryButtonLabel(title: title)
        }
    }
}

#Preview {

    PrimaryButton(title: "Continue") {

    }
    .padding()
}
