import Foundation

/// UserDefaults tabanlı basit veri saklama katmanı.
final class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let income = "financeTracker.income"
        static let debt = "financeTracker.debt"
        static let expenses = "financeTracker.expenses"
    }

    private init() {}

    var income: Double {
        get { defaults.double(forKey: Keys.income) }
        set { defaults.set(newValue, forKey: Keys.income) }
    }

    var debt: Double {
        get { defaults.double(forKey: Keys.debt) }
        set { defaults.set(newValue, forKey: Keys.debt) }
    }

    func loadExpenses() -> [Expense] {
        guard let data = defaults.data(forKey: Keys.expenses) else { return [] }
        return (try? JSONDecoder().decode([Expense].self, from: data)) ?? []
    }

    func saveExpenses(_ expenses: [Expense]) {
        guard let data = try? JSONEncoder().encode(expenses) else { return }
        defaults.set(data, forKey: Keys.expenses)
    }
}
