import Foundation

enum ElevationCalculator {
    static func groundElevation(phoneY: Float, stickHeightMeters: Float) -> Float {
        phoneY - stickHeightMeters
    }

    static func normalizeElevations(_ points: [CapturedPoint]) -> (normalized: [Float], min: Float, max: Float) {
        guard let first = points.first else {
            return ([], 0, 0)
        }

        var minElev = first.y
        var maxElev = first.y
        for point in points {
            minElev = min(minElev, point.y)
            maxElev = max(maxElev, point.y)
        }

        let range = maxElev - minElev
        let normalized: [Float]
        if range < Float.ulpOfOne {
            normalized = Array(repeating: Float(0), count: points.count)
        } else {
            normalized = points.map { ($0.y - minElev) / range }
        }

        return (normalized, minElev, maxElev)
    }

    static func reOrigin(_ points: [CapturedPoint]) -> [CapturedPoint] {
        guard let origin = points.first else { return [] }
        return points.map { point in
            CapturedPoint(
                id: point.id,
                x: point.x - origin.x,
                y: point.y - origin.y,
                z: point.z - origin.z,
                timestamp: point.timestamp
            )
        }
    }
}
