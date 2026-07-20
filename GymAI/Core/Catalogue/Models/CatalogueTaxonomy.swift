import Foundation

struct CatalogueSemanticKey: RawRepresentable, Codable, Hashable, Sendable {

    let rawValue: String

    nonisolated init?(rawValue: String) {
        guard Self.isValid(rawValue) else {
            return nil
        }

        self.rawValue = rawValue
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let semanticKey = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid catalogue semantic key: \(rawValue)"
            )
        }

        self = semanticKey
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    nonisolated static func isValid(_ value: String) -> Bool {
        let components = value.split(separator: ".", omittingEmptySubsequences: false)

        guard components.count >= 2 else {
            return false
        }

        return components.allSatisfy(isValidComponent)
    }

    nonisolated private static func isValidComponent(_ component: Substring) -> Bool {
        guard !component.isEmpty else {
            return false
        }

        var previousWasUnderscore = false

        for character in component {
            if character == "_" {
                guard !previousWasUnderscore else {
                    return false
                }

                previousWasUnderscore = true
                continue
            }

            guard character.isLowercaseASCIILetter || character.isASCIIWholeNumber else {
                return false
            }

            previousWasUnderscore = false
        }

        return component.first != "_" && component.last != "_"
    }
}

private extension Character {

    nonisolated var isLowercaseASCIILetter: Bool {
        guard let scalar = unicodeScalars.first, unicodeScalars.count == 1 else {
            return false
        }

        return scalar.value >= 97 && scalar.value <= 122
    }

    nonisolated var isASCIIWholeNumber: Bool {
        guard let scalar = unicodeScalars.first, unicodeScalars.count == 1 else {
            return false
        }

        return scalar.value >= 48 && scalar.value <= 57
    }
}

enum CatalogueSource: String, CaseIterable, Codable, Hashable, Sendable {
    case builtIn
    case gymAICloud
    case userCreated
    case coachCreated
    case aiGenerated
    case imported
}

enum CatalogueOwnership: String, CaseIterable, Codable, Hashable, Sendable {
    case gymAI
    case user
    case coach
    case partner
    case external
}

enum PublicationStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case draft
    case internalReview
    case published
    case deprecated
    case archived
}

enum WorkoutCategory: String, CaseIterable, Codable, Hashable, Sendable {
    case strength
    case hypertrophy
    case muscularEndurance
    case cardio
    case hiit
    case circuitTraining
    case crossTraining
    case functionalFitness
    case calisthenics
    case yoga
    case mobility
    case flexibility
    case pilates
    case core
    case balance
    case rehabilitation
    case prehabilitation
    case recovery
    case warmUp
    case coolDown
    case sportsPerformance
    case power
    case speed
    case agility
    case plyometrics
    case skillPractice
    case breathing
    case mindBody
}

enum TrainingGoal: String, CaseIterable, Codable, Hashable, Sendable {
    case generalFitness
    case strength
    case muscleGain
    case fatLoss
    case conditioning
    case endurance
    case mobility
    case flexibility
    case athleticPerformance
    case balance
    case posture
    case recovery
    case returnToTraining
    case skillDevelopment
}

enum ExperienceLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case beginner
    case novice
    case intermediate
    case advanced
    case allLevels
}

enum IntensityLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case veryLow
    case low
    case moderate
    case high
    case veryHigh
}

enum ImpactLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case noImpact
    case lowImpact
    case moderateImpact
    case highImpact
}

enum TrainingEnvironment: String, CaseIterable, Codable, Hashable, Sendable {
    case gym
    case home
    case outdoors
    case studio
    case pool
    case track
    case court
    case field
    case office
    case travel
}

enum SessionFormat: String, CaseIterable, Codable, Hashable, Sendable {
    case straightSets
    case superset
    case triSet
    case giantSet
    case circuit
    case interval
    case emom
    case amrap
    case tabata
    case timedFlow
    case continuousCardio
    case skillPractice
    case recoveryFlow
}

