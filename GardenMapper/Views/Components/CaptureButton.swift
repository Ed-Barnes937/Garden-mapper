import SwiftUI

struct CaptureButton: View {
    let mode: ARCaptureMode
    let canClose: Bool
    let isClosed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(ringColor, lineWidth: 4)
                    .frame(width: 86, height: 86)

                Circle()
                    .fill(discGradient)
                    .frame(width: 74, height: 74)

                glyphView
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
    }

    private var ringColor: Color {
        switch mode {
        case .elevation: return .white
        case .boundary: return isClosed ? GM.closed : GM.boundary
        }
    }

    private var discGradient: RadialGradient {
        switch mode {
        case .elevation:
            return RadialGradient(colors: [GM.cream, GM.tan], center: .center, startRadius: 0, endRadius: 37)
        case .boundary:
            if isClosed {
                return RadialGradient(colors: [GM.closed.opacity(0.8), GM.closed], center: .center, startRadius: 0, endRadius: 37)
            }
            return RadialGradient(colors: [GM.boundary.opacity(0.9), GM.boundary, GM.boundaryDark], center: .center, startRadius: 0, endRadius: 37)
        }
    }

    @ViewBuilder
    private var glyphView: some View {
        switch mode {
        case .elevation:
            VStack(spacing: 2) {
                Circle().fill(GM.moss).frame(width: 8, height: 8)
                Text("TAP").font(.system(size: 9, weight: .bold)).foregroundStyle(GM.moss)
            }
        case .boundary:
            if isClosed {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(red: 14/255, green: 58/255, blue: 18/255))
            } else if canClose {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(GM.boundaryInk)
            } else {
                Image(systemName: "flag.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(GM.boundaryInk)
            }
        }
    }
}
