#if os(macOS)
import CoreAudio
import Foundation

public actor MacOSVolumeControlService: VolumeControlService {
    private let sources: [AudioSource] = [
        .init(id: "system-output", displayName: "Output", kind: .systemOutput),
        .init(id: "mic-input", displayName: "Mic", kind: .microphoneInput)
    ]

    public init() {}

    public func allSources() async -> [AudioSource] {
        sources
    }

    public func currentVolume(for sourceID: String) async -> Float {
        switch sourceID {
        case "system-output":
            return readDefaultOutputVolume() ?? 0.5
        case "mic-input":
            return 0.5
        default:
            return 0.5
        }
    }

    public func setVolume(_ value: Float, for sourceID: String) async {
        let bounded = max(0, min(1, value))
        if sourceID == "system-output" {
            writeDefaultOutputVolume(bounded)
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
}
#endif
