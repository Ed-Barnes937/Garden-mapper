import SwiftUI
import RealityKit

struct ARCaptureView: View {
    @StateObject private var viewModel: ARCaptureViewModel
    let onDone: (ScanSession) -> Void

    init(stickHeightCm: Int, onDone: @escaping (ScanSession) -> Void) {
        let service = ARSessionService()
        _viewModel = StateObject(wrappedValue: ARCaptureViewModel(
            stickHeightCm: stickHeightCm,
            arService: service
        ))
        self.onDone = onDone
    }

    private var arView: ARView? {
        (viewModel.arService as? ARSessionService)?.arView
    }

    var body: some View {
        ZStack {
            if let arView {
                ARViewContainer(arView: arView) { point in
                    Task { await viewModel.captureAtScreenPoint(point) }
                }
                .ignoresSafeArea()
            }

            overlay
        }
        .statusBarHidden()
        .onAppear { viewModel.startSession() }
        .onDisappear { viewModel.stopSession() }
    }

    private var overlay: some View {
        GeometryReader { geo in
            ZStack {
                bottomFade
                topChrome
                ReticleView(mode: viewModel.captureMode)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.62)
                ElevationLegend()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 14)
                    .opacity(viewModel.captureMode == .elevation ? 1 : 0.3)
                bottomControls(screenSize: geo.size)
            }
        }
    }

    // MARK: - Top Chrome

    private var topChrome: some View {
        VStack(spacing: 10) {
            HStack {
                recordingChip
                Spacer()
                GlassPill(label: "Done") {
                    viewModel.stopSession()
                    onDone(viewModel.session)
                }
            }

            ModeSegmentedControl(mode: $viewModel.captureMode)

            if viewModel.showLoopBanner {
                LoopClosureBanner { viewModel.dismissLoopBanner() }
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.top, 56)
        .padding(.horizontal, GM.chromeInset)
        .animation(.easeOut(duration: 0.2), value: viewModel.showLoopBanner)
    }

    private var recordingChip: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(GM.record)
                .frame(width: 8, height: 8)
                .shadow(color: GM.record.opacity(0.6), radius: 4)
            Text("SCANNING")
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(.white)
            Text("· \(viewModel.session.stickHeightCm)cm")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
    }

    // MARK: - Bottom Controls

    private func bottomControls(screenSize: CGSize) -> some View {
        VStack {
            Spacer()
            captionLabel
            HStack {
                undoButton
                Spacer()
                captureButton(screenSize: screenSize)
                Spacer()
                countTile
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    private var bottomFade: some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var captionLabel: some View {
        if viewModel.captureMode == .boundary {
            let text: String = {
                if viewModel.session.boundaryClosed { return "REOPEN" }
                if viewModel.canCloseBoundary { return "CLOSE LOOP" }
                return "DROP STAKE"
            }()
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.65))
                .padding(.bottom, 6)
        }
    }

    private func captureButton(screenSize: CGSize) -> some View {
        CaptureButton(
            mode: viewModel.captureMode,
            canClose: viewModel.canCloseBoundary,
            isClosed: viewModel.session.boundaryClosed
        ) {
            handleCaptureButtonTap(screenSize: screenSize)
        }
    }

    private func handleCaptureButtonTap(screenSize: CGSize) {
        if viewModel.captureMode == .boundary {
            if viewModel.session.boundaryClosed {
                viewModel.reopenBoundary()
                return
            }
            if viewModel.canCloseBoundary {
                viewModel.closeBoundary()
                return
            }
        }
        let center = CGPoint(x: screenSize.width / 2, y: screenSize.height * 0.62)
        Task { await viewModel.captureAtScreenPoint(center) }
    }

    private var undoButton: some View {
        Button { viewModel.undo() } label: {
            VStack(spacing: 4) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 18, weight: .semibold))
                Text("UNDO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
            }
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
        }
        .disabled(!viewModel.canUndo)
        .opacity(viewModel.canUndo ? 1 : 0.4)
    }

    private var countTile: some View {
        Group {
            if viewModel.captureMode == .elevation {
                CountTile(count: viewModel.pointCount, label: "POINTS")
            } else {
                let label = viewModel.session.boundaryClosed ? "CLOSED" : "STAKES"
                CountTile(count: viewModel.stakeCount, label: label, accentColor: GM.boundary)
            }
        }
    }
}
