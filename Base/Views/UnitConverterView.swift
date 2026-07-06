import SwiftUI

struct UnitConverterView: View {
    @Environment(UnitConverterVM.self) private var vm
    @FocusState private var inputFocused: Bool
    @State private var swapRotation = 0.0

    var body: some View {
        VStack(spacing: 20) {
            categoryChips

            VStack(spacing: 10) {
                fromRow
                swapButton
                toRow
            }
            .padding(.horizontal, Theme.margin)

            unitGrid

            if vm.selectedCategory == .currency {
                Text("Approximate rates. Not for trading.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }

            Spacer()
        }
        .padding(.top, 20)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { inputFocused = false }
            }
        }
        .onTapGesture { inputFocused = false }
    }

    // MARK: Category

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(UnitCategory.allCases) { cat in
                    Button {
                        guard cat != vm.selectedCategory else { return }
                        Haptics.op()
                        withAnimation(.smooth(duration: 0.25)) {
                            vm.selectedCategory = cat
                            vm.categoryChanged()
                        }
                    } label: {
                        Text(cat.name)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(vm.selectedCategory == cat ? Theme.background : Theme.ink)
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(
                                Capsule().fill(vm.selectedCategory == cat ? Color.accentColor : Theme.keySurface)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(vm.selectedCategory == cat ? .isSelected : [])
                }
            }
            .padding(.horizontal, Theme.margin)
        }
    }

    // MARK: Rows

    private var fromRow: some View {
        @Bindable var vm = vm
        return HStack(spacing: 12) {
            unitBadge(vm.fromUnit)
            TextField("0", text: $vm.fromValue)
                .keyboardType(.numbersAndPunctuation)
                .focused($inputFocused)
                .font(Theme.display(34))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.trailing)
                .onChange(of: vm.fromValue) { _, _ in vm.convert() }
                .accessibilityLabel("Value in \(vm.fromUnit)")
        }
        .padding(.horizontal, 18)
        .frame(height: 76)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.keySurface))
    }

    private var toRow: some View {
        HStack(spacing: 12) {
            unitBadge(vm.toUnit)
            Spacer()
            Text(vm.toValue.isEmpty ? "—" : vm.toValue)
                .font(Theme.display(34))
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.2), value: vm.toValue)
                .accessibilityLabel("Result: \(vm.toValue) \(vm.toUnit)")
        }
        .padding(.horizontal, 18)
        .frame(height: 76)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous).fill(Theme.keySurface))
    }

    private var swapButton: some View {
        Button {
            Haptics.flip()
            withAnimation(.snappy(duration: 0.35)) {
                swapRotation += 180
                vm.swapUnits()
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .rotationEffect(.degrees(swapRotation))
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.keyRaised))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Swap units")
    }

    private func unitBadge(_ unit: String) -> some View {
        Text(unit)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.muted)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Capsule().fill(Theme.keyRaised))
            .fixedSize()
    }

    // MARK: Unit picker grid

    private var unitGrid: some View {
        let units = UnitConversion.units(for: vm.selectedCategory)
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 8)], spacing: 8) {
            ForEach(units, id: \.self) { unit in
                Button {
                    Haptics.digit()
                    if vm.fromUnit == unit {
                        return
                    } else if vm.toUnit == unit {
                        withAnimation(.snappy(duration: 0.3)) { vm.swapUnits() }
                    } else {
                        vm.toUnit = unit
                        vm.convert()
                    }
                } label: {
                    Text(unit)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(color(for: unit))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            Capsule().fill(fill(for: unit))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.margin)
        .animation(.smooth(duration: 0.2), value: vm.fromUnit)
        .animation(.smooth(duration: 0.2), value: vm.toUnit)
    }

    private func color(for unit: String) -> Color {
        if unit == vm.fromUnit { return Theme.background }
        if unit == vm.toUnit { return Color.accentColor }
        return Theme.muted
    }

    private func fill(for unit: String) -> Color {
        if unit == vm.fromUnit { return Color.accentColor }
        if unit == vm.toUnit { return Color.accentColor.opacity(0.18) }
        return Theme.keySurface
    }
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        UnitConverterView()
            .environment(UnitConverterVM())
    }
}
