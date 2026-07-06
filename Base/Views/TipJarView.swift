import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(StoreTip.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var purchasedID: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header
                tipOptions
                restoreButton
                disclaimer
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Tip Jar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.accentColor)
            Text("Base is free.")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text("If you find it useful, a tip helps keep it alive.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var tipOptions: some View {
        switch store.state {
        case .loading:
            ProgressView()
                .tint(Color.accentColor)
        case .failed(let error):
            Text(error)
                .font(.caption)
                .foregroundStyle(Theme.muted)
        case .loaded(let products):
            VStack(spacing: 12) {
                ForEach(products) { product in
                    Button {
                        Haptics.result()
                        Task {
                            let success = await store.purchase(product)
                            if success { purchasedID = product.id }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.displayName)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.ink)
                                Text(product.description)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.accentColor)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                                .fill(purchasedID == product.id ? Color.accentColor.opacity(0.12) : Theme.keySurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                                .stroke(purchasedID == product.id ? Color.accentColor : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(purchasedID == product.id)
                }
            }
        }
    }

    private var restoreButton: some View {
        Button("Restore previous purchases") {
            Task { await store.restore() }
        }
        .font(.system(size: 14, design: .rounded))
        .foregroundStyle(Theme.muted)
    }

    private var disclaimer: some View {
        Text("Tips are non-consumable purchases. Restore them on any device.")
            .font(.caption)
            .foregroundStyle(Theme.muted.opacity(0.6))
            .multilineTextAlignment(.center)
    }
}

#Preview {
    TipJarView()
        .environment(StoreTip())
}
