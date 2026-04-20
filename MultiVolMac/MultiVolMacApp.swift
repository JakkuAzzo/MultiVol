import SwiftUI

@main
struct MultiVolMacApp: App {
    var body: some Scene {
        MenuBarExtra("MultiVol", systemImage: "speaker.wave.2.fill") {
            MacContentView()
                .frame(width: 420, height: 320)
        }
        .menuBarExtraStyle(.window)

        Settings {
            VStack(alignment: .leading, spacing: 10) {
                Text("MultiVol")
                    .font(.headline)
                Text("Use the menu bar icon to control active audio sources.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
    }
}
