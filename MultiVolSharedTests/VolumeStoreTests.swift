import Foundation
import XCTest

final class VolumeStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "MultiVolSharedTests")
        defaults.removePersistentDomain(forName: "MultiVolSharedTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "MultiVolSharedTests")
        defaults = nil
        super.tearDown()
    }

    func testUpsertPersistsAndLoadsValues() async {
        let store = VolumeStore(defaults: defaults)

        await store.upsert(0.33, for: "app.spotify")
        await store.upsert(0.81, for: "system-output")

        let map = await store.loadMap()
        XCTAssertNotNil(map["app.spotify"])
        XCTAssertNotNil(map["system-output"])
        XCTAssertEqual(map["app.spotify"] ?? -1, Float(0.33), accuracy: Float(0.001))
        XCTAssertEqual(map["system-output"] ?? -1, Float(0.81), accuracy: Float(0.001))
    }

    func testValuesAreClampedIntoValidRange() async {
        let store = VolumeStore(defaults: defaults)

        await store.upsert(-2, for: "mic-input")
        await store.upsert(5, for: "system-output")

        let map = await store.loadMap()
        XCTAssertNotNil(map["mic-input"])
        XCTAssertNotNil(map["system-output"])
        XCTAssertEqual(map["mic-input"] ?? -1, Float(0), accuracy: Float(0.001))
        XCTAssertEqual(map["system-output"] ?? -1, Float(1), accuracy: Float(0.001))
    }
}
