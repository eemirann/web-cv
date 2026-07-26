import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }

            ExpenseListView()
                .tabItem { Label("Harcamalar", systemImage: "list.bullet") }

            BalanceChartView()
                .tabItem { Label("Grafik", systemImage: "chart.line.uptrend.xyaxis") }

            ScenarioView()
                .tabItem { Label("Senaryo", systemImage: "slider.horizontal.3") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FinanceViewModel())
}
