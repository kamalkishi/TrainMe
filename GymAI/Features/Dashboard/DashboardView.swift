import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)

                Text("GymAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your AI Fitness Companion")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
