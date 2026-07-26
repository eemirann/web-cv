import Foundation

@MainActor
final class FinanceViewModel: ObservableObject {

    @Published var income: Double {
        didSet { persistence.income = income }
    }

    @Published var debt: Double {
        didSet { persistence.debt = debt }
    }

    @Published private(set) var expenses: [Expense] {
        didSet { persistence.saveExpenses(expenses) }
    }

    @Published var errorMessage: String?

    // MARK: - Senaryo simülatörü
    @Published var simulatedDailySpending: Double = 0
    @Published var simulatedDayCount: Int = 30

    private let persistence: PersistenceManager

    init(persistence: PersistenceManager = .shared) {
        self.persistence = persistence
        self.income = persistence.income
        self.debt = persistence.debt
        self.expenses = persistence.loadExpenses()
    }

    // MARK: - Hesaplamalar

    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    /// remaining = income - debt - sum(expenses)
    var remainingBalance: Double {
        income - debt - totalExpenses
    }

    /// Seçilen günlük harcama senaryosuna göre projeksiyon.
    var projectedBalance: Double {
        remainingBalance - (simulatedDailySpending * Double(simulatedDayCount))
    }

    /// Zaman içindeki bakiye değişimi (grafik için), tarihe göre kümülatif.
    var balanceHistory: [BalancePoint] {
        let sortedExpenses = expenses.sorted { $0.date < $1.date }
        guard !sortedExpenses.isEmpty else {
            return [BalancePoint(date: Date(), balance: income - debt)]
        }

        var runningBalance = income - debt
        var points: [BalancePoint] = []

        let startDate = sortedExpenses[0].date.addingTimeInterval(-86_400)
        points.append(BalancePoint(date: startDate, balance: runningBalance))

        for expense in sortedExpenses {
            runningBalance -= expense.amount
            points.append(BalancePoint(date: expense.date, balance: runningBalance))
        }
        return points
    }

    // MARK: - Aksiyonlar

    func setIncome(_ value: Double) {
        guard value >= 0 else {
            errorMessage = "Gelir negatif olamaz."
            return
        }
        income = value
    }

    func setDebt(_ value: Double) {
        guard value >= 0 else {
            errorMessage = "Borç negatif olamaz."
            return
        }
        debt = value
    }

    func addExpense(amount: Double, note: String, date: Date) {
        guard amount > 0 else {
            errorMessage = "Harcama tutarı sıfırdan büyük olmalıdır."
            return
        }
        expenses.append(Expense(amount: amount, note: note, date: date))
    }

    func deleteExpense(withId id: UUID) {
        expenses.removeAll { $0.id == id }
    }

    func setSimulatedDailySpending(_ value: Double) {
        guard value >= 0 else {
            errorMessage = "Günlük harcama negatif olamaz."
            return
        }
        simulatedDailySpending = value
    }
}
