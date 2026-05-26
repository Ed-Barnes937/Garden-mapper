import simd

enum GeometryCalculator {
    static func polygonArea(vertices: [(x: Float, z: Float)]) -> Float {
        guard vertices.count >= 3 else { return 0 }
        var sum: Float = 0
        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            sum += vertices[i].x * vertices[j].z
            sum -= vertices[j].x * vertices[i].z
        }
        return abs(sum) / 2
    }

    static func polygonPerimeter(vertices: [(x: Float, z: Float)]) -> Float {
        guard vertices.count >= 3 else { return 0 }
        var total: Float = 0
        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            let dx = vertices[j].x - vertices[i].x
            let dz = vertices[j].z - vertices[i].z
            total += sqrt(dx * dx + dz * dz)
        }
        return total
    }

    static func pathDistance(positions: [SIMD3<Float>]) -> Float {
        guard positions.count >= 2 else { return 0 }
        var total: Float = 0
        for i in 1..<positions.count {
            total += simd_distance(positions[i - 1], positions[i])
        }
        return total
    }
}
