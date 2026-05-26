import Foundation
import CoreGraphics
import simd
@testable import GardenMapper

final class MockARSessionService: ARSessionProviding {
    var isLiDARAvailable: Bool = true
    var cameraTransform: simd_float4x4? = simd_float4x4(1)
    var mockRaycastResult: SIMD3<Float>? = SIMD3<Float>(0, 1.2, 0)

    private(set) var startSessionCalled = false
    private(set) var pauseSessionCalled = false
    private(set) var raycastCallCount = 0

    func startSession() {
        startSessionCalled = true
    }

    func pauseSession() {
        pauseSessionCalled = true
    }

    func raycast(from screenPoint: CGPoint) async -> SIMD3<Float>? {
        raycastCallCount += 1
        return mockRaycastResult
    }
}
