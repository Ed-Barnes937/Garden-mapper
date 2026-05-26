import SwiftUI
import SceneKit

struct PointCloudViewerView: View {
    @StateObject private var viewModel: PointCloudViewerViewModel
    @State private var scene: SCNScene?
    let onBack: () -> Void

    init(session: ScanSession, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: PointCloudViewerViewModel(session: session))
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            background
            if let scene {
                SceneKitView(scene: scene)
                    .ignoresSafeArea()
            }
            chrome
        }
        .onAppear { buildScene() }
        .onChange(of: viewModel.showBoundary) { visible in
            toggleBoundaryVisibility(visible)
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheetView(session: viewModel.session)
        }
    }

    private func buildScene() {
        scene = PointCloudSceneBuilder.buildScene(
            points: viewModel.displayPoints,
            normalizedElevations: viewModel.normalizedElevations,
            boundaryStakes: viewModel.session.boundaryStakes,
            boundaryClosed: viewModel.session.boundaryClosed,
            showBoundary: viewModel.showBoundary
        )
    }

    private func toggleBoundaryVisibility(_ visible: Bool) {
        guard let scene else { return }
        scene.rootNode.childNodes(passingTest: { node, _ in
            node.name == PointCloudSceneBuilder.boundaryNodeName
        }).forEach { $0.isHidden = !visible }
    }

    // MARK: - Background

    private var background: some View {
        RadialGradient(
            colors: [
                Color(red: 20/255, green: 36/255, blue: 27/255),
                GM.arBg,
                Color(red: 5/255, green: 8/255, blue: 7/255)
            ],
            center: .top,
            startRadius: 0,
            endRadius: 600
        )
        .ignoresSafeArea()
    }

    // MARK: - Chrome

    private var chrome: some View {
        VStack {
            topBar
            orbitHint
            Spacer()
            legendOverlay
            statsBar
        }
    }

    private var topBar: some View {
        HStack {
            GlassPill(label: "Back", icon: "chevron.left") { onBack() }
            Spacer()
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
            Spacer()
            Button { viewModel.showExportSheet = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
            }
        }
        .padding(.horizontal, GM.chromeInset)
        .padding(.top, 56)
    }

    private var title: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Garden · \(formatter.string(from: viewModel.session.startDate))"
    }

    private var orbitHint: some View {
        Text("DRAG TO ORBIT · PINCH TO ZOOM")
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.45))
            .padding(.top, 20)
    }

    private var legendOverlay: some View {
        HStack {
            ElevationLegend(
                highLabel: viewModel.elevationDeltaFormatted,
                lowLabel: "0.00m",
                barHeight: 180
            )
            .padding(.leading, 14)
            Spacer()
            boundaryToggle
                .padding(.trailing, 14)
        }
    }

    private var boundaryToggle: some View {
        Button { viewModel.showBoundary.toggle() } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.showBoundary ? GM.boundary : GM.boundary.opacity(0.25))
                    .frame(width: 8, height: 8)
                    .shadow(color: viewModel.showBoundary ? GM.boundary.opacity(0.5) : .clear, radius: 4)
                Text("Boundary")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(viewModel.showBoundary ? .white : .white.opacity(0.55))
            }
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .opacity(viewModel.session.boundaryStakes.isEmpty ? 0 : 1)
    }

    private var statsBar: some View {
        StatsBar(
            pointCount: viewModel.pointCount,
            elevationDelta: viewModel.elevationDeltaFormatted,
            area: viewModel.areaFormatted,
            perimeter: viewModel.perimeterFormatted
        )
        .padding(.horizontal, GM.chromeInset)
        .padding(.bottom, 36)
    }
}

// MARK: - SceneKit Wrapper

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.backgroundColor = .clear
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if uiView.scene !== scene {
            uiView.scene = scene
        }
    }
}
