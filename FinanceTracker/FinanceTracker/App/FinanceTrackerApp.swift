import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var viewModel = FinanceViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
