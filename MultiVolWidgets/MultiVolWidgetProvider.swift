import Foundation
import WidgetKit

struct MultiVolWidgetProvider: TimelineProvider {
    private func persistedEntry() async -> MultiVolWidgetEntry {
        let persisted = await VolumeStore.shared.load()
        let fallback = [
            VolumeSnapshot(sourceID: "system-output", volume: 0.5),
            VolumeSnapshot(sourceID: "mic-input", volume: 0.6),
            VolumeSnapshot(sourceID: "app.spotify", volume: 0.4)
        ]

        return MultiVolWidgetEntry(date: Date(), sourceLevels: persisted.isEmpty ? fallback : persisted)
    }

    func placeholder(in context: Context) -> MultiVolWidgetEntry {
        MultiVolWidgetEntry(
            date: Date(),
            sourceLevels: [
                .init(sourceID: "system-output", volume: 0.5),
                .init(sourceID: "mic-input", volume: 0.6),
                .init(sourceID: "app.spotify", volume: 0.4)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MultiVolWidgetEntry) -> Void) {
        Task {
            completion(await persistedEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MultiVolWidgetEntry>) -> Void) {
        Task {
            let entry = await persistedEntry()
            let refresh = Calendar.current.date(byAdding: .minute, value: 2, to: Date()) ?? Date()
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }
}
