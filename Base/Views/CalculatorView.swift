import SwiftUI

struct CalculatorView: View {
    @Environment(CalculatorVM.self) private var vm
    @State private var showingHistory = false

    var body: some View {
        VStack(spacing: 0) {
            displayArea
            keypad
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Display

    private var displayArea: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Spacer()

            HStack {
                Button {
                    showingHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(vm.history.isEmpty ? Theme.muted.opacity(0.4) : Theme.muted)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(vm.history.isEmpty)
                .accessibilityLabel("History")
                Spacer()
            }

            if !vm.preview.isEmpty {
                Text("= \(vm.preview)")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.muted)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.2), value: vm.preview)
                    .transition(.opacity)
            }

            Text(displayText)
                .font(Theme.display(displayFontSize))
                .monospacedDigit()
                .foregroundStyle(vm.hasError ? Color.accentColor : Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.25), value: vm.display)
                .accessibilityLabel("Display: \(displayText)")
        }
        .padding(.horizontal, Theme.margin + 4)
        .padding(.bottom, 16)
    }

    private var displayText: String {
        vm.showingResult || vm.hasError ? vm.display : Format.prettyExpression(vm.display)
    }

    private var displayFontSize: CGFloat {
        let count = vm.display.count
        if count > 18 { return 40 }
        if count > 10 { return 54 }
        return 72
    }

    // MARK: Keypad

    private let rows: [[Key]] = [
        [.clear, .sign, .percent, .op("÷")],
        [.digit("7"), .digit("8"), .digit("9"), .op("×")],
        [.digit("4"), .digit("5"), .digit("6"), .op("−")],
        [.digit("1"), .digit("2"), .digit("3"), .op("+")],
        [.digit("0"), .digit("."), .backspace, .equals],
    ]

    private var keypad: some View {
        Grid(horizontalSpacing: Theme.gutter, verticalSpacing: Theme.gutter) {
            ForEach(rows.indices, id: \.self) { r in
                GridRow {
                    ForEach(rows[r]) { key in
                        keyButton(key)
                    }
                }
            }
        }
        .aspectRatio(4/5.1, contentMode: .fit)
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func keyButton(_ key: Key) -> some View {
        switch key {
        case .backspace:
            Button {
                Haptics.op()
                vm.backspace()
            } label: {
                Image(systemName: "delete.backward")
                    .font(.system(size: 24, weight: .medium))
            }
            .buttonStyle(KeyStyle(fill: Theme.keySurface, textColor: Theme.ink))
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                Haptics.op()
                vm.clear()
            })
            .accessibilityLabel("Delete. Hold to clear all.")
        default:
            Button {
                key.haptic()
                key.act(on: vm)
            } label: {
                Text(key.label)
            }
            .buttonStyle(KeyStyle(fill: key.fill, textColor: key.textColor, font: key.font))
            .accessibilityLabel(key.accessibilityLabel)
        }
    }
}

// MARK: - Key model

private enum Key: Identifiable, Hashable {
    case digit(String), op(String), clear, sign, percent, backspace, equals

    var id: String { label }

    var label: String {
        switch self {
        case .digit(let d): return d
        case .op(let o): return o
        case .clear: return "AC"
        case .sign: return "⁺∕₋"
        case .percent: return "%"
        case .backspace: return "⌫"
        case .equals: return "="
        }
    }

    var fill: Color {
        switch self {
        case .equals: return Color.accentColor
        case .op: return Theme.keyRaised
        case .clear, .sign, .percent: return Theme.keyRaised
        case .digit, .backspace: return Theme.keySurface
        }
    }

    var textColor: Color {
        switch self {
        case .equals: return Theme.background
        case .op: return Color.accentColor
        case .clear, .sign, .percent: return Theme.muted
        case .digit, .backspace: return Theme.ink
        }
    }

    var font: Font {
        switch self {
        case .clear, .sign: return Theme.keySmall
        case .op, .equals: return .system(size: 30, weight: .medium, design: .rounded)
        default: return Theme.key
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .digit(let d): return d
        case .op("÷"): return "Divide"
        case .op("×"): return "Multiply"
        case .op("−"): return "Subtract"
        case .op("+"): return "Add"
        case .op(let o): return o
        case .clear: return "Clear all"
        case .sign: return "Toggle sign"
        case .percent: return "Percent"
        case .backspace: return "Delete"
        case .equals: return "Equals"
        }
    }

    func haptic() {
        switch self {
        case .digit: Haptics.digit()
        case .equals: Haptics.result()
        default: Haptics.op()
        }
    }

    func act(on vm: CalculatorVM) {
        switch self {
        case .digit(let d): vm.inputDigit(d)
        case .op(let o): vm.inputOperator(o)
        case .clear: vm.clear()
        case .sign: vm.toggleSign()
        case .percent: vm.inputPercent()
        case .backspace: vm.backspace()
        case .equals: vm.evaluate()
        }
    }
}

extension Format {
    /// Formats each number inside a display expression with grouping separators.
    static func prettyExpression(_ line: String) -> String {
        line.split(separator: " ", omittingEmptySubsequences: false)
            .map { piece in
                let s = String(piece)
                guard let value = Double(s), !s.hasSuffix(".") else { return s }
                // Preserve trailing decimals being typed, e.g. "3.10"
                if s.contains(".") { return s }
                return pretty(value)
            }
            .joined(separator: " ")
    }
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        CalculatorView()
            .environment(CalculatorVM())
    }
}
