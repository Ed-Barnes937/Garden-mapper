import XCTest
@testable import GardenMapper

final class ScanToExportIntegrationTests: XCTestCase {

    private func makeScanSession() -> ScanSession {
        var session = ScanSession(stickHeightCm: 120, startDate: Date())

        session.addPoint(CapturedPoint(x: 0, y: 1.0, z: 0))
        session.addPoint(CapturedPoint(x: 1, y: 1.3, z: 0))
        session.addPoint(CapturedPoint(x: 2, y: 1.1, z: 1))
        session.addPoint(CapturedPoint(x: 3, y: 0.8, z: 1))

        session.addStake(BoundaryStake(x: 0, z: 0, index: 1))
        session.addStake(BoundaryStake(x: 5, z: 0, index: 2))
        session.addStake(BoundaryStake(x: 5, z: 5, index: 3))
        session.addStake(BoundaryStake(x: 0, z: 5, index: 4))
        session.closeBoundary()

        return session
    }

    @MainActor
    func testViewerComputesCorrectStats() {
        let session = makeScanSession()
        let viewer = PointCloudViewerViewModel(session: session)

        XCTAssertEqual(viewer.pointCount, 4)
        XCTAssertEqual(viewer.displayPoints.count, 4)
        XCTAssertEqual(viewer.normalizedElevations.count, 4)

        XCTAssertEqual(viewer.displayPoints[0].x, 0, accuracy: 0.001)
        XCTAssertEqual(viewer.displayPoints[0].y, 0, accuracy: 0.001)

        XCTAssertEqual(viewer.elevationDelta, 0.5, accuracy: 0.001)
        XCTAssertEqual(viewer.elevationDeltaFormatted, "0.50m")

        XCTAssertNotNil(viewer.area)
        XCTAssertEqual(viewer.area!, 25.0, accuracy: 0.1)
        XCTAssertNotNil(viewer.perimeter)
        XCTAssertEqual(viewer.perimeter!, 20.0, accuracy: 0.1)
    }

    @MainActor
    func testExportProducesValidFiles() {
        let session = makeScanSession()
        let exporter = ExportSheetViewModel(session: session)

        let plyURL = exporter.exportFile(format: .ply)
        defer { try? FileManager.default.removeItem(at: plyURL) }

        let plyData = try? Data(contentsOf: plyURL)
        XCTAssertNotNil(plyData)
        let plyContent = String(data: plyData!, encoding: .utf8)!
        XCTAssertTrue(plyContent.hasPrefix("ply\n"))
        XCTAssertTrue(plyContent.contains("element vertex 4"))
        XCTAssertTrue(plyContent.contains("stick_height_cm 120"))

        let csvURL = exporter.exportFile(format: .csv)
        defer { try? FileManager.default.removeItem(at: csvURL) }

        let csvData = try? Data(contentsOf: csvURL)
        XCTAssertNotNil(csvData)
        let csvContent = String(data: csvData!, encoding: .utf8)!
        XCTAssertTrue(csvContent.contains("x,y,z"))
        let dataLines = csvContent.components(separatedBy: "\n").filter { !$0.hasPrefix("#") && !$0.isEmpty && $0 != "x,y,z" }
        XCTAssertEqual(dataLines.count, 4)
    }

    @MainActor
    func testFullCaptureToViewerPipeline() async {
        let mock = MockARSessionService()
        let vm = ARCaptureViewModel(stickHeightCm: 150, arService: mock)

        mock.mockRaycastResult = SIMD3(0, 1.5, 0)
        await vm.captureAtScreenPoint(.zero)

        mock.mockRaycastResult = SIMD3(2, 1.8, 0)
        await vm.captureAtScreenPoint(.zero)

        mock.mockRaycastResult = SIMD3(4, 1.6, 2)
        await vm.captureAtScreenPoint(.zero)

        XCTAssertEqual(vm.pointCount, 3)

        let viewer = PointCloudViewerViewModel(session: vm.session)
        XCTAssertEqual(viewer.pointCount, 3)
        XCTAssertTrue(viewer.elevationDelta > 0)

        let exporter = ExportSheetViewModel(session: vm.session)
        let url = exporter.exportFile(format: .ply)
        defer { try? FileManager.default.removeItem(at: url) }
        let data = try? Data(contentsOf: url)
        XCTAssertNotNil(data)
        let content = String(data: data!, encoding: .utf8)!
        XCTAssertTrue(content.contains("element vertex 3"))
    }
}
