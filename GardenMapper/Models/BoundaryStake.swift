import Foundation

struct BoundaryStake: Identifiable, Equatable, Codable {
    let id: UUID
    let x: Float
    let z: Float
    let index: Int
    let timestamp: Date

    init(id: UUID = UUID(), x: Float, z: Float, index: Int, timestamp: Date = Date()) {
        self.id = id
        self.x = x
        self.z = z
        self.index = index
        self.timestamp = timestamp
    }
}
