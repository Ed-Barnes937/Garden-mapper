import ARKit
import RealityKit
import CoreGraphics
import simd

final class ARSessionService: NSObject, ARSessionProviding {
    let arView = ARView(frame: .zero)

    var isLiDARAvailable: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    var cameraTransform: simd_float4x4? {
        arView.session.currentFrame?.camera.transform
    }

    func startSession() {
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }

    func pauseSession() {
        arView.session.pause()
    }

    func raycast(from screenPoint: CGPoint) async -> SIMD3<Float>? {
        let results = arView.raycast(from: screenPoint, allowing: .estimatedPlane, alignment: .horizontal)
        guard let first = results.first else { return nil }
        let col = first.worldTransform.columns.3
        return SIMD3(col.x, col.y, col.z)
    }
}
