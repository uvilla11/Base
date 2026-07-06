import SwiftUI

struct TipCalculatorView: View {
    @AppStorage("base.tip.percent") private var tipPercent = 18
    @State private var billAmount = ""
    @State private var splitCount = 1
    @FocusState private var billFocused: Bool

    private let tipChoices = [10, 15, 18, 20, 25]

    private var bill: Double { Double(billAmount) ?? 0 }
    private var tipAmount: Double { bill * Double(tipPercent) / 100 }
    private var total: Double { bill + tipAmount }
    private var perPerson: Double { splitCount > 0 ? total / Double(splitCount) : total }

    var body: some View {
        VStack(spacing: 24) {
            billField
            tipPicker
            splitStepper
            resultCard
            Spacer()
        }
        .padding(.horizontal, Theme.margin)
        .padding(.top, 24)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { billFocused = false }
            }
        }
        .onTapGesture { billFocused = false }
    }

    // MARK: Bill

    private var billField: some View {
        VStack(spacing: 4) {
            Text("Bill")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(Locale.current.currencySymbol ?? "$")
                    .font(Theme.display(30))
                    .foregroundStyle(Theme.muted)
                TextField("0", text: $billAmount)
                    .keyboardType(.decimalPad)
                    .focused($billFocused)
                    .font(Theme.display(56))
                    .monospacedDigit()
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .accessibilityLabel("Bill amount")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.keySurface))
        .onTapGesture { billFocused = true }
    }

    // MARK: Tip

    private var tipPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tip")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)
            HStack(spacing: 8) {
                ForEach(tipChoices, id: \.self) { pct in
                    Button {
                        Haptics.digit()
                        withAnimation(.snappy(duration: 0.2)) { tipPercent = pct }
                    } label: {
                        Text("\(pct)%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(tipPercent == pct ? Theme.background : Theme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                Capsule().fill(tipPercent == pct ? Color.accentColor : Theme.keySurface)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(pct) percent tip")
                    .accessibilityAddTraits(tipPercent == pct ? .isSelected : [])
                }
            }
        }
    }

    // MARK: Split

    private var splitStepper: some View {
        HStack {
            Text("Split")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)
            Spacer()
            HStack(spacing: 20) {
                stepButton("minus") {
                    if splitCount > 1 { splitCount -= 1 }
                }
                .disabled(splitCount <= 1)
                .opacity(splitCount <= 1 ? 0.35 : 1)

                HStack(spacing: 5) {
                    Image(systemName: splitCount == 1 ? "person.fill" : "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.muted)
                    Text("\(splitCount)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Theme.ink)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.2), value: splitCount)
                }
                .frame(minWidth: 56)

                stepButton("plus") {
                    if splitCount < 50 { splitCount += 1 }
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 64)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.keySurface))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Split between \(splitCount) people")
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.digit()
            withAnimation(.snappy(duration: 0.2)) { action() }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Theme.keyRaised))
        }
        .buttonStyle(.plain)
    }

    // MARK: Result

    private var resultCard: some View {
        VStack(spacing: 14) {
            row("Tip", Format.currency(tipAmount))
            row("Total", Format.currency(total))
            Divider().overlay(Theme.muted.opacity(0.3))
            HStack(alignment: .firstTextBaseline) {
                Text(splitCount > 1 ? "Each" : "You pay")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.muted)
                Spacer()
                Text(Format.currency(perPerson))
                    .font(Theme.display(40))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.25), value: perPerson)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.keySurface))
        .opacity(bill > 0 ? 1 : 0.45)
        .animation(.smooth(duration: 0.25), value: bill > 0)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.25), value: value)
        }
    }
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        TipCalculatorView()
    }
}
