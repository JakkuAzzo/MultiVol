import Foundation

#if canImport(AVFAudio)
import AVFAudio
import Darwin

public struct AppOwnedMixerBus: Sendable {
    public let id: String
    public let displayName: String
    public let kind: AudioSourceKind
    public let defaultVolume: Float

    public init(id: String, displayName: String, kind: AudioSourceKind, defaultVolume: Float) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.defaultVolume = max(0, min(1, defaultVolume))
    }
}

public actor AppOwnedAudioMixer {
    public static let shared = AppOwnedAudioMixer()

    public static let defaultBuses: [AppOwnedMixerBus] = [
        .init(id: "owned.music", displayName: "Music Bus", kind: .media, defaultVolume: 0.6),
        .init(id: "owned.call", displayName: "Call Bus", kind: .call, defaultVolume: 0.75),
        .init(id: "owned.fx", displayName: "Effects Bus", kind: .media, defaultVolume: 0.5)
    ]

    private let engine = AVAudioEngine()
    private var busMixers: [String: AVAudioMixerNode] = [:]
    private var filePlayers: [String: AVAudioPlayerNode] = [:]
    private var externalPlayers: [String: AVAudioPlayerNode] = [:]
    private var microphoneAttachedBuses: Set<String> = []
    private var configured = false

    public init() {}

    public func startIfNeeded(store: VolumeStore = .shared) async {
        guard !configured else { return }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif

        for bus in Self.defaultBuses {
            let mixer = AVAudioMixerNode()
            engine.attach(mixer)
            engine.connect(mixer, to: engine.mainMixerNode, format: nil)
            busMixers[bus.id] = mixer
        }

        if !engine.isRunning {
            try? engine.start()
        }

        let persisted = await store.loadMap()
        for bus in Self.defaultBuses {
            busMixers[bus.id]?.outputVolume = persisted[bus.id] ?? bus.defaultVolume
        }

        configured = true
    }

    public func attachMicrophoneInput(to busID: String) {
        guard let mixer = busMixers[busID], !microphoneAttachedBuses.contains(busID) else { return }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        guard session.recordPermission == .granted else { return }
        try? session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
        #endif

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixer, format: format)
        microphoneAttachedBuses.insert(busID)
    }

    public func attachLoopingAudioFile(at url: URL, to busID: String) throws {
        guard let busMixer = busMixers[busID] else { return }

        if let existing = filePlayers[busID] {
            existing.stop()
            engine.detach(existing)
            filePlayers[busID] = nil
        }

        let file = try AVAudioFile(forReading: url)
        guard let buffer = Self.makePCMBuffer(from: file) else { return }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: busMixer, format: buffer.format)
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        player.play()
        filePlayers[busID] = player
    }

    public func attachBuiltInTestTone(
        to busID: String,
        frequency: Float = 440,
        amplitude: Float = 0.2,
        duration: TimeInterval = 2.0
    ) {
        guard let busMixer = busMixers[busID] else { return }

        if let existing = filePlayers[busID] {
            existing.stop()
            engine.detach(existing)
            filePlayers[busID] = nil
        }

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 2),
              let buffer = Self.makeSineBuffer(
                format: format,
                frequency: frequency,
                amplitude: amplitude,
                duration: duration
              )
        else {
            return
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: busMixer, format: format)
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        player.play()
        filePlayers[busID] = player
    }

    public func attachPlayerNode(
        _ player: AVAudioPlayerNode,
        format: AVAudioFormat?,
        to busID: String,
        replaceExisting: Bool = true
    ) {
        guard let busMixer = busMixers[busID] else { return }

        if replaceExisting,
           let existing = externalPlayers[busID],
           existing !== player {
            existing.stop()
            engine.disconnectNodeOutput(existing)
        }

        if player.engine == nil {
            engine.attach(player)
        } else if player.engine !== engine {
            return
        }

        engine.disconnectNodeOutput(player)
        engine.connect(player, to: busMixer, format: format)
        externalPlayers[busID] = player
    }

    public func setVolume(_ value: Float, for busID: String) {
        guard let mixer = busMixers[busID] else { return }
        mixer.outputVolume = max(0, min(1, value))
    }

    public func currentVolume(for busID: String) -> Float? {
        busMixers[busID]?.outputVolume
    }

    private static func makePCMBuffer(from file: AVAudioFile) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
            return nil
        }

        do {
            try file.read(into: buffer)
        } catch {
            return nil
        }

        return buffer
    }

    private static func makeSineBuffer(
        format: AVAudioFormat,
        frequency: Float,
        amplitude: Float,
        duration: TimeInterval
    ) -> AVAudioPCMBuffer? {
        let sampleRate = Float(format.sampleRate)
        let safeDuration = max(0.2, duration)
        let frames = AVAudioFrameCount(sampleRate * Float(safeDuration))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else {
            return nil
        }

        buffer.frameLength = frames

        guard let channels = buffer.floatChannelData else {
            return nil
        }

        let gain = max(0, min(1, amplitude))
        let omega = 2.0 * Float.pi * frequency / sampleRate
        let channelCount = Int(format.channelCount)

        for frame in 0..<Int(frames) {
            let sample = sinf(omega * Float(frame)) * gain
            for channel in 0..<channelCount {
                channels[channel][frame] = sample
            }
        }

        return buffer
    }
}

#endif
