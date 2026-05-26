import SwiftUI

@MainActor
final class ExportSheetViewModel: ObservableObject {
    let session: ScanSession

    init(session: ScanSession) {
        self.session = session
    }

    var pointCount: Int {
        session.capturedPoints.count
    }

    func exportFile(format: ExportFormat) -> URL {
        let metadata = ExportService.ExportMetadata.from(session: session)
        let data: Data
        switch format {
        case .ply:
            data = ExportService.generatePLY(points: session.capturedPoints, metadata: metadata)
        case .csv:
            data = ExportService.generateCSV(points: session.capturedPoints, metadata: metadata)
        }

        let filename = ExportService.filename(format: format, date: session.startDate)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        return url
    }
}
