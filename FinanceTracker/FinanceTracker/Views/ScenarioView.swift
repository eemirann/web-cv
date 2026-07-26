import SwiftUI

struct ScenarioView: View {
    @EnvironmentObject private var viewModel: FinanceViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Senaryo Ayarları") {
                    VStack(alignment: .leading) {
                        Text("Günlük Harcama: \(viewModel.simulatedDailySpending.currencyTR)")
                        Slider(
                            value: Binding(
                                get: { viewModel.simulatedDailySpending },
                                set: { viewModel.setSimulatedDailySpending($0) }
                            ),
                            in: 0...1000,
                            step: 10
                        )
                    }

                    Stepper(
                        "Gün Sayısı: \(viewModel.simulatedDayCount)",
                        value: $viewModel.simulatedDayCount,
                        in: 1...365
                    )
                }

                Section("Sonuç") {
                    HStack {
                        Text("Mevcut Bakiye")
                        Spacer()
                        Text(viewModel.remainingBalance.currencyTR)
                    }
                    HStack {
                        Text("Projeksiyon (\(viewModel.simulatedDayCount) gün sonra)")
                        Spacer()
                        Text(viewModel.projectedBalance.currencyTR)
                            .foregroundStyle(viewModel.projectedBalance >= 0 ? .blue : .red)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Senaryo Simülatörü")
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
}

#Preview {
    ScenarioView()
        .environmentObject(FinanceViewModel())
}
