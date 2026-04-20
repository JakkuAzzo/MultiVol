import Foundation

#if canImport(AVFAudio)
import AVFAudio

public actor AppOwnedStreamRouter {
    public static let shared = AppOwnedStreamRouter()

    public init() {}

    public func connect(mediaProvider: any MediaAudioProvider) async {
        mediaProvider.prepareForRouting()
        await AppOwnedAudioMixer.shared.attachPlayerNode(
            mediaProvider.playerNode,
            format: mediaProvider.outputFormat,
            to: "owned.music",
            replaceExisting: true
        )
    }

    public func connect(callProvider: any CallAudioProvider) async {
        callProvider.prepareForRouting()
        await AppOwnedAudioMixer.shared.attachPlayerNode(
            callProvider.playerNode,
            format: callProvider.outputFormat,
            to: "owned.call",
            replaceExisting: true
        )
    }

    public func connect(effectsProvider: any EffectsAudioProvider) async {
        effectsProvider.prepareForRouting()
        await AppOwnedAudioMixer.shared.attachPlayerNode(
            effectsProvider.playerNode,
            format: effectsProvider.outputFormat,
            to: "owned.fx",
            replaceExisting: true
        )
    }

    public func connectMediaStream(playerNode: AVAudioPlayerNode, format: AVAudioFormat?) async {
        let provider = PlayerNodeMediaAudioProvider(playerNode: playerNode, outputFormat: format)
        await connect(mediaProvider: provider)
    }

    public func connectCallStream(playerNode: AVAudioPlayerNode, format: AVAudioFormat?) async {
        let provider = PlayerNodeCallAudioProvider(playerNode: playerNode, outputFormat: format)
        await connect(callProvider: provider)
    }

    public func connectEffectsStream(playerNode: AVAudioPlayerNode, format: AVAudioFormat?) async {
        let provider = PlayerNodeEffectsAudioProvider(playerNode: playerNode, outputFormat: format)
        await connect(effectsProvider: provider)
    }

    public func connectLoopingMediaFile(url: URL) async throws {
        try await AppOwnedAudioMixer.shared.attachLoopingAudioFile(at: url, to: "owned.music")
    }

    public func connectLoopingEffectsFile(url: URL) async throws {
        try await AppOwnedAudioMixer.shared.attachLoopingAudioFile(at: url, to: "owned.fx")
    }

    public func connectMicrophoneToCallBus() async {
        await AppOwnedAudioMixer.shared.attachMicrophoneInput(to: "owned.call")
    }
}

#endif
