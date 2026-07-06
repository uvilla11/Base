import Foundation

struct Expression: Codable, Identifiable, Equatable {
    let id: UUID
    let input: String
    let result: String
    let timestamp: Date
}

/// Fixed-capacity history, newest first, persisted to UserDefaults.
struct HistoryRing {
    private(set) var items: [Expression]
    private let capacity: Int
    private static let storageKey = "base.history.v1"

    init(capacity: Int = 50) {
        self.capacity = capacity
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([Expression].self, from: data) {
            items = saved
        } else {
            items = []
        }
    }

    /// Newest first.
    var all: [Expression] { items }
    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }

    mutating func append(_ expr: Expression) {
        items.insert(expr, at: 0)
        if items.count > capacity {
            items.removeLast(items.count - capacity)
        }
        persist()
    }

    mutating func remove(_ expr: Expression) {
        items.removeAll { $0.id == expr.id }
        persist()
    }

    mutating func clear() {
        items.removeAll()
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
