import SwiftUI

enum GM {
    // MARK: - Light surfaces
    static let paper = Color(red: 244/255, green: 240/255, blue: 234/255)
    static let paperDeep = Color(red: 232/255, green: 225/255, blue: 211/255)
    static let ink = Color(red: 26/255, green: 28/255, blue: 24/255)
    static let inkSoft = Color(red: 75/255, green: 78/255, blue: 71/255)
    static let inkMute = Color(red: 138/255, green: 141/255, blue: 133/255)
    static let hairline = Color(red: 26/255, green: 28/255, blue: 24/255).opacity(0.10)

    // MARK: - Greens
    static let moss = Color(red: 31/255, green: 58/255, blue: 40/255)
    static let mossDeep = Color(red: 19/255, green: 38/255, blue: 26/255)
    static let sage = Color(red: 92/255, green: 132/255, blue: 86/255)
    static let sageLight = Color(red: 143/255, green: 174/255, blue: 130/255)

    // MARK: - Earth tones
    static let clay = Color(red: 168/255, green: 123/255, blue: 91/255)
    static let tan = Color(red: 212/255, green: 181/255, blue: 142/255)
    static let cream = Color(red: 235/255, green: 216/255, blue: 181/255)

    // MARK: - Dark surfaces
    static let arBg = Color(red: 11/255, green: 16/255, blue: 12/255)
    static let arInk = Color(red: 242/255, green: 239/255, blue: 231/255)
    static let arGlass = Color(red: 20/255, green: 28/255, blue: 22/255).opacity(0.55)

    // MARK: - Accents
    static let boundary = Color(red: 255/255, green: 184/255, blue: 77/255)
    static let boundaryDark = Color(red: 201/255, green: 135/255, blue: 31/255)
    static let boundaryInk = Color(red: 61/255, green: 42/255, blue: 14/255)
    static let record = Color(red: 232/255, green: 79/255, blue: 61/255)
    static let closed = Color(red: 123/255, green: 201/255, blue: 123/255)
    static let error = Color(red: 217/255, green: 83/255, blue: 79/255)

    // MARK: - Spacing
    static let sidePadding: CGFloat = 16
    static let chromeInset: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let pillRadius: CGFloat = 14
    static let sheetRadius: CGFloat = 28
    static let buttonRadius: CGFloat = 18
}
