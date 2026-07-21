import Foundation

struct ExerciseExperienceService {
    func sampleExperiences() -> [ExerciseExperience] {
        do {
            return try CatalogueExerciseExperienceRuntimeMapper.experiences()
        } catch {
            preconditionFailure("Built-in exercise experience catalogue failed to map: \(error)")
        }
    }

    func experience(forExerciseID id: UUID) -> ExerciseExperience? {
        guard let exerciseDefinition = BuiltInExerciseCatalogue.definitions.first(where: { $0.id == id }) else {
            return nil
        }

        return experience(for: exerciseDefinition.semanticKey)
    }

    func experience(for semanticKey: CatalogueSemanticKey) -> ExerciseExperience? {
        guard BuiltInExerciseExperienceCatalogue.definition(for: semanticKey) != nil else {
            return nil
        }

        do {
            return try CatalogueExerciseExperienceRuntimeMapper.experience(for: semanticKey)
        } catch {
            preconditionFailure("Built-in exercise experience failed to map for \(semanticKey.rawValue): \(error)")
        }
    }
}
