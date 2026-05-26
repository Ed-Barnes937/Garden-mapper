import XCTest
@testable import GardenMapper

final class ExportSheetViewModelTests: XCTestCase {
    private func makeSession() -> ScanSession {
        var session = ScanSession(stickHeightCm: 120, startDate: Date())
        session.addPoint(CapturedPoint(x: 1, y: 2, z: 3))
        session.addPoint(CapturedPoint(x: 4, y: 5, z: 6))
        return session
    }

    @MainActor
    func testPointCount() {
        let vm = ExportSheetViewModel(session: makeSession())
        XCTAssertEqual(vm.pointCount, 2)
    }

    @MainActor
    func testExportPLY() {
        let vm = ExportSheetViewModel(session: makeSession())
        let url = vm.exportFile(format: .ply)
        XCTAssertTrue(url.lastPathComponent.hasSuffix(".ply"))
        let data = try? Data(contentsOf: url)
        XCTAssertNotNil(data)
        let content = String(data: data!, encoding: .utf8)!
        XCTAssertTrue(content.contains("ply"))
        XCTAssertTrue(content.contains("element vertex 2"))
        try? FileManager.default.removeItem(at: url)
    }

    @MainActor
    func testExportCSV() {
        let vm = ExportSheetViewModel(session: makeSession())
        let url = vm.exportFile(format: .csv)
        XCTAssertTrue(url.lastPathComponent.hasSuffix(".csv"))
        let data = try? Data(contentsOf: url)
        XCTAssertNotNil(data)
        let content = String(data: data!, encoding: .utf8)!
        XCTAssertTrue(content.contains("x,y,z"))
        try? FileManager.default.removeItem(at: url)
    }
}
