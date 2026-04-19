import Foundation

public actor VolumeStore {
    private let defaults: UserDefaults
    private let key = "multivol.volume.levels"

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
}
