#if os(iOS)
import Foundation

public actor IOSVolumeControlService: VolumeControlService {
    private let sources: [AudioSource] = [
        .init(id: "system-output", displayName: "System Output", kind: .systemOutput),
        .init(id: "media", displayName: "Media Mix", kind: .media),
        .init(id: "call", displayName: "Call Mix", kind: .call)
    ]

    private let store: VolumeStore

    public init(store: VolumeStore = .shared) {
        self.store = store
    }

    public func allSources() async -> [AudioSource] {
        sources
    }

    public func currentVolume(for sourceID: String) async -> Float {
        let map = await store.loadMap()
        return map[sourceID] ?? 0.5
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        await store.upsert(value, for: sourceID)
    }
}
#endif
