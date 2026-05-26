import SwiftUI

struct SetupView: View {
    @StateObject private var viewModel: SetupViewModel
    let onStartScan: (Int) -> Void
    let onCancel: () -> Void

    init(lidarAvailable: Bool, onStartScan: @escaping (Int) -> Void, onCancel: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: SetupViewModel(
            storage: StickHeightStorage(),
            lidarAvailable: lidarAvailable
        ))
        self.onStartScan = onStartScan
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            navbar
            ScrollView {
                VStack(spacing: 14) {
                    illustrationCard
                    stickHeightRow
                    helpText
                    checklist
                }
                .padding(.horizontal, GM.sidePadding)
                .padding(.top, 16)
            }
            startButton
        }
        .background(GM.paper)
    }

    // MARK: - Navbar

    private var navbar: some View {
        ZStack {
            Text("New Scan")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(GM.ink)
            HStack {
                Button("Cancel") { onCancel() }
                    .font(.system(size: 17))
                    .foregroundStyle(GM.moss)
                Spacer()
            }
            .padding(.horizontal, GM.sidePadding)
        }
        .frame(height: 44)
    }

    // MARK: - Illustration

    private var illustrationCard: some View {
        ZStack {
            LinearGradient(colors: [GM.paperDeep, GM.paper], startPoint: .bottom, endPoint: .top)
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "iphone")
                    .font(.system(size: 40))
                    .foregroundStyle(GM.moss)
                Rectangle()
                    .fill(GM.clay)
                    .frame(width: 5, height: 60)
                Spacer()
                dotGrid
            }
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var dotGrid: some View {
        Canvas { context, size in
            let cols = 14, rows = 4
            let dx = size.width / CGFloat(cols + 1)
            let dy = 20.0
            for r in 0..<rows {
                for c in 0..<cols {
                    let x = dx * CGFloat(c + 1)
                    let y = size.height - dy * CGFloat(rows - r)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)),
                        with: .color(GM.sageLight.opacity(0.35))
                    )
                }
            }
        }
        .frame(height: 80)
    }

    // MARK: - Stick Height

    private var stickHeightRow: some View {
        HStack {
            Image(systemName: "ruler")
                .font(.system(size: 16))
                .foregroundStyle(GM.moss)
                .frame(width: 36, height: 36)
                .background(GM.moss.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 9))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(viewModel.stickHeightCm)")
                    .font(.system(size: 28, weight: .semibold).monospacedDigit())
                    .foregroundStyle(GM.ink)
                Text("cm")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(GM.inkSoft)
            }

            Spacer()

            HStack(spacing: 0) {
                Button { viewModel.decrementHeight() } label: {
                    Text("−")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 32, height: 32)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                Button { viewModel.incrementHeight() } label: {
                    Text("+")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 32, height: 32)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
            .foregroundStyle(GM.ink)
            .padding(4)
            .background(GM.paperDeep)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: GM.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: GM.cardRadius).strokeBorder(GM.hairline, lineWidth: 1))
    }

    // MARK: - Help & Checklist

    private var helpText: some View {
        Text("Mount your iPhone at the top of a rigid stick or monopod. Hold at the same height for every point.")
            .font(.system(size: 13))
            .foregroundStyle(GM.inkSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checklist: some View {
        VStack(spacing: 0) {
            checklistRow(icon: "checkmark", tint: GM.sage, label: "LiDAR sensor detected", satisfied: viewModel.canStartScan)
        }
        .padding(.top, 14)
    }

    private func checklistRow(icon: String, tint: Color, label: String, satisfied: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(satisfied ? tint : .clear)
                    .frame(width: 20, height: 20)
                if satisfied {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .strokeBorder(GM.inkMute, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(satisfied ? GM.ink : GM.inkSoft)
            Spacer()
        }
        .padding(.vertical, 10)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button { onStartScan(viewModel.stickHeightCm) } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(GM.cream)
                    .frame(width: 8, height: 8)
                    .shadow(color: GM.cream.opacity(0.5), radius: 3)
                Text("Start Scan")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(GM.moss)
            .clipShape(RoundedRectangle(cornerRadius: GM.buttonRadius))
            .shadow(color: GM.moss.opacity(0.25), radius: 9, y: 6)
        }
        .disabled(!viewModel.canStartScan)
        .opacity(viewModel.canStartScan ? 1 : 0.5)
        .padding(.horizontal, GM.sidePadding)
        .padding(.bottom, 32)
    }
}
