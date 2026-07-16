//
//  WorkoutEntity.swift
//  GymAI
//
//  Created by Kamal Kishore on 12/07/26.
//
import Foundation
import SwiftData

@Model
final class WorkoutEntity {

    @Attribute(.unique)
    var id: UUID

    var name: String

    /// Stored as a raw value to keep the persistence layer
    /// independent of domain enums.
    var type: String
    var estimatedDuration: TimeInterval?
    var workoutDescription: String?
    var workoutSnapshotData: Data?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSessionEntity.workout)
    var sessions: [WorkoutSessionEntity]

    init(
        id: UUID,
        name: String,
        type: String,
        estimatedDuration: TimeInterval? = 0,
        workoutDescription: String? = "",
        workoutSnapshotData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.estimatedDuration = estimatedDuration
        self.workoutDescription = workoutDescription
        self.workoutSnapshotData = workoutSnapshotData
        self.sessions = []
    }
}
