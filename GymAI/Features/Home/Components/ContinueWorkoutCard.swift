import SwiftUI

struct ContinueWorkoutCard: View {

    private let diagnosticID = UUID()

    let session: WorkoutSession
    let onContinue: () -> Void
    let onSaveAndChooseAnotherConfirmed: () -> Bool

    @State private var isConfirmingWorkoutChoice = false
    @State private var isShowingWorkoutChoiceFailure = false

    var body: some View {
        let _ = WorkoutLifecycleLog.event(
            "ContinueWorkoutCard.body",
            ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
        )

        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("home.continue_workout.title", systemImage: "play.circle.fill")
                .font(AppFont.headline)

            Text(session.workout.name)
                .font(AppFont.title)

            Text("home.continue_workout.message")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)

            Button {
                WorkoutLifecycleLog.event(
                    "ContinueWorkoutCard.continueTapped",
                    ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
                )
                onContinue()
            } label: {
                PrimaryButtonLabel(title: "home.continue_workout.button")
            }

            Button(role: .destructive) {
                WorkoutLifecycleLog.event(
                    "ContinueWorkoutCard.chooseAnotherTapped",
                    ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
                )
                isConfirmingWorkoutChoice = true
            } label: {
                Text("home.choose_another.button")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
        .padding(AppStyle.cardPadding)
        .background(AppColor.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppStyle.cornerRadius
            )
        )
        .alert("home.choose_another.confirm_title", isPresented: $isConfirmingWorkoutChoice) {
            Button("home.continue_workout.button") {
                onContinue()
            }

            Button("home.choose_another.confirm_button") {
                WorkoutLifecycleLog.event(
                    "ContinueWorkoutCard.saveAndChooseAnotherConfirmed",
                    ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
                )
                if onSaveAndChooseAnotherConfirmed() {
                    WorkoutLifecycleLog.event(
                        "ContinueWorkoutCard.saveAndChooseAnotherSucceeded",
                        ["continueWorkoutCard.id=\(diagnosticID)"]
                    )
                    return
                } else {
                    WorkoutLifecycleLog.event(
                        "ContinueWorkoutCard.saveAndChooseAnotherFailed",
                        ["continueWorkoutCard.id=\(diagnosticID)"]
                    )
                    isShowingWorkoutChoiceFailure = true
                }
            }

            Button("common.cancel") {}
        } message: {
            Text("home.choose_another.confirm_message")
        }
        .alert("home.choose_another.failure_title", isPresented: $isShowingWorkoutChoiceFailure) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("home.choose_another.failure_message")
        }
    }
}

#Preview {
    ContinueWorkoutCard(
        session: WorkoutSession(
            workout: Workout(
                name: "Full Body Beginner",
                type: .strength,
                estimatedDuration: 45 * 60,
                description: "A balanced workout."
            )
        )
    ) {
    } onSaveAndChooseAnotherConfirmed: {
        true
    }
    .padding()
}
