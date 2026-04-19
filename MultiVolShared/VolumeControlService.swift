import Foundation

public struct VolumeSnapshot: Codable, Sendable {
    public let sourceID: String
    public let volume: Float

    public init(sourceID: String, volume: Float) {
        self.sourceID = sourceID
        self.volume = max(0, min(1, volume))
    }
}

public protocol VolumeControlService: Sendable {
    func allSources() async -> [AudioSource]
    func currentVolume(for sourceID: String) async -> Float
    func setVolume(_ value: Float, for sourceID: String) async
    func stepVolume(by delta: Float, for sourceID: String) async -> Float
}

public extension VolumeControlService {
    func stepVolume(by delta: Float, for sourceID: String) async -> Float {
        let current = await currentVolume(for: sourceID)
        let next = max(0, min(1, current + delta))
        await setVolume(next, for: sourceID)
        return next
    }
}
