import SwiftUI
import WidgetKit

struct MultiVolWidgetView: View {
    let entry: MultiVolWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.sourceLevels, id: \.sourceID) { item in
                HStack {
                    Text(item.sourceID)
                        .font(.caption2)
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(item.volume * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                }
            }
        }
        .padding(8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MultiVolWidget: Widget {
    let kind: String = "MultiVolWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MultiVolWidgetProvider()) { entry in
            MultiVolWidgetView(entry: entry)
        }
        .configurationDisplayName("MultiVol")
        .description("See and adjust audio source levels.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MultiVolWidgetBundle: WidgetBundle {
    var body: some Widget {
        MultiVolWidget()
    }
}
