import SwiftUI

struct MacContentView: View {
    private let service = MacOSVolumeControlService()
    @State private var sources: [AudioSource] = []
    @State private var levels: [String: Float] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MultiVol macOS")
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
                                Task { await service.setVolume(newValue, for: source.id) }
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
            sources = await service.allSources()
            for source in sources {
                levels[source.id] = await service.currentVolume(for: source.id)
            }
        }
    }
}
