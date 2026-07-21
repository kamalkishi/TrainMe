import Foundation

@MainActor
struct ProgramService {

    func samplePrograms() -> [RuntimeProgram] {
        do {
            return try CatalogueProgramRuntimeMapper.programs(from: BuiltInProgramCatalogue.allPrograms)
        } catch {
            preconditionFailure("Built-in program catalogue failed runtime mapping: \(error)")
        }
    }
}
