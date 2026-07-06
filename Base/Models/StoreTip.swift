import StoreKit
import SwiftUI

/// Tip-jar products managed in App Store Connect.
/// Product IDs: base.tip.small, base.tip.medium, base.tip.large
@Observable
final class StoreTip {
    enum State: Equatable {
        case loading
        case loaded([Product])
        case failed(String)
    }

    private(set) var state: State = .loading
    private var products: [Product] = []
    private var updateListener: Task<Void, Never>?

    private let productIDs = ["base.tip.small", "base.tip.medium", "base.tip.large"]

    init() {
        updateListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit { updateListener?.cancel() }

    /// Fetch products from App Store.
    @MainActor
    func loadProducts() async {
        state = .loading
        do {
            products = try await Product.products(for: Set(productIDs))
                .sorted { $0.price < $1.price }
            state = .loaded(products)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Purchase a product.
    @MainActor
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    return true
                }
                return false
            case .pending:
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    /// Restore previous purchases.
    @MainActor
    func restore() async {
        try? await AppStore.sync()
        await loadProducts()
    }

    /// Monitor App Store transactions.
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.loadProducts()
            }
        }
    }
}
