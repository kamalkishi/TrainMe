import SwiftUI

struct WorkoutDetailsView: View {

    let workout: Workout

    var body: some View {

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

                Text(workout.name)
                    .font(AppFont.largeTitle)

                Text(workout.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)

                Label(
                    "\(Int(workout.estimatedDuration / 60)) minutes",
                    systemImage: "clock"
                )

                Divider()

                Text("Exercises")
                    .font(AppFont.headline)

                if workout.exercises.isEmpty {

                    Text("Exercises will be added soon.")
                        .foregroundStyle(AppColor.textSecondary)

                } else {

                    ForEach(workout.exercises) { exercise in

                        Text(exercise.name)
                    }
                }

                Spacer(minLength: Spacing.lg)

                NavigationLink {

                    WorkoutSessionView(workout: workout)

                } label: {

                    PrimaryButtonLabel(title: "Start Workout")
                }
            }
            .padding(AppStyle.screenPadding)
        }
        .navigationTitle(workout.name)
        //.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {

    NavigationStack {

        WorkoutDetailsView(
            workout: Workout(
                name: "Push Day",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "Upper body strength workout."
            )
        )
    }
}
