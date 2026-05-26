import SceneKit
import UIKit

enum PointCloudSceneBuilder {
    static func buildScene(
        points: [CapturedPoint],
        normalizedElevations: [Float],
        boundaryStakes: [BoundaryStake],
        boundaryClosed: Bool,
        showBoundary: Bool
    ) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let rootNode = scene.rootNode
        addCamera(to: rootNode)
        addAmbientLight(to: rootNode)
        addGroundGrid(to: rootNode)
        addPoints(points, elevations: normalizedElevations, to: rootNode)

        if !boundaryStakes.isEmpty {
            addBoundary(boundaryStakes, closed: boundaryClosed, hidden: !showBoundary, to: rootNode)
        }

        return scene
    }

    // MARK: - Camera

    private static func addCamera(to root: SCNNode) {
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 1000

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(3, 5, 6)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        root.addChildNode(cameraNode)
    }

    // MARK: - Lighting

    private static func addAmbientLight(to root: SCNNode) {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 400
        ambient.color = UIColor(red: 242/255, green: 239/255, blue: 231/255, alpha: 1)

        let ambientNode = SCNNode()
        ambientNode.light = ambient
        root.addChildNode(ambientNode)

        let directional = SCNLight()
        directional.type = .directional
        directional.intensity = 600
        directional.color = UIColor.white

        let dirNode = SCNNode()
        dirNode.light = directional
        dirNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        root.addChildNode(dirNode)
    }

    // MARK: - Ground Grid

    private static func addGroundGrid(to root: SCNNode) {
        let gridNode = SCNNode()
        gridNode.name = "grid"
        let gridSize: Float = 8
        let divisions = 8
        let step = gridSize / Float(divisions)
        let halfGrid = gridSize / 2

        for i in 0...divisions {
            let offset = -halfGrid + step * Float(i)
            let isEdge = i == 0 || i == divisions
            let opacity: CGFloat = isEdge ? 0.4 : 0.18

            let hLine = lineBetween(
                SCNVector3(offset, 0, -halfGrid),
                SCNVector3(offset, 0, halfGrid),
                color: UIColor(red: 92/255, green: 132/255, blue: 86/255, alpha: opacity)
            )
            gridNode.addChildNode(hLine)

            let vLine = lineBetween(
                SCNVector3(-halfGrid, 0, offset),
                SCNVector3(halfGrid, 0, offset),
                color: UIColor(red: 92/255, green: 132/255, blue: 86/255, alpha: opacity)
            )
            gridNode.addChildNode(vLine)
        }

        root.addChildNode(gridNode)
    }

    // MARK: - Points

    static let pointNodeName = "elevationPoint"

    private static func addPoints(_ points: [CapturedPoint], elevations: [Float], to root: SCNNode) {
        let sphere = SCNSphere(radius: 0.06)
        sphere.segmentCount = 12

        for (i, point) in points.enumerated() {
            let t = i < elevations.count ? elevations[i] : 0
            let color = ColorRamp.uiColor(t: t)

            let material = SCNMaterial()
            material.diffuse.contents = color
            material.emission.contents = UIColor(cgColor: color.cgColor).withAlphaComponent(0.3)

            let node = SCNNode(geometry: sphere.copy() as? SCNGeometry)
            node.geometry?.materials = [material]
            node.name = pointNodeName
            node.position = SCNVector3(point.x, point.y, point.z)

            let dropLine = lineBetween(
                SCNVector3(point.x, point.y, point.z),
                SCNVector3(point.x, 0, point.z),
                color: UIColor(red: 92/255, green: 132/255, blue: 86/255, alpha: 0.18)
            )
            root.addChildNode(dropLine)
            root.addChildNode(node)
        }
    }

    // MARK: - Boundary

    static let boundaryNodeName = "boundaryElement"

    private static func addBoundary(_ stakes: [BoundaryStake], closed: Bool, hidden: Bool, to root: SCNNode) {
        for (i, stake) in stakes.enumerated() {
            let post = SCNNode()
            post.name = boundaryNodeName
            post.isHidden = hidden

            let cylinder = SCNCylinder(radius: 0.015, height: 0.3)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(red: 235/255, green: 216/255, blue: 181/255, alpha: 0.8)
            cylinder.materials = [mat]

            let postGeom = SCNNode(geometry: cylinder)
            postGeom.position = SCNVector3(stake.x, 0.15, stake.z)
            post.addChildNode(postGeom)

            let ball = SCNSphere(radius: 0.04)
            let ballMat = SCNMaterial()
            ballMat.diffuse.contents = UIColor(red: 255/255, green: 184/255, blue: 77/255, alpha: 1)
            ballMat.emission.contents = UIColor(red: 255/255, green: 184/255, blue: 77/255, alpha: 0.4)
            ball.materials = [ballMat]

            let ballNode = SCNNode(geometry: ball)
            ballNode.position = SCNVector3(stake.x, 0.3, stake.z)
            post.addChildNode(ballNode)

            root.addChildNode(post)

            if i > 0 {
                let prev = stakes[i - 1]
                let segment = lineBetween(
                    SCNVector3(prev.x, 0.01, prev.z),
                    SCNVector3(stake.x, 0.01, stake.z),
                    color: UIColor(red: 255/255, green: 184/255, blue: 77/255, alpha: 0.8)
                )
                segment.name = boundaryNodeName
                segment.isHidden = hidden
                root.addChildNode(segment)
            }
        }

        if closed, let first = stakes.first, let last = stakes.last {
            let closingSegment = lineBetween(
                SCNVector3(last.x, 0.01, last.z),
                SCNVector3(first.x, 0.01, first.z),
                color: UIColor(red: 255/255, green: 184/255, blue: 77/255, alpha: 0.8)
            )
            closingSegment.name = boundaryNodeName
            closingSegment.isHidden = hidden
            root.addChildNode(closingSegment)
        }
    }

    // MARK: - Helpers

    private static func lineBetween(_ a: SCNVector3, _ b: SCNVector3, color: UIColor) -> SCNNode {
        let vertices: [SCNVector3] = [a, b]
        let source = SCNGeometrySource(vertices: vertices)
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = color
        material.isDoubleSided = true
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }
}
