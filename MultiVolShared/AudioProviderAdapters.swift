import Foundation

#if canImport(AVFAudio)
import AVFAudio

public protocol MixerAudioProvider: AnyObject, Sendable {
    var playerNode: AVAudioPlayerNode { get }
    var outputFormat: AVAudioFormat? { get }
    func prepareForRouting()
}

public extension MixerAudioProvider {
    func prepareForRouting() {}
}

public protocol MediaAudioProvider: MixerAudioProvider {}
public protocol CallAudioProvider: MixerAudioProvider {}
public protocol EffectsAudioProvider: MixerAudioProvider {}

public final class PlayerNodeMediaAudioProvider: MediaAudioProvider, @unchecked Sendable {
    public let playerNode: AVAudioPlayerNode
    public let outputFormat: AVAudioFormat?

    public init(playerNode: AVAudioPlayerNode, outputFormat: AVAudioFormat? = nil) {
        self.playerNode = playerNode
        self.outputFormat = outputFormat
    }
}

public final class PlayerNodeCallAudioProvider: CallAudioProvider, @unchecked Sendable {
    public let playerNode: AVAudioPlayerNode
    public let outputFormat: AVAudioFormat?

    public init(playerNode: AVAudioPlayerNode, outputFormat: AVAudioFormat? = nil) {
        self.playerNode = playerNode
        self.outputFormat = outputFormat
    }
}

public final class PlayerNodeEffectsAudioProvider: EffectsAudioProvider, @unchecked Sendable {
    public let playerNode: AVAudioPlayerNode
    public let outputFormat: AVAudioFormat?

    public init(playerNode: AVAudioPlayerNode, outputFormat: AVAudioFormat? = nil) {
        self.playerNode = playerNode
        self.outputFormat = outputFormat
    }
}

#endif
