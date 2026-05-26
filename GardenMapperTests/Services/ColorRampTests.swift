import XCTest
@testable import GardenMapper

final class ColorRampTests: XCTestCase {
    private let accuracy: Float = 0.005

    // MARK: - Stop colors

    func testMossAtZero() {
        let c = ColorRamp.elevationColor(t: 0)
        XCTAssertEqual(c.r, 31/255, accuracy: accuracy)
        XCTAssertEqual(c.g, 58/255, accuracy: accuracy)
        XCTAssertEqual(c.b, 40/255, accuracy: accuracy)
    }

    func testSageAt035() {
        let c = ColorRamp.elevationColor(t: 0.35)
        XCTAssertEqual(c.r, 92/255, accuracy: accuracy)
        XCTAssertEqual(c.g, 132/255, accuracy: accuracy)
        XCTAssertEqual(c.b, 86/255, accuracy: accuracy)
    }

    func testClayAt065() {
        let c = ColorRamp.elevationColor(t: 0.65)
        XCTAssertEqual(c.r, 168/255, accuracy: accuracy)
        XCTAssertEqual(c.g, 123/255, accuracy: accuracy)
        XCTAssertEqual(c.b, 91/255, accuracy: accuracy)
    }

    func testCreamAtOne() {
        let c = ColorRamp.elevationColor(t: 1.0)
        XCTAssertEqual(c.r, 235/255, accuracy: accuracy)
        XCTAssertEqual(c.g, 216/255, accuracy: accuracy)
        XCTAssertEqual(c.b, 181/255, accuracy: accuracy)
    }

    // MARK: - Interpolation

    func testMidpointBetweenMossAndSage() {
        let c = ColorRamp.elevationColor(t: 0.175)
        let expectedR = (31.0 + 92.0) / 2 / 255
        let expectedG = (58.0 + 132.0) / 2 / 255
        let expectedB = (40.0 + 86.0) / 2 / 255
        XCTAssertEqual(c.r, Float(expectedR), accuracy: accuracy)
        XCTAssertEqual(c.g, Float(expectedG), accuracy: accuracy)
        XCTAssertEqual(c.b, Float(expectedB), accuracy: accuracy)
    }

    // MARK: - Clamping

    func testNegativeTClampedToMoss() {
        let c = ColorRamp.elevationColor(t: -0.5)
        let moss = ColorRamp.elevationColor(t: 0)
        XCTAssertEqual(c, moss)
    }

    func testAboveOneClamped() {
        let c = ColorRamp.elevationColor(t: 1.5)
        let cream = ColorRamp.elevationColor(t: 1.0)
        XCTAssertEqual(c, cream)
    }
}
