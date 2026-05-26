import simd
import CoreGraphics

protocol ARSessionProviding: AnyObject {
    var isLiDARAvailable: Bool { get }
    var cameraTransform: simd_float4x4? { get }

    func startSession()
    func pauseSession()
    func raycast(from screenPoint: CGPoint) async -> SIMD3<Float>?
}
