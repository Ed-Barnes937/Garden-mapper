import Foundation

enum ExportFormat: String, CaseIterable, Identifiable {
    case ply
    case csv

    var id: String { rawValue }

    var fileExtension: String { rawValue }

    var displayName: String {
        switch self {
        case .ply: return ".ply"
        case .csv: return ".csv"
        }
    }

    var subtitle: String {
        switch self {
        case .ply: return "3D point cloud format · CloudCompare, MeshLab, Blender"
        case .csv: return "Spreadsheet · x, y, z columns in meters"
        }
    }
}
