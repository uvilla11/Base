import SwiftUI

struct HistoryView: View {
    @Environment(CalculatorVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingClear = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if vm.history.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
                ToolbarItem(placement: .primaryAction) {
                    if !vm.history.isEmpty {
                        Button("Clear", role: .destructive) {
                            confirmingClear = true
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .confirmationDialog("Clear all history?", isPresented: $confirmingClear, titleVisibility: .visible) {
                Button("Clear All", role: .destructive) {
                    Haptics.op()
                    withAnimation { vm.clearHistory() }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(vm.history.all) { expr in
                Button {
                    Haptics.digit()
                    vm.recall(expr)
                    dismiss()
                } label: {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(Format.prettyExpression(expr.input))
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(Theme.muted)
                        Text("= \(expr.result)")
                            .font(.system(size: 21, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Theme.ink)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(Theme.background)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        vm.removeFromHistory(expr)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Theme.muted.opacity(0.5))
            Text("Results you calculate will appear here.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.muted)
        }
    }
}

#Preview {
    HistoryView()
        .environment(CalculatorVM())
}
