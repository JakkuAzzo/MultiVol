import AppIntents
import Foundation
import WidgetKit

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
        let persistedIDs = await VolumeStore.shared.load().map(\ .sourceID)
        let knownEntities = AudioSource.defaults
            .map { VolumeSourceEntity(id: $0.id, name: $0.displayName) }
        let persistedEntities = persistedIDs.map {
            VolumeSourceEntity(id: $0, name: AudioSource.displayName(for: $0))
        }

        let all = Dictionary(uniqueKeysWithValues: (knownEntities + persistedEntities).map { ($0.id, $0) })
        return identifiers.compactMap { all[$0] }
    }

    func suggestedEntities() async throws -> [VolumeSourceEntity] {
        let persistedIDs = await VolumeStore.shared.load().map(\ .sourceID)
        let knownEntities = AudioSource.defaults
            .map { VolumeSourceEntity(id: $0.id, name: $0.displayName) }
        let persistedEntities = persistedIDs.map {
            VolumeSourceEntity(id: $0, name: AudioSource.displayName(for: $0))
        }

        let deduped = Dictionary(uniqueKeysWithValues: (knownEntities + persistedEntities).map { ($0.id, $0) })
        return deduped.values.sorted { $0.name < $1.name }
    }
}

struct AdjustVolumeIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Source Volume"

    @Parameter(title: "Source")
    var source: VolumeSourceEntity

    @Parameter(title: "Increase")
    var increase: Bool

    init() {
        source = VolumeSourceEntity(id: "system-output", name: "System Output")
        increase = true
    }

    init(source: VolumeSourceEntity, increase: Bool) {
        self.source = source
        self.increase = increase
    }

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
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
