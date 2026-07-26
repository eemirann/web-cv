import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject private var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showError = false
    @State private var localErrorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Harcama Bilgisi") {
                    HStack {
                        Text("Tutar")
                        Spacer()
                        TextField("0", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    TextField("Not (isteğe bağlı)", text: $note)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Harcama Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(localErrorMessage ?? "")
            }
        }
    }

    private func save() {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalized), amount > 0 else {
            localErrorMessage = "Lütfen geçerli, sıfırdan büyük bir tutar girin."
            showError = true
            return
        }
        viewModel.addExpense(amount: amount, note: note, date: date)
        if viewModel.errorMessage == nil {
            dismiss()
        } else {
            localErrorMessage = viewModel.errorMessage
            showError = true
        }
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(FinanceViewModel())
}
