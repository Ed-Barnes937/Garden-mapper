import SwiftUI

@MainActor
final class PointCloudViewerViewModel: ObservableObject {
    @Published var showBoundary: Bool = true
    @Published var showExportSheet: Bool = false

    let session: ScanSession

    init(session: ScanSession) {
        self.session = session
    }

    var pointCount: Int {
        session.capturedPoints.count
    }

    var displayPoints: [CapturedPoint] {
        ElevationCalculator.reOrigin(session.capturedPoints)
    }

    var normalizedElevations: [Float] {
        ElevationCalculator.normalizeElevations(session.capturedPoints).normalized
    }

    var elevationRange: (min: Float, max: Float) {
        let result = ElevationCalculator.normalizeElevations(session.capturedPoints)
        return (result.min, result.max)
    }

    var elevationDelta: Float {
        let range = elevationRange
        return range.max - range.min
    }

    var elevationDeltaFormatted: String {
        String(format: "%.2fm", elevationDelta)
    }

    var area: Float? {
        guard session.boundaryClosed else { return nil }
        let vertices = session.boundaryStakes.map { (x: $0.x, z: $0.z) }
        return GeometryCalculator.polygonArea(vertices: vertices)
    }

    var areaFormatted: String? {
        guard let area else { return nil }
        return String(format: "%.1fm²", area)
    }

    var perimeter: Float? {
        guard session.boundaryClosed else { return nil }
        let vertices = session.boundaryStakes.map { (x: $0.x, z: $0.z) }
        return GeometryCalculator.polygonPerimeter(vertices: vertices)
    }

    var perimeterFormatted: String? {
        guard let perimeter else { return nil }
        return String(format: "%.1fm", perimeter)
    }
}
