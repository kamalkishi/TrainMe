import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()

    var body: some View {

        ScrollView {

            VStack(alignment: .leading,
                   spacing: Spacing.xl) {

                GreetingHeader()

                if let activeSession = viewModel.activeSession {
                    ContinueWorkoutCard(
                        session: activeSession,
                        onContinue: {
                            viewModel.continueActiveSession()
                        },
                        onStartFreshConfirmed: {
                            viewModel.abandonActiveSession()
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
            viewModel.loadActiveSession()
        }
        .navigationDestination(isPresented: $viewModel.shouldOpenWorkoutLibrary) {
            WorkoutLibraryView()
        }
        .navigationDestination(item: $viewModel.sessionToContinue) { session in
            WorkoutSessionView(session: session)
                .id(session.id)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
