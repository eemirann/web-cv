import Foundation

/// Grafikte gösterilen tek bir bakiye noktası (tarih + o tarihteki bakiye).
struct BalancePoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}
