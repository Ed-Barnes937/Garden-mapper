import SwiftUI

struct CountTile: View {
    let count: Int
    let label: String
    var accentColor: Color = .white.opacity(0.65)

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 22, weight: .semibold).monospacedDigit())
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(accentColor)
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(minWidth: 70, minHeight: 56)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: GM.buttonRadius))
    }
}
