import SwiftUI
import WidgetKit

struct IOSContentView: View {
    private let service = IOSVolumeControlService()
    @State private var sources: [AudioSource] = []
    @State private var levels: [String: Float] = [:]
    @State private var meterLevels: [String: Float] = [:]

    var body: some View {
        NavigationStack {
            List(sources, id: \.id) { source in
                VStack(alignment: .leading, spacing: 8) {
                    Text(source.displayName)
                        .font(.headline)
                    HStack {
                        Button("-") {
                            Task {
                                let next = await service.stepVolume(by: -0.05, for: source.id)
                                levels[source.id] = next
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
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
                        Button("+") {
                            Task {
                                let next = await service.stepVolume(by: 0.05, for: source.id)
                                levels[source.id] = next
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                    }

                    LevelMeterView(level: meterLevels[source.id] ?? 0)
                        .frame(height: 6)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("MultiVol Control Panel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Control Panel") {
                        ForEach(sources, id: \.id) { source in
                            Button("Raise \(source.displayName)") {
                                Task {
                                    let next = await service.stepVolume(by: 0.05, for: source.id)
                                    levels[source.id] = next
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }

                            Button("Lower \(source.displayName)") {
                                Task {
                                    let next = await service.stepVolume(by: -0.05, for: source.id)
                                    levels[source.id] = next
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await AppOwnedMixerBootstrap.shared.configureDefaults()
                sources = await service.allSources()
                for source in sources {
                    levels[source.id] = await service.currentVolume(for: source.id)
                    meterLevels[source.id] = await service.currentLevel(for: source.id)
                }
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
    }
}

private struct LevelMeterView: View {
    let level: Float

    var body: some View {
        GeometryReader { proxy in
            let bounded = max(0, min(1, level))
            let width = proxy.size.width * CGFloat(bounded)

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
                    .frame(width: width)
            }
        }
        .animation(.linear(duration: 0.08), value: level)
        .accessibilityLabel("Level meter")
        .accessibilityValue("\(Int(max(0, min(1, level)) * 100)) percent")
    }
}
