#if os(macOS)
import CoreAudio
import Foundation

final class MacOSProcessTapMixerRuntime {
    struct OutputContext {
        let deviceID: AudioObjectID
        let deviceUID: String
        let streamIndex: UInt
        let streamFormat: AudioStreamBasicDescription
    }

    enum Topology {
        case discoveryOnly
        case waitingForIsolatedOutput(currentOutput: OutputContext)
        case isolatedOutput(currentOutput: OutputContext, multiVolOutputUID: String)

        var canActivateLiveMixing: Bool {
            if case .isolatedOutput = self {
                return true
            }
            return false
        }

        var statusDescription: String {
            switch self {
            case .discoveryOnly:
                return "MultiVol is discovering app sessions, but no stable output route is available yet."
            case .waitingForIsolatedOutput:
                return "MultiVol is staging per-app sessions and waiting for an isolated MultiVol output device before live mixing turns on."
            case .isolatedOutput:
                return "MultiVol is attached to an isolated output device and can safely enable live per-app mixing."
            }
        }
    }

    struct PreparedSession: Equatable {
        let id: String
        let gain: Float
        let channelCount: Int
        let bufferedFrames: Int
    }

    private final class SessionBuffer {
        let channelCount: Int
        private let capacityFrames: Int
        private var storage: [Float]
        private var readIndex = 0
        private var writeIndex = 0
        private var availableFrames = 0
        private let lock = NSLock()
        private var gain: Float

        init(channelCount: Int, capacityFrames: Int = 32768, gain: Float) {
            self.channelCount = max(1, channelCount)
            self.capacityFrames = max(1024, capacityFrames)
            self.storage = Array(repeating: 0, count: self.capacityFrames * self.channelCount)
            self.gain = gain
        }

        func setGain(_ value: Float) {
            lock.lock()
            gain = value
            lock.unlock()
        }

        func snapshot(id: String) -> PreparedSession {
            lock.lock()
            defer { lock.unlock() }
            return PreparedSession(
                id: id,
                gain: gain,
                channelCount: channelCount,
                bufferedFrames: availableFrames
            )
        }

        func reset() {
            lock.lock()
            readIndex = 0
            writeIndex = 0
            availableFrames = 0
            if !storage.isEmpty {
                storage.replaceSubrange(0..<storage.count, with: repeatElement(0, count: storage.count))
            }
            lock.unlock()
        }
    }

    private var sessionBuffers: [String: SessionBuffer] = [:]
    private var topology: Topology = .discoveryOnly
    private let stateLock = NSLock()

    func configure(outputContext: OutputContext?) {
        stateLock.lock()
        defer { stateLock.unlock() }

        guard let outputContext else {
            topology = .discoveryOnly
            sessionBuffers.removeAll()
            return
        }

        switch topology {
        case let .isolatedOutput(_, multiVolOutputUID):
            topology = .isolatedOutput(currentOutput: outputContext, multiVolOutputUID: multiVolOutputUID)
        default:
            topology = .waitingForIsolatedOutput(currentOutput: outputContext)
        }
    }

    func topologyStatus() -> Topology {
        stateLock.lock()
        defer { stateLock.unlock() }
        return topology
    }

    func registerIsolatedOutputDevice(uid: String) {
        stateLock.lock()
        defer { stateLock.unlock() }

        switch topology {
        case let .waitingForIsolatedOutput(outputContext),
             let .isolatedOutput(outputContext, _):
            topology = .isolatedOutput(currentOutput: outputContext, multiVolOutputUID: uid)
        case .discoveryOnly:
            break
        }
    }

    func unregisterIsolatedOutputDevice() {
        stateLock.lock()
        defer { stateLock.unlock() }

        guard case let .isolatedOutput(outputContext, _) = topology else { return }
        topology = .waitingForIsolatedOutput(currentOutput: outputContext)
    }

    func stageSession(id: String, volume: Float, format: AudioStreamBasicDescription) {
        stateLock.lock()
        defer { stateLock.unlock() }

        let channelCount = Int(max(1, format.mChannelsPerFrame))
        if let buffer = sessionBuffers[id] {
            buffer.setGain(volume)
        } else {
            sessionBuffers[id] = SessionBuffer(channelCount: channelCount, gain: volume)
        }
    }

    func preparedSession(id: String) -> PreparedSession? {
        stateLock.lock()
        let buffer = sessionBuffers[id]
        stateLock.unlock()
        return buffer?.snapshot(id: id)
    }

    func setGain(_ value: Float, for id: String) {
        stateLock.lock()
        let buffer = sessionBuffers[id]
        stateLock.unlock()
        buffer?.setGain(value)
    }

    func removeSession(id: String) {
        stateLock.lock()
        let buffer = sessionBuffers.removeValue(forKey: id)
        stateLock.unlock()
        buffer?.reset()
    }

    func removeAllSessions() {
        stateLock.lock()
        let buffers = Array(sessionBuffers.values)
        sessionBuffers.removeAll()
        stateLock.unlock()

        for buffer in buffers {
            buffer.reset()
        }
    }
}
#endif
