import UIKit

/// The app is silent by design — haptics are the sound design. See DESIGN.md.
enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let notify = UINotificationFeedbackGenerator()

    /// Digit and decimal keys.
    static func digit() { light.impactOccurred(intensity: 0.7) }

    /// Operator keys (+ − × ÷) and function keys.
    static func op() { medium.impactOccurred() }

    /// Equals — the result lands.
    static func result() { notify.notificationOccurred(.success) }

    /// Calculation error.
    static func error() { notify.notificationOccurred(.error) }

    /// Unit swap, tab change.
    static func flip() { rigid.impactOccurred(intensity: 0.8) }
}
