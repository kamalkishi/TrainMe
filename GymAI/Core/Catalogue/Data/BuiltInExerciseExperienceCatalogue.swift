import Foundation

enum BuiltInExerciseExperienceCatalogue {
    static let definitions: [ExerciseExperienceContent] = [
        gobletSquat,
        pushUp,
        bentOverRow
    ]

    static func definition(for exerciseSemanticKey: CatalogueSemanticKey) -> ExerciseExperienceContent? {
        definitions.first { $0.exerciseSemanticKey == exerciseSemanticKey }
    }
}

private extension BuiltInExerciseExperienceCatalogue {
    static let gobletSquat = ExerciseExperienceContent(
        id: UUID(uuidString: "5F4731B7-8B50-4D49-9D29-D834F2EB9232")!,
        exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat")!,
        descriptionLocalizationKey: "catalogue.exercise.goblet_squat.description",
        instructionSteps: [
            ExerciseInstructionStep(
                id: UUID(uuidString: "0E99E816-B36D-4B6C-A3AA-68E4934541A1")!,
                textLocalizationKey: "catalogue.exercise.goblet_squat.instruction.1",
                sequenceNumber: 1
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "DA3A7D58-3F5F-4217-80FD-F0495704A457")!,
                textLocalizationKey: "catalogue.exercise.goblet_squat.instruction.2",
                sequenceNumber: 2
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "31A3842F-A8F4-48DA-B912-4410D04471A6")!,
                textLocalizationKey: "catalogue.exercise.goblet_squat.instruction.3",
                sequenceNumber: 3
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "B22EF873-2368-46A7-8512-D0BB10D99905")!,
                textLocalizationKey: "catalogue.exercise.goblet_squat.instruction.4",
                sequenceNumber: 4
            )
        ],
        tipLocalizationKeys: [
            "catalogue.exercise.goblet_squat.tip.1",
            "catalogue.exercise.goblet_squat.tip.2",
            "catalogue.exercise.goblet_squat.tip.3"
        ],
        commonMistakeLocalizationKeys: [
            "catalogue.exercise.goblet_squat.mistake.1",
            "catalogue.exercise.goblet_squat.mistake.2",
            "catalogue.exercise.goblet_squat.mistake.3"
        ],
        safetyNoteLocalizationKeys: [
            "catalogue.exercise.goblet_squat.safety.1",
            "catalogue.exercise.goblet_squat.safety.2"
        ],
        mediaReferences: [
            ExerciseMediaReference(
                id: UUID(uuidString: "2F4E41EF-2169-4D5D-AE0A-89C3A1257E8D")!,
                kind: .image,
                resourceKey: CatalogueSemanticKey(rawValue: "exercise.goblet_squat.demo.primary")!,
                accessibilityLabelLocalizationKey: "catalogue.exercise.goblet_squat.media.primary.accessibility_label",
                posterResourceKey: nil
            )
        ]
    )

    static let pushUp = ExerciseExperienceContent(
        id: UUID(uuidString: "CFE23D7F-2399-411B-866A-0F69B8159E8F")!,
        exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.push_up")!,
        descriptionLocalizationKey: "catalogue.exercise.push_up.description",
        instructionSteps: [
            ExerciseInstructionStep(
                id: UUID(uuidString: "63B8507A-88DF-4EF8-899B-3D93BF3B9D1F")!,
                textLocalizationKey: "catalogue.exercise.push_up.instruction.1",
                sequenceNumber: 1
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "4AA1F389-25DE-4774-83C1-C1B31D7B05CF")!,
                textLocalizationKey: "catalogue.exercise.push_up.instruction.2",
                sequenceNumber: 2
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "9FE83013-AFC5-4093-B7C9-DC9753BC6E48")!,
                textLocalizationKey: "catalogue.exercise.push_up.instruction.3",
                sequenceNumber: 3
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "0C197891-010A-4263-BD8A-E2341983D79D")!,
                textLocalizationKey: "catalogue.exercise.push_up.instruction.4",
                sequenceNumber: 4
            )
        ],
        tipLocalizationKeys: [
            "catalogue.exercise.push_up.tip.1",
            "catalogue.exercise.push_up.tip.2",
            "catalogue.exercise.push_up.tip.3"
        ],
        commonMistakeLocalizationKeys: [
            "catalogue.exercise.push_up.mistake.1",
            "catalogue.exercise.push_up.mistake.2",
            "catalogue.exercise.push_up.mistake.3"
        ],
        safetyNoteLocalizationKeys: [
            "catalogue.exercise.push_up.safety.1",
            "catalogue.exercise.push_up.safety.2"
        ],
        mediaReferences: [
            ExerciseMediaReference(
                id: UUID(uuidString: "E3C37B15-4964-402B-827D-B423E5778A3F")!,
                kind: .image,
                resourceKey: CatalogueSemanticKey(rawValue: "exercise.push_up.demo.primary")!,
                accessibilityLabelLocalizationKey: "catalogue.exercise.push_up.media.primary.accessibility_label",
                posterResourceKey: nil
            )
        ]
    )

    static let bentOverRow = ExerciseExperienceContent(
        id: UUID(uuidString: "63CEAFD5-8D7B-4F5C-B00A-D74941072C46")!,
        exerciseSemanticKey: CatalogueSemanticKey(rawValue: "exercise.bent_over_row")!,
        descriptionLocalizationKey: "catalogue.exercise.bent_over_row.description",
        instructionSteps: [
            ExerciseInstructionStep(
                id: UUID(uuidString: "B17908C6-9608-4E49-B3E4-C26372124875")!,
                textLocalizationKey: "catalogue.exercise.bent_over_row.instruction.1",
                sequenceNumber: 1
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "76C03DA1-22A8-4A01-AF9D-5D42314F81C3")!,
                textLocalizationKey: "catalogue.exercise.bent_over_row.instruction.2",
                sequenceNumber: 2
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "19C926B6-E4F9-455F-9E5A-01D4BB44249E")!,
                textLocalizationKey: "catalogue.exercise.bent_over_row.instruction.3",
                sequenceNumber: 3
            ),
            ExerciseInstructionStep(
                id: UUID(uuidString: "715418F3-2041-443E-BE90-7809B2B1CBAB")!,
                textLocalizationKey: "catalogue.exercise.bent_over_row.instruction.4",
                sequenceNumber: 4
            )
        ],
        tipLocalizationKeys: [
            "catalogue.exercise.bent_over_row.tip.1",
            "catalogue.exercise.bent_over_row.tip.2",
            "catalogue.exercise.bent_over_row.tip.3"
        ],
        commonMistakeLocalizationKeys: [
            "catalogue.exercise.bent_over_row.mistake.1",
            "catalogue.exercise.bent_over_row.mistake.2",
            "catalogue.exercise.bent_over_row.mistake.3"
        ],
        safetyNoteLocalizationKeys: [
            "catalogue.exercise.bent_over_row.safety.1",
            "catalogue.exercise.bent_over_row.safety.2"
        ],
        mediaReferences: [
            ExerciseMediaReference(
                id: UUID(uuidString: "7C10ED27-F418-4443-8F78-8E2E5A5580BC")!,
                kind: .image,
                resourceKey: CatalogueSemanticKey(rawValue: "exercise.bent_over_row.demo.primary")!,
                accessibilityLabelLocalizationKey: "catalogue.exercise.bent_over_row.media.primary.accessibility_label",
                posterResourceKey: nil
            )
        ]
    )
}
