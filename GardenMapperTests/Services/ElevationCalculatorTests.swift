import XCTest
@testable import GardenMapper

final class ElevationCalculatorTests: XCTestCase {
    // MARK: - Ground elevation

    func testGroundElevation() {
        let result = ElevationCalculator.groundElevation(phoneY: 2.4, stickHeightMeters: 1.2)
        XCTAssertEqual(result, 1.2, accuracy: 0.001)
    }

    func testGroundElevationAtGround() {
        let result = ElevationCalculator.groundElevation(phoneY: 1.0, stickHeightMeters: 1.0)
        XCTAssertEqual(result, 0.0, accuracy: 0.001)
    }

    func testGroundElevationNegative() {
        let result = ElevationCalculator.groundElevation(phoneY: 0.5, stickHeightMeters: 1.0)
        XCTAssertEqual(result, -0.5, accuracy: 0.001)
    }

    // MARK: - Normalize elevations

    func testNormalizeEmpty() {
        let (normalized, minE, maxE) = ElevationCalculator.normalizeElevations([])
        XCTAssertTrue(normalized.isEmpty)
        XCTAssertEqual(minE, 0)
        XCTAssertEqual(maxE, 0)
    }

    func testNormalizeSinglePoint() {
        let points = [CapturedPoint(x: 0, y: 5, z: 0)]
        let (normalized, minE, maxE) = ElevationCalculator.normalizeElevations(points)
        XCTAssertEqual(normalized.count, 1)
        XCTAssertEqual(normalized[0], 0)
        XCTAssertEqual(minE, 5)
        XCTAssertEqual(maxE, 5)
    }

    func testNormalizeMultiplePoints() {
        let points = [
            CapturedPoint(x: 0, y: 1.0, z: 0),
            CapturedPoint(x: 1, y: 2.0, z: 0),
            CapturedPoint(x: 2, y: 1.5, z: 0),
        ]
        let (normalized, minE, maxE) = ElevationCalculator.normalizeElevations(points)
        XCTAssertEqual(minE, 1.0, accuracy: 0.001)
        XCTAssertEqual(maxE, 2.0, accuracy: 0.001)
        XCTAssertEqual(normalized[0], 0.0, accuracy: 0.001)
        XCTAssertEqual(normalized[1], 1.0, accuracy: 0.001)
        XCTAssertEqual(normalized[2], 0.5, accuracy: 0.001)
    }

    // MARK: - Re-origin

    func testReOriginEmpty() {
        let result = ElevationCalculator.reOrigin([])
        XCTAssertTrue(result.isEmpty)
    }

    func testReOriginSetsFirstToZero() {
        let points = [
            CapturedPoint(x: 5, y: 10, z: 15),
            CapturedPoint(x: 7, y: 12, z: 17),
        ]
        let result = ElevationCalculator.reOrigin(points)
        XCTAssertEqual(result[0].x, 0, accuracy: 0.001)
        XCTAssertEqual(result[0].y, 0, accuracy: 0.001)
        XCTAssertEqual(result[0].z, 0, accuracy: 0.001)
        XCTAssertEqual(result[1].x, 2, accuracy: 0.001)
        XCTAssertEqual(result[1].y, 2, accuracy: 0.001)
        XCTAssertEqual(result[1].z, 2, accuracy: 0.001)
    }

    func testReOriginPreservesIds() {
        let id1 = UUID()
        let id2 = UUID()
        let points = [
            CapturedPoint(id: id1, x: 5, y: 10, z: 15),
            CapturedPoint(id: id2, x: 7, y: 12, z: 17),
        ]
        let result = ElevationCalculator.reOrigin(points)
        XCTAssertEqual(result[0].id, id1)
        XCTAssertEqual(result[1].id, id2)
    }
}
