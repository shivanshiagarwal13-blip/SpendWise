// Models.swift
import Foundation
import Combine

struct Expense: Identifiable, Codable {
    var id: UUID
    var date: String   // "yyyy-MM-dd"
    var item: String
    var amount: Double
    var owedAmount: Double   // amount someone owes you back for this expense (0 if none)
    var isSettled: Bool      // true once that owed amount has been paid back to you

    init(id: UUID = UUID(), date: String, item: String, amount: Double, owedAmount: Double = 0, isSettled: Bool = false) {
        self.id = id
        self.date = date
        self.item = item
        self.amount = amount
        self.owedAmount = owedAmount
        self.isSettled = isSettled
    }

    enum CodingKeys: String, CodingKey {
        case id, date, item, amount, owedAmount, isSettled
    }

    // Custom decoding so your old saved data (without owedAmount/isSettled) still loads fine
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(String.self, forKey: .date)
        item = try container.decode(String.self, forKey: .item)
        amount = try container.decode(Double.self, forKey: .amount)
        owedAmount = try container.decodeIfPresent(Double.self, forKey: .owedAmount) ?? 0
        isSettled = try container.decodeIfPresent(Bool.self, forKey: .isSettled) ?? false
    }

    // The amount that actually counts as "spent" right now.
    // While money is still owed to you, it counts fully as spent.
    // Once you tick it as paid back, that portion stops counting as spent.
    var netAmount: Double {
        amount - (isSettled ? owedAmount : 0)
    }
}

class BudgetStore: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var monthlyBudgets: [String: Double] = [:] // key "yyyy-MM"

    private let expensesKey = "expenses"
    private let budgetsKey = "monthlyBudgets"

    init() { load() }

    func addExpense(date: String, item: String, amount: Double, owedAmount: Double = 0) {
        expenses.append(Expense(date: date, item: item, amount: amount, owedAmount: owedAmount))
        save()
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        save()
    }

    func setBudget(monthKey: String, amount: Double) {
        monthlyBudgets[monthKey] = amount
        save()
    }

    func expenses(for date: String) -> [Expense] {
        expenses.filter { $0.date == date }
    }

    // Total counted as "spent" for the month — already-settled owed amounts are excluded.
    func total(forMonth monthKey: String) -> Double {
        expenses.filter { $0.date.hasPrefix(monthKey) }
                .reduce(0) { $0 + $1.netAmount }
    }

    func budget(forMonth monthKey: String) -> Double {
        monthlyBudgets[monthKey] ?? 0
    }

    // Mark an owed amount as paid back to you. This reduces "spent" and increases "remaining".
    func settle(_ expense: Expense) {
        if let idx = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[idx].isSettled = true
            save()
        }
    }

    // In case you tick something by mistake.
    func unsettle(_ expense: Expense) {
        if let idx = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[idx].isSettled = false
            save()
        }
    }

    // Everything where someone still owes you money.
    func pendingOwed() -> [Expense] {
        expenses.filter { $0.owedAmount > 0 && !$0.isSettled }
                .sorted { $0.date > $1.date }
    }

    // Total amount currently owed to you (not yet paid back).
    func totalOwed() -> Double {
        pendingOwed().reduce(0) { $0 + $1.owedAmount }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(data, forKey: expensesKey)
        }
        if let data = try? JSONEncoder().encode(monthlyBudgets) {
            UserDefaults.standard.set(data, forKey: budgetsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: expensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
        if let data = UserDefaults.standard.data(forKey: budgetsKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            monthlyBudgets = decoded
        }
    }
}

extension Date {
    func key() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
    func monthKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: self)
    }
}
