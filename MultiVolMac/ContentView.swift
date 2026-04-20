import SwiftUI
import WidgetKit
import Combine

struct MacContentView: View {
    private let service = MacOSVolumeControlService()
    @State private var sources: [AudioSource] = []
    @State private var levels: [String: Float] = [:]

    private func refreshSourcesAndLevels() async {
        let latestSources = await service.allSources()
        var latestLevels: [String: Float] = levels

        for source in latestSources {
            latestLevels[source.id] = await service.currentVolume(for: source.id)
        }

        sources = latestSources
        levels = latestLevels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MultiVol macOS Control Panel")
                .font(.title2.bold())

            ForEach(sources, id: \.id) { source in
                HStack(spacing: 12) {
                    Text(source.displayName)
                        .frame(width: 90, alignment: .leading)

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
            }
            Spacer()
        }
        .padding(16)
        .task {
            await refreshSourcesAndLevels()

            for await _ in Timer.publish(every: 2.0, on: .main, in: .common).autoconnect().values {
                await refreshSourcesAndLevels()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
