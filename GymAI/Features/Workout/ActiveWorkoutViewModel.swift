import Foundation
import SwiftUI

@Observable
final class ActiveWorkoutViewModel {

    var activeWorkout: ActiveWorkout

    init(workout: Workout) {
        self.activeWorkout = ActiveWorkout(workout: workout)
    }
}
