import XCTest
@testable import GardenMapper

final class PointCloudViewerViewModelTests: XCTestCase {
    private func makeSession(withBoundary: Bool = false, closed: Bool = false) -> ScanSession {
        var session = ScanSession(stickHeightCm: 120, startDate: Date())
        session.addPoint(CapturedPoint(x: 0, y: 1.0, z: 0))
        session.addPoint(CapturedPoint(x: 1, y: 1.3, z: 0))
        session.addPoint(CapturedPoint(x: 2, y: 1.1, z: 0))

        if withBoundary {
            session.addStake(BoundaryStake(x: 0, z: 0, index: 1))
            session.addStake(BoundaryStake(x: 10, z: 0, index: 2))
            session.addStake(BoundaryStake(x: 10, z: 10, index: 3))
            session.addStake(BoundaryStake(x: 0, z: 10, index: 4))
            if closed { session.closeBoundary() }
        }
        return session
    }

    @MainActor
    func testPointCount() {
        let vm = PointCloudViewerViewModel(session: makeSession())
        XCTAssertEqual(vm.pointCount, 3)
    }

    @MainActor
    func testDisplayPointsReOrigined() {
        let vm = PointCloudViewerViewModel(session: makeSession())
        let points = vm.displayPoints
        XCTAssertEqual(points[0].x, 0, accuracy: 0.001)
        XCTAssertEqual(points[0].y, 0, accuracy: 0.001)
        XCTAssertEqual(points[1].x, 1, accuracy: 0.001)
        XCTAssertEqual(points[1].y, 0.3, accuracy: 0.001)
    }

    @MainActor
    func testNormalizedElevations() {
        let vm = PointCloudViewerViewModel(session: makeSession())
        let normalized = vm.normalizedElevations
        XCTAssertEqual(normalized[0], 0.0, accuracy: 0.001)
        XCTAssertEqual(normalized[1], 1.0, accuracy: 0.001)
    }

    @MainActor
    func testElevationDelta() {
        let vm = PointCloudViewerViewModel(session: makeSession())
        XCTAssertEqual(vm.elevationDelta, 0.3, accuracy: 0.001)
        XCTAssertEqual(vm.elevationDeltaFormatted, "0.30m")
    }

    @MainActor
    func testAreaNilWhenBoundaryOpen() {
        let vm = PointCloudViewerViewModel(session: makeSession(withBoundary: true, closed: false))
        XCTAssertNil(vm.area)
        XCTAssertNil(vm.areaFormatted)
    }

    @MainActor
    func testAreaWhenBoundaryClosed() {
        let vm = PointCloudViewerViewModel(session: makeSession(withBoundary: true, closed: true))
        XCTAssertNotNil(vm.area)
        XCTAssertEqual(vm.area!, 100.0, accuracy: 0.1) // 10x10 square
    }

    @MainActor
    func testPerimeterNilWhenOpen() {
        let vm = PointCloudViewerViewModel(session: makeSession(withBoundary: true, closed: false))
        XCTAssertNil(vm.perimeter)
    }

    @MainActor
    func testPerimeterWhenClosed() {
        let vm = PointCloudViewerViewModel(session: makeSession(withBoundary: true, closed: true))
        XCTAssertNotNil(vm.perimeter)
        XCTAssertEqual(vm.perimeter!, 40.0, accuracy: 0.1) // 10x10 square
    }

    @MainActor
    func testNoBoundary() {
        let vm = PointCloudViewerViewModel(session: makeSession())
        XCTAssertNil(vm.area)
        XCTAssertNil(vm.perimeter)
    }
}
