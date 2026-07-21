import Foundation
import Testing
@testable import GymAI

@MainActor
struct CatalogueExerciseExperienceRuntimeMapperTests {

    @Test func allBuiltInExperiencesMapSuccessfully() throws {
        let experiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()

        #expect(experiences.count == BuiltInExerciseExperienceCatalogue.definitions.count)
    }

    @Test func runtimeIDsMatchCatalogueExerciseDefinitionIDs() throws {
        let experiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()
        let expectedIDs = BuiltInExerciseCatalogue.definitions.map(\.id)

        #expect(experiences.map(\.id) == expectedIDs)
    }

    @Test func semanticKeysAndDisplayNamesResolveCorrectly() throws {
        let experiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()

        #expect(experiences.map(\.semanticKey) == [
            Self.gobletSquatKey,
            Self.pushUpKey,
            Self.bentOverRowKey
        ])
        #expect(experiences.map(\.name) == [
            "Goblet Squat",
            "Push-up",
            "Bent-over Row"
        ])
    }

    @Test func descriptionsResolveCorrectly() throws {
        let experiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()

        #expect(experiences.map(\.description) == [
            "A beginner lower-body strength exercise using a weight held close to the chest to train squatting mechanics, legs and glutes.",
            "A bodyweight upper-body exercise that trains pressing strength while requiring a stable trunk position.",
            "A hip-hinged pulling exercise that trains the upper back while challenging trunk position."
        ])
    }

    @Test func exerciseMetadataProjectsToRuntimeExperience() throws {
        let gobletSquat = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.gobletSquatKey)
        let pushUp = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.pushUpKey)
        let bentOverRow = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.bentOverRowKey)

        #expect(gobletSquat.primaryMuscles == [.quadriceps, .gluteusMaximus])
        #expect(gobletSquat.secondaryMuscles == [.rectusAbdominis])
        #expect(gobletSquat.stabilizerMuscles == [.erectorSpinae])
        #expect(gobletSquat.requiredEquipment == [.kettlebell])
        #expect(gobletSquat.optionalEquipment == [.dumbbell])
        #expect(gobletSquat.difficulty == .beginner)
        #expect(gobletSquat.movementFamily == .squat)
        #expect(gobletSquat.movementPatterns == [.bilateralSquat])
        #expect(gobletSquat.mechanics == .compound)
        #expect(gobletSquat.laterality == .bilateral)
        #expect(gobletSquat.bodyPosition == .standing)

        #expect(pushUp.primaryMuscles == [.pectoralisMajor, .triceps])
        #expect(pushUp.requiredEquipment == [.bodyweight])
        #expect(pushUp.movementFamily == .horizontalPush)
        #expect(pushUp.movementPatterns == [.pushUp])

        #expect(bentOverRow.primaryMuscles == [.latissimusDorsi, .rhomboids, .trapezius])
        #expect(bentOverRow.requiredEquipment == [.dumbbell])
        #expect(bentOverRow.optionalEquipment == [.barbell, .kettlebell])
        #expect(bentOverRow.movementFamily == .horizontalPull)
        #expect(bentOverRow.movementPatterns == [.row])
    }

    @Test func instructionsTipsMistakesAndSafetyNotesResolveCorrectly() throws {
        let pushUp = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.pushUpKey)

        #expect(pushUp.instructionSteps.map(\.sequenceNumber) == [1, 2, 3, 4])
        #expect(pushUp.instructionSteps.map(\.text) == [
            "Place your hands slightly wider than shoulder width with fingers spread.",
            "Step back into a straight line from head to heels and brace your torso.",
            "Lower under control with elbows angled back rather than straight out.",
            "Press through the floor until your arms are straight without losing body alignment."
        ])
        #expect(pushUp.tips == [
            "Think about moving your chest and hips together.",
            "Use an elevated surface if the floor version breaks your position.",
            "Keep your neck neutral and eyes slightly ahead of your hands."
        ])
        #expect(pushUp.commonMistakes == [
            "Letting the hips sag toward the floor.",
            "Flaring the elbows straight out to the sides.",
            "Cutting the range short before the chest lowers under control."
        ])
        #expect(pushUp.safetyNotes == [
            "Use a regression that lets you keep a straight body line.",
            "Stop if wrist, shoulder or elbow discomfort changes your form."
        ])
    }

    @Test func instructionAndMediaIDsArePreserved() throws {
        let content = try #require(BuiltInExerciseExperienceCatalogue.definition(for: Self.bentOverRowKey))
        let experience = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.bentOverRowKey)

        #expect(experience.instructionSteps.map(\.id) == content.instructionSteps.map(\.id))
        #expect(experience.mediaReferences.map(\.id) == content.mediaReferences.map(\.id))
    }

    @Test func mediaReferencesMapCorrectly() throws {
        let gobletSquat = try CatalogueExerciseExperienceRuntimeMapper.experience(for: Self.gobletSquatKey)
        let mediaReference = try #require(gobletSquat.mediaReferences.first)

        #expect(mediaReference.kind == .image)
        #expect(mediaReference.resourceKey.rawValue == "exercise.goblet_squat.demo.primary")
        #expect(mediaReference.accessibilityLabel == "Goblet squat demonstration")
        #expect(mediaReference.posterResourceKey == nil)
    }

    @Test func repeatedMappingIsDeterministic() throws {
        let firstExperiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()
        let secondExperiences = try CatalogueExerciseExperienceRuntimeMapper.experiences()

        #expect(firstExperiences == secondExperiences)
    }

    @Test func missingCanonicalExerciseDefinitionFailsDeterministically() throws {
        let missingKey = try #require(CatalogueSemanticKey(rawValue: "exercise.missing"))
        let content = Self.content(
            exerciseSemanticKey: missingKey,
            resourceKey: CatalogueSemanticKey(rawValue: "exercise.missing.demo.primary")!
        )

        do {
            _ = try CatalogueExerciseExperienceRuntimeMapper.experience(from: content)
            Issue.record("Expected missing exercise definition to throw.")
        } catch CatalogueExerciseExperienceRuntimeMapper.MappingError.missingExerciseDefinition(let semanticKey) {
            #expect(semanticKey == missingKey)
        } catch {
            Issue.record("Expected missingExerciseDefinition, got \(error).")
        }
    }

    @Test func missingExperienceContentFailsDeterministically() throws {
        let definition = Self.syntheticExerciseDefinition()

        do {
            _ = try CatalogueExerciseExperienceRuntimeMapper.experience(from: definition)
            Issue.record("Expected missing experience content to throw.")
        } catch CatalogueExerciseExperienceRuntimeMapper.MappingError.missingExerciseExperienceContent(let semanticKey) {
            #expect(semanticKey == definition.semanticKey)
        } catch {
            Issue.record("Expected missingExerciseExperienceContent, got \(error).")
        }
    }

    @Test func unknownContentKeyFailsDeterministically() throws {
        let definition = try #require(BuiltInExerciseCatalogue.definition(for: Self.gobletSquatKey))
        let content = Self.content(
            exerciseSemanticKey: Self.gobletSquatKey,
            descriptionLocalizationKey: "catalogue.exercise.goblet_squat.description.unknown",
            resourceKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat.demo.primary")!
        )

        do {
            _ = try CatalogueExerciseExperienceRuntimeMapper.experience(from: definition, content: content)
            Issue.record("Expected unresolved content key to throw.")
        } catch CatalogueExerciseExperienceRuntimeMapper.MappingError.unresolvedContentKey(let key) {
            #expect(key == "catalogue.exercise.goblet_squat.description.unknown")
        } catch {
            Issue.record("Expected unresolvedContentKey, got \(error).")
        }
    }

    @Test func invalidEntriesCannotProducePartialOutput() throws {
        let validContent = try #require(BuiltInExerciseExperienceCatalogue.definition(for: Self.gobletSquatKey))
        let invalidContent = Self.content(
            exerciseSemanticKey: Self.pushUpKey,
            descriptionLocalizationKey: "catalogue.exercise.push_up.description.unknown",
            resourceKey: CatalogueSemanticKey(rawValue: "exercise.push_up.demo.primary")!
        )

        do {
            _ = try CatalogueExerciseExperienceRuntimeMapper.experiences(from: [validContent, invalidContent])
            Issue.record("Expected invalid entry to fail the full mapping operation.")
        } catch CatalogueExerciseExperienceRuntimeMapper.MappingError.unresolvedContentKey(let key) {
            #expect(key == "catalogue.exercise.push_up.description.unknown")
        } catch {
            Issue.record("Expected unresolvedContentKey, got \(error).")
        }
    }

    private static func content(
        exerciseSemanticKey: CatalogueSemanticKey,
        descriptionLocalizationKey: String = "catalogue.exercise.goblet_squat.description",
        resourceKey: CatalogueSemanticKey
    ) -> ExerciseExperienceContent {
        ExerciseExperienceContent(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            exerciseSemanticKey: exerciseSemanticKey,
            descriptionLocalizationKey: descriptionLocalizationKey,
            instructionSteps: [
                ExerciseInstructionStep(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
                    textLocalizationKey: "catalogue.exercise.goblet_squat.instruction.1",
                    sequenceNumber: 1
                )
            ],
            tipLocalizationKeys: ["catalogue.exercise.goblet_squat.tip.1"],
            commonMistakeLocalizationKeys: ["catalogue.exercise.goblet_squat.mistake.1"],
            safetyNoteLocalizationKeys: ["catalogue.exercise.goblet_squat.safety.1"],
            mediaReferences: [
                ExerciseMediaReference(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
                    kind: .image,
                    resourceKey: resourceKey,
                    accessibilityLabelLocalizationKey: "catalogue.exercise.goblet_squat.media.primary.accessibility_label",
                    posterResourceKey: nil
                )
            ]
        )
    }

    private static func syntheticExerciseDefinition() -> CatalogueExerciseDefinition {
        let baseDefinition = BuiltInExerciseCatalogue.definitions[0]
        return CatalogueExerciseDefinition(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
            semanticKey: CatalogueSemanticKey(rawValue: "exercise.synthetic_missing_content")!,
            titleLocalizationKey: "catalogue.exercise.synthetic_missing_content.title",
            metadata: baseDefinition.metadata,
            source: .builtIn,
            ownership: .gymAI,
            publicationStatus: .published,
            schemaVersion: 1,
            contentRevision: 1
        )
    }

    private static let gobletSquatKey = CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!
    private static let pushUpKey = CatalogueSemanticKey(rawValue: "exercise.push_up")!
    private static let bentOverRowKey = CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!
}
