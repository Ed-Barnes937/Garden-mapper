import XCTest
@testable import GardenMapper

final class ScanSessionTests: XCTestCase {
    private func makeSession() -> ScanSession {
        ScanSession(stickHeightCm: 120, startDate: Date())
    }

    private func makePoint(x: Float = 0, y: Float = 0, z: Float = 0) -> CapturedPoint {
        CapturedPoint(x: x, y: y, z: z)
    }

    private func makeStake(x: Float = 0, z: Float = 0, index: Int = 1) -> BoundaryStake {
        BoundaryStake(x: x, z: z, index: index)
    }

    // MARK: - Stick height

    func testStickHeightMeters() {
        let session = ScanSession(stickHeightCm: 150, startDate: Date())
        XCTAssertEqual(session.stickHeightMeters, 1.5, accuracy: 0.001)
    }

    // MARK: - Points

    func testAddPoint() {
        var session = makeSession()
        session.addPoint(makePoint(x: 1, y: 2, z: 3))
        XCTAssertEqual(session.capturedPoints.count, 1)
        XCTAssertEqual(session.capturedPoints[0].x, 1)
    }

    func testUndoLastPoint() {
        var session = makeSession()
        session.addPoint(makePoint(x: 1))
        session.addPoint(makePoint(x: 2))
        session.undoLastPoint()
        XCTAssertEqual(session.capturedPoints.count, 1)
        XCTAssertEqual(session.capturedPoints[0].x, 1)
    }

    func testUndoLastPointEmpty() {
        var session = makeSession()
        session.undoLastPoint()
        XCTAssertTrue(session.capturedPoints.isEmpty)
    }

    // MARK: - Stakes

    func testAddStake() {
        var session = makeSession()
        session.addStake(makeStake(x: 1, z: 2, index: 1))
        XCTAssertEqual(session.boundaryStakes.count, 1)
    }

    func testAddStakeBlockedWhenClosed() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.addStake(makeStake(index: 3))
        session.closeBoundary()
        session.addStake(makeStake(index: 4))
        XCTAssertEqual(session.boundaryStakes.count, 3)
    }

    func testUndoLastStake() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.undoLastStake()
        XCTAssertEqual(session.boundaryStakes.count, 1)
    }

    func testUndoLastStakeEmpty() {
        var session = makeSession()
        session.undoLastStake()
        XCTAssertTrue(session.boundaryStakes.isEmpty)
    }

    func testUndoStakeWhenClosedReopens() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.addStake(makeStake(index: 3))
        session.closeBoundary()
        XCTAssertTrue(session.boundaryClosed)
        session.undoLastStake()
        XCTAssertFalse(session.boundaryClosed)
        XCTAssertEqual(session.boundaryStakes.count, 2)
    }

    // MARK: - Boundary close/reopen

    func testCloseBoundaryRequiresThreeStakes() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.closeBoundary()
        XCTAssertFalse(session.boundaryClosed)
    }

    func testCloseBoundaryWithThreeStakes() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.addStake(makeStake(index: 3))
        session.closeBoundary()
        XCTAssertTrue(session.boundaryClosed)
    }

    func testReopenBoundary() {
        var session = makeSession()
        session.addStake(makeStake(index: 1))
        session.addStake(makeStake(index: 2))
        session.addStake(makeStake(index: 3))
        session.closeBoundary()
        session.reopenBoundary()
        XCTAssertFalse(session.boundaryClosed)
    }

    func testNextStakeIndex() {
        var session = makeSession()
        XCTAssertEqual(session.nextStakeIndex, 1)
        session.addStake(makeStake(index: 1))
        XCTAssertEqual(session.nextStakeIndex, 2)
        session.addStake(makeStake(index: 2))
        XCTAssertEqual(session.nextStakeIndex, 3)
    }
}
