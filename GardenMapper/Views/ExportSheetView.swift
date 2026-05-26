import SwiftUI

struct ExportSheetView: View {
    @StateObject private var viewModel: ExportSheetViewModel
    @Environment(\.dismiss) private var dismiss

    init(session: ScanSession) {
        _viewModel = StateObject(wrappedValue: ExportSheetViewModel(session: session))
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header
            formatList
            cancelButton
        }
        .padding(.bottom, 20)
        .background(GM.paper)
        .presentationDetents([.medium])
    }

    private var grabber: some View {
        Capsule()
            .fill(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, 4)
            .padding(.bottom, 8)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Export point cloud")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(GM.ink)
            Text("\(viewModel.pointCount) points · share via AirDrop, Files, or Mail")
                .font(.system(size: 13))
                .foregroundStyle(GM.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var formatList: some View {
        VStack(spacing: 0) {
            formatRow(format: .ply, icon: "cube", title: ".ply", subtitle: "3D point cloud · CloudCompare, MeshLab, Blender")
            Divider().padding(.leading, 74)
            formatRow(format: .csv, icon: "tablecells", title: ".csv", subtitle: "Spreadsheet · x, y, z columns in meters")
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: GM.buttonRadius))
        .overlay(RoundedRectangle(cornerRadius: GM.buttonRadius).strokeBorder(GM.hairline, lineWidth: 1))
        .padding(.horizontal, GM.sidePadding)
    }

    private func formatRow(format: ExportFormat, icon: String, title: String, subtitle: String) -> some View {
        Button {
            let url = viewModel.exportFile(format: format)
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shareFile(url: url)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(GM.moss)
                    .frame(width: 44, height: 44)
                    .background(GM.moss.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(GM.ink)
                    }
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(GM.inkSoft)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private var cancelButton: some View {
        Button { dismiss() } label: {
            Text("Cancel")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(GM.moss)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(GM.hairline, lineWidth: 1))
        }
        .padding(.horizontal, GM.sidePadding)
        .padding(.top, 14)
    }

    private func shareFile(url: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        root.present(activity, animated: true)
    }
}
