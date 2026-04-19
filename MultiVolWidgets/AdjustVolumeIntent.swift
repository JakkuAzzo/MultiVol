import AppIntents
import Foundation

struct VolumeSourceEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Audio Source"
    static var defaultQuery = VolumeSourceEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

struct VolumeSourceEntityQuery: EntityQuery {
    func entities(for identifiers: [VolumeSourceEntity.ID]) async throws -> [VolumeSourceEntity] {
        AudioSource.defaults
            .filter { identifiers.contains($0.id) }
            .map { VolumeSourceEntity(id: $0.id, name: $0.displayName) }
    }

    func suggestedEntities() async throws -> [VolumeSourceEntity] {
        AudioSource.defaults.map { VolumeSourceEntity(id: $0.id, name: $0.displayName) }
    }
}

struct AdjustVolumeIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Source Volume"

    @Parameter(title: "Source")
    var source: VolumeSourceEntity

    @Parameter(title: "Increase")
    var increase: Bool

    func perform() async throws -> some IntentResult {
        #if os(iOS)
        let service = IOSVolumeControlService()
        #elseif os(macOS)
        let service = MacOSVolumeControlService()
        #else
        let service = MockVolumeControlService()
        #endif

        let delta: Float = increase ? 0.05 : -0.05
        _ = await service.stepVolume(by: delta, for: source.id)
        return .result()
    }
}
