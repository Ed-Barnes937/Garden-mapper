import XCTest
@testable import GardenMapper

final class ExportServiceTests: XCTestCase {
    private let fixedDate = ISO8601DateFormatter().date(from: "2026-05-24T12:00:00Z")!

    private func makeMetadata(pointCount: Int = 3) -> ExportService.ExportMetadata {
        ExportService.ExportMetadata(
            scanDate: fixedDate,
            stickHeightCm: 120,
            pointCount: pointCount,
            coordinateSystemNote: "relative, first point = origin"
        )
    }

    private func makeSamplePoints() -> [CapturedPoint] {
        [
            CapturedPoint(x: 5, y: 1.0, z: 10),
            CapturedPoint(x: 6, y: 1.2, z: 11),
            CapturedPoint(x: 7, y: 1.1, z: 12),
        ]
    }

    // MARK: - PLY

    func testPLYHeader() {
        let data = ExportService.generatePLY(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")

        XCTAssertEqual(lines[0], "ply")
        XCTAssertEqual(lines[1], "format ascii 1.0")
        XCTAssertTrue(lines[2].contains("Garden Mapper"))
        XCTAssertTrue(lines[3].contains("scan_date"))
        XCTAssertTrue(lines[4].contains("stick_height_cm 120"))
        XCTAssertEqual(lines[6], "element vertex 3")
        XCTAssertEqual(lines[7], "property float x")
        XCTAssertEqual(lines[8], "property float y")
        XCTAssertEqual(lines[9], "property float z")
        XCTAssertEqual(lines[10], "end_header")
    }

    func testPLYVertexCount() {
        let data = ExportService.generatePLY(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")
        let headerEnd = lines.firstIndex(of: "end_header")!
        let vertexLines = lines[(headerEnd + 1)...].filter { !$0.isEmpty }
        XCTAssertEqual(vertexLines.count, 3)
    }

    func testPLYReOrigins() {
        let data = ExportService.generatePLY(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")
        let headerEnd = lines.firstIndex(of: "end_header")!
        let firstVertex = lines[headerEnd + 1]
        XCTAssertTrue(firstVertex.hasPrefix("0.000000"), "First vertex should be at origin, got: \(firstVertex)")
    }

    // MARK: - CSV

    func testCSVHeader() {
        let data = ExportService.generateCSV(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")

        XCTAssertTrue(lines[0].hasPrefix("# Garden Mapper"))
        XCTAssertTrue(lines[1].contains("scan_date"))
        XCTAssertTrue(lines[2].contains("stick_height_cm: 120"))
        XCTAssertEqual(lines[5], "x,y,z")
    }

    func testCSVDataRows() {
        let data = ExportService.generateCSV(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")
        let dataLines = lines.filter { !$0.hasPrefix("#") && !$0.isEmpty && $0 != "x,y,z" }
        XCTAssertEqual(dataLines.count, 3)
    }

    func testCSVReOrigins() {
        let data = ExportService.generateCSV(points: makeSamplePoints(), metadata: makeMetadata())
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n")
        let headerIndex = lines.firstIndex(of: "x,y,z")!
        let firstData = lines[headerIndex + 1]
        XCTAssertTrue(firstData.hasPrefix("0.000000"), "First row should be at origin, got: \(firstData)")
    }

    // MARK: - Empty

    func testPLYEmptyPoints() {
        let data = ExportService.generatePLY(points: [], metadata: makeMetadata(pointCount: 0))
        let content = String(data: data, encoding: .utf8)!
        XCTAssertTrue(content.contains("element vertex 0"))
    }

    func testCSVEmptyPoints() {
        let data = ExportService.generateCSV(points: [], metadata: makeMetadata(pointCount: 0))
        let content = String(data: data, encoding: .utf8)!
        let lines = content.components(separatedBy: "\n").filter { !$0.hasPrefix("#") && !$0.isEmpty && $0 != "x,y,z" }
        XCTAssertEqual(lines.count, 0)
    }

    // MARK: - Filename

    func testFilename() {
        let name = ExportService.filename(format: .ply, date: fixedDate)
        XCTAssertTrue(name.hasPrefix("garden_mapper_"))
        XCTAssertTrue(name.hasSuffix(".ply"))
    }

    func testFilenameCSV() {
        let name = ExportService.filename(format: .csv, date: fixedDate)
        XCTAssertTrue(name.hasSuffix(".csv"))
    }
}
