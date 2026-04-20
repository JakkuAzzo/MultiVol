#if os(macOS)
import Foundation

public enum MultiVolOwnedOutputCommand: String, Codable, Sendable {
    case installDriver
    case activateRoute
    case deactivateRoute
    case publishMixSnapshot
    case updateSessionGains
}

public enum MultiVolOwnedOutputRoutePhase: String, Codable, Sendable {
    case unavailable
    case staged
    case driverEmbedded
    case driverActivating
    case driverInstalled
    case routeAvailable
    case routeActive
    case failed
}

public struct MultiVolOwnedOutputSessionSnapshot: Codable, Hashable, Sendable {
    public let id: String
    public let gain: Float
    public let channelCount: Int
    public let bufferedFrames: Int

    public init(id: String, gain: Float, channelCount: Int, bufferedFrames: Int) {
        self.id = id
        self.gain = gain
        self.channelCount = channelCount
        self.bufferedFrames = bufferedFrames
    }
}

public struct MultiVolOwnedOutputBridgeMessage: Codable, Sendable {
    public let command: MultiVolOwnedOutputCommand
    public let issuedAt: Date
    public let routeUID: String?
    public let sessions: [MultiVolOwnedOutputSessionSnapshot]

    public init(
        command: MultiVolOwnedOutputCommand,
        issuedAt: Date = .now,
        routeUID: String? = nil,
        sessions: [MultiVolOwnedOutputSessionSnapshot] = []
    ) {
        self.command = command
        self.issuedAt = issuedAt
        self.routeUID = routeUID
        self.sessions = sessions
    }
}

public struct MultiVolOwnedOutputBridgeStatus: Codable, Sendable, Equatable {
    public let phase: MultiVolOwnedOutputRoutePhase
    public let routeUID: String?
    public let detail: String

    public init(phase: MultiVolOwnedOutputRoutePhase, routeUID: String? = nil, detail: String) {
        self.phase = phase
        self.routeUID = routeUID
        self.detail = detail
    }
}
#endif
