import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel
    @Environment(NavigationRouter.self) private var router

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let _ = WorkoutLifecycleLog.event("HomeView.body")

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

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
                        onStartFreshConfirmed: {
                            WorkoutLifecycleLog.event(
                                "HomeView.startFreshConfirmed",
                                WorkoutLifecycleLog.session(activeSession, label: "home.cardSession")
                            )
                            let abandoned = viewModel.abandonActiveSession()

                            if abandoned {
                                WorkoutLifecycleLog.event(
                                    "HomeView.startFreshOpeningWorkoutLibrary",
                                    ["navigationRouter.pathCount=\(router.path.count)"]
                                )
                                router.push(.workout)
                            }

                            return abandoned
                        }
                    )
                } else {
                    WorkoutCard()
                }

                WorkoutHistoryCard()

                AICoachCard()

                Spacer(minLength: Spacing.lg)
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
                onWorkoutCompleted: { completedSessionID in
                    WorkoutLifecycleLog.event(
                        "HomeView.continueSessionCompleted",
                        ["completedSessionID=\(completedSessionID.uuidString)"]
                    )
                    viewModel.handleWorkoutCompleted(sessionID: completedSessionID)
                }
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
