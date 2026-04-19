import SwiftUI

struct IOSContentView: View {
    private let service = IOSVolumeControlService()
    @State private var sources: [AudioSource] = []
    @State private var levels: [String: Float] = [:]

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
                            }
                        }
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
                        Button("+") {
                            Task {
                                let next = await service.stepVolume(by: 0.05, for: source.id)
                                levels[source.id] = next
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("MultiVol iOS")
            .task {
                sources = await service.allSources()
                for source in sources {
                    levels[source.id] = await service.currentVolume(for: source.id)
                }
            }
        }
    }
}
