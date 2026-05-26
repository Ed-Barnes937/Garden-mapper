import XCTest
@testable import GardenMapper

final class StickHeightStorageTests: XCTestCase {
    private var storage: StickHeightStorage!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "test-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        storage = StickHeightStorage(defaults: defaults)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(storage.stickHeight, 120)
    }

    func testPersistAndRead() {
        storage.stickHeight = 150
        let storage2 = StickHeightStorage(defaults: defaults)
        XCTAssertEqual(storage2.stickHeight, 150)
    }

    func testClampLow() {
        storage.stickHeight = 5
        XCTAssertEqual(storage.stickHeight, 20)
    }

    func testClampHigh() {
        storage.stickHeight = 500
        XCTAssertEqual(storage.stickHeight, 300)
    }

    func testClampFunction() {
        XCTAssertEqual(StickHeightStorage.clamp(10), 20)
        XCTAssertEqual(StickHeightStorage.clamp(400), 300)
        XCTAssertEqual(StickHeightStorage.clamp(150), 150)
    }
}
