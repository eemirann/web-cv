import Foundation

extension Double {
    /// Türk Lirası para birimi formatı (örn. ₺1.234,56).
    var currencyTR: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = "₺"
        return formatter.string(from: NSNumber(value: self)) ?? "₺0"
    }
}

extension Date {
    /// Türkçe, kısa tarih formatı (örn. 26 Tem 2026).
    var formattedTR: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
}
