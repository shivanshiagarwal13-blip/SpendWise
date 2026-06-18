import SwiftUI

struct MonthSummaryView: View {
    @EnvironmentObject var store: BudgetStore

    let monthKey: String
    let monthName: String

    var monthlyExpenses: [Expense] {
        store.expenses
            .filter { $0.date.hasPrefix(monthKey) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        let total  = store.total(forMonth: monthKey)
        let budget = store.budget(forMonth: monthKey)

        ScrollView {
            VStack(spacing: 16) {

                // Total card
                VStack(spacing: 8) {
                    Text("Total spent")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("₹")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.textSecondary)
                        Text("\(total, specifier: "%.0f")")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .contentTransition(.numericText())
                    }

                    if budget > 0 {
                        let progress = min(total / budget, 1.0)
                        let over     = total > budget

                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.appBackground)
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(over ? Color.accentTerracotta : Color.accentSage)
                                        .frame(width: geo.size.width * progress, height: 6)
                                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                                }
                            }
                            .frame(height: 6)

                            HStack {
                                Text(over
                                     ? "Over by ₹\(Int(total - budget))"
                                     : "₹\(Int(budget - total)) remaining")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(over ? .accentTerracotta : Color(red: 0.2, green: 0.65, blue: 0.4))
                                Spacer()
                                Text("Budget ₹\(budget, specifier: "%.0f")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .cardStyle()

                // Budget / Remaining
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Budget")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text("₹\(budget, specifier: "%.0f")")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle()

                    VStack(spacing: 4) {
                        Text("Remaining")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text("₹\(max(budget - total, 0), specifier: "%.0f")")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle()
                }

                // Transactions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Transactions")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                            .kerning(0.8)
                        Spacer()
                        Text("\(monthlyExpenses.count) entries")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }

                    if monthlyExpenses.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 28))
                                .foregroundColor(.textSecondary)
                            Text("No expenses this month")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(monthlyExpenses) { exp in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(colorForCategory(exp.item))
                                    .frame(width: 4, height: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(displayName(exp.item))
                                        .font(.system(size: 15))
                                        .foregroundColor(.textPrimary)
                                    Text(exp.date)
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                Text("₹\(exp.amount, specifier: "%.0f")")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.textPrimary)
                                Button {
                                    haptic(.light)
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        store.deleteExpense(exp)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textSecondary)
                                }
                                .buttonStyle(PressScaleStyle())
                            }
                            .padding(.vertical, 4)
                            .transition(.move(edge: .trailing).combined(with: .opacity))

                            if exp.id != monthlyExpenses.last?.id { Divider() }
                        }
                    }
                }
                .cardStyle()

                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(monthName)
        .navigationBarTitleDisplayMode(.large)
    }

    func displayName(_ item: String) -> String {
        if let r = item.range(of: ": ") { return String(item[r.upperBound...]) }
        return item
    }

    func colorForCategory(_ item: String) -> Color {
        if item.hasPrefix("Food")      { return .accentTerracotta }
        if item.hasPrefix("Transport") { return .accentSage }
        if item.hasPrefix("Shopping")  { return .accentAmber }
        if item.hasPrefix("Bills")     { return Color(red: 0.55, green: 0.50, blue: 0.80) }
        if item.hasPrefix("Fun")       { return .accentBlush }
        return .textSecondary
    }
}
