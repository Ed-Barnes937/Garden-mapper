import SwiftUI

struct StatsBar: View {
    let pointCount: Int
    let elevationDelta: String
    var area: String?
    var perimeter: String?

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "Points", value: "\(pointCount)", accent: .white)
            divider
            statItem(label: "Δ Elev", value: elevationDelta, accent: GM.cream)
            if let area {
                divider
                statItem(label: "Area", value: area, accent: GM.boundary)
            }
            if let perimeter {
                divider
                statItem(label: "Perimeter", value: perimeter, accent: GM.boundary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(Color(red: 11/255, green: 16/255, blue: 12/255).opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func statItem(label: String, value: String, accent: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .semibold).monospacedDigit())
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.14))
            .frame(width: 1, height: 28)
    }
}
