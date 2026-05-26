import SwiftUI

struct ElevationLegend: View {
    var highLabel = "HIGH"
    var lowLabel = "LOW"
    var barHeight: CGFloat = 120

    var body: some View {
        VStack(spacing: 4) {
            Text(highLabel)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.45))

            LinearGradient(
                colors: [GM.cream, GM.tan, GM.sage, GM.moss],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 6, height: barHeight)
            .clipShape(Capsule())

            Text(lowLabel)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.45))
        }
    }
}
