import SwiftUI

// Semantic design tokens. See DESIGN.md.
enum Theme {
    // MARK: Color
    static let background = Color("BaseBackground")
    static let keySurface = Color("KeySurface")
    static let keyRaised = Color("KeySurfaceRaised")
    static let ink = Color("InkPrimary")
    static let muted = Color("InkMuted")
    static let accent = Color.accentColor
    static let accentDeep = Color("AccentDeep")
    static let positive = Color("PositiveGreen")

    // MARK: Shape
    static let keyRadius: CGFloat = 16
    static let cardRadius: CGFloat = 16

    // MARK: Spacing
    static let gutter: CGFloat = 10
    static let margin: CGFloat = 16

    // MARK: Type
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }
    static let key: Font = .system(size: 28, weight: .medium, design: .rounded)
    static let keySmall: Font = .system(size: 22, weight: .medium, design: .rounded)
}

// MARK: - Number formatting

enum Format {
    static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 8
        f.usesGroupingSeparator = true
        return f
    }()

    /// "1234567.891" → "1,234,567.891". Falls back to input on non-numbers.
    static func pretty(_ raw: String) -> String {
        guard let value = Double(raw) else { return raw }
        return pretty(value)
    }

    static func pretty(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        if abs(value) >= 1e12 || (abs(value) < 1e-8 && value != 0) {
            return String(format: "%g", value)
        }
        return decimal.string(from: NSNumber(value: value)) ?? String(value)
    }

    static func currency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = Locale.current.currencySymbol ?? "$"
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Key button style

struct KeyStyle: ButtonStyle {
    var fill: Color = Theme.keySurface
    var textColor: Color = Theme.ink
    var font: Font = Theme.key

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous)
                    .fill(configuration.isPressed ? fill.opacity(0.72) : fill)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}
