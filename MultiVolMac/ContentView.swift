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

    private func refreshSourcesAndLevels() async {
        let latestSources = await service.allSources()
        let latestSessions = await service.appSessions()
        let latestTopologyStatus = await service.topologyStatusDescription()
        let latestOwnedRoutes = service.ownedOutputRoutes()
        let latestSelectedOwnedRouteID = service.selectedOwnedOutputRouteID() ?? ""
        let latestOwnedRouteStatus = service.ownedOutputRouteStateDescription()
        var latestLevels: [String: Float] = levels

        for source in latestSources {
            latestLevels[source.id] = await service.currentVolume(for: source.id)
        }

        sources = latestSources
        appSessions = Dictionary(uniqueKeysWithValues: latestSessions.map { ($0.id, $0) })
        levels = latestLevels
        topologyStatus = latestTopologyStatus
        ownedRoutes = latestOwnedRoutes
        selectedOwnedRouteID = latestSelectedOwnedRouteID
        ownedRouteStatus = latestOwnedRouteStatus
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

                    if let session = appSessions[source.id] {
                        Text(sessionStatus(for: session))
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
