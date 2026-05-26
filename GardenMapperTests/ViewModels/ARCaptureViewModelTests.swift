import XCTest
import simd
@testable import GardenMapper

final class ARCaptureViewModelTests: XCTestCase {
    @MainActor
    private func makeVM(stickHeight: Int = 120,
                        raycastResult: SIMD3<Float>? = SIMD3<Float>(1, 2.4, 3)) -> (ARCaptureViewModel, MockARSessionService) {
        let mock = MockARSessionService()
        mock.mockRaycastResult = raycastResult
        let vm = ARCaptureViewModel(stickHeightCm: stickHeight, arService: mock)
        return (vm, mock)
    }

    // MARK: - Session lifecycle

    @MainActor
    func testStartSession() {
        let (vm, mock) = makeVM()
        vm.startSession()
        XCTAssertTrue(mock.startSessionCalled)
    }

    @MainActor
    func testStopSession() {
        let (vm, mock) = makeVM()
        vm.stopSession()
        XCTAssertTrue(mock.pauseSessionCalled)
    }

    // MARK: - Elevation capture

    @MainActor
    func testCaptureElevationPoint() async {
        let (vm, _) = makeVM(stickHeight: 120, raycastResult: SIMD3(1, 2.4, 3))
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.pointCount, 1)
        let point = vm.session.capturedPoints[0]
        XCTAssertEqual(point.x, 1, accuracy: 0.001)
        XCTAssertEqual(point.y, 1.2, accuracy: 0.001)
        XCTAssertEqual(point.z, 3, accuracy: 0.001)
    }

    @MainActor
    func testCaptureIgnoredWhenRaycastFails() async {
        let (vm, mock) = makeVM(raycastResult: nil)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.pointCount, 0)
        XCTAssertEqual(mock.raycastCallCount, 1)
    }

    // MARK: - Boundary capture

    @MainActor
    func testPlaceBoundaryStake() async {
        let (vm, _) = makeVM(raycastResult: SIMD3(5, 0, 10))
        vm.switchMode(to: .boundary)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.stakeCount, 1)
        let stake = vm.session.boundaryStakes[0]
        XCTAssertEqual(stake.x, 5, accuracy: 0.001)
        XCTAssertEqual(stake.z, 10, accuracy: 0.001)
        XCTAssertEqual(stake.index, 1)
    }

    @MainActor
    func testCloseBoundary() async {
        let (vm, mock) = makeVM()
        vm.switchMode(to: .boundary)
        for i in 0..<3 {
            mock.mockRaycastResult = SIMD3(Float(i), 0, Float(i))
            await vm.captureAtScreenPoint(.zero)
        }
        XCTAssertTrue(vm.canCloseBoundary)
        vm.closeBoundary()
        XCTAssertTrue(vm.session.boundaryClosed)
        XCTAssertFalse(vm.canCloseBoundary)
    }

    @MainActor
    func testCannotCloseWithFewerThan3Stakes() async {
        let (vm, _) = makeVM()
        vm.switchMode(to: .boundary)
        await vm.captureAtScreenPoint(.zero)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertFalse(vm.canCloseBoundary)
    }

    @MainActor
    func testReopenBoundary() async {
        let (vm, mock) = makeVM()
        vm.switchMode(to: .boundary)
        for i in 0..<3 {
            mock.mockRaycastResult = SIMD3(Float(i), 0, Float(i))
            await vm.captureAtScreenPoint(.zero)
        }
        vm.closeBoundary()
        vm.reopenBoundary()
        XCTAssertFalse(vm.session.boundaryClosed)
    }

    // MARK: - Undo

    @MainActor
    func testUndoElevationPoint() async {
        let (vm, _) = makeVM()
        await vm.captureAtScreenPoint(.zero)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.pointCount, 2)
        vm.undo()
        XCTAssertEqual(vm.pointCount, 1)
    }

    @MainActor
    func testUndoBoundaryStake() async {
        let (vm, _) = makeVM()
        vm.switchMode(to: .boundary)
        await vm.captureAtScreenPoint(.zero)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.stakeCount, 2)
        vm.undo()
        XCTAssertEqual(vm.stakeCount, 1)
    }

    @MainActor
    func testUndoIsModeSeparate() async {
        let (vm, _) = makeVM()
        await vm.captureAtScreenPoint(.zero)
        vm.switchMode(to: .boundary)
        await vm.captureAtScreenPoint(.zero)
        vm.undo()
        XCTAssertEqual(vm.stakeCount, 0)
        XCTAssertEqual(vm.pointCount, 1)
    }

    @MainActor
    func testCanUndoElevation() async {
        let (vm, _) = makeVM()
        XCTAssertFalse(vm.canUndo)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertTrue(vm.canUndo)
    }

    @MainActor
    func testCanUndoBoundary() async {
        let (vm, _) = makeVM()
        vm.switchMode(to: .boundary)
        XCTAssertFalse(vm.canUndo)
        await vm.captureAtScreenPoint(.zero)
        XCTAssertTrue(vm.canUndo)
    }

    // MARK: - Mode switching

    @MainActor
    func testModeSwitchPreservesStacks() async {
        let (vm, _) = makeVM()
        await vm.captureAtScreenPoint(.zero)
        vm.switchMode(to: .boundary)
        await vm.captureAtScreenPoint(.zero)
        vm.switchMode(to: .elevation)
        XCTAssertEqual(vm.pointCount, 1)
        XCTAssertEqual(vm.stakeCount, 1)
    }

    // MARK: - Capture after boundary closed

    @MainActor
    func testCaptureIgnoredWhenBoundaryClosed() async {
        let (vm, mock) = makeVM()
        vm.switchMode(to: .boundary)
        for i in 0..<3 {
            mock.mockRaycastResult = SIMD3(Float(i), 0, Float(i))
            await vm.captureAtScreenPoint(.zero)
        }
        vm.closeBoundary()
        await vm.captureAtScreenPoint(.zero)
        XCTAssertEqual(vm.stakeCount, 3)
    }

    // MARK: - Loop closure banner

    @MainActor
    func testLoopBannerNotShownInitially() {
        let (vm, _) = makeVM()
        XCTAssertFalse(vm.showLoopBanner)
    }

    @MainActor
    func testLoopBannerShownAfterThreshold() {
        let (vm, _) = makeVM()
        vm.updateCameraPosition(SIMD3(0, 0, 0))
        vm.updateCameraPosition(SIMD3(16, 0, 0))
        XCTAssertTrue(vm.showLoopBanner)
    }

    @MainActor
    func testLoopBannerNotShownInBoundaryMode() {
        let (vm, _) = makeVM()
        vm.switchMode(to: .boundary)
        vm.updateCameraPosition(SIMD3(0, 0, 0))
        vm.updateCameraPosition(SIMD3(16, 0, 0))
        XCTAssertFalse(vm.showLoopBanner)
    }

    @MainActor
    func testLoopBannerDismissStaysDismissed() {
        let (vm, _) = makeVM()
        vm.updateCameraPosition(SIMD3(0, 0, 0))
        vm.updateCameraPosition(SIMD3(16, 0, 0))
        XCTAssertTrue(vm.showLoopBanner)
        vm.dismissLoopBanner()
        XCTAssertFalse(vm.showLoopBanner)
        vm.updateCameraPosition(SIMD3(32, 0, 0))
        XCTAssertFalse(vm.showLoopBanner)
    }
}
