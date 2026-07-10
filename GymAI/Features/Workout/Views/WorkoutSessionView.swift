import SwiftUI

struct WorkoutSessionView: View {

    let workout: Workout

    var body: some View {

        VStack(spacing: Spacing.lg) {

            Text("Workout in Progress")
                .font(AppFont.largeTitle)

            Text(workout.name)
                .font(AppFont.title)

            Text("AI camera integration coming soon.")
                .foregroundStyle(AppColor.textSecondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Workout")
    }
}

#Preview {

    NavigationStack {

        WorkoutSessionView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
