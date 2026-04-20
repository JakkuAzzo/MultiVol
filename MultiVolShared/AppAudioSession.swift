import Foundation

public struct AppAudioSession: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let displayName: String
    public let bundleID: String?
    public let processObjectIDs: [UInt32]
    public let processIDs: [Int32]
    public let supportsProcessTap: Bool
    public let hasProcessTap: Bool
    public let volume: Float

    public init(
        id: String,
        displayName: String,
        bundleID: String?,
        processObjectIDs: [UInt32],
        processIDs: [Int32],
        supportsProcessTap: Bool,
        hasProcessTap: Bool,
        volume: Float
    ) {
        self.id = id
        self.displayName = displayName
        self.bundleID = bundleID
        self.processObjectIDs = processObjectIDs
        self.processIDs = processIDs
        self.supportsProcessTap = supportsProcessTap
        self.hasProcessTap = hasProcessTap
        self.volume = max(0, min(1, volume))
    }
}
