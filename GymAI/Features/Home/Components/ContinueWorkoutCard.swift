import SwiftUI

struct ContinueWorkoutCard: View {

    private let diagnosticID = UUID()

    let session: WorkoutSession
    let onContinue: () -> Void
    let onStartFreshConfirmed: () -> Bool

    @State private var isConfirmingStartFresh = false
    @State private var isShowingStartFreshFailure = false

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
                    "ContinueWorkoutCard.startFreshTapped",
                    ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
                )
                isConfirmingStartFresh = true
            } label: {
                Text("home.start_fresh.button")
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
        .alert("home.start_fresh.confirm_title", isPresented: $isConfirmingStartFresh) {
            Button("home.continue_workout.button", role: .cancel) {}

            Button("home.start_fresh.confirm_button", role: .destructive) {
                WorkoutLifecycleLog.event(
                    "ContinueWorkoutCard.discardAndStartFreshConfirmed",
                    ["continueWorkoutCard.id=\(diagnosticID)"] + WorkoutLifecycleLog.session(session, label: "card.session")
                )
                if onStartFreshConfirmed() {
                    WorkoutLifecycleLog.event(
                        "ContinueWorkoutCard.discardAndStartFreshSucceeded",
                        ["continueWorkoutCard.id=\(diagnosticID)"]
                    )
                    return
                } else {
                    WorkoutLifecycleLog.event(
                        "ContinueWorkoutCard.discardAndStartFreshFailed",
                        ["continueWorkoutCard.id=\(diagnosticID)"]
                    )
                    isShowingStartFreshFailure = true
                }
            }

            Button("common.cancel") {}
        } message: {
            Text("home.start_fresh.confirm_message")
        }
        .alert("home.start_fresh.failure_title", isPresented: $isShowingStartFreshFailure) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("home.start_fresh.failure_message")
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
    } onStartFreshConfirmed: {
        true
    }
    .padding()
}