enum MovementFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case squat
    case hinge
    case lunge
    case horizontalPush
    case verticalPush
    case horizontalPull
    case verticalPull
    case carry
    case rotation
    case antiRotation
    case flexion
    case `extension`
    case lateralFlexion
    case locomotion
    case jump
    case `throw`
    case climb
    case crawl
    case balance
    case mobility
    case stretch
    case breathwork
    case isometricHold
    case cyclicCardio
    case sportSkill
}

enum MovementPattern: String, CaseIterable, Codable, Hashable, Sendable {
    case bilateralSquat
    case splitSquat
    case singleLegSquat
    case lateralSquat
    case deadlift
    case romanianDeadlift
    case goodMorning
    case hipThrust
    case swing
    case benchPress
    case pushUp
    case overheadPress
    case dip
    case fly
    case row
    case pullUp
    case pulldown
    case facePull
    case reverseFly
    case walk
    case run
    case sprint
    case cycle
    case rowingErgometer
    case stairClimb
    case swim
}

enum BodyRegion: String, CaseIterable, Codable, Hashable, Sendable {
    case fullBody
    case upperBody
    case lowerBody
    case core
    case neck
    case shoulder
    case chest
    case back
    case arms
    case forearms
    case hips
    case glutes
    case thighs
    case lowerLegs
    case feetAndAnkles
}

enum Equipment: String, CaseIterable, Codable, Hashable, Sendable {
    case bodyweight
    case barbell
    case dumbbell
    case kettlebell
    case weightPlate
    case resistanceBand
    case cable
    case smithMachine
    case selectorizedMachine
    case plateLoadedMachine
    case bench
    case rack
    case pullUpBar
    case dipBars
    case suspensionTrainer
    case medicineBall
    case stabilityBall
    case bosu
    case foamRoller
    case yogaMat
    case yogaBlock
    case pilatesRing
    case reformer
    case cardioMachine
    case treadmill
    case exerciseBike
    case rowingMachine
    case elliptical
    case stairMachine
    case sled
    case battleRope
    case plyometricBox
    case agilityLadder
    case cone
    case landmine
    case trapBar
    case ezBar
    case none
}

enum ExerciseMechanics: String, CaseIterable, Codable, Hashable, Sendable {
    case compound
    case isolation
    case cyclic
    case isometric
    case mobility
    case stretch
    case skill
}

enum ForceType: String, CaseIterable, Codable, Hashable, Sendable {
    case push
    case pull
    case pushAndPull
    case hold
    case locomotion
    case rotation
}

enum MovementPlane: String, CaseIterable, Codable, Hashable, Sendable {
    case sagittal
    case frontal
    case transverse
    case multiplanar
}

enum KineticChain: String, CaseIterable, Codable, Hashable, Sendable {
    case openChain
    case closedChain
    case mixed
}

enum BodyPosition: String, CaseIterable, Codable, Hashable, Sendable {
    case standing
    case seated
    case supine
    case prone
    case sideLying
    case kneeling
    case halfKneeling
    case quadruped
    case hanging
    case supported
    case inverted
    case moving
}

enum Laterality: String, CaseIterable, Codable, Hashable, Sendable {
    case bilateral
    case unilateral
    case alternating
    case independentBilateral
    case notApplicable
}

enum ExerciseDifficulty: String, CaseIterable, Codable, Hashable, Sendable {
    case foundational
    case beginner
    case intermediate
    case advanced
    case expert
}

enum DemandLevel: String, CaseIterable, Codable, Hashable, Sendable {
    case low
    case moderate
    case high
    case veryHigh
}

enum MeasurementType: String, CaseIterable, Codable, Hashable, Sendable {
    case repetitions
    case duration
    case distance
    case load
    case calories
    case pace
    case speed
    case heartRate
    case power
    case rounds
    case breathCycles
    case holdDuration
    case steps
    case laps
    case freePractice
}

enum AICapabilityState: String, CaseIterable, Codable, Hashable, Sendable {
    case unsupported
    case planned
    case demoOnly
    case poseTrackable
    case repCountable
    case formCoachable
    case fullySupported
}
