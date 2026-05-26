import XCTest
import SceneKit
@testable import GardenMapper

final class PointCloudSceneBuilderTests: XCTestCase {
    private func makePoints() -> [CapturedPoint] {
        [
            CapturedPoint(x: 0, y: 0, z: 0),
            CapturedPoint(x: 1, y: 0.5, z: 0),
            CapturedPoint(x: 2, y: 0.2, z: 1),
        ]
    }

    private func makeStakes() -> [BoundaryStake] {
        [
            BoundaryStake(x: 0, z: 0, index: 1),
            BoundaryStake(x: 5, z: 0, index: 2),
            BoundaryStake(x: 5, z: 5, index: 3),
        ]
    }

    func testSceneContainsPointNodes() {
        let points = makePoints()
        let elevations: [Float] = [0.0, 1.0, 0.4]
        let scene = PointCloudSceneBuilder.buildScene(
            points: points,
            normalizedElevations: elevations,
            boundaryStakes: [],
            boundaryClosed: false,
            showBoundary: false
        )

        let pointNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.pointNodeName
        })
        XCTAssertEqual(pointNodes.count, points.count)
    }

    func testSceneContainsBoundaryNodesWhenShown() {
        let scene = PointCloudSceneBuilder.buildScene(
            points: [],
            normalizedElevations: [],
            boundaryStakes: makeStakes(),
            boundaryClosed: false,
            showBoundary: true
        )

        let boundaryNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.boundaryNodeName
        })
        XCTAssertTrue(boundaryNodes.count > 0)
    }

    func testBoundaryHiddenWhenNotShown() {
        let scene = PointCloudSceneBuilder.buildScene(
            points: [],
            normalizedElevations: [],
            boundaryStakes: makeStakes(),
            boundaryClosed: false,
            showBoundary: false
        )

        let boundaryNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.boundaryNodeName
        })
        XCTAssertTrue(boundaryNodes.count > 0)
        XCTAssertTrue(boundaryNodes.allSatisfy { $0.isHidden })
    }

    func testClosedBoundaryHasClosingSegment() {
        let sceneOpen = PointCloudSceneBuilder.buildScene(
            points: [],
            normalizedElevations: [],
            boundaryStakes: makeStakes(),
            boundaryClosed: false,
            showBoundary: true
        )

        let sceneClosed = PointCloudSceneBuilder.buildScene(
            points: [],
            normalizedElevations: [],
            boundaryStakes: makeStakes(),
            boundaryClosed: true,
            showBoundary: true
        )

        let openCount = sceneOpen.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.boundaryNodeName
        }).count

        let closedCount = sceneClosed.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.boundaryNodeName
        }).count

        XCTAssertGreaterThan(closedCount, openCount)
    }

    func testEmptySceneHasGridAndCamera() {
        let scene = PointCloudSceneBuilder.buildScene(
            points: [],
            normalizedElevations: [],
            boundaryStakes: [],
            boundaryClosed: false,
            showBoundary: false
        )

        let gridNode = scene.rootNode.childNode(withName: "grid", recursively: false)
        XCTAssertNotNil(gridNode)

        let cameraNode = scene.rootNode.childNodes.first(where: { $0.camera != nil })
        XCTAssertNotNil(cameraNode)
    }

    func testPointPositionsMatchInput() {
        let points = makePoints()
        let scene = PointCloudSceneBuilder.buildScene(
            points: points,
            normalizedElevations: [0, 0.5, 1],
            boundaryStakes: [],
            boundaryClosed: false,
            showBoundary: false
        )

        let pointNodes = scene.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.pointNodeName
        })

        for (i, node) in pointNodes.enumerated() {
            XCTAssertEqual(node.position.x, points[i].x, accuracy: 0.001)
            XCTAssertEqual(node.position.y, points[i].y, accuracy: 0.001)
            XCTAssertEqual(node.position.z, points[i].z, accuracy: 0.001)
        }
    }
}
