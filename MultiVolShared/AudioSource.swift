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
        .init(id: "owned.music", displayName: "Music Bus", kind: .media),
        .init(id: "owned.call", displayName: "Call Bus", kind: .call),
        .init(id: "owned.fx", displayName: "Effects Bus", kind: .media),
        .init(id: "media", displayName: "Media", kind: .media),
        .init(id: "call", displayName: "Call", kind: .call)
    ]
}

public extension AudioSource {
    static func displayName(for sourceID: String) -> String {
        if let known = defaults.first(where: { $0.id == sourceID }) {
            return known.displayName
        }

        if sourceID.hasPrefix("app.") {
            return sourceID
                .replacingOccurrences(of: "app.", with: "")
                .replacingOccurrences(of: ".", with: " ")
                .capitalized
        }

        if sourceID.hasPrefix("owned.") {
            return sourceID
                .replacingOccurrences(of: "owned.", with: "")
                .replacingOccurrences(of: ".", with: " ")
                .capitalized + " Bus"
        }

        return sourceID
    }
}
