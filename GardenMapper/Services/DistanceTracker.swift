import simd

struct DistanceTracker {
    static let loopClosureThreshold: Float = 15.0

    private(set) var positions: [SIMD3<Float>] = []
    private(set) var totalDistance: Float = 0

    mutating func addPosition(_ pos: SIMD3<Float>) -> Bool {
        if let last = positions.last {
            totalDistance += simd_distance(last, pos)
        }
        positions.append(pos)
        return totalDistance >= Self.loopClosureThreshold
    }

    mutating func reset() {
        positions = []
        totalDistance = 0
    }
}
