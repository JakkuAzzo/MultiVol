import Foundation

public enum AudioSourceKind: String, Codable, CaseIterable, Sendable {
    case systemOutput
    case microphoneInput
    case media
    case call
}

public struct AudioSource: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let kind: AudioSourceKind

    public init(id: String, displayName: String, kind: AudioSourceKind) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
    }

    public static let defaults: [AudioSource] = [
        .init(id: "system-output", displayName: "Output", kind: .systemOutput),
        .init(id: "mic-input", displayName: "Mic", kind: .microphoneInput),
        .init(id: "media", displayName: "Media", kind: .media),
        .init(id: "call", displayName: "Call", kind: .call)
    ]
}
