import Foundation

struct CapturedPoint: Identifiable, Equatable, Codable {
    let id: UUID
    let x: Float
    let y: Float
    let z: Float
    let timestamp: Date

    init(id: UUID = UUID(), x: Float, y: Float, z: Float, timestamp: Date = Date()) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}
