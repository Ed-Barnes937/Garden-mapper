import XCTest
import simd
@testable import GardenMapper

final class DistanceTrackerTests: XCTestCase {
    func testInitialState() {
        let tracker = DistanceTracker()
        XCTAssertEqual(tracker.totalDistance, 0)
        XCTAssertTrue(tracker.positions.isEmpty)
    }

    func testSinglePositionNoThreshold() {
        var tracker = DistanceTracker()
        let triggered = tracker.addPosition(SIMD3(0, 0, 0))
        XCTAssertFalse(triggered)
        XCTAssertEqual(tracker.totalDistance, 0)
    }

    func testCumulativeDistance() {
        var tracker = DistanceTracker()
        _ = tracker.addPosition(SIMD3(0, 0, 0))
        _ = tracker.addPosition(SIMD3(3, 0, 0))
        _ = tracker.addPosition(SIMD3(3, 0, 4))
        XCTAssertEqual(tracker.totalDistance, 7.0, accuracy: 0.001)
    }

    func testThresholdTriggeredAtExactly15m() {
        var tracker = DistanceTracker()
        _ = tracker.addPosition(SIMD3(0, 0, 0))
        let triggered = tracker.addPosition(SIMD3(15, 0, 0))
        XCTAssertTrue(triggered)
    }

    func testThresholdNotTriggeredBelow15m() {
        var tracker = DistanceTracker()
        _ = tracker.addPosition(SIMD3(0, 0, 0))
        let triggered = tracker.addPosition(SIMD3(14.9, 0, 0))
        XCTAssertFalse(triggered)
    }

    func testThresholdTriggeredCumulatively() {
        var tracker = DistanceTracker()
        _ = tracker.addPosition(SIMD3(0, 0, 0))
        _ = tracker.addPosition(SIMD3(5, 0, 0))
        _ = tracker.addPosition(SIMD3(10, 0, 0))
        let triggered = tracker.addPosition(SIMD3(16, 0, 0))
        XCTAssertTrue(triggered)
    }

    func testReset() {
        var tracker = DistanceTracker()
        _ = tracker.addPosition(SIMD3(0, 0, 0))
        _ = tracker.addPosition(SIMD3(10, 0, 0))
        tracker.reset()
        XCTAssertEqual(tracker.totalDistance, 0)
        XCTAssertTrue(tracker.positions.isEmpty)
    }
}
