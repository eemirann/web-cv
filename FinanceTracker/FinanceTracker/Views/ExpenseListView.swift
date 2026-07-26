import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject private var viewModel: FinanceViewModel

    private var sortedExpenses: [Expense] {
        viewModel.expenses.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                if sortedExpenses.isEmpty {
                    ContentUnavailableView(
                        "Henüz harcama yok",
                        systemImage: "tray",
                        description: Text("Ana sayfadan yeni bir harcama ekleyebilirsiniz.")
                    )
                } else {
                    Section {
                        ForEach(sortedExpenses) { expense in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(expense.note.isEmpty ? "Harcama" : expense.note)
                                        .font(.body)
                                    Text(expense.date.formattedTR)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(expense.amount.currencyTR)
                                    .foregroundStyle(.red)
                            }
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Text("Toplam \(sortedExpenses.count) harcama")
                    }
                }
            }
            .navigationTitle("Harcamalar")
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteExpense(withId: sortedExpenses[index].id)
        }
    }
}

#Preview {
    ExpenseListView()
        .environmentObject(FinanceViewModel())
}
