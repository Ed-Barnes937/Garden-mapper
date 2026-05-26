import UIKit

enum ColorRamp {
    struct RGBColor: Equatable {
        let r: Float
        let g: Float
        let b: Float
    }

    static let stops: [(position: Float, color: RGBColor)] = [
        (0.00, RGBColor(r: 31/255, g: 58/255, b: 40/255)),   // moss
        (0.35, RGBColor(r: 92/255, g: 132/255, b: 86/255)),   // sage
        (0.65, RGBColor(r: 168/255, g: 123/255, b: 91/255)),  // clay
        (1.00, RGBColor(r: 235/255, g: 216/255, b: 181/255)), // cream
    ]

    static func elevationColor(t: Float) -> RGBColor {
        let clamped = max(0, min(1, t))

        if clamped <= stops[0].position { return stops[0].color }
        if clamped >= stops[stops.count - 1].position { return stops[stops.count - 1].color }

        for i in 0..<(stops.count - 1) {
            let lo = stops[i]
            let hi = stops[i + 1]
            if clamped >= lo.position && clamped <= hi.position {
                let frac = (clamped - lo.position) / (hi.position - lo.position)
                return RGBColor(
                    r: lo.color.r + (hi.color.r - lo.color.r) * frac,
                    g: lo.color.g + (hi.color.g - lo.color.g) * frac,
                    b: lo.color.b + (hi.color.b - lo.color.b) * frac
                )
            }
        }

        return stops[stops.count - 1].color
    }

    static func uiColor(t: Float) -> UIColor {
        let c = elevationColor(t: t)
        return UIColor(red: CGFloat(c.r), green: CGFloat(c.g), blue: CGFloat(c.b), alpha: 1)
    }
}
