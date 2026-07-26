import Foundation

struct Expense: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Double
    var note: String
    var date: Date

    init(id: UUID = UUID(), amount: Double, note: String = "", date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
    }
}
