import SwiftUI
import WidgetKit

struct MultiVolWidgetView: View {
    let entry: MultiVolWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.sourceLevels, id: \.sourceID) { item in
                HStack {
                    Text(AudioSource.displayName(for: item.sourceID))
                        .font(.caption2)
                        .lineLimit(1)
                    Spacer()
                    Button(intent: AdjustVolumeIntent(
                        source: VolumeSourceEntity(id: item.sourceID, name: AudioSource.displayName(for: item.sourceID)),
                        increase: false
                    )) {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.plain)
                    Text("\(Int(item.volume * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                    Button(intent: AdjustVolumeIntent(
                        source: VolumeSourceEntity(id: item.sourceID, name: AudioSource.displayName(for: item.sourceID)),
                        increase: true
                    )) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
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
        .description("Monitor active source levels in a compact control panel widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct MultiVolWidgetBundle: WidgetBundle {
    var body: some Widget {
        MultiVolWidget()
    }
}
