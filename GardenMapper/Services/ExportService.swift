import Foundation

enum ExportService {
    struct ExportMetadata {
        let scanDate: Date
        let stickHeightCm: Int
        let pointCount: Int
        let coordinateSystemNote: String

        static func from(session: ScanSession) -> ExportMetadata {
            ExportMetadata(
                scanDate: session.startDate,
                stickHeightCm: session.stickHeightCm,
                pointCount: session.capturedPoints.count,
                coordinateSystemNote: "relative, first point = origin"
            )
        }
    }

    static func generatePLY(points: [CapturedPoint], metadata: ExportMetadata) -> Data {
        var lines: [String] = []

        lines.append("ply")
        lines.append("format ascii 1.0")
        lines.append("comment Garden Mapper export")
        lines.append("comment scan_date \(iso8601(metadata.scanDate))")
        lines.append("comment stick_height_cm \(metadata.stickHeightCm)")
        lines.append("comment coordinate_system \(metadata.coordinateSystemNote)")
        lines.append("element vertex \(points.count)")
        lines.append("property float x")
        lines.append("property float y")
        lines.append("property float z")
        lines.append("end_header")

        let reOrigined = ElevationCalculator.reOrigin(points)
        for point in reOrigined {
            lines.append(String(format: "%.6f %.6f %.6f", point.x, point.y, point.z))
        }

        let content = lines.joined(separator: "\n") + "\n"
        return Data(content.utf8)
    }

    static func generateCSV(points: [CapturedPoint], metadata: ExportMetadata) -> Data {
        var lines: [String] = []

        lines.append("# Garden Mapper export")
        lines.append("# scan_date: \(iso8601(metadata.scanDate))")
        lines.append("# stick_height_cm: \(metadata.stickHeightCm)")
        lines.append("# point_count: \(metadata.pointCount)")
        lines.append("# coordinate_system: \(metadata.coordinateSystemNote)")
        lines.append("x,y,z")

        let reOrigined = ElevationCalculator.reOrigin(points)
        for point in reOrigined {
            lines.append(String(format: "%.6f,%.6f,%.6f", point.x, point.y, point.z))
        }

        let content = lines.joined(separator: "\n") + "\n"
        return Data(content.utf8)
    }

    static func filename(format: ExportFormat, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return "garden_mapper_\(formatter.string(from: date)).\(format.fileExtension)"
    }

    private static func iso8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
