#if os(macOS)
import CoreAudio
import Foundation

public struct MacOSDedicatedOutputRoute: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let deviceID: AudioDeviceID
    public let isDefaultOutput: Bool
    public let isOwnedByMultiVol: Bool

    public init(
        id: String,
        name: String,
        deviceID: AudioDeviceID,
        isDefaultOutput: Bool,
        isOwnedByMultiVol: Bool
    ) {
        self.id = id
        self.name = name
        self.deviceID = deviceID
        self.isDefaultOutput = isDefaultOutput
        self.isOwnedByMultiVol = isOwnedByMultiVol
    }
}

public enum MacOSDedicatedOutputRouteState: Sendable, Equatable {
    case unavailable
    case availableButInactive(route: MacOSDedicatedOutputRoute)
    case active(route: MacOSDedicatedOutputRoute)

    public var statusDescription: String {
        switch self {
        case .unavailable:
            return "No dedicated MultiVol output device is installed yet."
        case let .availableButInactive(route):
            return "Dedicated MultiVol route found (\(route.name)), but it is not the current default output device."
        case let .active(route):
            return "Dedicated MultiVol output route active: \(route.name)."
        }
    }
}

public final class MacOSDedicatedOutputRouteManager {
    public static let shared = MacOSDedicatedOutputRouteManager()

    private let selectedRouteDefaultsKey = "multivol.mac.selectedOwnedOutputRouteID"

    private init() {}

    public func ownedRoutes() -> [MacOSDedicatedOutputRoute] {
        let defaultOutputID = defaultOutputDeviceID()
        return outputDevices()
            .filter(\.isOwnedByMultiVol)
            .map { route in
                MacOSDedicatedOutputRoute(
                    id: route.id,
                    name: route.name,
                    deviceID: route.deviceID,
                    isDefaultOutput: route.deviceID == defaultOutputID,
                    isOwnedByMultiVol: route.isOwnedByMultiVol
                )
            }
            .sorted { lhs, rhs in
                if lhs.isDefaultOutput != rhs.isDefaultOutput {
                    return lhs.isDefaultOutput && !rhs.isDefaultOutput
                }
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
    }

    public func selectedRouteID() -> String? {
        UserDefaults.standard.string(forKey: selectedRouteDefaultsKey)
    }

    public func selectRoute(id: String?) {
        if let id, !id.isEmpty {
            UserDefaults.standard.set(id, forKey: selectedRouteDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedRouteDefaultsKey)
        }
    }

    public func routeState() -> MacOSDedicatedOutputRouteState {
        let routes = ownedRoutes()
        guard !routes.isEmpty else {
            return .unavailable
        }

        let preferredID = selectedRouteID()
        let chosenRoute = routes.first(where: { $0.id == preferredID })
            ?? routes.first(where: \.isDefaultOutput)
            ?? routes.first!

        if chosenRoute.isDefaultOutput {
            return .active(route: chosenRoute)
        }

        return .availableButInactive(route: chosenRoute)
    }

    private func outputDevices() -> [MacOSDedicatedOutputRoute] {
        let defaultOutputID = defaultOutputDeviceID()
        return audioDeviceIDs().compactMap { deviceID in
            guard hasOutputStreams(deviceID) else { return nil }
            guard let id = readStringProperty(deviceID, selector: kAudioDevicePropertyDeviceUID) else { return nil }
            let name = readStringProperty(deviceID, selector: kAudioObjectPropertyName)
                ?? readStringProperty(deviceID, selector: kAudioDevicePropertyDeviceNameCFString)
                ?? "Audio Device"
            let isOwned = isOwnedByMultiVol(id: id, name: name)
            return MacOSDedicatedOutputRoute(
                id: id,
                name: name,
                deviceID: deviceID,
                isDefaultOutput: deviceID == defaultOutputID,
                isOwnedByMultiVol: isOwned
            )
        }
    }

    private func isOwnedByMultiVol(id: String, name: String) -> Bool {
        MultiVolOwnedOutputRoute.matchesDevice(uid: id, name: name)
    }

    private func audioDeviceIDs() -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0

        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size
        ) == noErr else {
            return []
        }

        let count = Int(size) / MemoryLayout<AudioObjectID>.size
        var devices = Array(repeating: AudioObjectID(), count: count)
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &devices
        ) == noErr else {
            return []
        }

        return devices
    }

    private func hasOutputStreams(_ deviceID: AudioObjectID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size) == noErr else {
            return false
        }
        return size >= UInt32(MemoryLayout<AudioObjectID>.size)
    }

    private func defaultOutputDeviceID() -> AudioDeviceID? {
        var deviceID = AudioDeviceID()
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        return status == noErr ? deviceID : nil
    }

    private func readStringProperty(_ objectID: AudioObjectID, selector: AudioObjectPropertySelector) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var unmanagedValue: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &unmanagedValue)
        guard status == noErr, let unmanagedValue else { return nil }
        return unmanagedValue.takeUnretainedValue() as String
    }
}
#endif
