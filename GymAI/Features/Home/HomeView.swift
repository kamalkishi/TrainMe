import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @Environment(NavigationRouter.self) private var router
    private let onWorkoutCompleted: (WorkoutCompletionSummary) -> Void
    private let onWorkoutManuallyFinished: (WorkoutCompletionSummary) -> Void
    private let onRestTimerRequested: (RestTimerContext) -> Void

    init(
        viewModel: HomeViewModel,
        onWorkoutCompleted: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onWorkoutManuallyFinished: @escaping (WorkoutCompletionSummary) -> Void = { _ in },
        onRestTimerRequested: @escaping (RestTimerContext) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onWorkoutCompleted = onWorkoutCompleted
        self.onWorkoutManuallyFinished = onWorkoutManuallyFinished
        self.onRestTimerRequested = onRestTimerRequested
    }

    var body: some View {
        let _ = WorkoutLifecycleLog.event("HomeView.body")

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.lg) {

                GreetingHeader()

                if let activeSession = viewModel.activeSession {
                    ContinueWorkoutCard(
                        session: activeSession,
                        onContinue: {
                            WorkoutLifecycleLog.event(
                                "HomeView.continueTapped",
                                WorkoutLifecycleLog.session(activeSession, label: "home.cardSession")
                            )
                            viewModel.continueActiveSession()
                        },
                        onSaveAndChooseAnotherConfirmed: {
                            WorkoutLifecycleLog.event(
                                "HomeView.saveAndChooseAnotherConfirmed",
                                WorkoutLifecycleLog.session(activeSession, label: "home.cardSession")
                            )
                            let saved = viewModel.saveActiveSessionAndOpenWorkoutLibrary()

                            if saved {
                                WorkoutLifecycleLog.event(
                                    "HomeView.saveAndChooseAnotherOpeningWorkoutLibrary",
                                    ["navigationRouter.pathCount=\(router.path.count)"]
                                )
                                router.push(.workout)
                            }

                            return saved
                        }
                    )
                } else {
                    WorkoutCard()
                }

                WorkoutHistoryCard()

                AICoachCard()

            }
            .padding(AppStyle.screenPadding)
        }
        .background(AppColor.background)
        .navigationTitle("Home")
        .onAppear {
            WorkoutLifecycleLog.event("HomeView.onAppear.beforeLoad")
            viewModel.loadActiveSession()
            WorkoutLifecycleLog.event("HomeView.onAppear.afterLoad")
        }
        .navigationDestination(item: $viewModel.sessionToContinue) { session in
            let _ = WorkoutLifecycleLog.event(
                "HomeView.navigationDestination.continueSession",
                WorkoutLifecycleLog.session(session)
            )
            WorkoutSessionView(
                session: session,
                onWorkoutCompleted: { summary in
                    WorkoutLifecycleLog.event(
                        "HomeView.continueSessionCompleted",
                        ["completedSessionID=\(summary.id.uuidString)"]
                    )
                    viewModel.handleWorkoutCompleted(sessionID: summary.id)
                    onWorkoutCompleted(summary)
                },
                onWorkoutManuallyFinished: { summary in
                    WorkoutLifecycleLog.event(
                        "HomeView.continueSessionManuallyFinished",
                        ["completedSessionID=\(summary.id.uuidString)"]
                    )
                    viewModel.handleWorkoutCompleted(sessionID: summary.id)
                    onWorkoutManuallyFinished(summary)
                },
                onRestTimerRequested: onRestTimerRequested
            )
                .id(session.id)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel())
            .environment(NavigationRouter())
    }
}
