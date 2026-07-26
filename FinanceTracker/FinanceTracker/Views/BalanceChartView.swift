import SwiftUI
import Charts

struct BalanceChartView: View {
    @EnvironmentObject private var viewModel: FinanceViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.balanceHistory.count < 2 {
                    ContentUnavailableView(
                        "Grafik için yeterli veri yok",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Harcama ekledikçe bakiye değişim grafiği burada görünecek.")
                    )
                } else {
                    Chart(viewModel.balanceHistory) { point in
                        LineMark(
                            x: .value("Tarih", point.date),
                            y: .value("Bakiye", point.balance)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Tarih", point.date),
                            y: .value("Bakiye", point.balance)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel(format: .dateTime.day().month())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Bakiye Grafiği")
        }
    }
}

#Preview {
    BalanceChartView()
        .environmentObject(FinanceViewModel())
}
