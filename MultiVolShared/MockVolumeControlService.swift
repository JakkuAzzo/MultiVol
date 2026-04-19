import Foundation

public actor MockVolumeControlService: VolumeControlService {
    private let sources: [AudioSource]
    private var levels: [String: Float]

    public init(sources: [AudioSource] = AudioSource.defaults) {
        self.sources = sources
        self.levels = Dictionary(uniqueKeysWithValues: sources.map { ($0.id, 0.5) })
    }

    public func allSources() async -> [AudioSource] {
        sources
    }

    public func currentVolume(for sourceID: String) async -> Float {
        levels[sourceID] ?? 0.5
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        levels[sourceID] = max(0, min(1, value))
    }
}
