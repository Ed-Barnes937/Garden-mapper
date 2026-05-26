import XCTest
@testable import GardenMapper

final class SetupViewModelTests: XCTestCase {
    private final class MockStorage: StickHeightStoring {
        var stickHeight: Int = 120
    }

    @MainActor
    func testDefaultHeight() {
        let storage = MockStorage()
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        XCTAssertEqual(vm.stickHeightCm, 120)
    }

    @MainActor
    func testIncrementHeight() {
        let storage = MockStorage()
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.incrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 125)
    }

    @MainActor
    func testIncrementHeightClampsAtMax() {
        let storage = MockStorage()
        storage.stickHeight = 298
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.incrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 300)
        vm.incrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 300)
    }

    @MainActor
    func testDecrementHeight() {
        let storage = MockStorage()
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.decrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 115)
    }

    @MainActor
    func testDecrementHeightClampsAtMin() {
        let storage = MockStorage()
        storage.stickHeight = 22
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.decrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 20)
        vm.decrementHeight()
        XCTAssertEqual(vm.stickHeightCm, 20)
    }

    @MainActor
    func testSetHeightClamps() {
        let storage = MockStorage()
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.setHeight(500)
        XCTAssertEqual(vm.stickHeightCm, 300)
        vm.setHeight(5)
        XCTAssertEqual(vm.stickHeightCm, 20)
    }

    @MainActor
    func testHeightPersistsToStorage() {
        let storage = MockStorage()
        let vm = SetupViewModel(storage: storage, lidarAvailable: true)
        vm.stickHeightCm = 150
        XCTAssertEqual(storage.stickHeight, 150)
    }

    @MainActor
    func testCanStartScanWithLiDAR() {
        let vm = SetupViewModel(storage: MockStorage(), lidarAvailable: true)
        XCTAssertTrue(vm.canStartScan)
    }

    @MainActor
    func testCannotStartScanWithoutLiDAR() {
        let vm = SetupViewModel(storage: MockStorage(), lidarAvailable: false)
        XCTAssertFalse(vm.canStartScan)
    }
}
