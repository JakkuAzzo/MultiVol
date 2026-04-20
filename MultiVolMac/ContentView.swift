import SwiftUI
import WidgetKit
import Combine

struct MacContentView: View {
    private let service = MacOSVolumeControlService()
    @StateObject private var driverBridge = MultiVolAudioDriverBridge()
    @State private var sources: [AudioSource] = []
    @State private var appSessions: [String: AppAudioSession] = [:]
    @State private var levels: [String: Float] = [:]
    @State private var topologyStatus = ""
    @State private var ownedRouteStatus = ""
    @State private var ownedRoutes: [MacOSDedicatedOutputRoute] = []
    @State private var selectedOwnedRouteID = ""
    @State private var liveMixingActive = false
    @State private var meterLevels: [String: Float] = [:]
    @State private var appControlSupport: [String: Bool] = [:]

    private func refreshSourcesAndLevels() async {
        let latestSources = await service.allSources()
        let latestSessions = await service.appSessions()
        let latestTopologyStatus = await service.topologyStatusDescription()
        let latestOwnedRoutes = service.ownedOutputRoutes()
        let latestSelectedOwnedRouteID = service.selectedOwnedOutputRouteID() ?? ""
        let latestOwnedRouteStatus = service.ownedOutputRouteStateDescription()
        let latestLiveMixingActive = await service.isLiveMixingActive()
        var latestLevels: [String: Float] = levels
        var latestControlSupport: [String: Bool] = appControlSupport

        for source in latestSources {
            latestLevels[source.id] = await service.currentVolume(for: source.id)
            meterLevels[source.id] = await service.currentLevel(for: source.id)

            if source.kind == .application {
                latestControlSupport[source.id] = await service.isAppControlSupported(for: source.id)
            }
        }

        sources = latestSources
        appSessions = Dictionary(uniqueKeysWithValues: latestSessions.map { ($0.id, $0) })
        levels = latestLevels
        topologyStatus = latestTopologyStatus
        ownedRoutes = latestOwnedRoutes
        selectedOwnedRouteID = latestSelectedOwnedRouteID
        ownedRouteStatus = latestOwnedRouteStatus
        liveMixingActive = latestLiveMixingActive
        appControlSupport = latestControlSupport
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MultiVol macOS Control Panel")
                .font(.title2.bold())

            if !topologyStatus.isEmpty {
                Text(topologyStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Dedicated Output Route")
                    .font(.headline)

                Text(driverBridge.activationState.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if driverBridge.activationState == .embedded {
                    Button("Activate Embedded Driver") {
                        driverBridge.activateEmbeddedDriver()
                    }
                    .buttonStyle(.bordered)
                }

                if ownedRoutes.isEmpty {
                    Text(ownedRouteStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Picker(
                        "Dedicated Output Route",
                        selection: Binding(
                            get: { selectedOwnedRouteID },
                            set: { newValue in
                                selectedOwnedRouteID = newValue
                                Task {
                                    await service.selectOwnedOutputRoute(id: newValue.isEmpty ? nil : newValue)
                                    await refreshSourcesAndLevels()
                                }
                            }
                        )
                    ) {
                        Text("Automatic").tag("")
                        ForEach(ownedRoutes, id: \.id) { route in
                            Text(route.isDefaultOutput ? "\(route.name) (Active)" : route.name)
                                .tag(route.id)
                        }
                    }

                    Text(ownedRouteStatus)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(sources, id: \.id) { source in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 12) {
                        Text(source.displayName)
                            .frame(width: 130, alignment: .leading)

                        Slider(
                            value: Binding(
                                get: { levels[source.id] ?? 0.5 },
                                set: { newValue in
                                    levels[source.id] = newValue
                                    Task {
                                        await service.setVolume(newValue, for: source.id)
                                        WidgetCenter.shared.reloadAllTimelines()
                                    }
                                }
                            ),
                            in: 0...1
                        )

                        Text("\(Int((levels[source.id] ?? 0.5) * 100))%")
                            .frame(width: 42, alignment: .trailing)
                            .monospacedDigit()
                    }

                    LevelMeterView(level: meterLevels[source.id] ?? 0)
                        .padding(.leading, 142)

                    if let session = appSessions[source.id] {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sessionStatus(for: session))
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            if let isSupported = appControlSupport[source.id] {
                                Text(isSupported ? "Control supported on this setup." : "Control not supported on this setup.")
                                    .font(.caption2)
                                    .foregroundStyle(isSupported ? .green : .orange)
                            }
                        }
                        .padding(.leading, 142)
                    } else if source.id == "owned.music" {
                        Text("Built-in test tone is routed here when no bundled music-loop file is present.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 142)
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .task {
            await AppOwnedMixerBootstrap.shared.configureDefaults()
            driverBridge.refreshEmbeddedExtensionStatus()
            await refreshSourcesAndLevels()

            for await _ in Timer.publish(every: 2.0, on: .main, in: .common).autoconnect().values {
                await refreshSourcesAndLevels()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
        .task {
            for await _ in Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().values {
                var latest = meterLevels
                for source in sources {
                    latest[source.id] = await service.currentLevel(for: source.id)
                }
                meterLevels = latest
            }
        }
    }

    private func sessionStatus(for session: AppAudioSession) -> String {
        if session.hasProcessTap {
            return "Core Audio tap and live gain active for \(session.processIDs.count) process\(session.processIDs.count == 1 ? "" : "es")."
        }

        if session.supportsProcessTap {
            return "Session discovered and staged for a future isolated MultiVol output route. Direct device mixing stays off to protect current playback."
        }

        return "Per-app taps require macOS 14.2 or later."
    }
}

private struct LevelMeterView: View {
    let level: Float

    var body: some View {
        GeometryReader { proxy in
            let bounded = max(0, min(1, level))
            let activeWidth = proxy.size.width * CGFloat(bounded)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.2))

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: activeWidth)
            }
        }
        .frame(height: 6)
        .animation(.linear(duration: 0.08), value: level)
        .accessibilityLabel("Level meter")
        .accessibilityValue("\(Int(max(0, min(1, level)) * 100)) percent")
    }
}
