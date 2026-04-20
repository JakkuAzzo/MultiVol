#if os(macOS)
import AppKit
import CoreAudio
import Foundation

public actor MacOSVolumeControlService: VolumeControlService {
    private static let externalCallAppBundleIDs: Set<String> = [
        "net.whatsapp.WhatsApp",
        "com.whatsapp.WhatsApp",
        "com.apple.FaceTime"
    ]

    private let store: VolumeStore

    public init(store: VolumeStore = .shared) {
        self.store = store
    }

    public func allSources() async -> [AudioSource] {
        var base: [AudioSource] = [
            .init(id: "system-output", displayName: "System Output", kind: .systemOutput),
            .init(id: "mic-input", displayName: "Microphone", kind: .microphoneInput)
        ]

        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
        let owned = AppOwnedAudioMixer.defaultBuses.map {
            AudioSource(id: $0.id, displayName: $0.displayName, kind: $0.kind)
        }

        for source in owned {
            if !base.contains(where: { $0.id == source.id }) {
                base.append(source)
            }
        }

        return base
    }

    public func currentVolume(for sourceID: String) async -> Float {
        switch sourceID {
        case "system-output":
            return readDefaultOutputVolume() ?? 0.5
        case "mic-input":
            return readDefaultInputVolume() ?? 0.5
        default:
            if sourceID == "owned.call", isExternalCallAppActive() {
                return readDefaultOutputVolume() ?? 0.5
            }

            await AppOwnedAudioMixer.shared.startIfNeeded(store: store)

            if let live = await AppOwnedAudioMixer.shared.currentVolume(for: sourceID) {
                return live
            }

            let map = await store.loadMap()
            if let persisted = map[sourceID] {
                return persisted
            }

            if let bus = AppOwnedAudioMixer.defaultBuses.first(where: { $0.id == sourceID }) {
                return bus.defaultVolume
            }

            return 0.5
        }
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        let bounded = max(0, min(1, value))
        if sourceID == "system-output" {
            writeDefaultOutputVolume(bounded)
        } else if sourceID == "mic-input" {
            writeDefaultInputVolume(bounded)
        } else {
            await store.upsert(bounded, for: sourceID)
            await AppOwnedAudioMixer.shared.startIfNeeded(store: store)
            await AppOwnedAudioMixer.shared.setVolume(bounded, for: sourceID)

            if sourceID == "owned.call", isExternalCallAppActive() {
                // Public macOS APIs do not expose true per-app volume control.
                // When a known call app is active, bridge call bus to output volume so calls respond.
                writeDefaultOutputVolume(bounded)
            }
        }
    }

    private func isExternalCallAppActive() -> Bool {
        let runningIDs = Set(NSWorkspace.shared.runningApplications.compactMap(\ .bundleIdentifier))
        return !Self.externalCallAppBundleIDs.isDisjoint(with: runningIDs)
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
