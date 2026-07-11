import SwiftUI

struct WorkoutProgressCard: View {

    let currentExercise: Int
    let totalExercises: Int

    let exerciseName: String

    let currentSet: Int
    let targetSets: Int

    let targetReps: Int
    let restSeconds: Int

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.md) {

            Text("Exercise \(currentExercise) of \(totalExercises)")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textSecondary)

            Text(exerciseName)
                .font(AppFont.title)

            Divider()

            HStack {

                Label(
                    "Set \(currentSet) of \(targetSets)",
                    systemImage: "repeat"
                )

                Spacer()

                Label(
                    "\(targetReps) reps",
                    systemImage: "figure.strengthtraining.traditional"
                )
            }

            Label(
                "\(restSeconds) sec rest",
                systemImage: "timer"
            )
            .foregroundStyle(AppColor.textSecondary)

        }
        .padding()
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {

    WorkoutProgressCard(
        currentExercise: 1,
        totalExercises: 5,
        exerciseName: "Bench Press",
        currentSet: 1,
        targetSets: 4,
        targetReps: 10,
        restSeconds: 90
    )
}
