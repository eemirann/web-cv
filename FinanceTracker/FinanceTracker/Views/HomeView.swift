import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: FinanceViewModel

    @State private var incomeText: String = ""
    @State private var debtText: String = ""
    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Gelir ve Borç") {
                    HStack {
                        Text("Toplam Gelir")
                        Spacer()
                        TextField("0", text: $incomeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: incomeText) { _, _ in updateIncome() }
                    }
                    HStack {
                        Text("Toplam Borç")
                        Spacer()
                        TextField("0", text: $debtText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: debtText) { _, _ in updateDebt() }
                    }
                }

                Section("Özet") {
                    SummaryRow(title: "Toplam Gelir", value: viewModel.income, color: .green)
                    SummaryRow(title: "Toplam Borç", value: viewModel.debt, color: .red)
                    SummaryRow(title: "Toplam Harcama", value: viewModel.totalExpenses, color: .orange)
                    SummaryRow(
                        title: "Kalan Bakiye",
                        value: viewModel.remainingBalance,
                        color: viewModel.remainingBalance >= 0 ? .blue : .red,
                        isBold: true
                    )
                }

                Section {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Label("Harcama Ekle", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Finans Takibi")
            .onAppear {
                incomeText = viewModel.income == 0 ? "" : String(viewModel.income)
                debtText = viewModel.debt == 0 ? "" : String(viewModel.debt)
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .alert("Hata", isPresented: errorBinding) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private func updateIncome() {
        let normalized = incomeText.replacingOccurrences(of: ",", with: ".")
        if let value = Double(normalized) {
            viewModel.setIncome(value)
        } else if normalized.isEmpty {
            viewModel.setIncome(0)
        }
    }

    private func updateDebt() {
        let normalized = debtText.replacingOccurrences(of: ",", with: ".")
        if let value = Double(normalized) {
            viewModel.setDebt(value)
        } else if normalized.isEmpty {
            viewModel.setDebt(0)
        }
    }
}

private struct SummaryRow: View {
    let title: String
    let value: Double
    let color: Color
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(isBold ? .bold : .regular)
            Spacer()
            Text(value.currencyTR)
                .foregroundStyle(color)
                .fontWeight(isBold ? .bold : .regular)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(FinanceViewModel())
}
