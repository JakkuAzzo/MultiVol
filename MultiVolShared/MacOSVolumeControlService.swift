#if os(macOS)
import AppKit
import CoreAudio
import Foundation

public actor MacOSVolumeControlService: VolumeControlService {
    private static let trackedApps: [(bundleID: String, sourceID: String, name: String, kind: AudioSourceKind)] = [
        ("com.spotify.client", "app.spotify", "Spotify", .media),
        ("com.apple.FaceTime", "app.facetime", "FaceTime", .call),
        ("com.google.Chrome", "app.youtube", "YouTube (Browser)", .media),
        ("com.apple.Safari", "app.youtube", "YouTube (Browser)", .media)
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

        let runningBundleIDs = Set(NSWorkspace.shared.runningApplications.compactMap(\ .bundleIdentifier))
        for app in Self.trackedApps {
            if runningBundleIDs.contains(app.bundleID) {
                let source = AudioSource(id: app.sourceID, displayName: app.name, kind: app.kind)
                if !base.contains(where: { $0.id == source.id }) {
                    base.append(source)
                }
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
            let map = await store.loadMap()
            return map[sourceID] ?? 0.5
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
        }
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
