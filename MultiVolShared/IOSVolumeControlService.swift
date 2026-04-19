#if os(iOS)
import Foundation

public actor IOSVolumeControlService: VolumeControlService {
    private let sources: [AudioSource] = [
        .init(id: "system-output", displayName: "Output", kind: .systemOutput),
        .init(id: "media", displayName: "Media", kind: .media),
        .init(id: "call", displayName: "Call", kind: .call)
    ]

    private var levels: [String: Float] = [
        "system-output": 0.5,
        "media": 0.5,
        "call": 0.5
    ]

    public init() {}

    public func allSources() async -> [AudioSource] {
        sources
    }

    public func currentVolume(for sourceID: String) async -> Float {
        levels[sourceID] ?? 0.5
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        let bounded = max(0, min(1, value))
        levels[sourceID] = bounded
    }
}
#endif
