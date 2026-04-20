import Foundation

#if canImport(AVFAudio)
import AVFAudio

public actor AppOwnedMixerBootstrap {
    public static let shared = AppOwnedMixerBootstrap()

    private var didConfigure = false

    public init() {}

    public func configureDefaults(store: VolumeStore = .shared) async {
        guard !didConfigure else { return }

        await AppOwnedAudioMixer.shared.startIfNeeded(store: store)

        // Route live capture to the call bus when the platform permits it.
        #if os(iOS)
        await requestRecordPermissionIfNeeded()
        #endif
        await AppOwnedAudioMixer.shared.attachMicrophoneInput(to: "owned.call")

        // Route app-owned media/effects assets if bundled by the host app.
        if let musicURL = Self.findBundledAudioURL(candidates: [
            "music-loop.m4a",
            "music-loop.wav",
            "music-loop.mp3"
        ]) {
            try? await AppOwnedAudioMixer.shared.attachLoopingAudioFile(at: musicURL, to: "owned.music")
        }

        if let fxURL = Self.findBundledAudioURL(candidates: [
            "fx-loop.m4a",
            "fx-loop.wav",
            "fx-loop.mp3"
        ]) {
            try? await AppOwnedAudioMixer.shared.attachLoopingAudioFile(at: fxURL, to: "owned.fx")
        }

        didConfigure = true
    }

    #if os(iOS)
    private func requestRecordPermissionIfNeeded() async {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            return
        case .denied:
            return
        case .undetermined:
            _ = await withCheckedContinuation { continuation in
                session.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return
        }
    }
    #endif

    private static func findBundledAudioURL(candidates: [String]) -> URL? {
        for filename in candidates {
            let parts = filename.split(separator: ".", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            if let url = Bundle.main.url(forResource: parts[0], withExtension: parts[1]) {
                return url
            }
        }
        return nil
    }
}

#endif
