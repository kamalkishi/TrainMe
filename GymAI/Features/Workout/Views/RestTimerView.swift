import SwiftUI

struct RestTimerView: View {

    let context: RestTimerContext
    let onCompleted: () -> Void
    let onSkipped: () -> Void

    @State private var viewModel: RestTimerViewModel

    init(
        context: RestTimerContext,
        onCompleted: @escaping () -> Void,
        onSkipped: @escaping () -> Void
    ) {
        self.context = context
        self.onCompleted = onCompleted
        self.onSkipped = onSkipped
        _viewModel = State(initialValue: RestTimerViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("workout.rest.title")
                .font(AppFont.largeTitle)

            VStack(spacing: Spacing.sm) {
                Text(context.exerciseName)
                    .font(AppFont.title)

                Text("workout.rest.upcoming_set \(context.upcomingSet)")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Text(viewModel.formattedRemainingTime)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColor.accent)
                .accessibilityLabel("workout.rest.remaining_time \(viewModel.formattedRemainingTime)")

            Button {
                viewModel.skip(onSkipped: onSkipped)
            } label: {
                PrimaryButtonLabel(title: "workout.rest.skip")
            }
        }
        .padding(AppStyle.screenPadding)
        .task {
            await viewModel.start(onCompleted: onCompleted)
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}

@Observable
@MainActor
final class RestTimerViewModel {

    private(set) var remainingSeconds: Int
    private var hasFinished = false
    private var isRunning = false

    init(context: RestTimerContext) {
        self.remainingSeconds = max(context.durationSeconds, 0)
    }

    var formattedRemainingTime: String {
        let clampedSeconds = max(remainingSeconds, 0)
        let minutes = clampedSeconds / 60
        let seconds = clampedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start(onCompleted: @escaping () -> Void) async {
        guard !isRunning else {
            return
        }

        isRunning = true

        if remainingSeconds == 0 {
            complete(onCompleted: onCompleted)
            return
        }

        while remainingSeconds > 0 && isRunning && !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            guard isRunning, !Task.isCancelled else {
                return
            }

            tick(onCompleted: onCompleted)
        }
    }

    func tick(onCompleted: () -> Void) {
        guard !hasFinished else {
            return
        }

        remainingSeconds = max(remainingSeconds - 1, 0)

        if remainingSeconds == 0 {
            complete(onCompleted: onCompleted)
        }
    }

    func skip(onSkipped: () -> Void) {
        guard !hasFinished else {
            return
        }

        hasFinished = true
        isRunning = false
        onSkipped()
    }

    func cancel() {
        isRunning = false
    }

    private func complete(onCompleted: () -> Void) {
        guard !hasFinished else {
            return
        }

        hasFinished = true
        isRunning = false
        onCompleted()
    }
}

#Preview {
    RestTimerView(
        context: RestTimerContext(
            durationSeconds: 90,
            exerciseName: "Push Ups",
            upcomingSet: 2
        ),
        onCompleted: {},
        onSkipped: {}
    )
}
