import SwiftUI

@main
struct MultiVolMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .frame(minWidth: 420, minHeight: 280)
        }
    }
}
