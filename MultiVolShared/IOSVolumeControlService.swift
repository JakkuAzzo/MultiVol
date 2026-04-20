#if os(iOS)
import Foundation

public actor IOSVolumeControlService: VolumeControlService {
    private let store: VolumeStore

    public init(store: VolumeStore = .shared) {
        self.store = store
    }

    public func allSources() async -> [AudioSource] {
        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
        return AppOwnedAudioMixer.defaultBuses.map {
            AudioSource(id: $0.id, displayName: $0.displayName, kind: $0.kind)
        }
    }

    public func currentVolume(for sourceID: String) async -> Float {
        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)

        if let live = await AppOwnedAudioMixer.shared.currentVolume(for: sourceID) {
            return live
        }

        let map = await store.loadMap()

        if let persisted = map[sourceID] {
            return persisted
        }

        if let bus = AppOwnedAudioMixer.defaultBuses.first(where: { $0.id == sourceID }) {
            return bus.defaultVolume
        }

        return 0.5
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        let bounded = max(0, min(1, value))
        await store.upsert(bounded, for: sourceID)
        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
        await AppOwnedAudioMixer.shared.setVolume(bounded, for: sourceID)
    }
}
#endif
