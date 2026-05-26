import SwiftUI
import ARKit

enum AppRoute {
    case setup
    case arCapture(stickHeightCm: Int)
    case viewer(session: ScanSession)
}

@main
struct GardenMapperApp: App {
    @State private var route: AppRoute = .setup

    private var lidarAvailable: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch route {
                case .setup:
                    SetupView(
                        lidarAvailable: lidarAvailable,
                        onStartScan: { height in
                            route = .arCapture(stickHeightCm: height)
                        },
                        onCancel: {}
                    )

                case .arCapture(let height):
                    ARCaptureView(
                        stickHeightCm: height,
                        onDone: { session in
                            route = .viewer(session: session)
                        }
                    )

                case .viewer(let session):
                    PointCloudViewerView(
                        session: session,
                        onBack: { route = .setup }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: routeKey)
        }
    }

    private var routeKey: String {
        switch route {
        case .setup: return "setup"
        case .arCapture: return "arCapture"
        case .viewer: return "viewer"
        }
    }
}
