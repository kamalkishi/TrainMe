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

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSessionEntity.workout)
    var sessions: [WorkoutSessionEntity]

    init(
        id: UUID,
        name: String,
        type: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.sessions = []
    }
}
