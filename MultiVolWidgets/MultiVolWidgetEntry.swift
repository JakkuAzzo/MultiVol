import Foundation
import WidgetKit

struct MultiVolWidgetEntry: TimelineEntry {
    let date: Date
    let sourceLevels: [VolumeSnapshot]
}
