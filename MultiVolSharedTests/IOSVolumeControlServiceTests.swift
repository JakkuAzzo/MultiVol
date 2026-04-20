#if os(macOS)
import Foundation
import XCTest

final class IOSVolumeControlServiceTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "IOSVolumeControlServiceTests")
        defaults.removePersistentDomain(forName: "IOSVolumeControlServiceTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "IOSVolumeControlServiceTests")
        defaults = nil
        super.tearDown()
    }

    func testStepVolumePersistsViaSharedStoreAPI() async {
        let store = VolumeStore(defaults: defaults)

        await store.upsert(0.5, for: "media")
        await store.upsert(0.55, for: "media")

        let map = await store.loadMap()
        XCTAssertNotNil(map["media"])
        XCTAssertEqual(map["media"] ?? -1, Float(0.55), accuracy: Float(0.001))
    }

    func testDisplayNameNormalizationForAppSources() {
        XCTAssertEqual(AudioSource.displayName(for: "app.spotify"), "Spotify")
        XCTAssertEqual(AudioSource.displayName(for: "app.youtube.browser"), "Youtube Browser")
    }
}
#endif
