#if os(macOS)
import AppKit
import CoreAudio
import Foundation

public actor MacOSProcessTapController {
    public static let shared = MacOSProcessTapController()

    private struct SessionRecord {
        var session: AppAudioSession
        var tapID: AudioObjectID?
    }

    private var records: [String: SessionRecord] = [:]
    private let runtime = MacOSProcessTapMixerRuntime()

    public init() {}

    public func refreshSessions(store: VolumeStore = .shared) async -> [AppAudioSession] {
        let persisted = await store.loadMap()
        let discovered = discoverSessions(persistedVolumes: persisted)
        reconcileRecords(with: discovered)
        return sessions()
    }

    public func sessions() -> [AppAudioSession] {
        records.values.map(\.session).sorted(using: sessionSortComparator)
    }

    public func setVolume(_ value: Float, for sourceID: String) {
        guard var record = records[sourceID] else { return }
        record.session = AppAudioSession(
            id: record.session.id,
            displayName: record.session.displayName,
            bundleID: record.session.bundleID,
            processObjectIDs: record.session.processObjectIDs,
            processIDs: record.session.processIDs,
            supportsProcessTap: record.session.supportsProcessTap,
            hasProcessTap: record.tapID != nil,
            volume: value
        )
        records[sourceID] = record
        runtime.setGain(value, for: sourceID)
    }

    public func topologyStatusDescription() -> String {
        runtime.topologyStatus().statusDescription
    }

    public func isLiveMixingActive() -> Bool {
        runtime.topologyStatus().canActivateLiveMixing
    }

    private func reconcileRecords(with discovered: [AppAudioSession]) {
        guard let outputContext = defaultOutputContext() else {
            runtime.configure(outputContext: nil)
            records.removeAll()
            return
        }
        runtime.configure(outputContext: outputContext)
        syncOwnedOutputRouteRegistration()

        let discoveredByID = Dictionary(uniqueKeysWithValues: discovered.map { ($0.id, $0) })

        for removedID in records.keys.filter({ discoveredByID[$0] == nil }) {
            runtime.removeSession(id: removedID)
            if let tapID = records[removedID]?.tapID {
                AudioHardwareDestroyProcessTap(tapID)
            }
            records.removeValue(forKey: removedID)
        }

        for session in discovered {
            var record = records[session.id] ?? SessionRecord(session: session, tapID: nil)
            record.session = AppAudioSession(
                id: session.id,
                displayName: session.displayName,
                bundleID: session.bundleID,
                processObjectIDs: session.processObjectIDs,
                processIDs: session.processIDs,
                supportsProcessTap: session.supportsProcessTap,
                hasProcessTap: record.tapID != nil,
                volume: session.volume
            )
            runtime.stageSession(id: record.session.id, volume: record.session.volume, format: outputContext.streamFormat)

            if let tapID = record.tapID {
                runtime.removeSession(id: record.session.id)
                AudioHardwareDestroyProcessTap(tapID)
                record.tapID = nil
            }

            records[session.id] = record
        }
    }

    private func discoverSessions(persistedVolumes: [String: Float]) -> [AppAudioSession] {
        guard #available(macOS 14.2, *) else { return [] }

        let runningApps = NSWorkspace.shared.runningApplications
        let grouped = Dictionary(grouping: activeOutputProcesses()) { process -> String in
            if let bundleID = process.bundleID, !bundleID.isEmpty {
                return "app.\(bundleID)"
            }
            return "process.\(process.pid)"
        }

        return grouped.compactMap { sourceID, processes in
            let sortedProcesses = processes.sorted { lhs, rhs in
                lhs.pid < rhs.pid
            }
            guard let first = sortedProcesses.first else { return nil }

            return AppAudioSession(
                id: sourceID,
                displayName: preferredDisplayName(
                    for: first.bundleID,
                    pids: sortedProcesses.map(\.pid),
                    runningApps: runningApps
                ),
                bundleID: first.bundleID,
                processObjectIDs: sortedProcesses.map(\.objectID),
                processIDs: sortedProcesses.map(\.pid),
                supportsProcessTap: true,
                hasProcessTap: false,
                volume: persistedVolumes[sourceID] ?? 1
            )
        }
        .sorted(using: sessionSortComparator)
    }

    @available(macOS 14.2, *)
    private func createTap(for session: AppAudioSession, outputContext: MacOSProcessTapMixerRuntime.OutputContext) -> AudioObjectID? {
        guard !session.processObjectIDs.isEmpty else { return nil }

        let description = CATapDescription(
            processes: session.processObjectIDs,
            deviceUID: outputContext.deviceUID,
            stream: outputContext.streamIndex
        )
        description.name = session.displayName
        description.isPrivate = true

        var tapID = AudioObjectID()
        let status = AudioHardwareCreateProcessTap(description, &tapID)
        guard status == noErr else { return nil }
        return tapID
    }

    private func preferredDisplayName(
        for bundleID: String?,
        pids: [pid_t],
        runningApps: [NSRunningApplication]
    ) -> String {
        for pid in pids {
            if let app = runningApps.first(where: { $0.processIdentifier == pid }),
               let localizedName = app.localizedName,
               !localizedName.isEmpty {
                return localizedName
            }
        }

        if let bundleID, !bundleID.isEmpty {
            return AudioSource.displayName(for: "app.\(bundleID)")
        }

        if let pid = pids.first {
            return "Process \(pid)"
        }

        return "Unknown App"
    }

    private func activeOutputProcesses() -> [ProcessDescriptor] {
        processObjectIDs().compactMap { objectID in
            guard readUInt32Property(objectID, selector: kAudioProcessPropertyIsRunningOutput) == 1 else {
                return nil
            }

            guard let pidValue = readPIDProperty(objectID) else { return nil }
            guard pidValue != ProcessInfo.processInfo.processIdentifier else { return nil }

            return ProcessDescriptor(
                objectID: objectID,
                pid: pidValue,
                bundleID: readStringProperty(objectID, selector: kAudioProcessPropertyBundleID)
            )
        }
    }

    private func processObjectIDs() -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcessObjectList,
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
        var values = Array(repeating: AudioObjectID(), count: count)

        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &values
        ) == noErr else {
            return []
        }

        return values
    }

    private func readUInt32Property(_ objectID: AudioObjectID, selector: AudioObjectPropertySelector) -> UInt32? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &value)
        return status == noErr ? value : nil
    }

    private func readPIDProperty(_ objectID: AudioObjectID) -> pid_t? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioProcessPropertyPID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: pid_t = 0
        var size = UInt32(MemoryLayout<pid_t>.size)

        let status = AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &value)
        return status == noErr ? value : nil
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

    private func defaultOutputContext() -> MacOSProcessTapMixerRuntime.OutputContext? {
        guard let deviceID = defaultOutputDeviceID(),
              let deviceUID = readStringProperty(deviceID, selector: kAudioDevicePropertyDeviceUID),
              let streamObjectID = firstOutputStreamID(for: deviceID),
              let streamFormat = readStreamFormat(streamObjectID)
        else {
            return nil
        }

        return MacOSProcessTapMixerRuntime.OutputContext(
            deviceID: deviceID,
            deviceUID: deviceUID,
            streamIndex: 0,
            streamFormat: streamFormat
        )
    }

    private func syncOwnedOutputRouteRegistration() {
        switch MacOSDedicatedOutputRouteManager.shared.routeState() {
        case let .active(route):
            runtime.registerIsolatedOutputDevice(uid: route.id)
        case .availableButInactive, .unavailable:
            runtime.unregisterIsolatedOutputDevice()
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

    private func firstOutputStreamID(for deviceID: AudioDeviceID) -> AudioObjectID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size) == noErr else {
            return nil
        }

        let count = Int(size) / MemoryLayout<AudioObjectID>.size
        var streamIDs = Array(repeating: AudioObjectID(), count: count)
        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &streamIDs) == noErr else {
            return nil
        }

        return streamIDs.first
    }

    private func readStreamFormat(_ streamObjectID: AudioObjectID) -> AudioStreamBasicDescription? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioStreamPropertyVirtualFormat,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var format = AudioStreamBasicDescription()
        var size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        let status = AudioObjectGetPropertyData(streamObjectID, &address, 0, nil, &size, &format)
        return status == noErr ? format : nil
    }

    private var sessionSortComparator: KeyPathComparator<AppAudioSession> {
        KeyPathComparator(\.displayName, comparator: .localizedStandard)
    }
}

private struct ProcessDescriptor {
    let objectID: AudioObjectID
    let pid: pid_t
    let bundleID: String?
}
#endif
