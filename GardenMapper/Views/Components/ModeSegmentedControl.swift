import SwiftUI

struct ModeSegmentedControl: View {
    @Binding var mode: ARCaptureMode

    var body: some View {
        HStack(spacing: 0) {
            segment(.elevation, label: "Elevation", dotColor: GM.cream)
            segment(.boundary, label: "Boundary", dotColor: GM.boundary)
        }
        .padding(3)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func segment(_ target: ARCaptureMode, label: String, dotColor: Color) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { mode = target }
        } label: {
            HStack(spacing: 6) {
                Circle().fill(dotColor).frame(width: 8, height: 8)
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(mode == target ? .white : .white.opacity(0.65))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if mode == target {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.18))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                }
            }
        }
    }
}
