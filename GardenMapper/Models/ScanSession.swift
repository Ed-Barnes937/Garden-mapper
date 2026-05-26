import Foundation

struct ScanSession {
    let stickHeightCm: Int
    let startDate: Date
    var capturedPoints: [CapturedPoint] = []
    var boundaryStakes: [BoundaryStake] = []
    var boundaryClosed: Bool = false

    var stickHeightMeters: Float {
        Float(stickHeightCm) / 100.0
    }

    var nextStakeIndex: Int {
        boundaryStakes.count + 1
    }

    mutating func addPoint(_ point: CapturedPoint) {
        capturedPoints.append(point)
    }

    mutating func undoLastPoint() {
        guard !capturedPoints.isEmpty else { return }
        capturedPoints.removeLast()
    }

    mutating func addStake(_ stake: BoundaryStake) {
        guard !boundaryClosed else { return }
        boundaryStakes.append(stake)
    }

    mutating func undoLastStake() {
        guard !boundaryStakes.isEmpty else { return }
        if boundaryClosed {
            boundaryClosed = false
        }
        boundaryStakes.removeLast()
    }

    mutating func closeBoundary() {
        guard boundaryStakes.count >= 3, !boundaryClosed else { return }
        boundaryClosed = true
    }

    mutating func reopenBoundary() {
        boundaryClosed = false
    }
}
