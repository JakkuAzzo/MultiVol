import Foundation

public enum MultiVolSharedConfig {
    public static let appGroupID = "group.com.jakkuazzo.multivol"

    public static func sharedDefaults() -> UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
}

public actor VolumeStore {
    private let defaults: UserDefaults
    private let key = "multivol.volume.levels"

    public static let shared = VolumeStore(defaults: MultiVolSharedConfig.sharedDefaults())

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func save(_ snapshots: [VolumeSnapshot]) {
        do {
            let data = try JSONEncoder().encode(snapshots)
            defaults.set(data, forKey: key)
        } catch {
            defaults.removeObject(forKey: key)
        }
    }

    public func load() -> [VolumeSnapshot] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([VolumeSnapshot].self, from: data)
        else {
            return []
        }
        return decoded
    }

    public func loadMap() -> [String: Float] {
        Dictionary(uniqueKeysWithValues: load().map { ($0.sourceID, $0.volume) })
    }

    public func upsert(_ volume: Float, for sourceID: String) {
        var map = loadMap()
        map[sourceID] = max(0, min(1, volume))
        let snapshots = map.map { VolumeSnapshot(sourceID: $0.key, volume: $0.value) }
            .sorted { $0.sourceID < $1.sourceID }
        save(snapshots)
    }
}
