import SwiftUI

struct ReticleView: View {
    let mode: ARCaptureMode

    private let size: CGFloat = 44
    private var dotColor: Color {
        mode == .elevation ? GM.cream : GM.boundary
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                .frame(width: size, height: size)

            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: 1, height: 8)
                .offset(y: -16)
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: 1, height: 8)
                .offset(y: 16)
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: 8, height: 1)
                .offset(x: -16)
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(width: 8, height: 1)
                .offset(x: 16)

            Circle()
                .fill(dotColor)
                .frame(width: 4, height: 4)
        }
    }
}
