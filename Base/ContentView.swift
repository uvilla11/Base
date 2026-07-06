import SwiftUI

enum Tab: String, CaseIterable {
    case calculator = "Calculate"
    case converter = "Convert"
    case tip = "Split"

    var icon: String {
        switch self {
        case .calculator: return "plus.forwardslash.minus"
        case .converter: return "arrow.left.arrow.right"
        case .tip: return "fork.knife"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .calculator
    @Namespace private var tabIndicator
    @State private var showingTipJar = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                tabSwitcher
                    .padding(.horizontal, Theme.margin)
                    .padding(.top, 8)

                Group {
                    switch selectedTab {
                    case .calculator: CalculatorView()
                    case .converter: UnitConverterView()
                    case .tip: TipCalculatorView()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingTipJar) {
            TipJarView()
                .presentationDetents([.medium])
        }
    }

    private var tabSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    guard tab != selectedTab else { return }
                    Haptics.flip()
                    withAnimation(.smooth(duration: 0.25)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .semibold))
                        if selectedTab == tab {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .transition(.opacity)
                        }
                    }
                    .foregroundStyle(selectedTab == tab ? Theme.background : Theme.muted)
                    .padding(.horizontal, selectedTab == tab ? 16 : 14)
                    .frame(height: 38)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "tab", in: tabIndicator)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
            Spacer()
            Button {
                Haptics.op()
                showingTipJar = true
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Capsule().fill(Theme.keySurface))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tip jar")
        }
    }
}

#Preview {
    ContentView()
        .environment(CalculatorVM())
        .environment(UnitConverterVM())
}
