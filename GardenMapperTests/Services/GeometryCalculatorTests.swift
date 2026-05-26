import XCTest
import simd
@testable import GardenMapper

final class GeometryCalculatorTests: XCTestCase {
    // MARK: - Polygon area

    func testAreaTriangle() {
        let vertices: [(x: Float, z: Float)] = [
            (0, 0), (4, 0), (0, 3)
        ]
        let area = GeometryCalculator.polygonArea(vertices: vertices)
        XCTAssertEqual(area, 6.0, accuracy: 0.001)
    }

    func testAreaSquare() {
        let vertices: [(x: Float, z: Float)] = [
            (0, 0), (10, 0), (10, 10), (0, 10)
        ]
        let area = GeometryCalculator.polygonArea(vertices: vertices)
        XCTAssertEqual(area, 100.0, accuracy: 0.001)
    }

    func testAreaTooFewVertices() {
        XCTAssertEqual(GeometryCalculator.polygonArea(vertices: []), 0)
        XCTAssertEqual(GeometryCalculator.polygonArea(vertices: [(0, 0)]), 0)
        XCTAssertEqual(GeometryCalculator.polygonArea(vertices: [(0, 0), (1, 1)]), 0)
    }

    // MARK: - Perimeter

    func testPerimeterSquare() {
        let vertices: [(x: Float, z: Float)] = [
            (0, 0), (5, 0), (5, 5), (0, 5)
        ]
        let perimeter = GeometryCalculator.polygonPerimeter(vertices: vertices)
        XCTAssertEqual(perimeter, 20.0, accuracy: 0.001)
    }

    func testPerimeterTooFew() {
        XCTAssertEqual(GeometryCalculator.polygonPerimeter(vertices: []), 0)
        XCTAssertEqual(GeometryCalculator.polygonPerimeter(vertices: [(0, 0)]), 0)
        XCTAssertEqual(GeometryCalculator.polygonPerimeter(vertices: [(0, 0), (5, 0)]), 0)
    }

    // MARK: - Path distance

    func testPathDistanceStraightLine() {
        let positions: [SIMD3<Float>] = [
            SIMD3(0, 0, 0),
            SIMD3(3, 0, 0),
            SIMD3(3, 0, 4),
        ]
        let distance = GeometryCalculator.pathDistance(positions: positions)
        XCTAssertEqual(distance, 7.0, accuracy: 0.001)
    }

    func testPathDistanceEmpty() {
        XCTAssertEqual(GeometryCalculator.pathDistance(positions: []), 0)
    }

    func testPathDistanceSinglePoint() {
        XCTAssertEqual(GeometryCalculator.pathDistance(positions: [SIMD3(0, 0, 0)]), 0)
    }
}
