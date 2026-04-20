#if os(macOS)
import CoreAudio
import Foundation

public actor MacOSVolumeControlService: VolumeControlService {
    private let store: VolumeStore
    private let ownedBuses: [AudioSource] = AppOwnedAudioMixer.defaultBuses.map {
        AudioSource(id: $0.id, displayName: $0.displayName, kind: $0.kind)
    }

    public init(store: VolumeStore = .shared) {
        self.store = store
    }

    public func allSources() async -> [AudioSource] {
        let base: [AudioSource] = [
            .init(id: "system-output", displayName: "System Output", kind: .systemOutput),
            .init(id: "mic-input", displayName: "Microphone", kind: .microphoneInput)
        ]

        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
        let sessions = await MacOSProcessTapController.shared.refreshSessions(store: store)
        let canLiveMixApps = await MacOSProcessTapController.shared.isLiveMixingActive()
        let appSources = canLiveMixApps ? sessions.map {
            AudioSource(id: $0.id, displayName: $0.displayName, kind: .application)
        } : []

        return base + ownedBuses + appSources
    }

    public func currentVolume(for sourceID: String) async -> Float {
        switch sourceID {
        case "system-output":
            return readDefaultOutputVolume() ?? 0.5
        case "mic-input":
            return readDefaultInputVolume() ?? 0.5
        default:
            if sourceID.hasPrefix("owned.") {
                await AppOwnedAudioMixer.shared.startIfNeeded(store: store)

                if let live = await AppOwnedAudioMixer.shared.currentVolume(for: sourceID) {
                    return live
                }
            }

            let map = await store.loadMap()
            if let persisted = map[sourceID] {
                return persisted
            }

            if let bus = AppOwnedAudioMixer.defaultBuses.first(where: { $0.id == sourceID }) {
                return bus.defaultVolume
            }

            return 1
        }
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        let bounded = max(0, min(1, value))
        if sourceID == "system-output" {
            writeDefaultOutputVolume(bounded)
        } else if sourceID == "mic-input" {
            writeDefaultInputVolume(bounded)
        } else if sourceID.hasPrefix("owned.") {
            await store.upsert(bounded, for: sourceID)
            await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
            await AppOwnedAudioMixer.shared.setVolume(bounded, for: sourceID)
        } else {
            await store.upsert(bounded, for: sourceID)
            await MacOSProcessTapController.shared.setVolume(bounded, for: sourceID)
        }
    }

    public func appSessions() async -> [AppAudioSession] {
        await MacOSProcessTapController.shared.refreshSessions(store: store)
    }

    public func topologyStatusDescription() async -> String {
        await MacOSProcessTapController.shared.topologyStatusDescription()
    }

    public func ownedOutputRoutes() -> [MacOSDedicatedOutputRoute] {
        MacOSDedicatedOutputRouteManager.shared.ownedRoutes()
    }

    public func selectedOwnedOutputRouteID() -> String? {
        MacOSDedicatedOutputRouteManager.shared.selectedRouteID()
    }

    public func selectOwnedOutputRoute(id: String?) async {
        MacOSDedicatedOutputRouteManager.shared.selectRoute(id: id)
        _ = await MacOSProcessTapController.shared.refreshSessions(store: store)
    }

    public func ownedOutputRouteStateDescription() -> String {
        MacOSDedicatedOutputRouteManager.shared.routeState().statusDescription
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

    private func defaultInputDeviceID() -> AudioDeviceID? {
        var deviceID = AudioDeviceID()
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
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

    private func readDefaultOutputVolume() -> Float? {
        guard let deviceID = defaultOutputDeviceID() else { return nil }

        for channel in [UInt32(1), UInt32(2), UInt32(kAudioObjectPropertyElementMain)] {
            var volume: Float32 = 0
            var size = UInt32(MemoryLayout<Float32>.size)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: channel
            )

            if AudioObjectHasProperty(deviceID, &address) {
                let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
                if status == noErr {
                    return volume
                }
            }
        }

        return nil
    }

    private func writeDefaultOutputVolume(_ volume: Float) {
        guard let deviceID = defaultOutputDeviceID() else { return }

        for channel in [UInt32(1), UInt32(2), UInt32(kAudioObjectPropertyElementMain)] {
            var newVolume = Float32(volume)
            let size = UInt32(MemoryLayout<Float32>.size)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: channel
            )

            if AudioObjectHasProperty(deviceID, &address) {
                _ = AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &newVolume)
            }
        }
    }

    private func readDefaultInputVolume() -> Float? {
        guard let deviceID = defaultInputDeviceID() else { return nil }

        for channel in [UInt32(1), UInt32(2), UInt32(kAudioObjectPropertyElementMain)] {
            var volume: Float32 = 0
            var size = UInt32(MemoryLayout<Float32>.size)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeInput,
                mElement: channel
            )

            if AudioObjectHasProperty(deviceID, &address) {
                let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
                if status == noErr {
                    return volume
                }
            }
        }

        return nil
    }

    private func writeDefaultInputVolume(_ volume: Float) {
        guard let deviceID = defaultInputDeviceID() else { return }

        for channel in [UInt32(1), UInt32(2), UInt32(kAudioObjectPropertyElementMain)] {
            var newVolume = Float32(volume)
            let size = UInt32(MemoryLayout<Float32>.size)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeInput,
                mElement: channel
            )

            if AudioObjectHasProperty(deviceID, &address) {
                _ = AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &newVolume)
            }
        }
    }
}
#endif
