import Foundation
import WidgetKit

struct MultiVolWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultiVolWidgetEntry {
        MultiVolWidgetEntry(
            date: Date(),
            sourceLevels: [
                .init(sourceID: "system-output", volume: 0.5),
                .init(sourceID: "mic-input", volume: 0.6),
                .init(sourceID: "media", volume: 0.4)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MultiVolWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MultiVolWidgetEntry>) -> Void) {
        let entry = placeholder(in: context)
        let refresh = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}
