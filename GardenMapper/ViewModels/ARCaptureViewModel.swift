import SwiftUI
import simd

@MainActor
final class ARCaptureViewModel: ObservableObject {
    @Published private(set) var session: ScanSession
    @Published var captureMode: ARCaptureMode = .elevation
    @Published var showLoopBanner: Bool = false

    let arService: ARSessionProviding
    private var distanceTracker = DistanceTracker()
    private var loopBannerDismissed = false

    init(stickHeightCm: Int, arService: ARSessionProviding) {
        self.session = ScanSession(stickHeightCm: stickHeightCm, startDate: Date())
        self.arService = arService
    }

    var pointCount: Int { session.capturedPoints.count }
    var stakeCount: Int { session.boundaryStakes.count }

    var canUndo: Bool {
        switch captureMode {
        case .elevation: return !session.capturedPoints.isEmpty
        case .boundary: return !session.boundaryStakes.isEmpty
        }
    }

    var canCloseBoundary: Bool {
        session.boundaryStakes.count >= 3 && !session.boundaryClosed
    }

    func startSession() {
        arService.startSession()
    }

    func stopSession() {
        arService.pauseSession()
    }

    func captureAtScreenPoint(_ screenPoint: CGPoint) async {
        guard let position = await arService.raycast(from: screenPoint) else { return }
        switch captureMode {
        case .elevation:
            addElevationPoint(at: position)
        case .boundary:
            addBoundaryStake(at: position)
        }
    }

    func undo() {
        switch captureMode {
        case .elevation:
            session.undoLastPoint()
        case .boundary:
            session.undoLastStake()
        }
    }

    func switchMode(to mode: ARCaptureMode) {
        captureMode = mode
    }

    func closeBoundary() {
        session.closeBoundary()
    }

    func reopenBoundary() {
        session.reopenBoundary()
    }

    func dismissLoopBanner() {
        loopBannerDismissed = true
        showLoopBanner = false
    }

    func updateCameraPosition(_ position: SIMD3<Float>) {
        let thresholdExceeded = distanceTracker.addPosition(position)
        if captureMode == .elevation && thresholdExceeded && !loopBannerDismissed {
            showLoopBanner = true
        }
    }

    // MARK: - Private

    private func addElevationPoint(at worldPosition: SIMD3<Float>) {
        let elevation = ElevationCalculator.groundElevation(
            phoneY: worldPosition.y,
            stickHeightMeters: session.stickHeightMeters
        )
        let point = CapturedPoint(
            x: worldPosition.x,
            y: elevation,
            z: worldPosition.z
        )
        session.addPoint(point)
    }

    private func addBoundaryStake(at worldPosition: SIMD3<Float>) {
        let stake = BoundaryStake(
            x: worldPosition.x,
            z: worldPosition.z,
            index: session.nextStakeIndex
        )
        session.addStake(stake)
    }
}
